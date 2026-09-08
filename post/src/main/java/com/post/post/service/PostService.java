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
import org.springframework.transaction.annotation.Transactional; // 트랜잭션 추가
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
     * 게시글 등록 (검증 + 저장 + 미디어 파일 업로드)
     */
    @Transactional // 쓰기 작업이므로 트랜잭션 활성화
    public void save(PostDto postDto, List<MultipartFile> mediaFiles) throws IOException {
        // 1. PostValidator를 통한 미디어 파일 검증 (이미지 + 오디오 + 비디오 허용 확인)
        postValidator.validateSave(mediaFiles);

        // 2. 게시글 기본 정보 저장 (DB Insert 후 PK 생성)
        postMapper.save(postDto);
        Long postId = postDto.getPostId();

        // 3. 첨부파일 업로드 및 미디어 정보 DB 저장
        if (mediaFiles != null && !mediaFiles.isEmpty()) {
            int fileOrder = 0;
            for (MultipartFile file : mediaFiles) {
                if (file.isEmpty()) continue;

                // 서버 디스크에 파일 저장
                SavedFile savedFile = fileUploadUtil.save(file, postUploadDir, "/uploads/post");

                PostImageDto imageDto = PostImageDto.builder()
                        .originName(savedFile.getOriginalName())
                        .uploadPath(savedFile.getPath())
                        .imageOrder(fileOrder++)
                        .build();

                postMapper.saveImage(imageDto);
                Long uploadId = imageDto.getUploadId();

                postMapper.savePostImage(postId, uploadId);
            }
        }
    }

    /**
     * 게시글 수정 (정보 수정 + 기존 미디어 삭제 + 새 미디어 추가)
     */
    @Transactional // 쓰기 작업이므로 트랜잭션 활성화
    public void update(PostDto postDto, List<Long> deleteImageIds, List<MultipartFile> mediaFiles) throws IOException {
        Long postId = postDto.getPostId();

        // 1. 기존 이미지 목록 조회
        List<PostImageDto> existingImages = postMapper.findImagesByPostId(postId);

        // 2. PostValidator를 통한 수정 파일 검증
        postValidator.validateUpdate(existingImages, deleteImageIds, mediaFiles);

        // 3. 게시글 기본 정보 업데이트
        postMapper.update(postDto);

        // 4. 삭제 대상 이미지 처리 (POST_UPLOAD 관계 먼저 끊고, IMAGE_UPLOAD 삭제)
        if (deleteImageIds != null && !deleteImageIds.isEmpty()) {
            for (Long uploadId : deleteImageIds) {
                postMapper.deleteByPostIdAndUploadId(postId, uploadId); // 관계 테이블 삭제
                postMapper.deleteImage(uploadId); // 이미지 본문 테이블 삭제
            }
        }

        // 5. 새 미디어 업로드 및 저장
        if (mediaFiles != null && !mediaFiles.isEmpty()) {
            int imageOrder = existingImages.size();
            for (MultipartFile file : mediaFiles) {
                if (file.isEmpty()) continue;

                SavedFile savedFile = fileUploadUtil.save(file, postUploadDir, "/uploads/post");

                PostImageDto imageDto = PostImageDto.builder()
                        .originName(savedFile.getOriginalName())
                        .uploadPath(savedFile.getPath())
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

    @Transactional
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