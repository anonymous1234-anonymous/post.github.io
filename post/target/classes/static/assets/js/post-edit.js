document.addEventListener("DOMContentLoaded", () => {
    const postForm = document.querySelector("#post-form");
    if (!postForm) return;

    postForm.addEventListener("submit", async (e) => {
        e.preventDefault();

        const submitBtn = postForm.querySelector('button[type="submit"]');
        if (submitBtn) submitBtn.disabled = true;

        try {
            // post-preview.js에서 관리 중인 선택된 파일 목록을 가져옵니다.
            const selectedFiles = window.postImageManager ? window.postImageManager.getSelectedFiles() : [];
            const savedFileNames = [];

            if (selectedFiles.length > 0) {
                console.log("파일 청크 업로드 시작...");

                for (const file of selectedFiles) {
                    const uploadResult = await uploadFileWithChunkAndMerge(file);
                    if (!uploadResult || !uploadResult.savedFileName) {
                        throw new Error("파일 업로드 중 오류가 발생했습니다.");
                    }
                    savedFileNames.push(uploadResult.savedFileName);
                }
            }

            // 최종 폼 데이터 수집 및 전송
            const finalPayload = new FormData();
            const postIdInput = postForm.querySelector('input[name="postId"]');
            const postId = postIdInput ? postIdInput.value : null;

            finalPayload.append("title", postForm.querySelector('#post-title')?.value || "");
            finalPayload.append("place", postForm.querySelector('#post-place')?.value || "");
            finalPayload.append("content", postForm.querySelector('#post-content')?.value || "");
            finalPayload.append("transportCost", postForm.querySelector('#transport-cost')?.value || 0);
            finalPayload.append("foodCost", postForm.querySelector('#food-cost')?.value || 0);
            finalPayload.append("otherCost", postForm.querySelector('#other-cost')?.value || 0);

            // 🌟 수정된 부분: 배열을 JSON 문자열로 변환하여 전송
            if (savedFileNames.length > 0) {
                finalPayload.append("savedFileNamesJson", JSON.stringify(savedFileNames));
            }

            const url = postId ? `/api/posts/${postId}/update` : '/api/posts';
            const response = await fetch(url, {
                method: 'POST',
                body: finalPayload
            });

            const result = await response.json();

            if (response.ok && result.success) {
                alert(postId ? "게시글이 성공적으로 수정되었습니다!" : "게시글이 성공적으로 등록되었습니다!");
                window.location.href = postId ? `/detail?postId=${postId}` : "/main-post";
            } else {
                alert("처리에 실패했습니다: " + (result.message || ""));
                if (submitBtn) submitBtn.disabled = false;
            }

        } catch (error) {
            console.error("서버 전송 에러:", error);
            alert("오류가 발생했습니다: " + error.message);
            if (submitBtn) submitBtn.disabled = false;
        }
    });
});

// 청크 단위 파일 업로드 및 병합 헬퍼 함수
async function uploadFileWithChunkAndMerge(file) {
    const CHUNK_SIZE = 5 * 1024 * 1024; // 5MB
    const totalChunks = Math.ceil(file.size / CHUNK_SIZE);
    const fileUid = (typeof crypto !== 'undefined' && crypto.randomUUID) ? crypto.randomUUID() : 'file-' + Date.now();
    let finalSavedFileName = null;

    for (let chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
        const start = chunkIndex * CHUNK_SIZE;
        const end = Math.min(start + CHUNK_SIZE, file.size);
        const chunk = file.slice(start, end);

        const formData = new FormData();
        formData.append("file", chunk);
        formData.append("fileUid", fileUid);
        formData.append("originalName", file.name);
        formData.append("chunkIndex", chunkIndex);
        formData.append("totalChunks", totalChunks);

        const response = await fetch('/api/posts/upload-chunk', {
            method: 'POST',
            body: formData
        });

        if (!response.ok) {
            throw new Error(`${chunkIndex + 1}번째 청크 업로드 실패`);
        }

        const result = await response.json();
        if (!result.success) {
            throw new Error(result.message || "청크 업로드 실패");
        }

        const targetData = result.data !== undefined ? result.data : result;
        if (targetData) {
            if (typeof targetData === 'string') {
                finalSavedFileName = targetData;
            } else if (targetData.savedFileName) {
                finalSavedFileName = targetData.savedFileName;
            }
        }
        if (!finalSavedFileName && result.savedFileName) {
            finalSavedFileName = result.savedFileName;
        }
    }

    if (!finalSavedFileName) {
        throw new Error("최종 파일명을 가져오지 못했습니다.");
    }

    return {
        savedFileName: finalSavedFileName,
        originalName: file.name
    };
}