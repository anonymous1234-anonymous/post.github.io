package com.post.post.service;

import com.post.common.response.PageRequest;
import com.post.common.response.PageResponse;
import com.post.common.util.FileUploadUtil;
import com.post.common.util.SavedFile;
import com.post.post.dto.PostDto;
import com.post.post.dto.PostImageDto;
import com.post.post.mapper.PostMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

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

    /**
     * 페이징, 정렬, 검색 조건을 반영하여 PageResponse 객체로 반환
     */
    public PageResponse getPostPage(PageRequest pageRequest, String sort, String keyword) { // 제네릭 제거
        if (pageRequest.getPage() < 1) {
            pageRequest.setPage(1);
        }

        int totalCount = postMapper.countAll(keyword);
        List<PostDto> list = postMapper.findPage(sort, keyword, pageRequest.getOffset(), pageRequest.getSize());

        return new PageResponse(list, totalCount, pageRequest); // 제네릭 제거
    }

    /**
     * 기존에 호출하던 곳을 위한 헬퍼 메서드 (findPage)
     */
    public List<PostDto> findPage(String sort, String keyword, int offset, int size) {
        return postMapper.findPage(sort, keyword, offset, size);
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

    public void save(PostDto post, List<MultipartFile> imageFiles) throws IOException {
        // 1. 이미지 개수 제한 검증
        checkFileLimit(imageFiles);

        // 2. 게시글 먼저 저장 (postId 생성)
        postMapper.save(post);

        if (imageFiles == null || imageFiles.isEmpty()) {
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

            // Builder 패턴을 사용하여 PostImageDto 생성 및 값 세팅
            PostImageDto postImage = PostImageDto.builder()
                    .postId(post.getPostId())
                    .originName(savedFile.getOriginalName())
                    .uploadPath(savedFile.getPath())
                    .imageOrder(imageOrder)
                    .build();

            postMapper.saveImage(postImage);
            postMapper.savePostImage(post.getPostId(), postImage.getUploadId());

            imageOrder++;
        }
    }

    private void checkFileLimit(List<MultipartFile> imageFiles) throws IOException {
        long imageCount = imageFiles == null
                ? 0
                : imageFiles.stream()
                .filter(file -> !file.isEmpty())
                .count();

        if (imageCount > MAX_IMAGE_COUNT) {
            throw new IllegalArgumentException("이미지는 최대 5장까지 등록할 수 있습니다.");
        }
    }
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

        postMapper.update(post);

        // 삭제 대상 이미지 처리 (DB 및 물리 파일 삭제)

        for (PostImageDto image : imagesToDelete) {
            fileUploadUtil.delete(image.getUploadPath(), postUploadDir);
            postMapper.deleteByPostIdAndUploadId(post.getPostId(), image.getUploadId());
            postMapper.deleteImage(image.getUploadId());
        }

        // 남은 이미지들의 순서 재정렬

        List<PostImageDto> remainingImages = postMapper.findImagesByPostId(post.getPostId());
        int imageOrder = 1;

        for (PostImageDto image : remainingImages) {
            postMapper.updateImageOrder(image.getUploadId(), imageOrder);
            imageOrder++;
        }

        if (imageFiles == null) {
            return;
        }

        // 이미지 저장
        for (MultipartFile imageFile : imageFiles) {
            if (imageFile.isEmpty()) {
                continue;
            }

            SavedFile savedFile = fileUploadUtil.save(imageFile, postUploadDir, "/uploads/post");

            PostImageDto postImage = PostImageDto.builder()
                    .postId(post.getPostId())
                    .originName(savedFile.getOriginalName())
                    .uploadPath(savedFile.getPath())
                    .imageOrder(imageOrder)
                    .build();

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

    public List<PostDto> findAll(String sort, String keyword) {
        return postMapper.findAll(sort);
    }

    public int countAll(String keyword) {
        return postMapper.countAll(keyword);
    }
}