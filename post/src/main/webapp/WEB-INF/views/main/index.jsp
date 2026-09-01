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
        <a href="${pageContext.request.contextPath}/home" class="active" aria-label="home"><i
                class="bi bi-house"></i></a>
        <a href="${pageContext.request.contextPath}/main-post" class="" aria-label="post"><i
                class="bi bi-grid-3x3-gap"></i></a>
        <a href="${pageContext.request.contextPath}/new-post" class="" aria-label="new"><i
                class="bi bi-plus-square"></i></a>
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

                <button class="btn btn-outline-secondary"
                        type="submit">
                    검색
                </button>
            </form>

            <c:forEach items="${latestPosts}" var="post">
                <article class="zt-panel zt-post">

                    <div class="zt-main-post-title-area">
                        <span class="zt-main-post-category">
                            여행 이야기
                        </span>
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
                                    <img class="zt-avatar"
                                         src="${pageContext.request.contextPath}${post.authorProfile}"
                                         alt="작성자 프로필">
                                </c:when>
                                <c:otherwise>
                                    <img class="zt-avatar"
                                         src="${pageContext.request.contextPath}/assets/images/profile-ethan.svg"
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
                                                 onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/zzanmat-default.jpg';">
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
                                            <span data-carousel-current>1</span>
                                            /
                                            <span data-carousel-total>${post.images.size()}</span>
                                        </div>
                                    </c:if>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <a href="${pageContext.request.contextPath}/post-detail?postId=${post.postId}">
                                    <img class="zt-post-image"
                                         src="${pageContext.request.contextPath}/assets/images/z-default.jpg"
                                         alt="기본 이미지">
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </div>

                </article>
            </c:forEach>

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