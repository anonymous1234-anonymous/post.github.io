package com.post.post.controller;

import com.post.common.dto.ApiResponse;
import com.post.post.dto.ChunkDto;
import com.post.post.dto.PostDto;
import com.post.post.service.PostService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/posts")
public class PostApiController {

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
     * 2. 대용량 파일 청크(조각) 업로드 API
     * POST /api/posts/upload-chunk
     */
    @PostMapping("/upload-chunk")
    public ResponseEntity<?> uploadChunk(ChunkDto chunkDto) {
        try {
            String savedFileName = postService.processChunkUpload(chunkDto);

            Map<String, Object> responseData = new HashMap<>();
            if (savedFileName != null) {
                responseData.put("completed", true);
                responseData.put("savedFileName", savedFileName);
            } else {
                responseData.put("completed", false);
            }

            return ResponseEntity.ok(Map.of("success", true, "data", responseData));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    /**
     * 3. 최종 글 등록 API (FormData로 넘어오는 postDto와 savedFileNames 받기)
     * POST /api/posts
     */
    @PostMapping
    public ResponseEntity<?> createPost(
            @RequestPart("postDto") PostDto postDto,
            @RequestParam(value = "savedFileNames", required = false) List<String> savedFileNames
    ) {
        try {
            postService.saveWithFiles(postDto, savedFileNames);
            return ResponseEntity.ok(Map.of("success", true));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", e.getMessage()));
        }
    }

    /**
     * 4. 게시글 수정 API
     * PUT /api/posts/{postId}
     */
    @PutMapping("/{postId}")
    public ApiResponse<Void> updatePost(
            @PathVariable Long postId,
            @RequestPart("postDto") PostDto postDto,
            @RequestParam(value = "deleteImageIds", required = false) List<Long> deleteImageIds,
            @RequestParam(value = "savedFileNames", required = false) List<String> savedFileNames
    ) throws IOException {
        postDto.setPostId(postId);
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