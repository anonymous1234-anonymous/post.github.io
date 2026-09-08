document.addEventListener("DOMContentLoaded", () => {
    const maxFileCount = 10; // 👈 10개 제한

    const uploader = document.querySelector("[data-post-image-uploader]");
    const imageInput = document.querySelector("#new-post-image");
    const emptyMessage = document.querySelector("#post-image-empty");
    const mainPreview = document.querySelector("#post-main-preview");
    const thumbnailList = document.querySelector("#post-thumbnail-list");
    const imageCount = document.querySelector("#post-image-count"); // "1 / 10" 표시용

    const prevBtn = document.querySelector("#post-prev-btn");
    const nextBtn = document.querySelector("#post-next-btn");

    if (!uploader || !imageInput || !emptyMessage || !mainPreview || !thumbnailList || !imageCount) {
        return;
    }

    let selectedFiles = [];
    let currentImageIndex = 0;
    let currentPreviewUrl = null;

    function renderMainPreview(index) {
        if (selectedFiles.length === 0) {
            emptyMessage.style.display = "flex";
            mainPreview.hidden = true;
            mainPreview.removeAttribute("src");
            const existingMedia = mainPreview.parentElement.querySelector("#dynamic-media-view");
            if (existingMedia) existingMedia.style.display = "none";
            if (prevBtn) prevBtn.style.display = "none";
            if (nextBtn) nextBtn.style.display = "none";
            imageCount.textContent = "0";
            return;
        }

        if (index >= selectedFiles.length) {
            index = selectedFiles.length - 1;
        }
        currentImageIndex = index;

        const file = selectedFiles[index];

        if (currentPreviewUrl) {
            URL.revokeObjectURL(currentPreviewUrl);
        }

        currentPreviewUrl = URL.createObjectURL(file);
        emptyMessage.style.display = "none";

        const container = mainPreview.parentElement;
        let mediaElement = container.querySelector("#dynamic-media-view");

        if (!mediaElement) {
            mediaElement = document.createElement("div");
            mediaElement.id = "dynamic-media-view";
            mediaElement.style.width = "100%";
            mediaElement.style.height = "100%";
            mediaElement.style.display = "flex";
            mediaElement.style.alignItems = "center";
            mediaElement.style.justifyContent = "center";
            container.appendChild(mediaElement);
        }

        mainPreview.hidden = true;
        mediaElement.style.display = "flex";

        const fileNameLower = file.name.toLowerCase();
        // 💡 확장자와 타입 모두 체크하여 .webm 같은 파일도 완벽하게 동영상으로 인식하도록 수정
        const isVideo = file.type.startsWith("video/") || fileNameLower.endsWith(".webm") || fileNameLower.endsWith(".mp4") || fileNameLower.endsWith(".mov");
        const isImage = file.type.startsWith("image/") || fileNameLower.endsWith(".jpg") || fileNameLower.endsWith(".jpeg") || fileNameLower.endsWith(".png") || fileNameLower.endsWith(".gif");
        const isAudio = file.type.startsWith("audio/") || fileNameLower.endsWith(".mp3") || fileNameLower.endsWith(".wav");

        if (isImage) {
            mediaElement.innerHTML = `<img src="${currentPreviewUrl}" alt="${file.name}" style="width: 100%; height: 100%; object-fit: contain; border-radius: 8px;">`;
        } else if (isVideo) {
            // 💡 동영상 첫 프레임을 미리 보여주기 위해 preload="metadata" 추가
            mediaElement.innerHTML = `<video src="${currentPreviewUrl}" controls preload="metadata" style="width: 100%; height: 100%; object-fit: contain; border-radius: 8px; background: #000;"></video>`;
            const videoEl = mediaElement.querySelector("video");
            if (videoEl) {
                videoEl.currentTime = 0.1; // 첫 화면 프레임 강제 로드
            }
        } else if (isAudio) {
            mediaElement.innerHTML = `<div class="text-center p-4"><i class="bi bi-file-earmark-music display-4 mb-2"></i><p>${file.name}</p><audio src="${currentPreviewUrl}" controls class="w-100"></audio></div>`;
        } else {
            mediaElement.innerHTML = `<div class="text-center p-4"><i class="bi bi-file-earmark-arrow-down display-4 mb-2"></i><p>${file.name}</p><small class="text-muted">파일이 정상적으로 등록되었습니다.</small></div>`;
        }

        imageCount.textContent = `${currentImageIndex + 1} / ${selectedFiles.length}`;

        if (prevBtn && nextBtn) {
            const hasMultiple = selectedFiles.length > 1;
            prevBtn.style.display = hasMultiple ? "block" : "none";
            nextBtn.style.display = hasMultiple ? "block" : "none";
        }
    }

    function renderThumbnails() {
        thumbnailList.innerHTML = "";

        selectedFiles.forEach((file, index) => {
            const item = document.createElement("div");
            item.className = "zt-post-thumbnail-item me-2 d-inline-block position-relative";

            const button = document.createElement("button");
            button.type = "button";
            button.className = "zt-post-thumbnail btn p-0 border-0";

            if (index === currentImageIndex) {
                button.classList.add("active");
            }

            const thumbContent = document.createElement("div");
            thumbContent.style.width = "60px";
            thumbContent.style.height = "60px";
            thumbContent.style.borderRadius = "4px";
            thumbContent.style.overflow = "hidden";
            thumbContent.style.display = "flex";
            thumbContent.style.alignItems = "center";
            thumbContent.style.justifyContent = "center";
            thumbContent.style.background = "#f1f3f5";

            const thumbnailUrl = URL.createObjectURL(file);
            const fileNameLower = file.name.toLowerCase();
            const isImage = file.type.startsWith("image/") || fileNameLower.endsWith(".jpg") || fileNameLower.endsWith(".jpeg") || fileNameLower.endsWith(".png") || fileNameLower.endsWith(".gif");
            const isVideo = file.type.startsWith("video/") || fileNameLower.endsWith(".webm") || fileNameLower.endsWith(".mp4") || fileNameLower.endsWith(".mov");

            if (isImage) {
                thumbContent.innerHTML = `<img src="${thumbnailUrl}" alt="${file.name}" style="width: 100%; height: 100%; object-fit: cover;">`;
            } else if (isVideo) {
                thumbContent.innerHTML = `<i class="bi bi-file-earmark-play-fill text-dark" style="font-size: 1.5rem;"></i>`;
            } else {
                thumbContent.innerHTML = `<i class="bi bi-file-earmark-fill text-dark" style="font-size: 1.5rem;"></i>`;
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

                if (currentImageIndex >= selectedFiles.length) {
                    currentImageIndex = Math.max(0, selectedFiles.length - 1);
                } else if (index < currentImageIndex) {
                    currentImageIndex--;
                }

                updateImageInput();
                renderMainPreview(currentImageIndex);
                renderThumbnails();
            });

            item.append(button);
            item.append(removeButton);
            thumbnailList.append(item);
        });
    }

    function updateImageInput() {
        const dataTransfer = new DataTransfer();
        selectedFiles.forEach((file) => {
            dataTransfer.items.add(file);
        });
        imageInput.files = dataTransfer.files;
    }

    if (prevBtn) {
        prevBtn.addEventListener("click", () => {
            if (selectedFiles.length <= 1) return;
            currentImageIndex = (currentImageIndex - 1 + selectedFiles.length) % selectedFiles.length;
            renderMainPreview(currentImageIndex);
            renderThumbnails();
        });
    }

    if (nextBtn) {
        nextBtn.addEventListener("click", () => {
            if (selectedFiles.length <= 1) return;
            currentImageIndex = (currentImageIndex + 1) % selectedFiles.length;
            renderMainPreview(currentImageIndex);
            renderThumbnails();
        });
    }
    imageInput.addEventListener("change", () => {
        const newFiles = Array.from(imageInput.files);
        imageInput.value = "";

        // 🚫 보안상 차단할 확장자 목록
        const blockedExtensions = [".exe", ".zip", ".bat", ".cmd", ".sh", ".jar", ".msi", ".iso", ".dmg"];

        // 1. 허용된 파일과 차단된 파일 분리
        const validFiles = [];
        let hasBlockedFile = false;

        newFiles.forEach(file => {
            const fileNameLower = file.name.toLowerCase();
            const isBlocked = blockedExtensions.some(ext => fileNameLower.endsWith(ext));
            if (isBlocked) {
                hasBlockedFile = true;
            } else {
                validFiles.push(file);
            }
        });

        // 차단된 파일이 있었다면 경고 메시지 출력
        if (hasBlockedFile) {
            alert("보안상 `.exe`, `.zip` 등의 실행 파일 및 압축 파일은 업로드할 수 없습니다. (해당 파일은 제외됨)");
        }

        if (validFiles.length === 0) {
            return;
        }

        const remainingCount = maxFileCount - selectedFiles.length;

        if (validFiles.length > remainingCount) {
            alert(`파일은 최대 ${maxFileCount}개까지만 선택할 수 있습니다.`);
        }

        const filesToAdd = validFiles.slice(0, remainingCount);

        if (filesToAdd.length > 0) {
            selectedFiles = [...selectedFiles, ...filesToAdd];
            updateImageInput();

            renderMainPreview(currentImageIndex);
            renderThumbnails();
        }
    });
});