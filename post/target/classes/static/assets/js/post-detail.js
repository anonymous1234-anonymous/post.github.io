document.addEventListener("DOMContentLoaded", () => {
    const maxImageCount = 10;
    const CHUNK_SIZE = 1 * 1024 * 1024; // 1MB 단위로 청크 분할

    const uploader = document.querySelector("[data-post-image-uploader]");
    const imageInput = document.querySelector("#new-post-image");
    const emptyMessage = document.querySelector("#post-image-empty");
    const mainPreview = document.querySelector("#post-main-preview");
    const thumbnailList = document.querySelector("#post-thumbnail-list");
    const imageCount = document.querySelector("#post-image-count");

    const prevBtn = document.querySelector("#post-prev-btn");
    const nextBtn = document.querySelector("#post-next-btn");
    const postForm = document.querySelector("#post-form"); // 게시글 작성 form 태그 id

    if (
        !uploader
        || !imageInput
        || !emptyMessage
        || !mainPreview
        || !thumbnailList
        || !imageCount
    ) {
        return;
    }

    let selectedFiles = [];
    let currentImageIndex = 0;

    // 허용할 파일 형식 화이트리스트 (이미지 + 동영상/쇼츠)
    const allowedTypes = [
        "image/jpeg",
        "image/png",
        "image/gif",
        "image/webp",
        "video/mp4",
        "video/quicktime",
        "video/webm",
        "video/x-msvideo"
    ];

    function renderMainPreview(index) {
        if (selectedFiles.length === 0) {
            emptyMessage.style.display = "flex";
            mainPreview.hidden = true;
            mainPreview.removeAttribute("src");
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
        const previewUrl = URL.createObjectURL(file);

        mainPreview.src = previewUrl;
        mainPreview.hidden = false;
        emptyMessage.style.display = "none";

        imageCount.textContent = `${currentImageIndex + 1} / ${selectedFiles.length}`;

        if (prevBtn && nextBtn) {
            const hasMultiple = selectedFiles.length > 1;
            prevBtn.style.display = hasMultiple ? "block" : "none";
            nextBtn.style.display = hasMultiple ? "block" : "none";
        }

        mainPreview.onload = () => {
            URL.revokeObjectURL(previewUrl);
        };
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

            const thumbnailContent = document.createElement("div");
            thumbnailContent.style.width = "60px";
            thumbnailContent.style.height = "60px";
            thumbnailContent.style.borderRadius = "4px";
            thumbnailContent.style.overflow = "hidden";
            thumbnailContent.style.backgroundColor = "#000";
            thumbnailContent.style.display = "flex";
            thumbnailContent.style.alignItems = "center";
            thumbnailContent.style.justifyContent = "center";

            if (file.type.startsWith("video/")) {
                const video = document.createElement("video");
                video.src = URL.createObjectURL(file);
                video.style.width = "100%";
                video.style.height = "100%";
                video.style.objectFit = "cover";
                thumbnailContent.append(video);
            } else {
                const image = document.createElement("img");
                image.src = URL.createObjectURL(file);
                image.alt = file.name;
                image.style.width = "100%";
                image.style.height = "100%";
                image.style.objectFit = "cover";
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

        const validFiles = newFiles.filter((file) => {
            return allowedTypes.includes(file.type);
        });

        if (validFiles.length !== newFiles.length) {
            alert("지원하지 않는 형식의 파일이 포함되어 있습니다. (이미지 및 동영상/쇼츠 파일만 업로드 가능합니다)");
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

            try {
                const savedFileNames = [];

                for (const file of selectedFiles) {
                    const totalChunks = Math.ceil(file.size / CHUNK_SIZE);
                    let fileSavedName = null;

                    for (let chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
                        const start = chunkIndex * CHUNK_SIZE;
                        const end = Math.min(start + CHUNK_SIZE, file.size);
                        const chunk = file.slice(start, end);

                        const chunkFormData = new FormData();
                        chunkFormData.append("file", chunk);
                        chunkFormData.append("chunkIndex", chunkIndex);
                        chunkFormData.append("totalChunks", totalChunks);
                        chunkFormData.append("fileName", file.name);

                        const response = await fetch("/api/posts/upload-chunk", {
                            method: "POST",
                            body: chunkFormData
                        });

                        const result = await response.json();
                        if (!result.success) {
                            throw new Error(result.message || "청크 업로드 중 오류가 발생했습니다.");
                        }

                        if (result.data.completed) {
                            fileSavedName = result.data.savedFileName;
                        }
                    }

                    if (fileSavedName) {
                        savedFileNames.push(fileSavedName);
                    }
                }

                const formDataObj = new FormData(postForm);
                const postDto = {
                    title: formDataObj.get("title"),
                    content: formDataObj.get("content"),
                    writer: formDataObj.get("writer")
                };

                const finalPayload = new FormData();
                finalPayload.append("postDto", new Blob([JSON.stringify(postDto)], { type: "application/json" }));

                savedFileNames.forEach((name) => {
                    finalPayload.append("savedFileNames", name);
                });

                const postResponse = await fetch("/api/posts", {
                    method: "POST",
                    body: finalPayload
                });

                const postResult = await postResponse.json();
                if (postResult.success) {
                    alert("게시글이 성공적으로 등록되었습니다.");
                    window.location.href = "/main-post";
                } else {
                    alert("게시글 등록 실패: " + postResult.message);
                }

            } catch (error) {
                console.error("업로드 및 등록 중 에러 발생:", error);
                alert("오류가 발생했습니다: " + error.message);
            }
        });
    }
});