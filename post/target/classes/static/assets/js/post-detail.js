document.addEventListener("DOMContentLoaded", () => {
    const maxImageCount = 10;
    const CHUNK_SIZE = 5 * 1024 * 1024; // 1MB 단위 청크 분할

    const uploader = document.querySelector("[data-post-image-uploader]");
    const imageInput = document.querySelector("#new-post-image");
    const emptyMessage = document.querySelector("#post-image-empty");
    const mainPreview = document.querySelector("#post-main-preview");
    const thumbnailList = document.querySelector("#post-thumbnail-list");
    const imageCount = document.querySelector("#post-image-count");

    const prevBtn = document.querySelector("#post-prev-btn");
    const nextBtn = document.querySelector("#post-next-btn");
    const postForm = document.querySelector("form"); // form 태그 선택

    if (!uploader || !imageInput) {
        return;
    }

    let selectedFiles = [];

    // 🌟 [추가] 서버에서 전달된 기존 파일(수정 모드)이 있다면 초기 파일 배열에 세팅
    if (window.initialFiles && window.initialFiles.length > 0) {
        selectedFiles = [...window.initialFiles];
    }

    let currentImageIndex = 0;
    let currentSlideIndex = 0;

    const allowedTypes = [
        "image/jpeg", "image/png", "image/gif", "image/webp",
        "video/mp4", "video/quicktime", "video/webm", "video/x-msvideo", "video/m4v",
        "audio/mpeg", "audio/wav", "audio/x-wav", "audio/mp3", "audio/wave"
    ];

    window.moveSlide = function (direction) {
        const slides = document.querySelectorAll('.slide-item');
        if (slides.length <= 1) return;

        const currentSlide = slides[currentSlideIndex];
        const activeVideo = currentSlide?.querySelector('video');
        const activeAudio = currentSlide?.querySelector('audio');
        if (activeVideo) activeVideo.pause();
        if (activeAudio) activeAudio.pause();

        currentSlideIndex = (currentSlideIndex + direction + slides.length) % slides.length;

        slides.forEach((slide, index) => {
            if (index === currentSlideIndex) {
                slide.style.display = 'flex';
            } else {
                slide.style.display = 'none';
            }
        });

        const currentIndexSpan = document.querySelector('#current-index');
        if (currentIndexSpan) {
            currentIndexSpan.textContent = currentSlideIndex + 1;
        }
    };

    function renderMainPreview(index) {
        const container = mainPreview.parentElement;
        const existingVideo = container.querySelector("#dynamic-video-preview");
        const existingAudio = container.querySelector("#dynamic-audio-preview");

        if (selectedFiles.length === 0) {
            if (emptyMessage) emptyMessage.style.display = "flex";
            if (mainPreview) {
                mainPreview.hidden = true;
                mainPreview.removeAttribute("src");
            }
            if (existingVideo) existingVideo.remove();
            if (existingAudio) existingAudio.remove();
            if (prevBtn) prevBtn.style.display = "none";
            if (nextBtn) nextBtn.style.display = "none";
            if (imageCount) imageCount.textContent = "0";
            return;
        }

        if (index >= selectedFiles.length) {
            index = selectedFiles.length - 1;
        }
        currentImageIndex = index;

        const file = selectedFiles[index];

        const isStringUrl = typeof file === "string";
        const previewUrl = isStringUrl ? file : URL.createObjectURL(file);

        const isVideo = isStringUrl
            ? (file.includes(".mp4") || file.includes(".mov") || file.includes(".webm") || file.includes(".m4v") || file.includes(".qt"))
            : file.type.startsWith("video/");

        const isAudio = isStringUrl
            ? (file.includes(".mp3") || file.includes(".wav") || file.includes(".ogg"))
            : file.type.startsWith("audio/");

        if (emptyMessage) emptyMessage.style.display = "none";

        if (mainPreview) {
            mainPreview.hidden = true;
            mainPreview.removeAttribute("src");
        }
        if (existingVideo) existingVideo.style.display = "none";
        if (existingAudio) existingAudio.style.display = "none";

        if (isVideo) {
            if (existingAudio) existingAudio.removeAttribute("src");

            let videoPreview = existingVideo;
            if (!videoPreview) {
                videoPreview = document.createElement("video");
                videoPreview.id = "dynamic-video-preview";
                videoPreview.controls = true;
                videoPreview.style.cssText = "width: 100%; height: 100%; object-fit: contain; background: #000; border-radius: 8px;";
                container.insertBefore(videoPreview, mainPreview);
            }
            videoPreview.src = previewUrl;
            videoPreview.style.display = "block";

        } else if (isAudio) {
            if (existingVideo) existingVideo.removeAttribute("src");

            let audioPreview = existingAudio;
            if (!audioPreview) {
                audioPreview = document.createElement("div");
                audioPreview.id = "dynamic-audio-preview";
                audioPreview.className = "text-center text-dark p-4 w-100";
                audioPreview.innerHTML = `
                    <i class="bi bi-file-earmark-music display-1 mb-3 text-primary"></i>
                    <p class="file-name-label small text-muted text-truncate mb-2"></p>
                    <audio controls class="w-75"></audio>
                `;
                container.insertBefore(audioPreview, mainPreview);
            }
            audioPreview.querySelector(".file-name-label").textContent = isStringUrl ? file.split('/').pop() : file.name;
            audioPreview.querySelector("audio").src = previewUrl;
            audioPreview.style.display = "block";

        } else {
            if (existingVideo) existingVideo.removeAttribute("src");
            if (existingAudio) existingAudio.removeAttribute("src");

            if (mainPreview) {
                mainPreview.src = previewUrl;
                mainPreview.hidden = false;
                if (!isStringUrl) {
                    mainPreview.onload = () => URL.revokeObjectURL(previewUrl);
                }
            }
        }

        if (imageCount) {
            imageCount.textContent = `${currentImageIndex + 1} / ${selectedFiles.length}`;
        }

        if (prevBtn && nextBtn) {
            const hasMultiple = selectedFiles.length > 1;
            prevBtn.style.display = hasMultiple ? "flex" : "none";
            nextBtn.style.display = hasMultiple ? "flex" : "none";
        }
    }

    function renderThumbnails() {
        if (!thumbnailList) return;
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

            const thumbnailContent = document.createElement("div");
            thumbnailContent.style.cssText = "width: 60px; height: 60px; border-radius: 4px; overflow: hidden; background: #000; display: flex; align-items: center; justify-content: center;";

            const isStringUrl = typeof file === "string";
            const previewUrl = isStringUrl ? file : URL.createObjectURL(file);

            const isVideo = isStringUrl
                ? (file.includes(".mp4") || file.includes(".mov") || file.includes(".webm") || file.includes(".m4v") || file.includes(".qt"))
                : file.type.startsWith("video/");

            const isAudio = isStringUrl
                ? (file.includes(".mp3") || file.includes(".wav") || file.includes(".ogg"))
                : file.type.startsWith("audio/");

            if (isVideo) {
                const video = document.createElement("video");
                video.src = previewUrl;
                video.style.cssText = "width: 100%; height: 100%; object-fit: cover;";
                thumbnailContent.append(video);
            } else if (isAudio) {
                thumbnailContent.style.background = "#212529";
                thumbnailContent.innerHTML = `<i class="bi bi-file-earmark-music text-white fs-4"></i>`;
            } else {
                const image = document.createElement("img");
                image.src = previewUrl;
                image.style.cssText = "width: 100%; height: 100%; object-fit: cover;";
                thumbnailContent.append(image);
            }

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

            button.append(thumbnailContent);
            item.append(button);
            item.append(removeButton);
            thumbnailList.append(item);
        });
    }

    function updateImageInput() {
        const dataTransfer = new DataTransfer();
        selectedFiles.forEach((file) => {
            if (file instanceof File) {
                dataTransfer.items.add(file);
            }
        });
        imageInput.files = dataTransfer.files;
    }

    // 초기 파일이 존재할 경우 첫 화면 렌더링 실행
    if (selectedFiles.length > 0) {
        renderMainPreview(0);
        renderThumbnails();
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

        const validFiles = newFiles.filter((file) => allowedTypes.includes(file.type));

        if (validFiles.length !== newFiles.length) {
            alert("지원하지 않는 형식의 파일이 포함되어 있습니다. (이미지, 동영상, 오디오만 가능)");
        }

        const remainingCount = maxImageCount - selectedFiles.length;
        if (validFiles.length > remainingCount) {
            alert(`파일은 최대 ${maxImageCount}개까지만 선택할 수 있습니다.`);
        }

        const filesToAdd = validFiles.slice(0, remainingCount);

        if (filesToAdd.length > 0) {
            const newIndex = selectedFiles.length;
            selectedFiles = [...selectedFiles, ...filesToAdd];
            updateImageInput();
            renderMainPreview(newIndex);
            renderThumbnails();
        }
    });

    if (postForm) {
        postForm.addEventListener("submit", async (e) => {
            e.preventDefault();

            const submitBtn = postForm.querySelector("button[type='submit']");
            if (submitBtn) submitBtn.disabled = true;

            try {
                const savedFileNames = [];

                for (const file of selectedFiles) {
                    if (typeof file === "string") continue; // 기존 파일(문자열 경로)은 업로드 스킵

                    const totalChunks = Math.ceil(file.size / CHUNK_SIZE);
                    let fileSavedName = null;
                    const fileUid = 'file_' + Date.now() + '_' + Math.random().toString(36).substring(2, 9);

                    for (let chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
                        const start = chunkIndex * CHUNK_SIZE;
                        const end = Math.min(start + CHUNK_SIZE, file.size);
                        const chunk = file.slice(start, end);

                        const chunkFormData = new FormData();
                        chunkFormData.append("file", chunk);
                        chunkFormData.append("chunkIndex", chunkIndex);
                        chunkFormData.append("totalChunks", totalChunks);
                        chunkFormData.append("originalName", file.name);
                        chunkFormData.append("fileUid", fileUid);

                        const response = await fetch("/api/posts/upload-chunk", {
                            method: "POST",
                            body: chunkFormData
                        });

                        const result = await response.json();
                        if (!result.success) {
                            throw new Error(result.message || "청크 업로드 중 오류가 발생했습니다.");
                        }

                        if (result.data && result.data.completed) {
                            fileSavedName = result.data.savedFileName;
                        }
                    }

                    if (fileSavedName) {
                        savedFileNames.push(fileSavedName);
                    }
                }

                const titleVal = document.querySelector("#post-title")?.value || "";
                const placeVal = document.querySelector("#post-place")?.value || "";
                const contentVal = document.querySelector("#post-content")?.value || "";
                const transportCostVal = document.querySelector("#transport-cost")?.value || "0";
                const foodCostVal = document.querySelector("#food-cost")?.value || "0";
                const otherCostVal = document.querySelector("#other-cost")?.value || "0";

                const postIdInput = document.querySelector("input[name='postId']") || document.querySelector("#post-id");
                const postId = postIdInput ? postIdInput.value : null;

                const formData = new FormData();
                formData.append("title", titleVal);
                formData.append("place", placeVal);
                formData.append("content", contentVal);
                formData.append("transportCost", transportCostVal);
                formData.append("foodCost", foodCostVal);
                formData.append("otherCost", otherCostVal);

                // 🌟 [핵심 수정] 값이 존재할 때만 append (빈 문자열 전송에 따른 500 에러 원천 차단)
                if (savedFileNames && savedFileNames.length > 0) {
                    savedFileNames.forEach((name) => {
                        formData.append("savedFileNames", name);
                    });
                }

                if (postId) {
                    const deleteImageCheckboxes = document.querySelectorAll("input[name='deleteImageIds']:checked");
                    if (deleteImageCheckboxes && deleteImageCheckboxes.length > 0) {
                        deleteImageCheckboxes.forEach((chk) => {
                            formData.append("deleteImageIds", chk.value);
                        });
                    }
                }

                const url = postId ? `/api/posts/${postId}/update` : "/api/posts";
                const method = "POST";

                const postResponse = await fetch(url, {
                    method: method,
                    body: formData
                });

                const postResult = await postResponse.json();
                const isSuccess = postResponse.ok && (postResult.success === true || postResult.status === "SUCCESS");

                if (isSuccess) {
                    alert(postId ? "게시글이 성공적으로 수정되었습니다." : "게시글이 성공적으로 등록되었습니다.");
                    window.location.href = postId ? `/detail?postId=${postId}` : "/main-post";
                } else {
                    alert("처리 실패: " + (postResult.message || "알 수 없는 오류"));
                    if (submitBtn) submitBtn.disabled = false;
                }

            } catch (error) {
                console.error("에러 발생:", error);
                alert("오류가 발생했습니다: " + error.message);
                if (submitBtn) submitBtn.disabled = false;
            }
        });
    }
});