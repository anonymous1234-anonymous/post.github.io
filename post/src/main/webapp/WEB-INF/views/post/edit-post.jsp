<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="게시물 수정 페이지">
  <title>게시물 수정 | post</title>
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
    <a href="${pageContext.request.contextPath}/new-post" class="" aria-label="new"><i class="bi bi-plus-square"></i></a>
    <a href="${pageContext.request.contextPath}/profile" class="" aria-label="profile"><i class="bi bi-person-circle"></i></a>
  </nav>

  <div class="zt-layout">

    <jsp:include page="/WEB-INF/views/components/sidebar.jsp">
      <jsp:param name="activePage" value="new-post" />
    </jsp:include>

    <main class="zt-content">

      <header class="zt-page-header">
        <h1>게시글 수정</h1>
        <p>사진, 여행 동선, 경비와 태그를 수정합니다.</p>
      </header>

      <section class="zt-panel zt-profile-card">
        <form class="row g-4"
              action="${pageContext.request.contextPath}/edit-post"
              method="post"
              enctype="multipart/form-data">

          <input type="hidden" name="postId" value="${post.postId}">

          <!-- 이미지 관리 영역 (좌우 버튼 슬라이더 + 기존 이미지 삭제 + 새 사진 추가) -->
          <div class="col-lg-6">
            <div class="zt-post-image-uploader" data-post-image-uploader>

              <h2 class="h5 mb-3">등록된 사진 미리보기</h2>
              <div class="zt-post-main-preview position-relative">

                <c:choose>
                  <c:when test="${not empty post.images}">
                    <img id="post-main-preview"
                         class="zt-post-main-image"
                         src="${pageContext.request.contextPath}${post.images[0].uploadPath}"
                         alt="메인 이미지 미리보기"
                         style="width: 100%; height: 350px; object-fit: cover; border-radius: 8px;">
                  </c:when>
                  <c:otherwise>
                    <div id="post-image-empty" class="zt-post-image-empty" style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 350px; background: #f8f9fa; border-radius: 8px;">
                      <i class="bi bi-images display-5"></i>
                      <strong>등록된 사진이 없습니다</strong>
                    </div>
                    <img id="post-main-preview"
                         class="zt-post-main-image"
                         src=""
                         alt="선택한 사진 미리보기"
                         hidden>
                  </c:otherwise>
                </c:choose>

                <!-- 좌우 넘기기 버튼 (작성 페이지와 동일한 원형 스타일 적용) -->
                <button type="button" id="post-prev-btn" class="zt-slider-btn zt-prev-btn" style="display: none; position: absolute; left: 12px; top: 50%; transform: translateY(-50%); z-index: 10; width: 36px; height: 36px; border-radius: 50%; background: rgba(0, 0, 0, 0.5); color: white; border: none; align-items: center; justify-content: center; font-size: 16px; cursor: pointer;">❮</button>
                <button type="button" id="post-next-btn" class="zt-slider-btn zt-next-btn" style="display: none; position: absolute; right: 12px; top: 50%; transform: translateY(-50%); z-index: 10; width: 36px; height: 36px; border-radius: 50%; background: rgba(0, 0, 0, 0.5); color: white; border: none; align-items: center; justify-content: center; font-size: 16px; cursor: pointer;">❯</button>
              </div>

              <!-- 기존 등록된 사진들의 삭제 체크박스 리스트 -->
              <div class="mt-3">
                <p class="mb-2 text-muted small"><i class="bi bi-check2-square"></i> 삭제할 기존 사진을 선택하세요:</p>
                <div class="d-flex flex-wrap gap-2">
                  <c:forEach var="image" items="${post.images}" varStatus="status">
                    <div class="position-relative border p-1 rounded text-center" style="width: 70px;">
                      <img src="${pageContext.request.contextPath}${image.uploadPath}" alt="썸네일" style="width: 60px; height: 60px; object-fit: cover; border-radius: 4px;">
                      <div class="form-check d-flex justify-content-center mt-1">
                        <input class="form-check-input" type="checkbox" name="deleteImageIds" value="${image.uploadId}" id="del-${image.uploadId}">
                      </div>
                    </div>
                  </c:forEach>
                </div>
              </div>

              <!-- 새 사진 추가 영역 -->
              <div class="mt-4">
                <label class="form-label" for="edit-post-images">새 사진 추가</label>
                <input id="edit-post-images"
                       name="imageFiles"
                       class="form-control"
                       type="file"
                       accept="image/jpeg,image/png"
                       multiple>
                <small class="zt-muted d-block mt-2">기존 사진과 새 사진을 합쳐 최대 5장까지 등록할 수 있습니다.</small>
              </div>

            </div>
          </div>

          <!-- 게시글 입력 폼 영역 -->
          <div class="col-lg-6">
            <div class="mb-3">
              <label class="form-label" for="post-title">제목</label>
              <input id="post-title" name="title" class="form-control" type="text" maxlength="60" placeholder="여행 제목" value="${post.title}" required>
            </div>
            <div class="mb-3">
              <label class="form-label" for="post-place">여행 장소</label>
              <input id="post-place" name="place" class="form-control" type="text" placeholder="예: 서울 망원동" value="${post.place}" required>
            </div>
            <div class="mb-3">
              <label class="form-label" for="post-content">내용</label>
              <textarea id="post-content"
                        name="content"
                        class="form-control"
                        rows="8"
                        placeholder="여행 내용을 적어 주세요."
                        required>${post.content}</textarea>
            </div>

            <div class="mb-3">
              <label class="form-label" for="transport-cost">교통비</label>
              <input id="transport-cost"
                     name="transportCost"
                     class="form-control"
                     type="number"
                     min="0"
                     value="${post.transportCost}"
                     required>
            </div>

            <div class="mb-3">
              <label class="form-label" for="food-cost">식비</label>
              <input id="food-cost"
                     name="foodCost"
                     class="form-control"
                     type="number"
                     min="0"
                     value="${post.foodCost}"
                     required>
            </div>

            <div class="mb-3">
              <label class="form-label" for="other-cost">입장료 및 기타 비용</label>
              <input id="other-cost"
                     name="otherCost"
                     class="form-control"
                     type="number"
                     min="0"
                     value="${post.otherCost}"
                     required>
            </div>

            <div class="mb-3">
              <label class="form-label" for="post-tags">태그</label>
              <input id="post-tags" class="form-control" type="text" placeholder="#여행 #가성비여행">
            </div>
            <div class="form-check form-switch mb-4">
              <input id="share-route" class="form-check-input" type="checkbox" checked>
              <label class="form-check-label" for="share-route">동선 공개</label>
            </div>
            <button class="btn btn-primary zt-primary-btn w-100 py-2" type="submit">수정 완료</button>
          </div>
        </form>
      </section>

    </main>

  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/post-detail-carousel.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-edit-image.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-image-preview.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-infinite-scroll.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
</body>
</html>