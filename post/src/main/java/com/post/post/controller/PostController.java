package com.post.post.controller;

import com.post.common.page.PageRequest;
import com.post.common.page.PageResponse;
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


// 2. 서비스 호출하여 PageResponse 가져오기 (목록 + 페이징 계산 한 번에 처리)
// List<PostDto> 조회할 데이터 가져오기 10개씩 페이지
// limit, pagePerCounts - current PageId 1,2,3,4
// offset - currentPageId * limit 1*10 = 10
// offset > (currentPageId -1 ) * limit = 0 -> limit 갯수
// 2-1*10 = 10
// 실제 조회 list 8개, totalcount = 98개 --> currentPageId 10page, limit 10pg



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

    // 새 게시물 등록 처리 (POST)
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

    // 삭제 처리
    @PostMapping("/delete-post")
    public String deletePost(@RequestParam("postId") Long postId) {
        if (postId != null) {
            postService.delete(postId);
        }
        return "redirect:/main-post";
    }
}