<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content=" 커뮤니티 메인 피드">
    <title>메인 피드 | post </title>
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
        <a href="${pageContext.request.contextPath}/main-post" class="" aria-label="post"><i class="bi bi-grid-3x3-gap"></i></a>
        <a href="${pageContext.request.contextPath}/new-post" class="" aria-label="new"><i class="bi bi-plus-square"></i></a>
    </nav>

    <div class="zt-layout">

        <jsp:include page="/WEB-INF/views/components/sidebar.jsp">
            <jsp:param name="activePage" value="home"/>
        </jsp:include>

        <main class="zt-content">
            <c:if test="${not empty message}">
                <script>
                    alert("${message}");
                </script>
            </c:if>

            <form class="input-group zt-search"
                  action="${pageContext.request.contextPath}/main-post"
                  method="get"
                  role="search">
                <span class="input-group-text bg-white">
                    <i class="bi bi-search"></i>
                </span>
                <input class="form-control bg-white"
                       type="search"
                       name="keyword"
                       placeholder="게시글 제목·내용 검색"
                       required>
                <button class="btn btn-outline-secondary" type="submit">
                    검색
                </button>
            </form>

            <c:forEach items="${latestPosts}" var="post">
                <article class="zt-panel zt-post">
                    <div class="zt-main-post-title-area">
                        <span class="zt-main-post-category">이야기</span>
                        <h2 class="zt-main-post-title">
                            <a href="${pageContext.request.contextPath}/post-detail?postId=${post.postId}">
                                <c:out value="${post.title}"/>
                            </a>
                        </h2>
                    </div>

                    <header class="zt-post-header zt-main-author-header">
                        <div class="zt-detail-author">
                            <c:choose>
                                <c:when test="${not empty post.authorProfile}">
                                    <img src="${pageContext.request.contextPath}${post.authorProfile}" alt="작성자 프로필">
                                </c:when>
                                <c:otherwise>
                                    <img class="zt-avatar"
                                         src="${pageContext.request.contextPath}/assets/images/1.jpg"
                                         alt="기본 프로필">
                                </c:otherwise>
                            </c:choose>

                            <div class="zt-user-meta">
                                <div class="zt-main-author-main">
                                    <strong>
                                        <c:out value="${post.authorNickname}" default="사용자"/>
                                    </strong>
                                </div>
                            </div>
                        </div>
                    </header>

                    <!-- 이미지 및 캐러셀 영역 -->
                    <div class="zt-post-body">
                        <c:choose>
                            <c:when test="${not empty post.images}">
                                <div class="zt-detail-carousel" data-detail-carousel>
                                    <a class="zt-detail-slides"
                                       href="${pageContext.request.contextPath}/post-detail?postId=${post.postId}">
                                        <c:forEach var="image" items="${post.images}" varStatus="status">
                                            <img class="zt-post-image zt-detail-slide ${status.first ? 'is-active' : ''}"
                                                 src="${pageContext.request.contextPath}${image.uploadPath}"
                                                 alt="${image.originName}"
                                                 data-slide-index="${status.index}"
                                                 onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/1.jpg'">
                                        </c:forEach>
                                    </a>

                                    <c:if test="${post.images.size() > 1}">
                                        <button type="button"
                                                class="zt-detail-carousel-button zt-detail-carousel-prev"
                                                data-carousel-prev
                                                aria-label="이전 사진">
                                            <i class="bi bi-chevron-left"></i>
                                        </button>

                                        <button type="button"
                                                class="zt-detail-carousel-button zt-detail-carousel-next"
                                                data-carousel-next
                                                aria-label="다음 사진">
                                            <i class="bi bi-chevron-right"></i>
                                        </button>

                                        <div class="zt-detail-carousel-count">
                                            <span data-carousel-current>1</span> /
                                            <span data-carousel-total>${post.images.size()}</span>
                                        </div>
                                    </c:if>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/post-detail?postId=${post.postId}">
                                    <img class="zt-post-image"
                                         src="${pageContext.request.contextPath}/assets/images/1.jpg"
                                         alt="기본 이미지">
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </article>
            </c:forEach>

            <!-- 상단 메인 자동/수동 슬라이드 영역 (3장의 실제 존재하는 이미지 사용) -->
            <section class="mb-5">
                <div id="mainAutoCarousel" class="carousel slide shadow-sm rounded overflow-hidden" data-bs-ride="carousel" data-bs-interval="4000">

                    <!-- 하단 인디케이터 (3개) -->
                    <div class="carousel-indicators">
                        <button type="button" data-bs-target="#mainAutoCarousel" data-bs-slide-to="0" class="active" aria-current="true" aria-label="Slide 1"></button>
                        <button type="button" data-bs-target="#mainAutoCarousel" data-bs-slide-to="1" aria-label="Slide 2"></button>
                        <button type="button" data-bs-target="#mainAutoCarousel" data-bs-slide-to="2" aria-label="Slide 3"></button>
                    </div>

                    <!-- 슬라이드 이미지 항목들 -->
                    <div class="carousel-inner" style="height: 380px;">

                        <!-- 1번 슬라이드 -->
                        <div class="carousel-item active h-100">
                            <img src="${pageContext.request.contextPath}/assets/images/1.jpg" class="d-block w-100 h-100" style="object-fit: cover;" alt="여행 이미지 1">
                            <div class="carousel-caption d-none d-md-block bg-dark bg-opacity-50 rounded p-2">
                                <h5 class="fw-bold">나만의 특별한 기록</h5>
                                <p class="mb-0">소중한 추억을 남겨보세요.</p>
                            </div>
                        </div>

                        <!-- 2번 슬라이드 -->
                        <div class="carousel-item h-100">
                            <img src="${pageContext.request.contextPath}/assets/images/2.jpg" class="d-block w-100 h-100" style="object-fit: cover;" alt="여행 이미지 2">
                            <div class="carousel-caption d-none d-md-block bg-dark bg-opacity-50 rounded p-2">
                                <h5 class="fw-bold">합리적인 여행 경비 관리</h5>
                                <p class="mb-0">교통비, 식비, 기타 비용을 한눈에 계산하세요.</p>
                            </div>
                        </div>

                        <!-- 3번 슬라이드 -->
                        <div class="carousel-item h-100">
                            <img src="${pageContext.request.contextPath}/assets/images/3.jpg" class="d-block w-100 h-100" style="object-fit: cover;" alt="여행 이미지 3">
                            <div class="carousel-caption d-none d-md-block bg-dark bg-opacity-50 rounded p-2">
                                <h5 class="fw-bold">다양한 이야기 둘러보기</h5>
                                <p class="mb-0">생생한 피드를 구경해 보세요.</p>
                            </div>
                        </div>

                    </div>

                    <!-- 좌측 이전 버튼 -->
                    <button class="carousel-control-prev" type="button" data-bs-target="#mainAutoCarousel" data-bs-slide="prev">
                        <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                        <span class="visually-hidden">이전</span>
                    </button>

                    <!-- 우측 다음 버튼 -->
                    <button class="carousel-control-next" type="button" data-bs-target="#mainAutoCarousel" data-bs-slide="next">
                        <span class="carousel-control-next-icon" aria-hidden="true"></span>
                        <span class="visually-hidden">다음</span>
                    </button>

                </div>
            </section>

        </main>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/follow.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-detail-carousel.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-like.js"></script>

</body>
</html>