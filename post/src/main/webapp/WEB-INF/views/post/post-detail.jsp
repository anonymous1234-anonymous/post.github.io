<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
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
      <span>post</span>
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
            <div class="zt-detail-carousel" style="position: relative !important; width: 100%; height: 400px; background: #000; border-radius: 8px; overflow: hidden; margin-bottom: 1rem;">

              <div id="image-slider-container" style="position: relative; width: 100%; height: 100%;">
                <c:forEach var="image" items="${post.images}" varStatus="status">
                  <div class="slide-item"
                       style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; display: ${status.first ? 'flex' : 'none'}; align-items: center; justify-content: center; background: #000;"
                       data-index="${status.index}">

                    <c:set var="path" value="${image.uploadPath}" />

                    <%-- 파일 확장자에 따른 분기 처리 --%>
                    <c:choose>
                      <%-- 1. 이미지 파일인 경우 --%>
                      <c:when test="${fn:endsWith(fn:toLowerCase(path), '.jpg') || fn:endsWith(fn:toLowerCase(path), '.jpeg') || fn:endsWith(fn:toLowerCase(path), '.png') || fn:endsWith(fn:toLowerCase(path), '.gif') || fn:endsWith(fn:toLowerCase(path), '.webp')}">
                        <img src="${pageContext.request.contextPath}${image.uploadPath}"
                             alt="${image.originName}"
                             style="width: 100%; height: 100%; object-fit: contain;">
                      </c:when>

                      <%-- 2. 비디오 파일인 경우 --%>
                      <c:when test="${fn:endsWith(fn:toLowerCase(path), '.mp4') || fn:endsWith(fn:toLowerCase(path), '.webm') || fn:endsWith(fn:toLowerCase(path), '.mov') || fn:endsWith(fn:toLowerCase(path), '.avi')}">
                        <video src="${pageContext.request.contextPath}${image.uploadPath}"
                               controls
                               style="width: 100%; height: 100%; object-fit: contain;"></video>
                      </c:when>

                      <%-- 3. 오디오 파일인 경우 --%>
                      <c:when test="${fn:endsWith(fn:toLowerCase(path), '.mp3') || fn:endsWith(fn:toLowerCase(path), '.wav') || fn:endsWith(fn:toLowerCase(path), '.ogg')}">
                        <div class="text-center text-white">
                          <i class="bi bi-file-earmark-music display-1 mb-3"></i>
                          <p><c:out value="${image.originName}"/></p>
                          <audio src="${pageContext.request.contextPath}${image.uploadPath}" controls class="w-75"></audio>
                        </div>
                      </c:when>

                      <%-- 4. 그 외 일반 파일 (ZIP, PDF 등)인 경우 --%>
                      <c:otherwise>
                        <div class="text-center text-white">
                          <i class="bi bi-file-earmark-arrow-down display-1 mb-3"></i>
                          <p class="mb-3"><c:out value="${image.originName}"/></p>
                          <a href="${pageContext.request.contextPath}${image.uploadPath}" download class="btn btn-light btn-sm">
                            <i class="bi bi-download"></i> 파일 다운로드
                          </a>
                        </div>
                      </c:otherwise>
                    </c:choose>

                  </div>
                </c:forEach>
              </div>

              <c:if test="${post.images.size() > 1}">
                <button type="button" onclick="moveSlide(-1)" aria-label="이전 파일"
                        style="position: absolute !important; left: 15px !important; top: 50% !important; transform: translateY(-50%) !important; z-index: 100 !important; width: 40px !important; height: 40px !important; border-radius: 50% !important; background: rgba(0, 0, 0, 0.6) !important; color: white !important; border: none !important; display: flex !important; align-items: center !important; justify-content: center !important; cursor: pointer !important; padding: 0 !important;">
                  <i class="bi bi-chevron-left" style="font-size: 1.2rem;"></i>
                </button>

                <button type="button" onclick="moveSlide(1)" aria-label="다음 파일"
                        style="position: absolute !important; right: 15px !important; top: 50% !important; transform: translateY(-50%) !important; z-index: 100 !important; width: 40px !important; height: 40px !important; border-radius: 50% !important; background: rgba(0, 0, 0, 0.6) !important; color: white !important; border: none !important; display: flex !important; align-items: center !important; justify-content: center !important; cursor: pointer !important; padding: 0 !important;">
                  <i class="bi bi-chevron-right" style="font-size: 1.2rem;"></i>
                </button>

                <div style="position: absolute !important; bottom: 15px !important; right: 15px !important; background: rgba(0, 0, 0, 0.6) !important; color: white !important; padding: 4px 12px !important; border-radius: 12px !important; font-size: 0.85rem !important; z-index: 100 !important;">
                  <span id="current-index">1</span> / <span>${post.images.size()}</span>
                </div>
              </c:if>

            </div>
          </c:when>
          <c:otherwise>
            <img class="rounded mb-3"
                 src="${pageContext.request.contextPath}/assets/images/c85e75481a9f216601e5c9593baf1854.jpg"
                 alt="등록된 파일이 없습니다"
                 style="width: 100%; height: 400px; object-fit: cover;">
          </c:otherwise>
        </c:choose>

      </article>
    </main>

  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/post-detail-carousel.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-preview.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-detail.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/post-infinite-scroll.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
</body>
</html>