package com.post.post.controller;
import com.post.common.response.PageRequest;
import com.post.common.response.PageResponse;
import com.post.post.dto.PostDto;
import com.post.post.service.PostService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;


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

    @GetMapping("/detail")
    public String detail(@RequestParam(value = "postId", required = false) Long postId, Model model) {
        if (postId == null) {
            return "redirect:/main-post";
        }
        PostDto post = postService.findById(postId);

        // 만약 postService.findById() 안에서 post.setImages(...) 처리가 안 되어 있다면 여기서 직접 세팅
        // post.setImages(fileService.findByPostId(postId));

        model.addAttribute("post", post);
        return "post/post-detail";
    }


    // 수정 페이지 이동 (GET)
    @GetMapping("/edit-post")
    public String editPostForm(@RequestParam("postId") Long postId, Model model) {
        if (postId == null) {
            return "redirect:/main-post";
        }
        PostDto post = postService.findById(postId);

        model.addAttribute("post", post);
        model.addAttribute("postFiles", post.getSavedFileNames()); // 👈 수정 페이지에도 기존 파일 목록 전달

        return "post/edit-post";
    }
    // 새 게시물 작성 페이지 이동 (GET)
    @GetMapping({"/post/new", "/new-post"})
    public String createPostForm(Model model) {
        // JSP에서 ${post.title} 등을 쓸 때 NullPointerException이 나지 않도록 빈 객체 전달
        model.addAttribute("post", new PostDto());
        return "post/new-post"; // /WEB-INF/views/post/new-post.jsp 경로 반환
    }

    @PostMapping({"/post/new", "/new-post"})
    public String createPost(
            @ModelAttribute PostDto postDto,
            @RequestParam(value = "files", required = false) List<MultipartFile> mediaFiles
    ) {
        try {
            postService.save(postDto, mediaFiles);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "redirect:/main-post";
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