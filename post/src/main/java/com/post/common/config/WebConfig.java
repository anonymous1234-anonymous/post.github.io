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
        String absolutePath = new File(postUploadDir).getAbsolutePath().replace("\\", "/");

        // 1. 외부 업로드 이미지 경로 매핑
        registry.addResourceHandler("/uploads/post/**")
                .addResourceLocations("file:///" + absolutePath + "/");

        // 2. [필수 추가] /assets/** 요청이 오면 스프링 부트 static/assets 폴더를 바라보도록 매핑
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