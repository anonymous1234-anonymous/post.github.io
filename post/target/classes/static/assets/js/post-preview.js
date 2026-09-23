document.addEventListener("DOMContentLoaded", () => {
    const maxFileCount = 10;
    const uploader = document.querySelector("[data-post-image-uploader]");
    const imageInput = document.querySelector("#new-post-image");
    const emptyMessage = document.querySelector("#post-image-empty");
    const mediaElement = document.querySelector("#dynamic-media-view");
    const thumbnailList = document.querySelector("#post-thumbnail-list");
    const imageCount = document.querySelector("#post-image-count");

    const prevBtn = document.querySelector("#post-prev-btn");
    const nextBtn = document.querySelector("#post-next-btn");

    if (!uploader || !imageInput || !emptyMessage || !mediaElement || !thumbnailList || !imageCount) {
        return;
    }

    let selectedFiles = [];
    let currentImageIndex = 0;
    let currentPreviewUrl = null;

    function renderMainPreview(index) {
        mediaElement.innerHTML = "";

        if (selectedFiles.length === 0) {
            if (currentPreviewUrl) {
                URL.revokeObjectURL(currentPreviewUrl);
                currentPreviewUrl = null;
            }
            emptyMessage.style.display = "flex";
            const mainPreviewEl = document.querySelector("#post-main-preview");
            if (mainPreviewEl) mainPreviewEl.hidden = false;

            mediaElement.style.display = "none";
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

        const fileNameLower = file.name.toLowerCase();
        const isVideo = file.type.startsWith("video/") || fileNameLower.endsWith(".webm") || fileNameLower.endsWith(".mp4") || fileNameLower.endsWith(".mov");
        const isImage = file.type.startsWith("image/") || fileNameLower.endsWith(".jpg") || fileNameLower.endsWith(".jpeg") || fileNameLower.endsWith(".png") || fileNameLower.endsWith(".gif") || fileNameLower.endsWith(".webp");
        const isAudio = file.type.startsWith("audio/") || fileNameLower.endsWith(".mp3") || fileNameLower.endsWith(".wav");

        if (isImage) {
            mediaElement.innerHTML = `<img src="${currentPreviewUrl}" alt="${file.name}" style="max-width: 100%; max-height: 250px; width: auto; height: auto; object-fit: contain; border-radius: 8px;">`;
        } else if (isVideo) {
            mediaElement.innerHTML = `
                <div class="text-center p-4">
                    <i class="bi bi-file-earmark-play-fill display-4 mb-2 text-danger"></i>
                    <p class="mb-1">${file.name}</p>
                    <small class="text-muted">동영상 파일이 선택되었습니다.</small>
                </div>
            `;
        } else if (isAudio) {
            mediaElement.innerHTML = `
                <div class="text-center p-4">
                    <i class="bi bi-file-earmark-music display-4 mb-2 text-primary"></i>
                    <p class="mb-1">${file.name}</p>
                    <audio src="${currentPreviewUrl}" controls class="w-100 mt-2"></audio>
                </div>
            `;
        } else {
            mediaElement.innerHTML = `
                <div class="text-center p-4">
                    <i class="bi bi-file-earmark-fill display-4 mb-2"></i>
                    <p class="mb-1">${file.name}</p>
                    <small class="text-muted">일반 파일이 선택되었습니다.</small>
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
            const isImage = file.type.startsWith("image/") || fileNameLower.endsWith(".jpg") || fileNameLower.endsWith(".jpeg") || fileNameLower.endsWith(".png") || fileNameLower.endsWith(".gif") || fileNameLower.endsWith(".webp");

            if (isImage) {
                thumbContent.innerHTML = `<img src="${thumbnailUrl}" alt="${file.name}" style="width: 100%; height: 100%; object-fit: cover;">`;
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
                currentImageIndex = Math.max(0, Math.min(currentImageIndex, selectedFiles.length - 1));
                renderMainPreview(currentImageIndex);
                renderThumbnails();
            });

            item.append(button, removeButton);
            thumbnailList.append(item);
        });
    }

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

    imageInput.addEventListener("change", () => {
        const newFiles = Array.from(imageInput.files);
        imageInput.value = "";

        const blockedExtensions = [".exe", ".zip", ".bat", ".cmd", ".sh", ".jar", ".msi", ".iso", ".dmg"];
        const validFiles = newFiles.filter(file => !blockedExtensions.some(ext => file.name.toLowerCase().endsWith(ext)));

        if (validFiles.length < newFiles.length) alert("보안상 실행 및 압축 파일은 업로드할 수 없습니다.");
        if (validFiles.length === 0) return;

        const remainingCount = maxFileCount - selectedFiles.length;
        if (validFiles.length > remainingCount) {
            alert(`파일은 최대 ${maxFileCount}개까지만 선택할 수 있습니다.`);
        }

        const filesToAdd = validFiles.slice(0, remainingCount);
        if (filesToAdd.length > 0) {
            selectedFiles = [...selectedFiles, ...filesToAdd];
            currentImageIndex = 0;
            renderMainPreview(currentImageIndex);
            renderThumbnails();
        }
    });

    // 다른 파일(edit.js)에서 현재 선택된 파일 목록을 가져갈 수 있도록 전역 인터페이스 제공
    window.postImageManager = {
        getSelectedFiles: () => selectedFiles
    };
});