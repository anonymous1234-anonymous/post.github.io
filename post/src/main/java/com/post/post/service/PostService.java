package com.post.post.service;

import com.post.common.util.FileUploadUtil;
import com.post.common.util.SavedFile;
import com.post.post.dto.PostDto;
import com.post.post.dto.PostImageDto;
import com.post.post.mapper.PostMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.ArrayList;

@Service
public class PostService {

    private static final int MAX_IMAGE_COUNT = 5;

    private final PostMapper postMapper;
    private final FileUploadUtil fileUploadUtil;

    @Value("${file.upload-dir.post}")
    private String postUploadDir;

    public PostService(
            PostMapper postMapper,
            FileUploadUtil fileUploadUtil
    ) {
        this.postMapper = postMapper;
        this.fileUploadUtil = fileUploadUtil;
    }

    public PostDto findById(Long postId) {
        PostDto post = postMapper.findById(postId);

        if (post == null) {
            return null;
        }

        List<PostImageDto> images = postMapper.findImagesByPostId(postId);
        post.setImages(images);

        return post;
    }

    @Transactional(rollbackFor = Exception.class)
    public void save(PostDto post, List<MultipartFile> imageFiles) throws IOException {
        long imageCount = imageFiles == null
                ? 0
                : imageFiles.stream()
                .filter(file -> !file.isEmpty())
                .count();

        if (imageCount > MAX_IMAGE_COUNT) {
            throw new IllegalArgumentException("이미지는 최대 5장까지 등록할 수 있습니다.");
        }

        postMapper.save(post);

        if (imageFiles == null) {
            return;
        }

        int imageOrder = 1;

        for (MultipartFile imageFile : imageFiles) {
            if (imageFile.isEmpty()) {
                continue;
            }

            String contentType = imageFile.getContentType();

            if (!"image/jpeg".equals(contentType) && !"image/png".equals(contentType)) {
                throw new IllegalArgumentException("JPG 또는 PNG 이미지만 등록할 수 있습니다.");
            }

            SavedFile savedFile = fileUploadUtil.save(imageFile, postUploadDir, "/uploads/post");

            PostImageDto postImage = new PostImageDto();
            postImage.setPostId(post.getPostId());
            postImage.setOriginName(savedFile.getOriginalName());
            postImage.setUploadPath(savedFile.getPath());
            postImage.setImageOrder(imageOrder);

            postMapper.saveImage(postImage);
            postMapper.savePostImage(post.getPostId(), postImage.getUploadId());

            imageOrder++;
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void update(PostDto post, List<Long> deleteImageIds, List<MultipartFile> imageFiles) throws IOException {

        List<PostImageDto> existingImages = postMapper.findImagesByPostId(post.getPostId());

        List<PostImageDto> imagesToDelete = existingImages.stream()
                .filter(image ->
                        deleteImageIds != null
                                && deleteImageIds.contains(image.getUploadId())
                )
                .toList();

        long newImageCount = imageFiles == null
                ? 0
                : imageFiles.stream()
                .filter(file -> !file.isEmpty())
                .count();

        int remainingImageCount = existingImages.size() - imagesToDelete.size();

        if (remainingImageCount + newImageCount > MAX_IMAGE_COUNT) {
            throw new IllegalArgumentException("이미지는 최대 5장까지 등록할 수 있습니다.");
        }

        if (imageFiles != null) {
            for (MultipartFile imageFile : imageFiles) {
                if (imageFile.isEmpty()) {
                    continue;
                }

                String contentType = imageFile.getContentType();

                if (!"image/jpeg".equals(contentType) && !"image/png".equals(contentType)) {
                    throw new IllegalArgumentException("JPG 또는 PNG 이미지만 등록할 수 있습니다.");
                }
            }
        }

        List<String> newlySavedPaths = new ArrayList<>();
        TransactionSynchronizationManager.registerSynchronization(
                new TransactionSynchronization() {

                    @Override
                    public void afterCommit() {
                        for (PostImageDto image : imagesToDelete) {
                            fileUploadUtil.delete(
                                    image.getUploadPath(),
                                    postUploadDir
                            );
                        }
                    }

                    @Override
                    public void afterCompletion(int status) {
                        if (status == TransactionSynchronization.STATUS_ROLLED_BACK) {
                            for (String savedPath : newlySavedPaths) {
                                fileUploadUtil.delete(
                                        savedPath,
                                        postUploadDir
                                );
                            }
                        }
                    }
                }
        );

        postMapper.update(post);

        // 선택된 삭제 대상 이미지들 DB에서 삭제
        for (PostImageDto image : imagesToDelete) {
            postMapper.deleteByPostIdAndUploadId(post.getPostId(), image.getUploadId());
            postMapper.deleteImage(image.getUploadId());
        }

        // 삭제 후 남은 이미지들의 순서 재정렬
        List<PostImageDto> remainingImages = postMapper.findImagesByPostId(post.getPostId());
        int imageOrder = 1;

        for (PostImageDto image : remainingImages) {
            postMapper.updateImageOrder(image.getUploadId(), imageOrder);
            imageOrder++;
        }

        // 새로 추가된 이미지가 없다면 여기서 종료 (사진만 단독으로 삭제한 경우도 정상 처리됨)
        if (imageFiles == null) {
            return;
        }

        for (MultipartFile imageFile : imageFiles) {
            if (imageFile.isEmpty()) {
                continue;
            }

            SavedFile savedFile = fileUploadUtil.save(imageFile, postUploadDir, "/uploads/post");
            newlySavedPaths.add(savedFile.getPath());

            PostImageDto postImage = new PostImageDto();
            postImage.setPostId(post.getPostId());
            postImage.setOriginName(savedFile.getOriginalName());
            postImage.setUploadPath(savedFile.getPath());
            postImage.setImageOrder(imageOrder);

            postMapper.saveImage(postImage);
            postMapper.savePostImage(post.getPostId(), postImage.getUploadId());

            imageOrder++;
        }
    }

    public void deleteById(Long postId) {
        postMapper.deleteById(postId);
    }

    public void delete(Long postId) {
        postMapper.delete(postId);
    }

    public List<PostDto> findPage(String sort, String keyword, int page, int size) {
        if (page < 1) {
            page = 1;
        }

        int offset = (page - 1) * size;

        if (offset < 0) {
            offset = 0;
        }

        return postMapper.findPage(sort, keyword, offset, size);
    }

    public List<PostDto> findAll(String sort, String keyword) {
        return postMapper.findAll(sort);
    }

    public int countAll(String keyword) {
        return postMapper.countAll(keyword);
    }
}