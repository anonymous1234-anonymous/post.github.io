package com.post.post.service;

import com.post.common.response.PageRequest;
import com.post.common.response.PageResponse;
import com.post.common.util.FileUploadUtil;
import com.post.common.util.SavedFile;
import com.post.common.validation.PostValidator;
import com.post.post.dto.ChunkDto;
import com.post.post.dto.PostDto;
import com.post.post.dto.PostImageDto;
import com.post.post.mapper.PostMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.util.List;
import java.util.UUID;

@Service
public class PostService {

    private final PostMapper postMapper;
    private final FileUploadUtil fileUploadUtil;
    private final PostValidator postValidator;

    @Value("${file.upload-dir.post}")
    private String postUploadDir;

    private static final String WEB_PREFIX = "/uploads/post";

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
     * 대용량 파일 청크(조각) 임시 저장 및 마지막 청크 도달 시 자동 병합 처리
     * (PostApiController의 /upload-chunk에서 호출하는 메서드)
     */
    public String processChunkUpload(ChunkDto dto) throws IOException {
        File tempDir = new File(postUploadDir + "/temp/" + dto.getUploadId());
        if (!tempDir.exists()) {
            tempDir.mkdirs();
        }

        // 1. 현재 청크 파일 임시 저장
        File chunkFile = new File(tempDir, "chunk_" + dto.getChunkIndex());
        dto.getFile().transferTo(chunkFile);

        // 2. 모든 청크가 다 전송되었는지 확인
        boolean isAllUploaded = true;
        for (int i = 0; i < dto.getTotalChunks(); i++) {
            File f = new File(tempDir, "chunk_" + i);
            if (!f.exists()) {
                isAllUploaded = false;
                break;
            }
        }

        // 3. 모든 청크가 모였다면 최종 병합 수행 및 temp 폴더 자동 삭제
        if (isAllUploaded) {
            String originName = (dto.getOriginalName() != null) ? dto.getOriginalName() : "unknown";
            String savedFileName = UUID.randomUUID().toString() + "_" + originName;

            File finalDirFile = new File(postUploadDir);
            if (!finalDirFile.exists()) {
                finalDirFile.mkdirs();
            }

            File finalFile = new File(postUploadDir, savedFileName);

            // 청크들을 순서대로 합치기
            try (FileOutputStream fos = new FileOutputStream(finalFile, true)) {
                for (int i = 0; i < dto.getTotalChunks(); i++) {
                    File f = new File(tempDir, "chunk_" + i);
                    Files.copy(f.toPath(), fos);
                    f.delete(); // 개별 조각 파일 삭제
                }
            }

            // 임시 디렉토리 자체 삭제 (자동 클린업)
            if (tempDir.exists()) {
                tempDir.delete();
            }

            return savedFileName; // 병합 완료된 최종 파일명 반환
        }

        return null; // 아직 모든 청크가 오지 않았음
    }

    /**
     * 게시글 단건 조회 (이미지 리스트 포함)
     */
    public PostDto findById(Long postId) {
        PostDto post = postMapper.findById(postId);
        if (post != null) {
            List<PostImageDto> images = postMapper.findImagesByPostId(postId);
            post.setImages(images);
        }
        return post;
    }

    @Transactional
    public void save(PostDto postDto, List<MultipartFile> mediaFiles) throws IOException {
        postValidator.validateSave(mediaFiles);
        postMapper.save(postDto);
        Long postId = postDto.getPostId();

        if (mediaFiles != null && !mediaFiles.isEmpty()) {
            int fileOrder = 0;
            for (MultipartFile file : mediaFiles) {
                if (file.isEmpty()) continue;
                SavedFile savedFile = fileUploadUtil.save(file, postUploadDir, WEB_PREFIX);
                String fileName = new File(savedFile.getPath()).getName();

                PostImageDto imageDto = PostImageDto.builder()
                        .originName(savedFile.getOriginalName())
                        .uploadPath(fileName)
                        .imageOrder(fileOrder++)
                        .build();

                postMapper.saveImage(imageDto);
                postMapper.savePostImage(postId, imageDto.getUploadId());
            }
        }
    }

    @Transactional
    public void saveWithFiles(PostDto postDto, List<String> savedFileNames) {
        postMapper.save(postDto);
        Long postId = postDto.getPostId();

        if (savedFileNames != null && !savedFileNames.isEmpty()) {
            int fileOrder = 0;
            for (String savedFileName : savedFileNames) {
                int underscoreIndex = savedFileName.indexOf("_");
                String originName = (underscoreIndex != -1) ? savedFileName.substring(underscoreIndex + 1) : savedFileName;

                PostImageDto imageDto = PostImageDto.builder()
                        .originName(originName)
                        .uploadPath(savedFileName)
                        .imageOrder(fileOrder++)
                        .build();

                postMapper.saveImage(imageDto);
                postMapper.savePostImage(postId, imageDto.getUploadId());
            }
        }
    }
    @Transactional
    public void updateWithFiles(PostDto postDto, List<Long> deleteImageIds, List<String> savedFileNames) {
        Long postId = postDto.getPostId();
        postMapper.update(postDto);

        // 1. 삭제할 이미지가 있다면 삭제 처리
        if (deleteImageIds != null && !deleteImageIds.isEmpty()) {
            for (Long uploadId : deleteImageIds) {
                postMapper.deleteByPostIdAndUploadId(postId, uploadId);
                postMapper.deleteImage(uploadId);
            }
        }

        // 2. 새로 추가된 파일명 리스트가 있다면 DB 저장 처리 (청크 업로드로 이미 서버에 저장된 파일명 활용)
        if (savedFileNames != null && !savedFileNames.isEmpty()) {
            List<PostImageDto> existingImages = postMapper.findImagesByPostId(postId);
            int imageOrder = existingImages.size();

            for (String savedFileName : savedFileNames) {
                int underscoreIndex = savedFileName.indexOf("_");
                String originName = (underscoreIndex != -1) ? savedFileName.substring(underscoreIndex + 1) : savedFileName;

                PostImageDto imageDto = PostImageDto.builder()
                        .originName(originName)
                        .uploadPath(savedFileName)
                        .imageOrder(imageOrder++)
                        .build();

                postMapper.saveImage(imageDto);
                postMapper.savePostImage(postId, imageDto.getUploadId());
            }
        }
    }

    public PageResponse getPostPage(PageRequest pageRequest, String sort, String keyword) {
        if (pageRequest.getPage() < 1) pageRequest.setPage(1);
        int totalCount = postMapper.countAll(keyword);
        List<PostDto> list = postMapper.findPage(sort, keyword, pageRequest.getOffset(), pageRequest.getSize());

        for (PostDto post : list) {
            post.setImages(postMapper.findImagesByPostId(post.getPostId()));
        }
        return new PageResponse(list, totalCount, pageRequest);
    }

    public List<PostDto> findPage(String sort, String keyword, int offset, int size) {
        List<PostDto> list = postMapper.findPage(sort, keyword, offset, size);
        for (PostDto post : list) {
            post.setImages(postMapper.findImagesByPostId(post.getPostId()));
        }
        return list;
    }

    public List<PostDto> findAll(String sort, String keyword) {
        List<PostDto> list = postMapper.findAll(sort);
        for (PostDto post : list) {
            post.setImages(postMapper.findImagesByPostId(post.getPostId()));
        }
        return list;
    }

    // 🌟 에러 해결을 위해 delete 및 deleteById 메서드 모두 제공
    public void delete(Long postId) {
        deleteById(postId);
    }

    @Transactional
    public void deleteById(Long postId) {
        postMapper.deleteById(postId);
    }

    public int countAll(String keyword) {
        return postMapper.countAll(keyword);
    }
}