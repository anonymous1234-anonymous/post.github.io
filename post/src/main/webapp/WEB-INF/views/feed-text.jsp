<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="텍스트 중심 여행 피드 상세 페이지">
  <title>여행 기록 상세 | 짠맛투어</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
  
</head>
<body>
<div class="zt-app">
  
<header class="zt-mobile-header">
  <a class="zt-brand" href="${pageContext.request.contextPath}/home">
    <span>짠맛투어</span>
  </a>
  <a href="${pageContext.request.contextPath}/login" class="fs-5" aria-label="로그인"><i class="bi bi-box-arrow-in-right"></i></a>
</header>
<nav class="zt-mobile-nav" aria-label="모바일 메뉴">
  <a href="${pageContext.request.contextPath}/home" class="active" aria-label="home"><i class="bi bi-house"></i></a>
<a href="${pageContext.request.contextPath}/my-travel" class="" aria-label="짠맛투어"><i class="bi bi-grid-3x3-gap"></i></a>
<a href="${pageContext.request.contextPath}/new-post" class="" aria-label="new"><i class="bi bi-plus-square"></i></a>
<a href="${pageContext.request.contextPath}/chat" class="" aria-label="chat"><i class="bi bi-chat-dots"></i></a>
<a href="${pageContext.request.contextPath}/profile" class="" aria-label="profile"><i class="bi bi-person-circle"></i></a>
</nav>

  <div class="zt-layout">
    
<jsp:include page="/WEB-INF/views/components/sidebar.jsp">
  <jsp:param name="activePage" value="home" />
</jsp:include>

    <main class="zt-content">
      
<header class="zt-page-header">
  <h1>여행 기록 상세</h1>
  <p>사진 없이 동선과 경비를 자세히 공유하는 게시물입니다.</p>
</header>

<article class="zt-panel zt-text-detail">
  <header class="d-flex align-items-center gap-3 mb-4">
    <img class="zt-avatar" src="${pageContext.request.contextPath}/assets/images/profile-ethan.svg" alt="travel_ethan 프로필">
    <div class="zt-user-meta">
      <strong>travel_ethan</strong>
      <span>2026년 7월 20일 · 서울</span>
    </div>
    <button class="zt-icon-btn fs-5 ms-auto"><i class="bi bi-three-dots"></i></button>
  </header>

  <div class="d-flex justify-content-between gap-3 mb-3">
    <h2 class="h4 fw-bold mb-0">서울 2만 원 하루 여행 코스</h2>
    <span class="zt-muted small">created_at</span>
  </div>

  <div class="zt-article-content">#서울여행 #가성비여행

오전 10시 홍대입구역에서 출발했습니다.

1. 경의선숲길 산책
2. 망원시장 점심
3. 한강공원 이동
4. 무료 전시 관람
5. 버스를 이용해 귀가

총경비
교통비 3,000원
점심 8,000원
간식 4,500원
기타 2,000원

총 17,500원을 사용했습니다. 이동 시간이 길지 않아 초보 혼행러도 따라가기 쉬운 코스였습니다.</div>

  <div class="zt-post-actions px-0 mt-2">
    <button class="zt-icon-btn" data-like-button><i class="bi bi-heart"></i></button>
    <a class="zt-icon-btn" href="${pageContext.request.contextPath}/post-detail#comments"><i class="bi bi-chat"></i></a>
    <button class="zt-icon-btn"><i class="bi bi-send"></i></button>
    <button class="zt-icon-btn zt-save-btn"><i class="bi bi-bookmark"></i></button>
  </div>
  <p class="fw-bold mb-1">좋아요 94개</p>
  <a class="zt-muted small" href="${pageContext.request.contextPath}/post-detail#comments">댓글 12개 보기</a>
</article>

    </main>

  </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>

</body>
</html>
