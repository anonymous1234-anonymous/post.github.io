package com.post.common.page;
import lombok.Data;

@Data
public class PageRequest {
    private int page = 1;      // 현재 페이지 (기본값 1)
    private int size = 10;     // 한 페이지당 게시글 수 (기본값 10)
    private int blockSize = 10;// 하단에 보여줄 페이지 번호 개수

    // DB 조회용 OFFSET 계산 메서드
    public int getOffset() {
        return (page - 1) * size;
    }
}