package com.post.post.controller;
import com.post.common.response.PageRequest;
import com.post.common.response.PageResponse;
import com.post.post.dto.PostDto;
import com.post.post.service.PostService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
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
        PageRequest pageRequest = new PageRequest();
        pageRequest.setPage(page);
        pageRequest.setSize(9);

        PageResponse pageResponse = postService.getPostPage(pageRequest, sort, keyword);

        model.addAttribute("posts", pageResponse.getList()); // 실제 게시글 리스트
        model.addAttribute("paging", pageResponse);          // pagination.jsp용 객체
        model.addAttribute("sort", sort);
        model.addAttribute("keyword", keyword);

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

    // 삭제 처리
    @PostMapping("/delete-post")
    public String deletePost(@RequestParam("postId") Long postId) {
        if (postId != null) {
            postService.delete(postId);
        }
        return "redirect:/main-post";
    }
}