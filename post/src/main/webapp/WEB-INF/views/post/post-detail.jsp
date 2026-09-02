<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="게시물 상세 페이지">
  <title>피드 상세 | post</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/post-detail.css">
</head>
<body>
<div class="zt-app">

<header class="zt-mobile-header">
  <a class="zt-brand" href="${pageContext.request.contextPath}/home">
    <span> post</span>
  </a>
</header>
<nav class="zt-mobile-nav" aria-label="모바일 메뉴">
  <a href="${pageContext.request.contextPath}/home" class="" aria-label="home"><i class="bi bi-house"></i></a>
  <a href="${pageContext.request.contextPath}/main-post" class="active" aria-label="이야기"><i class="bi bi-grid-3x3-gap"></i></a>
  <a href="${pageContext.request.contextPath}/new-post" class="" aria-label="new"><i class="bi bi-plus-square"></i></a>
</nav>

  <div class="zt-layout">

<jsp:include page="/WEB-INF/views/components/sidebar.jsp">
  <jsp:param name="activePage" value="my-travel" />
</jsp:include>

    <main class="zt-content">
<article class="zt-panel overflow-hidden">

  <div class="zt-detail-title-area">
    <span class="zt-detail-category">이야기</span>
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

    <%-- 수정 및 삭제 버튼 영역 --%>
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
      <!-- 캐러셀 메인 박스 -->
      <div class="zt-detail-carousel" style="position: relative !important; width: 100%; height: 400px; background: #000; border-radius: 8px; overflow: hidden; margin-bottom: 1rem;">

        <!-- 이미지 목록 -->
        <div id="image-slider-container" style="position: relative; width: 100%; height: 100%;">
          <c:forEach var="image" items="${post.images}" varStatus="status">
            <img class="slide-item"
                 src="${pageContext.request.contextPath}${image.uploadPath}"
                 alt="${image.originName}"
                 style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; object-fit: contain; display: ${status.first ? 'block' : 'none'};"
                 data-index="${status.index}">
          </c:forEach>
        </div>

        <!-- 2장 이상일 때만 좌우 버튼 및 카운트 표시 -->
        <c:if test="${post.images.size() > 1}">
          <!-- 왼쪽 이전 버튼 -->
          <button type="button" onclick="moveSlide(-1)" aria-label="이전 사진"
                  style="position: absolute !important; left: 15px !important; top: 50% !important; transform: translateY(-50%) !important; z-index: 100 !important; width: 40px !important; height: 40px !important; border-radius: 50% !important; background: rgba(0, 0, 0, 0.6) !important; color: white !important; border: none !important; display: flex !important; align-items: center !important; justify-content: center !important; cursor: pointer !important; padding: 0 !important;">
            <i class="bi bi-chevron-left" style="font-size: 1.2rem;"></i>
          </button>

          <!-- 오른쪽 다음 버튼 -->
          <button type="button" onclick="moveSlide(1)" aria-label="다음 사진"
                  style="position: absolute !important; right: 15px !important; top: 50% !important; transform: translateY(-50%) !important; z-index: 100 !important; width: 40px !important; height: 40px !important; border-radius: 50% !important; background: rgba(0, 0, 0, 0.6) !important; color: white !important; border: none !important; display: flex !important; align-items: center !important; justify-content: center !important; cursor: pointer !important; padding: 0 !important;">
            <i class="bi bi-chevron-right" style="font-size: 1.2rem;"></i>
          </button>

          <!-- 현재 번호 / 총 개수 -->
          <div style="position: absolute !important; bottom: 15px !important; right: 15px !important; background: rgba(0, 0, 0, 0.6) !important; color: white !important; padding: 4px 12px !important; border-radius: 12px !important; font-size: 0.85rem !important; z-index: 100 !important;">
            <span id="current-index">1</span> / <span>${post.images.size()}</span>
          </div>
        </c:if>

      </div>

      <!-- 1장씩 넘기기 제어 스크립트 -->
      <c:if test="${post.images.size() > 1}">
        <script>
          if (typeof window.moveSlide === 'undefined') {
              let currentIndex = 0;
              const slides = document.querySelectorAll('.slide-item');
              const totalSlides = slides.length;
              const currentIndexSpan = document.getElementById('current-index');

              window.moveSlide = function(direction) {
                  if (totalSlides === 0) return;

                  slides[currentIndex].style.display = 'none';
                  currentIndex = (currentIndex + direction + totalSlides) % totalSlides;
                  slides[currentIndex].style.display = 'block';

                  if (currentIndexSpan) {
                      currentIndexSpan.textContent = currentIndex + 1;
                  }
              };
          }
        </script>
      </c:if>

    </c:when>
    <c:otherwise>
      <img class="rounded mb-3"
           src="${pageContext.request.contextPath}/assets/images/c85e75481a9f216601e5c9593baf1854.jpg"
           alt="등록된 사진이 없습니다"
           style="width: 100%; height: 400px; object-fit: cover;">
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

<!-- 스크립트 영역 -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
</body>
</html>