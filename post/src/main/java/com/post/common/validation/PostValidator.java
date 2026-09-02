package com.post.common.validation;

import com.post.post.dto.PostImageDto;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;
import java.util.List;

@Component
public class PostValidator {

    private static final int MAX_IMAGE_COUNT = 5;

    /**
     * 게시글 등록 시 파일 검증
     */
    public void validateSave(List<MultipartFile> imageFiles) {
        checkFileLimit(0, imageFiles);
        checkFileExtensions(imageFiles);
    }

    /**
     * 게시글 수정 시 파일 검증
     */
    public void validateUpdate(List<PostImageDto> existingImages, List<Long> deleteImageIds, List<MultipartFile> imageFiles) {
        int deleteCount = (deleteImageIds == null) ? 0 : deleteImageIds.size();
        int remainingCount = existingImages.size() - deleteCount;

        checkFileLimit(remainingCount, imageFiles);
        checkFileExtensions(imageFiles);
    }

    /**
     * 이미지 개수 제한 검증 (최대 5장)
     */
    private void checkFileLimit(int baseCount, List<MultipartFile> imageFiles) {
        long newImageCount = imageFiles == null
                ? 0
                : imageFiles.stream().filter(file -> !file.isEmpty()).count();

        if (baseCount + newImageCount > MAX_IMAGE_COUNT) {
            throw new IllegalArgumentException("이미지는 최대 5장까지 등록할 수 있습니다.");
        }
    }

    /**
     * 이미지 확장자 검증 (JPG, PNG만 허용)
     */
    private void checkFileExtensions(List<MultipartFile> imageFiles) {
        if (imageFiles == null) return;

        for (MultipartFile imageFile : imageFiles) {
            if (imageFile.isEmpty()) continue;

            String contentType = imageFile.getContentType();
            if (!"image/jpeg".equals(contentType) && !"image/png".equals(contentType)) {
                throw new IllegalArgumentException("JPG 또는 PNG 이미지만 등록할 수 있습니다.");
            }
        }
    }
}