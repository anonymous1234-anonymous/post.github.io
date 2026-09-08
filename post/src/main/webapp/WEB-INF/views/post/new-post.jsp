<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="게시물 작성 페이지 / Post Creation Page">
  <title>새 게시물 / post | post</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
</head>
<body>
<div class="zt-app">

  <header class="zt-mobile-header">
    <a class="zt-brand" href="${pageContext.request.contextPath}/home">
      <span>post</span>
    </a>
  </header>
  <nav class="zt-mobile-nav" aria-label="모바일 메뉴">
    <a href="${pageContext.request.contextPath}/home" class="" aria-label="home"><i class="bi bi-house"></i></a>
    <a href="${pageContext.request.contextPath}/main-post" class="" aria-label="post"><i class="bi bi-grid-3x3-gap"></i></a>
    <a href="${pageContext.request.contextPath}/new-post" class="active" aria-label="new"><i class="bi bi-plus-square"></i></a>
    <a href="${pageContext.request.contextPath}/profile" class="" aria-label="profile"><i class="bi bi-person-circle"></i></a>
  </nav>

  <div class="zt-layout">

    <jsp:include page="/WEB-INF/views/components/sidebar.jsp">
      <jsp:param name="activePage" value="new-post" />
    </jsp:include>

    <main class="zt-content">

      <header class="zt-page-header">
        <h1>새 게시물 만들기</h1>
        <p>사진, 동영상, 오디오 및 파일들을 입력합니다.</p>
      </header>

      <section class="zt-panel zt-profile-card">
        <c:if test="${not empty errorMessage}">
          <div class="alert alert-danger" role="alert">
            <c:out value="${errorMessage}"/>
          </div>
        </c:if>
        <form class="row g-4"
              action="${pageContext.request.contextPath}/new-post"
              method="post"
              enctype="multipart/form-data"
              onsubmit="return validateAndBlock(event);">

          <div class="col-lg-6">
            <div class="zt-post-image-uploader" data-post-image-uploader>

              <div class="zt-post-main-preview position-relative" style="min-height: 250px; display: flex; align-items: center; justify-content: center; background: #f8f9fa; border-radius: 8px; overflow: hidden;">
                <div id="post-image-empty" class="zt-post-image-empty text-center p-4">
                  <i class="bi bi-folder-plus display-5"></i>
                  <strong>파일을 선택하세요</strong>
                  <p class="mb-0"><small>이미지, 동영상, 오디오 등 최대 10개까지 선택할 수 있습니다.</small></p>
                </div>

                <div id="dynamic-media-view" style="width: 100%; height: 100%; display: none; align-items: center; justify-content: center;"></div>

                <img id="post-main-preview"
                     class="zt-post-main-image"
                     src=""
                     alt="선택한 파일 미리보기"
                     hidden>

                <button type="button" id="post-prev-btn" class="zt-slider-btn zt-prev-btn" style="display: none; position: absolute; left: 10px; top: 50%; transform: translateY(-50%); z-index: 10;">〈</button>
                <button type="button" id="post-next-btn" class="zt-slider-btn zt-next-btn" style="display: none; position: absolute; right: 10px; top: 50%; transform: translateY(-50%); z-index: 10;">〉</button>
              </div>

              <div class="zt-post-thumbnail-row mt-2">
                <div id="post-thumbnail-list" class="zt-post-thumbnail-list"></div>

                <label class="zt-post-add-image" for="new-post-image">
                  <i class="bi bi-plus-lg"></i>
                  <span>파일</span>

                  <input id="new-post-image"
                         name="files"
                         type="file"
                         multiple
                         class="d-none">
                </label>
              </div>

              <p class="zt-post-image-count mt-2 text-center">
                <strong id="post-image-count">0</strong> / 10
              </p>

            </div>
          </div>

          <div class="col-lg-6">
            <div class="mb-3">
              <label class="form-label" for="post-title">제목</label>
              <input id="post-title" name="title" class="form-control" type="text" maxlength="60" placeholder="제목을 입력하세요" value="<c:out value='${post.title}'/>" required>
            </div>
            <div class="mb-3">
              <label class="form-label" for="post-place">장소 </label>
              <input id="post-place" name="place" class="form-control" type="text" placeholder="예: 서울 성수 " value="<c:out value='${post.place}'/>" required>
            </div>
            <div class="mb-3">
              <label class="form-label" for="post-content">내용</label>
              <textarea id="post-content"
                        name="content"
                        class="form-control"
                        rows="8"
                        placeholder="내용을 적어 주세요. (최소 10자 이상)"
                        required><c:out value="${post.content}"/></textarea>
            </div>

            <div class="mb-3">
              <label class="form-label" for="transport-cost">교통비</label>
              <input id="transport-cost"
                     name="transportCost"
                     class="form-control"
                     type="number"
                     min="0"
                     value="${empty post.transportCost ? 0 : post.transportCost}"
                     onfocus="if (this.value === '0') { this.value = ''; }"
                     onblur="if (this.value === '') { this.value = '0'; }"
                     required>
            </div>

            <div class="mb-3">
              <label class="form-label" for="food-cost">식비</label>
              <input id="food-cost"
                     name="foodCost"
                     class="form-control"
                     type="number"
                     min="0"
                     value="${empty post.foodCost ? 0 : post.foodCost}"
                     onfocus="if (this.value === '0') { this.value = ''; }"
                     onblur="if (this.value === '') { this.value = '0'; }"
                     required>
            </div>

            <div class="mb-3">
              <label class="form-label" for="other-cost">입장료 및 기타 비용</label>
              <input id="other-cost"
                     name="otherCost"
                     class="form-control"
                     type="number"
                     min="0"
                     value="${empty post.otherCost ? 0 : post.otherCost}"
                     onfocus="if (this.value === '0') { this.value = ''; }"
                     onblur="if (this.value === '') { this.value = '0'; }"
                     required>
            </div>

            <div class="mb-3">
              <label class="form-label" for="post-tags">태그</label>
              <input id="post-tags" class="form-control" type="text" placeholder="#여행 #가성비">
            </div>
            <div class="form-check form-switch mb-4">
              <input id="share-route" class="form-check-input" type="checkbox" checked>
              <label class="form-check-label" for="share-route"> 동선 공개</label>
            </div>
            <button class="btn btn-primary zt-primary-btn w-100 py-2" type="submit">작성 완료</button>
          </div>
        </form>
      </section>

    </main>

  </div>
</div>

<script>
  document.addEventListener("DOMContentLoaded", () => {
    const maxFileCount = 10;

    const uploader = document.querySelector("[data-post-image-uploader]");
    const imageInput = document.querySelector("#new-post-image");
    const emptyMessage = document.querySelector("#post-image-empty");
    const mainPreview = document.querySelector("#post-main-preview");
    const dynamicMediaView = document.querySelector("#dynamic-media-view");
    const thumbnailList = document.querySelector("#post-thumbnail-list");
    const imageCount = document.querySelector("#post-image-count");

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
        if (dynamicMediaView) {
          dynamicMediaView.style.display = "none";
          dynamicMediaView.innerHTML = "";
        }
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

      if (currentPreviewUrl) {
        URL.revokeObjectURL(currentPreviewUrl);
      }

      currentPreviewUrl = URL.createObjectURL(file);
      emptyMessage.style.display = "none";

      const fileNameLower = file.name.toLowerCase();
      const isVideo = file.type.startsWith("video/") || fileNameLower.endsWith(".webm") || fileNameLower.endsWith(".mp4") || fileNameLower.endsWith(".mov");
      const isImage = file.type.startsWith("image/") || fileNameLower.endsWith(".jpg") || fileNameLower.endsWith(".jpeg") || fileNameLower.endsWith(".png") || fileNameLower.endsWith(".gif");
      const isAudio = file.type.startsWith("audio/") || fileNameLower.endsWith(".mp3") || fileNameLower.endsWith(".wav");

      mainPreview.hidden = true;
      if (dynamicMediaView) {
        dynamicMediaView.style.display = "flex";

        if (isImage) {
          dynamicMediaView.innerHTML = `<img src="${currentPreviewUrl}" alt="${file.name}" style="max-width: 100%; max-height: 350px; object-fit: contain; border-radius: 8px;">`;
        } else if (isVideo) {
          dynamicMediaView.innerHTML = `<video src="${currentPreviewUrl}" controls preload="metadata" style="max-width: 100%; max-height: 350px; background: #000; border-radius: 8px;"></video>`;
          const videoElement = dynamicMediaView.querySelector("video");
          if (videoElement) {
            videoElement.currentTime = 0.1;
          }
        } else if (isAudio) {
          dynamicMediaView.innerHTML = `<div class="text-center p-3"><i class="bi bi-file-earmark-music display-4 mb-2"></i><p class="mb-2">${file.name}</p><audio src="${currentPreviewUrl}" controls class="w-100"></audio></div>`;
        } else {
          dynamicMediaView.innerHTML = `<div class="text-center p-3"><i class="bi bi-file-earmark-fill display-4 mb-2"></i><p class="mb-1"><strong>${file.name}</strong></p><small class="text-muted">파일이 정상적으로 등록되었습니다.</small></div>`;
        }
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

        const fileNameLower = file.name.toLowerCase();
        const isImage = file.type.startsWith("image/") || fileNameLower.endsWith(".jpg") || fileNameLower.endsWith(".jpeg") || fileNameLower.endsWith(".png") || fileNameLower.endsWith(".gif");
        const isVideo = file.type.startsWith("video/") || fileNameLower.endsWith(".webm") || fileNameLower.endsWith(".mp4") || fileNameLower.endsWith(".mov");

        if (isImage) {
          const image = document.createElement("img");
          image.src = URL.createObjectURL(file);
          image.alt = file.name;
          image.style.width = "60px";
          image.style.height = "60px";
          image.style.objectFit = "cover";
          image.style.borderRadius = "4px";
          button.append(image);
        } else {
          const iconDiv = document.createElement("div");
          iconDiv.className = "bg-secondary text-white d-flex align-items-center justify-content-center";
          iconDiv.style.width = "60px";
          iconDiv.style.height = "60px";
          iconDiv.style.borderRadius = "4px";

          if (isVideo) {
            iconDiv.innerHTML = '<i class="bi bi-file-earmark-play-fill fs-4"></i>';
          } else {
            iconDiv.innerHTML = '<i class="bi bi-file-earmark-fill fs-4"></i>';
          }
          button.append(iconDiv);
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

      // 🚫 보안상 차단할 확장자 목록 (.exe, .zip 등)
      const blockedExtensions = [".exe", ".zip", ".bat", ".cmd", ".sh", ".jar", ".msi", ".iso", ".dmg"];

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

  function getSanitizedText(str) {
    if (!str) return "";
    return str.toLowerCase()
            .replace(/@/g, "a")
            .replace(/[\s\p{P}\p{S}]/gu, "")
            .replace(/1/g, "i")
            .replace(/3/g, "e")
            .replace(/4/g, "a")
            .replace(/0/g, "o")
            .replace(/5/g, "s")
            .replace(/7/g, "t");
  }

  function validateAndBlock(e) {
    const titleInput = document.querySelector("#post-title");
    const contentInput = document.querySelector("#post-content");

    const title = titleInput ? titleInput.value.trim() : "";
    const content = contentInput ? contentInput.value.trim() : "";

    if (content === "" || content.length < 10) {
      alert("내용을 10자 이상 작성해주세요.");
      if (e) e.preventDefault();
      return false;
    }

    if (/^[ㄱ-ㅎㅏ-ㅣ\s]+$/.test(content)) {
      alert("자음이나 모음만으로는 작성할 수 없습니다.");
      if (e) e.preventDefault();
      return false;
    }

    const cleanContent = getSanitizedText(content);
    const cleanTitle = getSanitizedText(title);
    const badWords = [
      "시발", "씨발", "병신", "개새끼", "ㅅㅂ", "ㅂㅅ", "지랄", "꺼져",
      "fuck", "shit", "bitch", "asshole", "motherfucker", "bastard", "stfu"
    ];

    for (let word of badWords) {
      const cleanWord = getSanitizedText(word);
      if (cleanContent.includes(cleanWord) || cleanTitle.includes(cleanWord)) {
        alert("욕설, 비속어 또는 부적절한 내용은 올릴 수 없습니다.");
        if (e) e.preventDefault();
        return false;
      }
    }

    return true;
  }
</script>

<script src="${pageContext.request.contextPath}/assets/js/post-detail-carousel.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-preview.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-infinite-scroll.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
</body>
</html>