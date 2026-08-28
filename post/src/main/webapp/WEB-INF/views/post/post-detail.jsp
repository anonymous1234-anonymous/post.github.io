<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="여행 게시물 사진 상세 페이지">
  <title>피드 상세 | 짠맛투어</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/post-detail.css">
</head>
<body>
<div class="zt-app">

<header class="zt-mobile-header">
  <a class="zt-brand" href="${pageContext.request.contextPath}/home">
    <span>짠맛투어</span>
  </a>
</header>
<nav class="zt-mobile-nav" aria-label="모바일 메뉴">
  <a href="${pageContext.request.contextPath}/home" class="" aria-label="home"><i class="bi bi-house"></i></a>
  <a href="${pageContext.request.contextPath}/my-travel" class="active" aria-label="여행 이야기"><i class="bi bi-grid-3x3-gap"></i></a>
  <a href="${pageContext.request.contextPath}/new-post" class="" aria-label="new"><i class="bi bi-plus-square"></i></a>
  <a href="${pageContext.request.contextPath}/chat" class="" aria-label="chat"><i class="bi bi-chat-dots"></i></a>
  <a href="${pageContext.request.contextPath}/profile" class="" aria-label="profile"><i class="bi bi-person-circle"></i></a>
</nav>

  <div class="zt-layout">

<jsp:include page="/WEB-INF/views/components/sidebar.jsp">
  <jsp:param name="activePage" value="my-travel" />
</jsp:include>

    <main class="zt-content">
<article class="zt-panel overflow-hidden">

  <div class="zt-detail-title-area">
    <span class="zt-detail-category">여행 이야기</span>
    <h1 class="zt-detail-title">
      <c:out value="${post.title}"/>
    </h1>
  </div>

  <header class="zt-post-header zt-detail-author-header">
    <div class="zt-detail-author">
      <img class="zt-avatar"
           src="${pageContext.request.contextPath}/assets/images/c85e75481a9f216601e5c9593baf1854.jpg"
           alt="기본 프로필">

      <div class="zt-user-meta">
        <div class="zt-detail-author-main">
          <strong>
            <c:out value="${empty post.writer ? '익명' : post.writer}"/>
          </strong>
        </div>
        <div class="zt-detail-author-sub">
          <span><c:out value="${post.formattedCreateAt}"/></span>
          <span>조회수 <c:out value="${post.viewCount}" default="0"/></span>
        </div>
      </div>
    </div>

    <%-- 🚀 수정 및 삭제 버튼 영역 복원 --%>
    <div class="zt-detail-owner-actions">
      <a class="btn btn-outline-secondary btn-sm" href="${pageContext.request.contextPath}/edit-post?postId=${post.postId}">수정</a>
      <form action="${pageContext.request.contextPath}/delete-post" method="post" onsubmit="return confirm('정말 삭제하시겠습니까?');" style="display:inline;">
        <input type="hidden" name="postId" value="${post.postId}">
        <button type="submit" class="btn btn-outline-danger btn-sm">삭제</button>
      </form>
    </div>
  </header>

  <c:choose>
    <c:when test="${not empty post.images}">
      <div class="zt-detail-carousel" data-detail-carousel>
        <div class="zt-detail-slides">
          <c:forEach var="image" items="${post.images}" varStatus="status">
            <img class="zt-detail-image zt-detail-slide ${status.first ? 'is-active' : ''}"
                 src="${pageContext.request.contextPath}${image.uploadPath}"
                 alt="${image.originName}"
                 data-slide-index="${status.index}"
                 onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/c85e75481a9f216601e5c9593baf1854.jpg';">
          </c:forEach>
        </div>

        <c:if test="${post.images.size() > 1}">
          <button type="button" class="zt-detail-carousel-button zt-detail-carousel-prev" data-carousel-prev aria-label="이전 사진">
            <i class="bi bi-chevron-left"></i>
          </button>
          <button type="button" class="zt-detail-carousel-button zt-detail-carousel-next" data-carousel-next aria-label="다음 사진">
            <i class="bi bi-chevron-right"></i>
          </button>
          <div class="zt-detail-carousel-count">
            <span data-carousel-current>1</span> / <span data-carousel-total>${post.images.size()}</span>
          </div>
        </c:if>
      </div>
    </c:when>
    <c:otherwise>
      <img class="zt-detail-image"
           src="${pageContext.request.contextPath}/assets/images/c85e75481a9f216601e5c9593baf1854.jpg"
           alt="등록된 사진이 없습니다">
    </c:otherwise>
  </c:choose>

  <div class="zt-post-body mt-3">
    <p>
      <c:out value="${post.content}"/>
    </p>

    <div class="border rounded p-3 mb-3">
      <h2 class="h6 fw-bold mb-3">여행 경비</h2>
      <div class="d-flex justify-content-between mb-2">
        <span>교통비</span>
        <strong><fmt:formatNumber value="${empty post.transportCost ? 0 : post.transportCost}"/>원</strong>
      </div>
      <div class="d-flex justify-content-between mb-2">
        <span>식비</span>
        <strong><fmt:formatNumber value="${empty post.foodCost ? 0 : post.foodCost}"/>원</strong>
      </div>
      <div class="d-flex justify-content-between mb-2">
        <span>입장료 및 기타 비용</span>
        <strong><fmt:formatNumber value="${empty post.otherCost ? 0 : post.otherCost}"/>원</strong>
      </div>
    </div>

    <hr>

    <c:set var="totalCost" value="${(empty post.transportCost ? 0 : post.transportCost) + (empty post.foodCost ? 0 : post.foodCost) + (empty post.otherCost ? 0 : post.otherCost)}" />

    <div class="d-flex justify-content-between">
      <span class="fw-bold">총비용</span>
      <strong class="text-primary">
        <fmt:formatNumber value="${totalCost}"/>원
      </strong>
    </div>
  </div>
</article>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-detail.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-image-preview.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-detail-carousel.js"></script>

</body>
</html>