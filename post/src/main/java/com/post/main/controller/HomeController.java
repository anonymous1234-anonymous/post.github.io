package com.post.main.controller;

import com.post.post.service.PostService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    private final PostService postService;

    public HomeController(PostService postService) {
        this.postService = postService;
    }

        // 루트(/) 또는 /home으로 접속했을 때 메인 페이지나 특정 뷰로 이동
        @GetMapping({"/", "/home"})
        public String home() {
            // 만약 /WEB-INF/views/main/index.jsp 파일을 띄우고 싶다면:
            return "main/index";

            // 혹은 곧바로 게시글 피드(main-post)로 바로 보내고 싶다면 아래처럼 리다이렉트 시킬 수도 있습니다.
            // return "redirect:/main-post";
        }


    @GetMapping("/terms")
    public String terms() {
        return "legal/terms";
    }

    @GetMapping("/privacy")
    public String privacy() {
        return "legal/privacy";
    }
}