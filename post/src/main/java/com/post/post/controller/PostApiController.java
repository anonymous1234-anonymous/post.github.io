package com.post.post.controller;

import com.post.common.dto.ApiResponse;
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
     * GET /api/posts
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
     * 게시글 등록 API (로그인 없이)
     * POST /api/posts
     */
    @PostMapping
    public ApiResponse<Void> createPost(
            @RequestPart("com/post/audio/controller") PostDto postDto,
            @RequestPart(value = "imageFiles", required = false) List<MultipartFile> imageFiles
    ) throws IOException {
        postService.save(postDto, imageFiles);
        return ApiResponse.success(null);
    }

    /**
     * 게시글 수정 API (로그인 없이)

     */
    @PutMapping("/{postId}")
    public ApiResponse<Void> updatePost(
            @PathVariable Long postId,
            @RequestPart("com/post/audio/controller") PostDto postDto,
            @RequestParam(value = "deleteImageIds", required = false) List<Long> deleteImageIds,
            @RequestPart(value = "imageFiles", required = false) List<MultipartFile> imageFiles
    ) throws IOException {
        postDto.setPostId(postId);
        postService.update(postDto, deleteImageIds, imageFiles);
        return ApiResponse.success(null);
    }

    /**
     * 게시글 삭제 API (로그인 없이)
     * DELETE /api/posts/{postId}
     */
    @DeleteMapping("/{postId}")
    public ApiResponse<Void> deletePost(@PathVariable Long postId) {
        postService.deleteById(postId);
        return ApiResponse.success(null);
    }
}