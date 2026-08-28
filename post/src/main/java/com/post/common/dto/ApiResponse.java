package com.post.common.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class ApiResponse<T> {

    private boolean success; // 성공여부
    private String message; // 성공, 실패에 따른 메세지
    private T data;

    //성공 응답을 간단하게 만들기위해서 정적 메서드
    public static <T> ApiResponse<T> success(T data){
        return new ApiResponse<>(true, null, data);
    }

    public static <T> ApiResponse<T> success(String message, T data){
        return new ApiResponse<>(true, message, data);
    }

    //실패했을 경우 사용할 정적 메서드
    public static <T> ApiResponse<T> fail(String message){
        return new ApiResponse<>(false, message, null);
    }
}
