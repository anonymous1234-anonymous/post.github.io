document.addEventListener("DOMContentLoaded", () => {
    const maxFileCount = 10;

    const uploader = document.querySelector("[data-post-image-uploader]");
    const imageInput = document.querySelector("#new-post-image");
    const emptyMessage = document.querySelector("#post-image-empty");
    const mainPreview = document.querySelector("#post-main-preview");
    const thumbnailList = document.querySelector("#post-thumbnail-list");
    const imageCount = document.querySelector("#post-image-count");

    const prevBtn = document.querySelector("#post-prev-btn");
    const nextBtn = document.querySelector("#post-next-btn");
    const form = document.querySelector("form");

    if (!uploader || !imageInput || !emptyMessage || !mainPreview || !thumbnailList || !imageCount) {
        return;
    }

    let selectedFiles = [];
    let currentImageIndex = 0;
    let currentPreviewUrl = null;

    const container = mainPreview.parentElement;
    let mediaElement = container.querySelector("#dynamic-media-view");

    // dynamic-media-view 안전하게 확보 및 스타일 정렬 (absolute 제거로 버튼 클릭 방해 방지)
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

    function renderMainPreview(index) {
        if (selectedFiles.length === 0) {
            emptyMessage.style.display = "flex";
            mainPreview.hidden = true;
            mediaElement.style.display = "none";
            mediaElement.innerHTML = "";
            if (prevBtn) prevBtn.style.display = "none";
            if (nextBtn) nextBtn.style.display = "none";
            imageCount.textContent = "0";
            return;
        }

        if (index >= selectedFiles.length) {
            index = selectedFiles.length - 1;
        }
        if (index < 0) {
            index = 0;
        }
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
        const isAudio = file.type.startsWith("audio/") || fileNameLower.endsWith(".mp3") || fileNameLower.endsWith(".wav");

        if (isImage) {
            mediaElement.innerHTML = `<img src="${currentPreviewUrl}" alt="${file.name}" style="max-width: 100%; max-height: 250px; width: auto; height: auto; object-fit: contain; border-radius: 8px;">`;
        } else if (isVideo) {
            mediaElement.innerHTML = `<video src="${currentPreviewUrl}" controls preload="metadata" style="max-width: 100%; max-height: 250px; width: 100%; height: auto; object-fit: contain; border-radius: 8px; background: #000;"></video>`;
            const videoEl = mediaElement.querySelector("video");
            if (videoEl) videoEl.currentTime = 0.1;
        } else if (isAudio) {
            mediaElement.innerHTML = `<div class="text-center p-4"><i class="bi bi-file-earmark-music display-4 mb-2"></i><p>${file.name}</p><audio src="${currentPreviewUrl}" controls class="w-100"></audio></div>`;
        } else {
            mediaElement.innerHTML = `<div class="text-center p-4"><i class="bi bi-file-earmark-arrow-down display-4 mb-2"></i><p>${file.name}</p><small class="text-muted">파일이 정상적으로 등록되었습니다.</small></div>`;
        }

        imageCount.textContent = `${currentImageIndex + 1} / ${selectedFiles.length}`;

        // 양옆 버튼 가시성 제어 및 클릭 방해 방지를 위한 z-index 부여
        if (prevBtn && nextBtn) {
            const hasMultiple = selectedFiles.length > 1;
            prevBtn.style.display = hasMultiple ? "block" : "none";
            nextBtn.style.display = hasMultiple ? "block" : "none";
            prevBtn.style.zIndex = "30";
            nextBtn.style.zIndex = "30";
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
                }

                renderMainPreview(currentImageIndex);
                renderThumbnails();
            });

            item.append(button);
            item.append(removeButton);
            thumbnailList.append(item);
        });
    }

    // 좌측 이동 버튼 이벤트
    if (prevBtn) {
        prevBtn.onclick = (e) => {
            e.preventDefault();
            if (selectedFiles.length <= 1) return;
            currentImageIndex = (currentImageIndex - 1 + selectedFiles.length) % selectedFiles.length;
            renderMainPreview(currentImageIndex);
            renderThumbnails();
        };
    }

    // 우측 이동 버튼 이벤트
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
        const validFiles = newFiles.filter(file => {
            const fileNameLower = file.name.toLowerCase();
            return !blockedExtensions.some(ext => fileNameLower.endsWith(ext));
        });

        if (validFiles.length < newFiles.length) {
            alert("보안상 실행 및 압축 파일은 업로드할 수 없습니다.");
        }

        if (validFiles.length === 0) return;

        const remainingCount = maxFileCount - selectedFiles.length;
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

    // 폼 제출 로직 (오류 문법 정리 완료)
    if (form) {
        form.addEventListener("submit", async (e) => {
            e.preventDefault();

            const submitBtn = form.querySelector("button[type='submit']");
            if (submitBtn) submitBtn.disabled = true;

            try {
                let savedFileNames = [];

                for (const file of selectedFiles) {
                    const CHUNK_SIZE = 5 * 1024 * 1024;
                    const totalChunks = Math.ceil(file.size / CHUNK_SIZE);
                    const fileUid = self.crypto.randomUUID();

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

                        const chunkRes = await fetch('${pageContext.request.contextPath}/api/posts/upload-chunk', {
                            method: 'POST',
                            body: formData
                        });

                        const chunkResult = await chunkRes.json();
                        if (chunkResult.data && chunkResult.data.completed) {
                            savedFileNames.push(chunkResult.data.savedFileName);
                        }
                    }
                }

                const postData = {
                    title: form.querySelector('#post-title').value,
                    place: form.querySelector('#post-place').value,
                    content: form.querySelector('#post-content').value,
                    transportCost: form.querySelector('#transport-cost').value,
                    foodCost: form.querySelector('#food-cost').value,
                    otherCost: form.querySelector('#other-cost').value,
                    savedFileNames: savedFileNames
                };

                const finalRes = await fetch('${pageContext.request.contextPath}/new-post', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(postData)
                });

                if (finalRes.ok) {
                    alert("게시글이 성공적으로 등록되었습니다!");
                    location.href = "${pageContext.request.contextPath}/home";
                } else {
                    alert("게시글 등록에 실패했습니다.");
                    if (submitBtn) submitBtn.disabled = false;
                }

            } catch (error) {
                console.error("업로드 중 오류 발생:", error);
                alert("오류가 발생했습니다. 다시 시도해주세요.");
                if (submitBtn) submitBtn.disabled = false;
            }
        });
    }
});