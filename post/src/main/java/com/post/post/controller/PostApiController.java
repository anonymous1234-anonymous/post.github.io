package com.post.post.controller;

import com.post.common.dto.ApiResponse;
import com.post.post.dto.ChunkUploadDto; // 청크용 DTO 추가 필요
import com.post.post.dto.PostDto;
import com.post.post.service.PostService;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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
     * 비동기 게시글 목록 데이터 조회 API
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
     * [추가] 대용량 파일 청크(조각) 업로드 API
     * POST /api/posts/upload-chunk
     */
    @PostMapping("/upload-chunk")
    public ApiResponse<Map<String, Object>> uploadChunk(ChunkUploadDto chunkDto) throws IOException {
        // 서비스에서 조각을 저장하고, 마지막 조각이면 최종 병합 후 저장된 파일명을 리턴
        String savedFileName = postService.processChunkUpload(chunkDto);

        Map<String, Object> response = new HashMap<>();
        if (savedFileName != null) {
            response.put("completed", true);
            response.put("savedFileName", savedFileName); // 병합된 최종 파일명
        } else {
            response.put("completed", false); // 아직 조각 전송 중
        }

        return ApiResponse.success(response);
    }

    /**
     * 게시글 등록 API (청크 업로드 완료 후 최종 호출)
     * POST /api/posts
     */
    @PostMapping
    public ApiResponse<Void> createPost(
            @RequestPart("postDto") PostDto postDto,
            @RequestParam(value = "savedFileNames", required = false) List<String> savedFileNames
            // 파일 객체(MultipartFile) 대신 이미 서버에 업로드/병합된 파일 이름 리스트를 받습니다.
    ) throws IOException {
        postService.saveWithFiles(postDto, savedFileNames);
        return ApiResponse.success(null);
    }

    /**
     * 게시글 수정 API
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
     * 게시글 삭제 API
     */
    @DeleteMapping("/{postId}")
    public ApiResponse<Void> deletePost(@PathVariable Long postId) {
        postService.deleteById(postId);
        return ApiResponse.success(null);
    }
}