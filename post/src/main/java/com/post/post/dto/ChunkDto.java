package com.post.post.dto;

import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

@Data
public class ChunkDto {
    private String fileUid;      // 파일 고유 식별자 (UUID) - 여러 파일이 동시에 업로드될 때 조각들을 구분하는 용도
    private String originalName; // 원본 파일명
    private int chunkIndex;      // 현재 조각 번호 (0부터 시작)
    private int totalChunks;     // 총 조각 개수
    private MultipartFile file;  // 쪼개진 조각 파일 데이터
}