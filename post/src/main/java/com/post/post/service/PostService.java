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
     * 대용량 파일 청크(조각) 저장 및 병합 로직 (실제 저장 수행)
     */
    public String processChunkUpload(ChunkDto dto) throws IOException {
        File tempDir = new File(postUploadDir + "/temp/" + dto.getFileUid());
        if (!tempDir.exists()) {
            tempDir.mkdirs();
        }

        // 1. 현재 조각 파일을 임시 폴더에 저장
        File chunkFile = new File(tempDir, "chunk_" + dto.getChunkIndex());
        dto.getFile().transferTo(chunkFile);

        // 2. 모든 조각이 다 전송되었는지 확인
        boolean isAllUploaded = true;
        for (int i = 0; i < dto.getTotalChunks(); i++) {
            File f = new File(tempDir, "chunk_" + i);
            if (!f.exists()) {
                isAllUploaded = false;
                break;
            }
        }

        // 3. 마지막 조각까지 다 도착했다면 하나로 병합 (Merge)
        if (isAllUploaded) {
            String originName = (dto.getOriginalName() != null) ? dto.getOriginalName() : "unknown";
            String savedFileName = UUID.randomUUID().toString() + "_" + originName;

            File finalDirFile = new File(postUploadDir);
            if (!finalDirFile.exists()) {
                finalDirFile.mkdirs();
            }

            File finalFile = new File(postUploadDir, savedFileName);

            try (FileOutputStream fos = new FileOutputStream(finalFile, true)) {
                for (int i = 0; i < dto.getTotalChunks(); i++) {
                    File f = new File(tempDir, "chunk_" + i);
                    Files.copy(f.toPath(), fos);
                    f.delete(); // 병합 후 개별 조각 파일 삭제
                }
            }

            // 임시 폴더 삭제
            if (tempDir.exists()) {
                tempDir.delete();
            }

            return savedFileName;
        }

        return null;
    }

    /**
     * 게시글 등록 (검증 + 저장 + 미디어 파일 업로드) - 일반 업로드용
     */
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
     * 청크 업로드 완료된 파일 이름 리스트를 받아 게시글 등록 처리
     */
    @Transactional
    public void saveWithFiles(PostDto postDto, List<String> savedFileNames) {
        postMapper.save(postDto);
        Long postId = postDto.getPostId();

        if (savedFileNames != null && !savedFileNames.isEmpty()) {
            int fileOrder = 0;
            for (String savedFileName : savedFileNames) {
                int underscoreIndex = savedFileName.indexOf("_");
                String originName = (underscoreIndex != -1) ? savedFileName.substring(underscoreIndex + 1) : savedFileName;
                String uploadPath = WEB_PREFIX + "/" + savedFileName;

                PostImageDto imageDto = PostImageDto.builder()
                        .originName(originName)
                        .uploadPath(uploadPath)
                        .imageOrder(fileOrder++)
                        .build();

                postMapper.saveImage(imageDto);
                Long uploadId = imageDto.getUploadId();

                postMapper.savePostImage(postId, uploadId);
            }
        }
    }

    /**
     * 게시글 수정 (정보 수정 + 기존 미디어 삭제 + 새 미디어 추가) - 일반 수정용
     */
    @Transactional
    public void update(PostDto postDto, List<Long> deleteImageIds, List<MultipartFile> mediaFiles) throws IOException {
        Long postId = postDto.getPostId();

        List<PostImageDto> existingImages = postMapper.findImagesByPostId(postId);
        postValidator.validateUpdate(existingImages, deleteImageIds, mediaFiles);

        postMapper.update(postDto);

        if (deleteImageIds != null && !deleteImageIds.isEmpty()) {
            for (Long uploadId : deleteImageIds) {
                postMapper.deleteByPostIdAndUploadId(postId, uploadId);
                postMapper.deleteImage(uploadId);
            }
        }

        if (mediaFiles != null && !mediaFiles.isEmpty()) {
            int imageOrder = existingImages.size();
            for (MultipartFile file : mediaFiles) {
                if (file.isEmpty()) continue;

                SavedFile savedFile = fileUploadUtil.save(file, postUploadDir, WEB_PREFIX);

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

    /**
     * 청크 업로드를 통해 수정할 때 사용하는 메서드
     */
    @Transactional
    public void updateWithFiles(PostDto postDto, List<Long> deleteImageIds, List<String> savedFileNames) {
        Long postId = postDto.getPostId();

        postMapper.update(postDto);

        if (deleteImageIds != null && !deleteImageIds.isEmpty()) {
            for (Long uploadId : deleteImageIds) {
                postMapper.deleteByPostIdAndUploadId(postId, uploadId);
                postMapper.deleteImage(uploadId);
            }
        }

        if (savedFileNames != null && !savedFileNames.isEmpty()) {
            List<PostImageDto> existingImages = postMapper.findImagesByPostId(postId);
            int imageOrder = existingImages.size();

            for (String savedFileName : savedFileNames) {
                int underscoreIndex = savedFileName.indexOf("_");
                String originName = (underscoreIndex != -1) ? savedFileName.substring(underscoreIndex + 1) : savedFileName;

                String uploadPath = WEB_PREFIX + "/" + savedFileName;

                PostImageDto imageDto = PostImageDto.builder()
                        .originName(originName)
                        .uploadPath(uploadPath)
                        .imageOrder(imageOrder++)
                        .build();

                postMapper.saveImage(imageDto);
                Long uploadId = imageDto.getUploadId();

                postMapper.savePostImage(postId, uploadId);
            }
        }
    }

    /**
     * 🌟 [수정됨] 메인 피드 페이지네이션 목록 조회 시 각 게시글의 이미지 목록을 함께 세팅하도록 보완
     */
    public PageResponse getPostPage(PageRequest pageRequest, String sort, String keyword) {
        if (pageRequest.getPage() < 1) {
            pageRequest.setPage(1);
        }

        int totalCount = postMapper.countAll(keyword);
        List<PostDto> list = postMapper.findPage(sort, keyword, pageRequest.getOffset(), pageRequest.getSize());

        // 가져온 게시글 목록에 각각 이미지 정보를 매핑해 줍니다.
        for (PostDto post : list) {
            List<PostImageDto> images = postMapper.findImagesByPostId(post.getPostId());
            post.setImages(images);
        }

        return new PageResponse(list, totalCount, pageRequest);
    }

    /**
     * 🌟 [수정됨] 일반 목록 조회 시에도 이미지 목록을 함께 세팅하도록 보완
     */
    public List<PostDto> findPage(String sort, String keyword, int offset, int size) {
        List<PostDto> list = postMapper.findPage(sort, keyword, offset, size);
        for (PostDto post : list) {
            List<PostImageDto> images = postMapper.findImagesByPostId(post.getPostId());
            post.setImages(images);
        }
        return list;
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
        List<PostDto> list = postMapper.findAll(sort);
        for (PostDto post : list) {
            List<PostImageDto> images = postMapper.findImagesByPostId(post.getPostId());
            post.setImages(images);
        }
        return list;
    }

    public int countAll(String keyword) {
        return postMapper.countAll(keyword);
    }
}