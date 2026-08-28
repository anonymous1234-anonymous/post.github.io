package com.post.common.util;

import java.util.List;

public final class PostContentFilter {

    private static final List<String> BAD_WORDS = List.of(
            "시발", "씨발", "병신", "개새끼", "ㅅㅂ", "ㅂㅅ", "지랄", "꺼져",
            "fuck", "shit", "bitch", "asshole", "motherfucker", "bastard", "stfu"
    );

    private PostContentFilter() {
    }

    public static String rejectReason(String title, String content, boolean forMission) {
        String safeContent = content == null ? "" : content;
        String trimmed = safeContent.trim();

        if (trimmed.length() < 10) {
            return forMission
                    ? "미션 인증을 위해 내용을 10자 이상 작성해주세요."
                    : "내용을 10자 이상 작성해주세요.";
        }

        if (trimmed.matches("^[ㄱ-ㅎㅏ-ㅣ\\s]+$")) {
            return "자음이나 모음만으로는 작성할 수 없습니다.";
        }

        if (containsBadWord(title) || containsBadWord(safeContent)) {
            return "욕설, 비속어 또는 부적절한 내용은 올릴 수 없습니다.";
        }

        return null;
    }

    private static boolean containsBadWord(String text) {
        String cleaned = sanitize(text);
        if (cleaned.isEmpty()) {
            return false;
        }
        for (String word : BAD_WORDS) {
            if (cleaned.contains(sanitize(word))) {
                return true;
            }
        }
        return false;
    }

    private static String sanitize(String text) {
        if (text == null || text.isEmpty()) {
            return "";
        }
        return text.toLowerCase()
                .replace("@", "a")
                .replaceAll("[\\s\\p{Punct}]", "")
                .replace("1", "i")
                .replace("3", "e")
                .replace("4", "a")
                .replace("0", "o")
                .replace("5", "s")
                .replace("7", "t");
    }
}
