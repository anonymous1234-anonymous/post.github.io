package com.post.post.dto;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class PostImageDto {

    private Long uploadId;
    private Long postId;
    private String originName;
    private String uploadPath;
    private Integer imageOrder;
}
