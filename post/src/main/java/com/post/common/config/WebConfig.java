package com.post.common.config;

import com.post.common.interceptor.CacheControlInterceptor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // 🌟 윈도우 절대 경로 포맷: file:///C:/uploads/files/
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:///C:/uploads/files/");

        registry.addResourceHandler("/assets/**")
                .addResourceLocations("classpath:/static/assets/");
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new CacheControlInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns(
                        "/assets/**",
                        "/uploads/**" // 🌟 업로드 경로가 인터셉터에 걸리지 않도록 예외 처리 필수
                );
    }
}