<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="게시물 작성 페이지">
  <title>새 게시물 | post</title>
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
  <h1>게시글 수정</h1>
  <p>사진, 여행 동선, 경비와 태그를 입력합니다.</p>
</header>

<section class="zt-panel zt-profile-card">
  <form class="row g-4"
        action="${pageContext.request.contextPath}/edit-post"
        method="post"
        enctype="multipart/form-data">

    <input type="hidden" name="postId" value="${post.postId}">
  <div class="col-lg-6">
    <div class="zt-edit-image-section">
      <h2 class="h5 mb-3">등록된 사진</h2>

      <c:choose>
        <c:when test="${not empty post.images}">
          <div class="zt-edit-image-list">
            <c:forEach var="image"
                       items="${post.images}"
                       varStatus="status">
             <div class="zt-edit-image-item">
               <img src="${pageContext.request.contextPath}${image.uploadPath}"
                    alt="${image.originName}">

               <span class="zt-edit-image-order">
                 ${status.count}
               </span>

                <label class="zt-edit-image-delete">
                  <input type="checkbox"
                         name="deleteImageIds"
                         value="${image.uploadId}">
                  삭제
                </label>
              </div>
            </c:forEach>
          </div>
        </c:when>

        <c:otherwise>
          <p class="zt-muted">
             현재 등록된 사진이 없습니다.
          </p>
        </c:otherwise>
      </c:choose>

      <div class="mt-4">
        <label class="form-label"
               for="edit-post-images">
          새 사진 추가
        </label>

        <input id="edit-post-images"
               name="imageFiles"
               class="form-control"
               type="file"
               accept="image/jpeg,image/png"
               multiple>

        <small class="zt-muted d-block mt-2">
          기존 사진과 새 사진을 합쳐 최대 5장까지 등록할 수 있습니다.
        </small>

        <div class="zt-edit-new-images mt-3">
          <p class="mb-2">
            새로 선택한 사진
            <strong>
              <span id="edit-new-image-count">0</span>장
            </strong>
          </p>

          <div id="edit-new-image-preview"
               class="zt-edit-new-image-preview"></div>
        </div>
      </div>
    </div>
  </div>

    <div class="col-lg-6">
      <div class="mb-3">
        <label class="form-label" for="post-title">제목</label>
        <input id="post-title" name="title" class="form-control" type="text" maxlength="60" placeholder="여행 제목" value="${post.title}" required>
      </div>
      <div class="mb-3">
        <label class="form-label" for="post-place">여행 장소</label>
        <input id="post-place" name="place" class="form-control" type="text"
               placeholder="예: 서울 " value="${post.place}" required>
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
        <label class="form-label"
               for="transport-cost">
          교통비
        </label>

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
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-edit-image.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-image-preview.js"></script>

</body>
</html>