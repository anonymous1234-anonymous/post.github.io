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

    @Value("${file.upload-dir}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        String absolutePath = new File(uploadDir).getAbsolutePath();

        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:" + absolutePath + File.separator);
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {

        // JSP/컨트롤러 응답은 캐시하지 않음.
        // CSS, JS, 이미지, 업로드 파일은 성능을 위해 제외.
        registry.addInterceptor(new CacheControlInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns(
                        "/assets/**",
                        "/uploads/**"
                );
    }
}
