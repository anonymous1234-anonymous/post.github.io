document.addEventListener("DOMContentLoaded", () => {
    const maxImageCount = 5;

    const uploader = document.querySelector(
        "[data-post-image-uploader]"
    );
    const imageInput = document.querySelector(
        "#new-post-image"
    );
    const emptyMessage = document.querySelector(
        "#post-image-empty"
    );
    const mainPreview = document.querySelector(
        "#post-main-preview"
    );
    const thumbnailList = document.querySelector(
        "#post-thumbnail-list"
    );
    const imageCount = document.querySelector(
        "#post-image-count"
    );

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

    function renderMainPreview(index) {
        if (selectedFiles.length === 0) {
            emptyMessage.hidden = false;
            mainPreview.hidden = true;
            mainPreview.removeAttribute("src");
            return;
        }

        currentImageIndex = index;

        const previewUrl = URL.createObjectURL(
            selectedFiles[index]
        );

        mainPreview.src = previewUrl;
        mainPreview.hidden = false;
        emptyMessage.hidden = true;

        mainPreview.onload = () => {
            URL.revokeObjectURL(previewUrl);
        };
    }

    function renderThumbnails() {
        thumbnailList.innerHTML = "";

        selectedFiles.forEach((file, index) => {
            const item = document.createElement("div");
            item.className = "zt-post-thumbnail-item";

            const button = document.createElement("button");

            button.type = "button";
            button.className = "zt-post-thumbnail";

            if (index === currentImageIndex) {
                button.classList.add("active");
            }

            const image = document.createElement("img");
            const thumbnailUrl = URL.createObjectURL(file);

            image.src = thumbnailUrl;
            image.alt = file.name;

            image.onload = () => {
                URL.revokeObjectURL(thumbnailUrl);
            };

            button.addEventListener("click", () => {
                renderMainPreview(index);
                renderThumbnails();
            });

            const removeButton =
                document.createElement("button");

            removeButton.type = "button";
            removeButton.className =
                "zt-post-thumbnail-remove";
            removeButton.setAttribute(
                "aria-label",
                "사진 삭제"
            );
            removeButton.textContent = "×";

            removeButton.addEventListener("click", () => {
                selectedFiles.splice(index,1);

                if(
                    currentImageIndex
                    >= selectedFiles.length
                ) {
                    currentImageIndex = Math.max(
                        0,
                        selectedFiles.length - 1
                    );
                } else if (index < currentImageIndex) {
                    currentImageIndex--;
                }

                updateImageInput();

                imageCount.textContent =
                    String(selectedFiles.length);

                renderMainPreview(currentImageIndex);
                renderThumbnails()
            });

            button.append(image);
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

    imageInput.addEventListener("change", () => {
        const newFiles = Array.from(imageInput.files);

        const imageFiles = newFiles.filter((file) => {
            return file.type === "image/jpeg"
                || file.type === "image/png";
        });

        if (imageFiles.length !== newFiles.length) {
            alert("JPG 또는 PNG 이미지만 선택할 수 있습니다.");
        }

        const remainingCount =
            maxImageCount - selectedFiles.length;

        if (imageFiles.length > remainingCount) {
            alert("이미지는 최대 5장까지 선택할 수 있습니다.");
        }

        const filesToAdd = imageFiles.slice(
            0,
            remainingCount
        );

        selectedFiles = [
            ...selectedFiles,
            ...filesToAdd
        ];

        updateImageInput();

        imageCount.textContent =
            String(selectedFiles.length);

        renderMainPreview(0);
        renderThumbnails();
    });
});