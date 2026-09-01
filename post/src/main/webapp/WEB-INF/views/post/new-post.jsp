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
        <p>사진, 동선, 경비와 태그를 입력합니다.</p>
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

          <!-- 이미지 업로더 영역 (화살표 버튼 및 카운터 포함) -->
          <div class="col-lg-6">
            <div class="zt-post-image-uploader" data-post-image-uploader>

              <div class="zt-post-main-preview position-relative">
                <div id="post-image-empty" class="zt-post-image-empty">
                  <i class="bi bi-images display-5"></i>
                  <strong>사진을 선택하세요</strong>
                  <small>JPG, PNG 파일을 최대 5장까지 선택할 수 있습니다.</small>
                </div>

                <img id="post-main-preview"
                     class="zt-post-main-image"
                     src=""
                     alt="선택한 사진 미리보기"
                     hidden>

                <!-- 좌우 넘기기 버튼 -->
                <button type="button" id="post-prev-btn" class="zt-slider-btn zt-prev-btn" style="display: none; position: absolute; left: 10px; top: 50%; transform: translateY(-50%); z-index: 10;">〈</button>
                <button type="button" id="post-next-btn" class="zt-slider-btn zt-next-btn" style="display: none; position: absolute; right: 10px; top: 50%; transform: translateY(-50%); z-index: 10;">〉</button>
              </div>

              <div class="zt-post-thumbnail-row mt-2">
                <div id="post-thumbnail-list" class="zt-post-thumbnail-list"></div>

                <label class="zt-post-add-image" for="new-post-image">
                  <i class="bi bi-plus-lg"></i>
                  <span>사진</span>

                  <input id="new-post-image"
                         name="imageFiles"
                         type="file"
                         accept="image/jpeg,image/png"
                         multiple
                         hidden>
                </label>
              </div>

              <!-- 현재 번호 / 총 개수 형식의 카운터 -->
              <p class="zt-post-image-count mt-2 text-center">
                <strong id="post-image-count">0</strong> / 5
              </p>

            </div>
          </div>

          <!-- 게시글 입력 폼 영역 -->
          <div class="col-lg-6">
            <div class="mb-3">
              <label class="form-label" for="post-title">제목</label>
              <input id="post-title" name="title" class="form-control" type="text" maxlength="60" placeholder="여행 제목을 입력하세요" value="<c:out value='${post.title}'/>" required>
            </div>
            <div class="mb-3">
              <label class="form-label" for="post-place">장소 </label>
              <input id="post-place" name="place" class="form-control" type="text" placeholder="예: 서울 망원동" value="<c:out value='${post.place}'/>" required>
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

<script src="${pageContext.request.contextPath}/js/common.js"></script>
 <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
 <script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<script>
  document.addEventListener("DOMContentLoaded", () => {
    const maxImageCount = 5;

    const uploader = document.querySelector("[data-post-image-uploader]");
    const imageInput = document.querySelector("#new-post-image");
    const emptyMessage = document.querySelector("#post-image-empty");
    const mainPreview = document.querySelector("#post-main-preview");
    const thumbnailList = document.querySelector("#post-thumbnail-list");
    const imageCount = document.querySelector("#post-image-count");

    const prevBtn = document.querySelector("#post-prev-btn");
    const nextBtn = document.querySelector("#post-next-btn");

    if (!uploader || !imageInput || !emptyMessage || !mainPreview || !thumbnailList || !imageCount) {
      return;
    }

    let selectedFiles = [];
    let currentImageIndex = 0;

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

      // '현재 번호 / 총 개수' 형식으로 갱신
      imageCount.textContent = `${currentImageIndex + 1} / ${selectedFiles.length}`;

      // 이미지가 2장 이상일 때만 좌우 버튼 표시
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

        const image = document.createElement("img");
        const thumbnailUrl = URL.createObjectURL(file);
        image.src = thumbnailUrl;
        image.alt = file.name;
        image.style.width = "60px";
        image.style.height = "60px";
        image.style.objectFit = "cover";
        image.style.borderRadius = "4px";

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

    // 왼쪽 화살표 클릭 이벤트
    if (prevBtn) {
      prevBtn.addEventListener("click", () => {
        if (selectedFiles.length <= 1) return;
        currentImageIndex = (currentImageIndex - 1 + selectedFiles.length) % selectedFiles.length;
        renderMainPreview(currentImageIndex);
        renderThumbnails();
      });
    }

    // 오른쪽 화살표 클릭 이벤트
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

      const imageFiles = newFiles.filter((file) => {
        return file.type === "image/jpeg" || file.type === "image/png";
      });

      if (imageFiles.length !== newFiles.length) {
        alert("JPG 또는 PNG 이미지만 선택할 수 있습니다.");
      }

      const remainingCount = maxImageCount - selectedFiles.length;

      if (imageFiles.length > remainingCount) {
        alert(`이미지는 최대 ${maxImageCount}장까지 선택할 수 있습니다.`);
      }

      const filesToAdd = imageFiles.slice(0, remainingCount);

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
</body>
</html>