package com.post.post.controller;

import com.post.common.dto.ApiResponse;
import com.post.post.dto.ChunkDto;
import com.post.post.dto.PostDto;
import com.post.post.service.PostService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/posts")
public class PostApiController {

    // 임시 청크가 저장될 폴더 경로 (환경에 맞게 수정)
    private final String TEMP_DIR = "C:/uploads/temp/";
    // 최종 병합된 파일이 저장될 폴더 경로
    private final String UPLOAD_DIR = "C:/uploads/files/";

    private final PostService postService;

    public PostApiController(PostService postService) {
        this.postService = postService;
    }

    /**
     * 1. 비동기 게시글 목록 데이터 조회 API
     */
    @GetMapping
    public ApiResponse<Map<String, Object>> getPostPage(
            @RequestParam(defaultValue = "latest") String sort,
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(defaultValue = "1") int page
    ) {
        int size = 9;
        int totalCount = postService.countAll(keyword);
        int totalPages = (int) Math.ceil((double) totalCount / size);
        if (page < 1) page = 1;
        int offset = (page - 1) * size;

        Map<String, Object> result = new HashMap<>();
        result.put("posts", postService.findPage(sort, keyword, offset, size));
        result.put("page", page);
        result.put("totalPages", totalPages);
        result.put("hasNext", page < totalPages);

        return ApiResponse.success(result);
    }

    /**
     * 2. 대용량 파일 청크(조각) 업로드 및 마지막 청크 시 자동 병합 API
     * POST /api/posts/upload-chunk
     */
    @PostMapping("/upload-chunk")
    public ResponseEntity<Map<String, Object>> uploadChunk(ChunkDto dto) {
        Map<String, Object> response = new HashMap<>();

        try {
            File tempDirFile = new File(TEMP_DIR + dto.getUploadId());
            if (!tempDirFile.exists()) {
                tempDirFile.mkdirs();
            }

            // 1. 현재 청크 조각을 임시 파일로 저장 (예: chunk_0, chunk_1 ...)
            File chunkFile = new File(tempDirFile, "chunk_" + dto.getChunkIndex());
            dto.getFile().transferTo(chunkFile);

            boolean completed = false;
            String savedFileName = null;

            // 2. 마지막 청크인지 검사 (모든 조각이 다 도착했는지 확인)
            File[] chunks = tempDirFile.listFiles((dir, name) -> name.startsWith("chunk_"));
            if (chunks != null && chunks.length == dto.getTotalChunks()) {

                // 3. 🌟 최종 파일 병합 작업 수행
                String ext = dto.getOriginalName().substring(dto.getOriginalName().lastIndexOf("."));
                savedFileName = UUID.randomUUID().toString() + ext;
                File targetFile = new File(UPLOAD_DIR + savedFileName);

                // 최종 저장 디렉토리가 없으면 생성
                if (!targetFile.getParentFile().exists()) {
                    targetFile.getParentFile().mkdirs();
                }

                try (BufferedOutputStream bout = new BufferedOutputStream(new FileOutputStream(targetFile, true))) {
                    for (int i = 0; i < dto.getTotalChunks(); i++) {
                        File cFile = new File(tempDirFile, "chunk_" + i);
                        Files.copy(cFile.toPath(), bout);
                    }
                }

                // 4. 🌟 병합 완료 후 낱개로 쪼개져 있던 임시 청크 파일들 및 임시 폴더 자동 제거 (Clean-up)
                for (int i = 0; i < dto.getTotalChunks(); i++) {
                    File cFile = new File(tempDirFile, "chunk_" + i);
                    if (cFile.exists()) {
                        cFile.delete();
                    }
                }
                if (tempDirFile.exists()) {
                    tempDirFile.delete(); // 텅 빈 임시 디렉토리 삭제
                }

                completed = true;
            }

            // 프론트엔드로 결과 반환 (completed가 true일 때만 savedFileName 전달)
            Map<String, Object> data = new HashMap<>();
            data.put("completed", completed);
            data.put("savedFileName", savedFileName);

            response.put("success", true);
            response.put("data", data);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            e.printStackTrace();
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 3. 최종 글 등록 API (파일 이름 목록 포함)
     * POST /api/posts
     */
    @PostMapping
    public ResponseEntity<?> createPost(
            @RequestParam("title") String title,
            @RequestParam(value = "place", required = false) String place,
            @RequestParam("content") String content,
            @RequestParam(value = "transportCost", defaultValue = "0") Long transportCost,
            @RequestParam(value = "foodCost", defaultValue = "0") Long foodCost,
            @RequestParam(value = "otherCost", defaultValue = "0") Long otherCost,
            @RequestParam(value = "savedFileNames", required = false) List<String> savedFileNames
    ) {
        try {
            PostDto postDto = new PostDto();
            postDto.setTitle(title);
            postDto.setPlace(place);
            postDto.setContent(content);
            postDto.setTransportCost(transportCost);
            postDto.setFoodCost(foodCost);
            postDto.setOtherCost(otherCost);

            postService.saveWithFiles(postDto, savedFileNames);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    /**
     * 4. 게시글 수정 API (경로에 /update가 없거나 있는 경우 모두 대응)
     * POST /api/posts/{postId} 또는 /api/posts/{postId}/update
     */
    @PostMapping(value = {"/{postId}", "/{postId}/update"})
    public ApiResponse<Void> updatePost(
            @PathVariable Long postId,
            @RequestParam("title") String title,
            @RequestParam(value = "place", required = false) String place,
            @RequestParam("content") String content,
            @RequestParam(value = "transportCost", defaultValue = "0") Long transportCost,
            @RequestParam(value = "foodCost", defaultValue = "0") Long foodCost,
            @RequestParam(value = "otherCost", defaultValue = "0") Long otherCost,
            @RequestParam(value = "deleteImageIds", required = false) List<Long> deleteImageIds,
            @RequestParam(value = "savedFileNames", required = false) List<String> savedFileNames
    ) throws IOException {
        PostDto postDto = new PostDto();
        postDto.setPostId(postId);
        postDto.setTitle(title);
        postDto.setPlace(place);
        postDto.setContent(content);
        postDto.setTransportCost(transportCost);
        postDto.setFoodCost(foodCost);
        postDto.setOtherCost(otherCost);

        postService.updateWithFiles(postDto, deleteImageIds, savedFileNames);
        return ApiResponse.success(null);
    }

    /**
     * 5. 게시글 삭제 API
     * DELETE /api/posts/{postId}
     */
    @DeleteMapping("/{postId}")
    public ApiResponse<Void> deletePost(@PathVariable Long postId) {
        postService.deleteById(postId);
        return ApiResponse.success(null);
    }
}