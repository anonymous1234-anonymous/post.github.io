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
        // ⭐ 수동 문자열 조합 대신 toURI().toString()을 사용하면 OS 경로 마찰이 100% 사라집니다.
        String uploadImageUrl = new File(postUploadDir).toURI().toString();

        // 1. 외부 업로드 이미지 경로 매핑
        registry.addResourceHandler("/uploads/post/**")
                .addResourceLocations(uploadImageUrl);

        // 2. /assets/** 요청 매핑
        registry.addResourceHandler("/assets/**")
                .addResourceLocations("classpath:/static/assets/");
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new CacheControlInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns(
                        "/assets/**",
                        "/uploads/**"
                );
    }
}