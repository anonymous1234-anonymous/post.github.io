document.addEventListener("DOMContentLoaded", () => {
    // ==========================================
    // [글 작성/수정 페이지 전용 로직]
    // ==========================================
    const maxFileCount = 10;
    const CHUNK_SIZE = 5 * 1024 * 1024; // 5MB 단위 청크 분할

    const uploader = document.querySelector("[data-post-image-uploader]");
    const imageInput = document.querySelector("#new-post-image");
    const emptyMessage = document.querySelector("#post-image-empty");
    const mainPreview = document.querySelector("#post-main-preview");
    const thumbnailList = document.querySelector("#post-thumbnail-list");
    const imageCount = document.querySelector("#post-image-count");

    const prevBtn = document.querySelector("#post-prev-btn");
    const nextBtn = document.querySelector("#post-next-btn");
    const form = document.querySelector("form");

    // 작성/수정 페이지 요소들이 없으면 실행 중단
    if (!uploader || !imageInput || !emptyMessage || !mainPreview || !thumbnailList || !imageCount) {
        return;
    }

    let selectedFiles = [];
    let currentImageIndex = 0;
    let currentPreviewUrl = null;

    const container = mainPreview.parentElement;
    let mediaElement = container.querySelector("#dynamic-media-view");

    if (!mediaElement) {
        mediaElement = document.createElement("div");
        mediaElement.id = "dynamic-media-view";
        mediaElement.style.cssText = "width: 100%; height: 100%; display: none; align-items: center; justify-content: center;";
        container.insertBefore(mediaElement, mainPreview);
    } else {
        mediaElement.style.position = "static";
        mediaElement.style.width = "100%";
        mediaElement.style.height = "100%";
    }

    // 메인 프리뷰 렌더링 함수
    function renderMainPreview(index) {
        if (selectedFiles.length === 0) {
            if (currentPreviewUrl) {
                URL.revokeObjectURL(currentPreviewUrl);
                currentPreviewUrl = null;
            }
            emptyMessage.style.display = "flex";
            mainPreview.hidden = true;
            mediaElement.style.display = "none";
            mediaElement.innerHTML = "";
            if (prevBtn) prevBtn.style.display = "none";
            if (nextBtn) nextBtn.style.display = "none";
            imageCount.textContent = "0";
            return;
        }

        if (index >= selectedFiles.length) index = selectedFiles.length - 1;
        if (index < 0) index = 0;
        currentImageIndex = index;

        const file = selectedFiles[index];
        if (currentPreviewUrl) {
            URL.revokeObjectURL(currentPreviewUrl);
        }

        currentPreviewUrl = URL.createObjectURL(file);
        emptyMessage.style.display = "none";
        mediaElement.style.display = "flex";
        mainPreview.hidden = true;

        const fileNameLower = file.name.toLowerCase();
        const isVideo = file.type.startsWith("video/") || fileNameLower.endsWith(".webm") || fileNameLower.endsWith(".mp4") || fileNameLower.endsWith(".mov");
        const isImage = file.type.startsWith("image/") || fileNameLower.endsWith(".jpg") || fileNameLower.endsWith(".jpeg") || fileNameLower.endsWith(".png") || fileNameLower.endsWith(".gif");

        if (isImage) {
            mediaElement.innerHTML = `<img src="${currentPreviewUrl}" alt="${file.name}" style="max-width: 100%; max-height: 250px; width: auto; height: auto; object-fit: contain; border-radius: 8px;">`;
        } else if (isVideo) {
            mediaElement.innerHTML = `
                <div class="text-center p-4">
                    <i class="bi bi-file-earmark-play-fill display-4 mb-2 text-danger"></i>
                    <p class="mb-1">${file.name}</p>
                    <small class="text-muted">동영상 파일이 선택되었습니다. (등록 시 재생됩니다)</small>
                </div>
            `;
        }

        imageCount.textContent = `${currentImageIndex + 1} / ${selectedFiles.length}`;

        if (prevBtn && nextBtn) {
            const hasMultiple = selectedFiles.length > 1;
            prevBtn.style.display = hasMultiple ? "block" : "none";
            nextBtn.style.display = hasMultiple ? "block" : "none";
        }
    }

    // 썸네일 목록 렌더링 함수
    function renderThumbnails() {
        thumbnailList.innerHTML = "";
        selectedFiles.forEach((file, index) => {
            const item = document.createElement("div");
            item.className = "zt-post-thumbnail-item me-2 d-inline-block position-relative";

            const button = document.createElement("button");
            button.type = "button";
            button.className = "zt-post-thumbnail btn p-0 border-0";
            if (index === currentImageIndex) button.classList.add("active");

            const thumbContent = document.createElement("div");
            thumbContent.style.cssText = "width: 60px; height: 60px; border-radius: 4px; overflow: hidden; display: flex; align-items: center; justify-content: center; background: #f1f3f5; position: relative;";

            const thumbnailUrl = URL.createObjectURL(file);
            const fileNameLower = file.name.toLowerCase();
            const isImage = file.type.startsWith("image/") || fileNameLower.endsWith(".jpg") || fileNameLower.endsWith(".jpeg") || fileNameLower.endsWith(".png") || fileNameLower.endsWith(".gif");
            const isVideo = file.type.startsWith("video/") || fileNameLower.endsWith(".webm") || fileNameLower.endsWith(".mp4") || fileNameLower.endsWith(".mov");

            if (isImage) {
                thumbContent.innerHTML = `<img src="${thumbnailUrl}" alt="${file.name}" style="width: 100%; height: 100%; object-fit: cover;">`;
            } else if (isVideo) {
                thumbContent.innerHTML = `
                    <i class="bi bi-file-earmark-play-fill text-dark" style="font-size: 1.5rem;"></i>
                    <span class="position-absolute bottom-0 end-0 badge bg-dark text-white" style="font-size: 8px; padding: 1px 3px;">VIDEO</span>
                `;
                URL.revokeObjectURL(thumbnailUrl);
            } else {
                thumbContent.innerHTML = `<i class="bi bi-file-earmark-fill text-dark" style="font-size: 1.5rem;"></i>`;
                URL.revokeObjectURL(thumbnailUrl);
            }

            button.appendChild(thumbContent);
            button.addEventListener("click", () => {
                renderMainPreview(index);
                renderThumbnails();
            });

            const removeButton = document.createElement("button");
            removeButton.type = "button";
            removeButton.className = "zt-post-thumbnail-remove btn btn-danger btn-sm position-absolute top-0 end-0 p-0 px-1";
            removeButton.style.fontSize = "10px";
            removeButton.textContent = "×";

            removeButton.addEventListener("click", (e) => {
                e.stopPropagation();
                selectedFiles.splice(index, 1);
                currentImageIndex = Math.max(0, Math.min(currentImageIndex, selectedFiles.length - 1));
                renderMainPreview(currentImageIndex);
                renderThumbnails();
            });

            item.append(button, removeButton);
            thumbnailList.append(item);
        });
    }

    // 좌우 슬라이드 버튼 이벤트 연결
    if (prevBtn) {
        prevBtn.onclick = (e) => {
            e.preventDefault();
            if (selectedFiles.length <= 1) return;
            currentImageIndex = (currentImageIndex - 1 + selectedFiles.length) % selectedFiles.length;
            renderMainPreview(currentImageIndex);
            renderThumbnails();
        };
    }

    if (nextBtn) {
        nextBtn.onclick = (e) => {
            e.preventDefault();
            if (selectedFiles.length <= 1) return;
            currentImageIndex = (currentImageIndex + 1) % selectedFiles.length;
            renderMainPreview(currentImageIndex);
            renderThumbnails();
        };
    }

    // 키보드 방향키(←, →) 슬라이드 단축키 지원
    document.addEventListener("keydown", (e) => {
        if (selectedFiles.length <= 1) return;
        if (["INPUT", "TEXTAREA"].includes(document.activeElement.tagName)) return;

        if (e.key === "ArrowLeft") {
            e.preventDefault();
            currentImageIndex = (currentImageIndex - 1 + selectedFiles.length) % selectedFiles.length;
            renderMainPreview(currentImageIndex);
            renderThumbnails();
        } else if (e.key === "ArrowRight") {
            e.preventDefault();
            currentImageIndex = (currentImageIndex + 1) % selectedFiles.length;
            renderMainPreview(currentImageIndex);
            renderThumbnails();
        }
    });

    // 파일 입력(Input Change) 이벤트
    imageInput.addEventListener("change", () => {
        const newFiles = Array.from(imageInput.files);
        imageInput.value = "";

        const blockedExtensions = [".exe", ".zip", ".bat", ".cmd", ".sh", ".jar", ".msi", ".iso", ".dmg"];
        const validFiles = newFiles.filter(file => !blockedExtensions.some(ext => file.name.toLowerCase().endsWith(ext)));

        if (validFiles.length < newFiles.length) alert("보안상 실행 및 압축 파일은 업로드할 수 없습니다.");
        if (validFiles.length === 0) return;

        const existingThumbnails = document.querySelectorAll('input[name="deleteImageIds"]');
        let deletedCount = 0;
        existingThumbnails.forEach(checkbox => {
            if (checkbox.checked) deletedCount++;
        });

        const currentRemainingExisting = existingThumbnails.length - deletedCount;
        const totalCurrentCount = currentRemainingExisting + selectedFiles.length;
        const remainingCount = maxFileCount - totalCurrentCount;

        if (validFiles.length > remainingCount) {
            alert(`파일은 최대 ${maxFileCount}개까지만 선택할 수 있습니다.`);
        }

        const filesToAdd = validFiles.slice(0, remainingCount);
        if (filesToAdd.length > 0) {
            selectedFiles = [...selectedFiles, ...filesToAdd];
            renderMainPreview(currentImageIndex);
            renderThumbnails();
        }
    });

    // 폼 제출(Submit) 및 청크 업로드 처리
    if (form) {
        form.addEventListener("submit", async (e) => {
            e.preventDefault();

            const submitBtn = form.querySelector("button[type='submit']");
            if (submitBtn) submitBtn.disabled = true;

            try {
                let savedFileNames = [];

                for (const file of selectedFiles) {
                    if (typeof file === "string") continue;

                    const totalChunks = Math.ceil(file.size / CHUNK_SIZE);
                    const uploadId = (typeof crypto !== 'undefined' && crypto.randomUUID) ? crypto.randomUUID() : 'upload-' + Date.now();
                    let fileSavedName = null;

                    for (let chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
                        const start = chunkIndex * CHUNK_SIZE;
                        const end = Math.min(start + CHUNK_SIZE, file.size);
                        const chunk = file.slice(start, end);

                        const formData = new FormData();
                        formData.append("file", chunk);
                        formData.append("uploadId", uploadId);
                        formData.append("originalName", file.name);
                        formData.append("chunkIndex", chunkIndex);
                        formData.append("totalChunks", totalChunks);

                        const chunkRes = await fetch('/api/posts/upload-chunk', {method: 'POST', body: formData});
                        const chunkResult = await chunkRes.json();

                        if (!chunkResult.success) {
                            throw new Error(chunkResult.message || "청크 업로드 실패");
                        }

                        if (chunkResult.data && chunkResult.data.completed === true && chunkResult.data.savedFileName) {
                            fileSavedName = chunkResult.data.savedFileName;
                        }
                    }

                    if (fileSavedName) {
                        savedFileNames.push(fileSavedName);
                    }
                }

                // 업로드된 파일명들을 숨김 필드로 폼에 추가하여 서버 전송
                savedFileNames.forEach(fileName => {
                    const hiddenInput = document.createElement("input");
                    hiddenInput.type = "hidden";
                    hiddenInput.name = "savedFileNames";
                    hiddenInput.value = fileName;
                    form.appendChild(hiddenInput);
                });

                form.submit();

            } catch (error) {
                console.error("파일 업로드 중 에러 발생:", error);
                alert("파일 업로드에 실패했습니다: " + error.message);
                if (submitBtn) submitBtn.disabled = false;
            }
        });
    }
});