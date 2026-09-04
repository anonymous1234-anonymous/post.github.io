package com.post.common.config;

import com.post.common.interceptor.CacheControlInterceptor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.io.File;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${file.upload-dir.post}")
    private String postUploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 윈도우 경로(\)를 리눅스/URL 스타일(/)로 변환하고 끝에 슬래시 추가
        String absolutePath = new File(postUploadDir).getAbsolutePath().replace("\\", "/");

        // 1. 외부 업로드 이미지 경로 매핑 (/uploads/post/**)
        registry.addResourceHandler("/uploads/post/**")
                .addResourceLocations("file:///" + absolutePath + "/");

        // 2. 스프링 부트 정적 자원 경로 매핑 (오타 수정: static.assets -> static/assets)
        registry.addResourceHandler("/css/**").addResourceLocations("classpath:/static/css/");
        registry.addResourceHandler("/js/**").addResourceLocations("classpath:/static/js/");
        registry.addResourceHandler("/images/**").addResourceLocations("classpath:/static/images/");
        registry.addResourceHandler("/assets/**").addResourceLocations("classpath:/static/assets/");
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new CacheControlInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns(
                        "/css/**",
                        "/js/**",
                        "/images/**",
                        "/assets/**",
                        "/uploads/**"
                );
    }
}