document.addEventListener("DOMContentLoaded", () => {
    const maxFileCount = 10; // 최대 파일 제한 개수
    const CHUNK_SIZE = 5 * 1024 * 1024; // 5MB 단위 청크 분할

    const imageInput = document.querySelector("#new-post-image");
    const editForm = document.querySelector("form"); // 수정 페이지 폼 태그

    if (!imageInput || !editForm) return;

    let newSelectedFiles = []; // 새로 추가한 파일 배열

    // 1. 파일 선택 및 보안 필터링 / 개수 검증 이벤트
    imageInput.addEventListener("change", () => {
        const rawNewFiles = Array.from(imageInput.files);
        imageInput.value = ""; // 입력 초기화 (같은 파일 재선택 허용)

        // 🚫 보안상 차단할 확장자 검사 (.exe, .zip 등)
        const blockedExtensions = [".exe", ".zip", ".bat", ".cmd", ".sh", ".jar", ".msi", ".iso", ".dmg"];
        const validFiles = [];
        let hasBlockedFile = false;

        rawNewFiles.forEach(file => {
            const fileNameLower = file.name.toLowerCase();
            const isBlocked = blockedExtensions.some(ext => fileNameLower.endsWith(ext));
            if (isBlocked) {
                hasBlockedFile = true;
            } else {
                validFiles.push(file);
            }
        });

        if (hasBlockedFile) {
            alert("보안상 `.exe`, `.zip` 등의 실행 파일 및 압축 파일은 업로드할 수 없습니다.");
        }

        if (validFiles.length === 0) return;

        // 기존 DB에 등록된 파일 개수와 삭제 체크된 개수 확인
        const existingThumbnails = document.querySelectorAll('input[name="deleteImageIds"]');
        let deletedCount = 0;
        existingThumbnails.forEach(checkbox => {
            if (checkbox.checked) deletedCount++;
        });

        // 남아있는 기존 파일 수 + 현재 새로 추가된 파일 수 합산
        const currentRemainingExisting = existingThumbnails.length - deletedCount;
        const totalCurrentCount = currentRemainingExisting + newSelectedFiles.length;
        const remainingAllowed = maxFileCount - totalCurrentCount;

        if (validFiles.length > remainingAllowed) {
            alert(`기존 파일과 새 파일을 합쳐 최대 ${maxFileCount}개까지만 등록할 수 있습니다.`);
        }

        const filesToAdd = validFiles.slice(0, remainingAllowed);

        if (filesToAdd.length > 0) {
            newSelectedFiles = [...newSelectedFiles, ...filesToAdd];
            updateNewFilesInput();
            renderNewFilesPreview();
        }
    });

    // 폼 인풋에 동적으로 파일 재할당
    function updateNewFilesInput() {
        const dataTransfer = new DataTransfer();
        newSelectedFiles.forEach(file => {
            dataTransfer.items.add(file);
        });
        imageInput.files = dataTransfer.files;
    }

    // 새로 추가된 파일들의 미리보기 화면 렌더링
    function renderNewFilesPreview() {
        let newPreviewContainer = document.querySelector("#dynamic-new-files-preview");
        if (!newPreviewContainer) {
            newPreviewContainer = document.createElement("div");
            newPreviewContainer.id = "dynamic-new-files-preview";
            newPreviewContainer.className = "mt-3";
            // 삭제 체크박스 영역 하단에 삽입
            const thumbnailSection = document.querySelector('input[name="deleteImageIds"]')?.closest('.mt-3')?.parentElement || imageInput.parentElement;
            thumbnailSection.appendChild(newPreviewContainer);
        }

        if (newSelectedFiles.length === 0) {
            newPreviewContainer.innerHTML = "";
            return;
        }

        let html = `<p class="mb-2 text-muted small"><i class="bi bi-plus-circle"></i> 새로 추가된 파일 목록:</p>`;
        html += `<div class="d-flex flex-wrap gap-2">`;

        newSelectedFiles.forEach((file, index) => {
            const fileUrl = URL.createObjectURL(file);
            const fileNameLower = file.name.toLowerCase();
            const isImage = file.type.startsWith("image/") || /\.(jpg|jpeg|png|gif|webp)$/.test(fileNameLower);

            html += `<div class="position-relative border p-1 rounded text-center" style="width: 70px; background: #fff;">`;
            if (isImage) {
                html += `<img src="${fileUrl}" alt="${file.name}" style="width: 60px; height: 60px; object-fit: cover; border-radius: 4px;">`;
            } else {
                html += `<div class="bg-dark text-white d-flex align-items-center justify-content-center" style="width: 60px; height: 60px; border-radius: 4px;"><i class="bi bi-file-earmark-play-fill"></i></div>`;
            }
            html += `<button type="button" class="btn btn-danger btn-sm position-absolute top-0 end-0 p-0 px-1 remove-new-file" data-index="${index}" style="font-size: 10px;">×</button>`;
            html += `</div>`;
        });

        html += `</div>`;
        newPreviewContainer.innerHTML = html;

        // 새로 추가된 파일 개별 삭제 버튼 이벤트
        newPreviewContainer.querySelectorAll(".remove-new-file").forEach(btn => {
            btn.addEventListener("click", (e) => {
                const idx = parseInt(e.target.getAttribute("data-index"));
                newSelectedFiles.splice(idx, 1);
                updateNewFilesInput();
                renderNewFilesPreview();
            });
        });
    }

    // 기존 파일 삭제 체크박스 변경 시 개수 제한 실시간 반영을 위한 이벤트 연동
    document.querySelectorAll('input[name="deleteImageIds"]').forEach(checkbox => {
        checkbox.addEventListener("change", () => {
            // 필요 시 삭제 개수에 따른 추가 검증 로직 수행 가능
        });
    });

    // ==========================================
    // [수정된 최종 폼 제출부]
    // ==========================================
    editForm.addEventListener("submit", async (e) => {
        e.preventDefault();

        const submitBtn = editForm.querySelector("button[type='submit']");
        if (submitBtn) submitBtn.disabled = true;

        try {
            let savedFileNames = [];

            // 1. 새로 추가된 파일 청크 업로드
            for (const file of newSelectedFiles) {
                const totalChunks = Math.ceil(file.size / CHUNK_SIZE);
                const fileUid = (typeof crypto !== 'undefined' && crypto.randomUUID) ? crypto.randomUUID() : 'file-' + Date.now();
                let fileSavedName = null;

                for (let chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
                    const start = chunkIndex * CHUNK_SIZE;
                    const end = Math.min(start + CHUNK_SIZE, file.size);
                    const chunk = file.slice(start, end);

                    const chunkFormData = new FormData();
                    chunkFormData.append("file", chunk);
                    chunkFormData.append("fileUid", fileUid);
                    chunkFormData.append("originalName", file.name);
                    chunkFormData.append("chunkIndex", chunkIndex);
                    chunkFormData.append("totalChunks", totalChunks);

                    const response = await fetch('/api/posts/upload-chunk', {
                        method: 'POST',
                        body: chunkFormData
                    });

                    const result = await response.json();
                    if (!result.success) {
                        throw new Error(result.message || "청크 업로드 실패");
                    }

                    if (result.data && result.data.completed) {
                        fileSavedName = result.data.savedFileName;
                    }
                }

                if (fileSavedName) {
                    savedFileNames.push(fileSavedName);
                }
            }

            // 2. 최종 Payload 구성 (FormData)
            const finalPayload = new FormData();
            const postId = editForm.querySelector('input[name="postId"]').value;

            finalPayload.append("title", editForm.querySelector('#post-title')?.value || "");
            finalPayload.append("place", editForm.querySelector('#post-place')?.value || "");
            finalPayload.append("content", editForm.querySelector('#post-content')?.value || "");
            finalPayload.append("transportCost", editForm.querySelector('#transport-cost')?.value || 0);
            finalPayload.append("foodCost", editForm.querySelector('#food-cost')?.value || 0);
            finalPayload.append("otherCost", editForm.querySelector('#other-cost')?.value || 0);

            // 체크된 삭제 이미지 ID들 추가
            editForm.querySelectorAll('input[name="deleteImageIds"]:checked').forEach(checkbox => {
                finalPayload.append("deleteImageIds", checkbox.value);
            });

            // 업로드된 새 파일 이름들 추가
            savedFileNames.forEach(name => {
                finalPayload.append("savedFileNames", name);
            });

            // 3. 백엔드 컨트롤러와 주소/메서드 방식 일치시키기 (PUT -> POST, 경로 수정)
            const updateResponse = await fetch(`/api/posts/${postId}/update`, {
                method: 'POST', // 💡 컨트롤러의 @PostMapping("/{postId}/update")와 일치시킴
                body: finalPayload
            });

            const updateResult = await updateResponse.json();

            if (updateResponse.ok && updateResult.success) {
                alert("게시글이 성공적으로 수정되었습니다!");
                location.href = `/main-post`;
            } else {
                alert("수정 실패: " + (updateResult.message || ""));
                if (submitBtn) submitBtn.disabled = false;
            }

        } catch (error) {
            console.error("오류 발생:", error);
            alert("오류가 발생했습니다: " + error.message);
            if (submitBtn) submitBtn.disabled = false;
        }
    });
})