package com.post.post.controller;

import com.post.post.dto.PostDto;
import com.post.post.service.PostService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;
import java.io.IOException;

@Controller
public class PostController {

    private final PostService postService;

    public PostController(PostService postService) {
        this.postService = postService;
    }

    // 메인 피드 / 목록 페이지
    @GetMapping({"/main-post"})
    public String mainPost(
            @RequestParam(defaultValue = "latest") String sort,
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(defaultValue = "1") int page,
            Model model
    ) {
        int size = 9;
        int totalCount = postService.countAll(keyword);
        int totalPages = (int) Math.ceil((double) totalCount / size);

        if (page < 1) page = 1;
        if (totalPages > 0 && page > totalPages) page = totalPages;

        int offset = Math.max(0, (page - 1) * size);

        model.addAttribute("posts", postService.findPage(sort, keyword, offset, size));
        model.addAttribute("sort", sort);
        model.addAttribute("keyword", keyword);
        model.addAttribute("page", page);
        model.addAttribute("totalPages", totalPages);

        return "post/main-post";
    }

    // 게시글 상세 조회
    @GetMapping("/detail")
    public String detail(@RequestParam(value = "postId", required = false) Long postId, Model model) {
        if (postId == null) {
            return "redirect:/main-post";
        }
        PostDto post = postService.findById(postId);
        model.addAttribute("post", post);
        return "post/post-detail";
    }

    // 글 작성 폼 페이지
    @GetMapping({"/post/new", "/new-post"})
    public String postForm() {
        return "post/new-post";
    }

    // 새 게시물 등록 처리 (POST) - 로그인 없이 익명 처리
    @PostMapping("/new-post")
    public String createPost(PostDto postDto, @RequestParam(value = "imageFiles", required = false) List<MultipartFile> imageFiles) {
        try {
            if (postDto.getWriter() == null || postDto.getWriter().trim().isEmpty()) {
                postDto.setWriter("익명");
            }

            postService.save(postDto, imageFiles);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "redirect:/main-post";
    }

    // 수정 페이지 이동 (GET)
    @GetMapping("/edit-post")
    public String editPostForm(@RequestParam("postId") Long postId, Model model) {
        if (postId == null) {
            return "redirect:/main-post";
        }
        PostDto post = postService.findById(postId);
        model.addAttribute("post", post);
        return "post/edit-post";
    }

    @PostMapping("/edit-post")
    public String updatePost(
            PostDto post,
            @RequestParam(value = "deleteImageIds", required = false) List<Long> deleteImageIds,
            @RequestParam(value = "imageFiles", required = false) List<MultipartFile> imageFiles
    ) {
        try {
            postService.update(post, deleteImageIds, imageFiles);
        } catch (IOException e) {
            e.printStackTrace();
        }

        return "redirect:/detail?postId=" + post.getPostId();
    }


    // 삭제 처리 -> 삭제 완료 후 main-post로 이동
    @PostMapping("/delete-post")
    public String deletePost(@RequestParam("postId") Long postId) {
        if (postId != null) {
            postService.delete(postId);
        }
        return "redirect:/main-post";
    }
}