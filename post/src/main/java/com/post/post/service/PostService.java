package com.post.post.service;

import com.post.common.response.PageRequest;
import com.post.common.response.PageResponse;
import com.post.common.util.FileUploadUtil;
import com.post.common.util.SavedFile;
import com.post.common.validation.PostValidator;
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

    private final PostMapper postMapper;
    private final FileUploadUtil fileUploadUtil;
    private final PostValidator postValidator;

    @Value("${file.upload-dir.post}")
    private String postUploadDir;

    public PostService(
            PostMapper postMapper,
            FileUploadUtil fileUploadUtil,
            PostValidator postValidator
    ) {
        this.postMapper = postMapper;
        this.fileUploadUtil = fileUploadUtil;
        this.postValidator = postValidator;
    }

    /**
     * 게시글 등록 (검증 + 저장 + 파일 업로드)
     */
    public void save(PostDto postDto, List<MultipartFile> imageFiles) throws IOException {
        // 1. PostValidator를 통한 파일 검증
        postValidator.validateSave(imageFiles);

        // 2. 게시글 기본 정보 저장 (DB Insert 후 PK 생성)
        postMapper.save(postDto);
        Long postId = postDto.getPostId();

        // 3. 첨부파일 업로드 및 이미지 정보 DB 저장 (2단계 처리)
        if (imageFiles != null && !imageFiles.isEmpty()) {
            int imageOrder = 0; // 이미지 순서 처리용
            for (MultipartFile file : imageFiles) {
                if (file.isEmpty()) continue;

                SavedFile savedFile = fileUploadUtil.save(file, postUploadDir, "post");

                // 💡 PostImageDto 빌더 (uploadPath 필드명 사용 기준)
                PostImageDto imageDto = PostImageDto.builder()
                        .originName(savedFile.getSaveName())
                        .uploadPath(savedFile.getSaveName()) // XML의 #{uploadPath}와 매칭
                        .imageOrder(imageOrder++)
                        .build();

                // ① IMAGE_UPLOAD 테이블에 저장 (useGeneratedKeys로 uploadId가 imageDto에 담김)
                postMapper.saveImage(imageDto);
                Long uploadId = imageDto.getUploadId(); // 생성된 PK 획득

                // ② POST_UPLOAD 관계 테이블에 매핑 저장
                postMapper.savePostImage(postId, uploadId);
            }
        }
    }

    /**
     * 게시글 수정 (정보 수정 + 기존 이미지 삭제 + 새 이미지 추가)
     */
    public void update(PostDto postDto, List<Long> deleteImageIds, List<MultipartFile> imageFiles) throws IOException {
        Long postId = postDto.getPostId();

        // 1. 기존 이미지 목록 조회
        List<PostImageDto> existingImages = postMapper.findImagesByPostId(postId);

        // 2. PostValidator를 통한 수정 파일 검증
        postValidator.validateUpdate(existingImages, deleteImageIds, imageFiles);

        // 3. 게시글 기본 정보 업데이트
        postMapper.update(postDto);

        // 4. 삭제 대상 이미지 처리 (POST_UPLOAD 관계 먼저 끊고, IMAGE_UPLOAD 삭제)
        if (deleteImageIds != null && !deleteImageIds.isEmpty()) {
            for (Long uploadId : deleteImageIds) {
                postMapper.deleteByPostIdAndUploadId(postId, uploadId); // 관계 테이블 삭제
                postMapper.deleteImage(uploadId); // 이미지 본문 테이블 삭제
            }
        }

        // 5. 새 이미지 업로드 및 저장
        if (imageFiles != null && !imageFiles.isEmpty()) {
            // 현재 남아있는 이미지 개수를 고려해 order 시작값 지정 가능 (여기서는 단순 예시)
            int imageOrder = existingImages.size();
            for (MultipartFile file : imageFiles) {
                if (file.isEmpty()) continue;

                SavedFile savedFile = fileUploadUtil.save(file, postUploadDir, "post");


                PostImageDto imageDto = PostImageDto.builder()
                        .originName(savedFile.getSaveName())
                        .uploadPath(savedFile.getSaveName())
                        .imageOrder(imageOrder++)
                        .build();

                postMapper.saveImage(imageDto);
                Long uploadId = imageDto.getUploadId();

                postMapper.savePostImage(postId, uploadId);
            }
        }
    }

    public PageResponse getPostPage(PageRequest pageRequest, String sort, String keyword) {
        if (pageRequest.getPage() < 1) {
            pageRequest.setPage(1);
        }

        int totalCount = postMapper.countAll(keyword);
        List<PostDto> list = postMapper.findPage(sort, keyword, pageRequest.getOffset(), pageRequest.getSize());

        return new PageResponse(list, totalCount, pageRequest);
    }

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

    public void delete(Long postId) {
        deleteById(postId);
    }

    public void deleteById(Long postId) {
        postMapper.deleteById(postId);
    }

    public List<PostDto> findAll(String sort, String keyword) {
        return postMapper.findAll(sort);
    }

    public int countAll(String keyword) {
        return postMapper.countAll(keyword);
    }
}