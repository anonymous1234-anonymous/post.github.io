package com.post.post.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
public class PostImageDto {

    private Long uploadId;
    private Long postId;
    private String originName;
    private String uploadPath;
    private Integer imageOrder;


    @Builder
    public PostImageDto(Long uploadId, Long postId, String originName, String uploadPath, Integer imageOrder) {
        this.uploadId = uploadId;
        this.postId = postId;
        this.originName = originName;
        this.uploadPath = uploadPath;
        this.imageOrder = imageOrder;
    }
}
