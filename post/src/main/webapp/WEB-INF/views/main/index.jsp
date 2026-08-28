<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!doctype html>
<html lang="ko">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="인스타그램 스타일 여행 커뮤니티 메인 피드">
    <title>메인 피드 | 짠맛투어</title>
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
        <a href="${pageContext.request.contextPath}/login" class="fs-5" aria-label="로그인"><i
                class="bi bi-box-arrow-in-right"></i></a>
    </header>
    <nav class="zt-mobile-nav" aria-label="모바일 메뉴">
        <a href="${pageContext.request.contextPath}/home" class="active" aria-label="home"><i
                class="bi bi-house"></i></a>
        <a href="${pageContext.request.contextPath}/my-travel" class="" aria-label="짠맛투어"><i
                class="bi bi-grid-3x3-gap"></i></a>
        <a href="${pageContext.request.contextPath}/new-post" class="" aria-label="new"><i
                class="bi bi-plus-square"></i></a>
        <a href="${pageContext.request.contextPath}/chat" class="" aria-label="chat"><i class="bi bi-chat-dots"></i></a>
        <a href="${pageContext.request.contextPath}/profile" class="" aria-label="profile"><i
                class="bi bi-person-circle"></i></a>
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
                  action="${pageContext.request.contextPath}/my-travel"
                  method="get"
                  role="seach">

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
                                        <c:out value="${post.authorNickname}"
                                               default="알 수 없는 사용자"/>
                                    </strong>

                                        <%-- 로그인 상태이며 자신의 게시글이 아닌 경우 --%>
                                    <c:if test="${not post.authorDeleted
                                              and not empty sessionScope.loginMember
                                              and sessionScope.loginMember.id ne post.userId}">

                                        <button type="button"
                                                class="zt-follow-button btn btn-link btn-sm p-0 text-decoration-none ${post.following ? 'is-following' : ''}"
                                                data-follow-button
                                                data-logged-in="true"
                                                data-context-path="${pageContext.request.contextPath}"
                                                data-following-id="${post.userId}"
                                                data-following="${post.following}">

                                            <c:choose>
                                                <c:when test="${post.following}">
                                                    팔로잉
                                                </c:when>

                                                <c:otherwise>
                                                    팔로우
                                                </c:otherwise>
                                            </c:choose>
                                        </button>
                                    </c:if>

                                        <%-- 비로그인 상태인 경우 --%>
                                    <c:if test="${not post.authorDeleted and empty sessionScope.loginMember}">
                                        <button type="button"
                                                class="zt-follow-button btn btn-link btn-sm p-0 text-decoration-none"
                                                data-follow-button
                                                data-logged-in="false"
                                                data-context-path="${pageContext.request.contextPath}"
                                                data-following-id="${post.userId}"
                                                data-following="false">
                                            팔로우
                                        </button>
                                    </c:if>
                                </div>

                                <div class="zt-main-author-sub">
        <span>
          <c:out value="${post.formattedCreateAt}"/>
        </span>

                                    <span>
          조회수
          <c:out value="${post.viewCount}" default="0"/>
        </span>
                                </div>
                            </div>
                        </div>
                    </header>

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
                                     src="${pageContext.request.contextPath}/assets/images/zzanmat-default.jpg"
                                     alt="기본 여행 이미지">
                            </a>
                        </c:otherwise>
                    </c:choose>

                    <div class="zt-post-actions">

                        <form class="zt-main-like-form zt-main-stat"
                              action="${pageContext.request.contextPath}/post-like"
                              method="post">

                            <input type="hidden"
                                   name="postId"
                                   value="${post.postId}">

                            <button type="submit"
                                    class="zt-icon-btn"
                                    aria-label="좋아요">

                                <c:choose>
                                    <c:when test="${post.liked}">
                                        <i class="bi bi-heart-fill text-danger"
                                           data-like-icon></i>
                                    </c:when>

                                    <c:otherwise>
                                        <i class="bi bi-heart"
                                           data-like-icon></i>
                                    </c:otherwise>
                                </c:choose>

                            </button>

                            <span data-like-count>
        <c:out value="${post.likeCount}"/>
    </span>

                        </form>

                        <a class="zt-icon-btn zt-main-stat"
                           href="${pageContext.request.contextPath}/post-detail?postId=${post.postId}#comments"
                           aria-label="댓글">

                            <i class="bi bi-chat"></i>

                            <span>
        <c:out value="${post.commentCount}"/>
    </span>
                        </a>

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