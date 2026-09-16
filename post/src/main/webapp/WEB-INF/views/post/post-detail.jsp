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
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/post-detail.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/common.css">
</head>
<body>
<div class="app">

  <header class="mobile-header">
    <a class="brand" href="${pageContext.request.contextPath}/home">
      <span>post</span>
    </a>
  </header>
  <nav class="mobile-nav" aria-label="모바일 메뉴">
    <a href="${pageContext.request.contextPath}/home" class="" aria-label="home"><i class="bi bi-house"></i></a>
    <a href="${pageContext.request.contextPath}/main-post" class="active" aria-label="이야기"><i class="bi bi-grid-3x3-gap"></i></a>
    <a href="${pageContext.request.contextPath}/new-post" class="" aria-label="new"><i class="bi bi-plus-square"></i></a>
  </nav>

  <div class="layout">

    <jsp:include page="/WEB-INF/views/components/sidebar.jsp">
      <jsp:param name="activePage" value="new-post" />
    </jsp:include>

    <main class="content">
      <article class="panel overflow-hidden">

        <div class="detail-title-area">
          <span class="detail-category">이야기</span>
          <h1 class="detail-title">
            <c:out value="${post.title}"/>
          </h1>
        </div>

        <div class="user-meta">
          <div class="detail-author-main">
            <strong>
              <c:out value="${empty post.writer ? '익명' : post.writer}"/>
            </strong>
          </div>
          <div class="detail-author-sub">
            <span><c:out value="${post.formattedCreateAt}"/></span>
            <span>조회수 <c:out value="${post.viewCount}" default="0"/></span>
          </div>
        </div>

        <%-- 수정 및 삭제 버튼 영역 --%>
        <div class="detail-owner-actions">
          <a class="btn btn-outline-secondary btn-sm" href="${pageContext.request.contextPath}/edit-post?postId=${post.postId}">수정</a>
          <form action="${pageContext.request.contextPath}/delete-post" method="post" onsubmit="return confirm('정말 삭제하시겠습니까?');" style="display:inline;">
            <input type="hidden" name="postId" value="${post.postId}">
            <button type="submit" class="btn btn-outline-danger btn-sm">삭제</button>
          </form>
        </div>

        <c:choose>
          <c:when test="${not empty post.images}">
            <div class="zt-detail-carousel" style="position: relative !important; width: 100%; height: 400px; background: #000; border-radius: 8px; overflow: hidden; margin-bottom: 1rem;">

              <div id="image-slider-container" style="position: relative; width: 100%; height: 100%;">
                <c:forEach var="image" items="${post.images}" varStatus="status">
                  <div class="slide-item"
                       style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; display: ${status.first ? 'flex' : 'none'}; align-items: center; justify-content: center; background: #000;"
                       data-index="${status.index}">

                    <c:set var="path" value="${image.uploadPath}" />
                    <c:set var="lowerPath" value="${fn:toLowerCase(path)}" />

                    <%-- ⭐ 스마트 경로 정규화 (DB에 전체경로가 있든 파일명만 있든 중복 슬래시 없이 완벽 매핑) --%>
                    <c:choose>
                      <c:when test="${fn:startsWith(path, '/') || fn:startsWith(path, 'http')}">
                        <c:set var="resolvedPath" value="${path}" />
                      </c:when>
                      <c:otherwise>
                        <c:set var="resolvedPath" value="/uploads/post/${path}" />
                      </c:otherwise>
                    </c:choose>

                    <%-- 파일 확장자에 따른 분기 처리 --%>
                    <c:choose>
                      <%-- 1. 이미지 파일인 경우 (.webp 포함) --%>
                      <c:when test="${fn:endsWith(lowerPath, '.jpg') || fn:endsWith(lowerPath, '.jpeg') || fn:endsWith(lowerPath, '.png') || fn:endsWith(lowerPath, '.gif') || fn:endsWith(lowerPath, '.webp')}">
                        <img src="${resolvedPath}"
                             alt="${image.originName}"
                             style="width: 100%; height: 100%; object-fit: contain;">
                      </c:when>

                      <%-- 2. 비디오 파일인 경우 (.webm 포함) --%>
                      <c:when test="${fn:endsWith(lowerPath, '.mp4') || fn:endsWith(lowerPath, '.webm') || fn:endsWith(lowerPath, '.mov') || fn:endsWith(lowerPath, '.avi')}">
                        <video src="${resolvedPath}"
                               controls
                               preload="metadata"
                               style="width: 100%; height: 100%; object-fit: contain;"></video>
                      </c:when>

                      <%-- 3. 오디오 파일인 경우 --%>
                      <c:when test="${fn:endsWith(lowerPath, '.mp3') || fn:endsWith(lowerPath, '.wav') || fn:endsWith(lowerPath, '.ogg') || fn:endsWith(lowerPath, '.m4a') || fn:endsWith(lowerPath, '.flac')}">
                        <div class="text-center text-white">
                            <i class="bi bi-file-earmark-music display-1 mb-3"></i>
                            <p><c:out value="${image.originName}"/></p>
                            <audio src="${resolvedPath}" controls class="w-75"></audio>
                        </div>
                      </c:when>

                      <%-- 4. 그 외 일반 파일 --%>
                      <c:otherwise>
                        <div class="text-center text-white">
                          <i class="bi bi-file-earmark-arrow-down display-1 mb-3"></i>
                          <p class="mb-3"><c:out value="${image.originName}"/></p>
                          <a href="${resolvedPath}" download class="btn btn-light btn-sm">
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
            <div class="text-center text-white p-5 bg-dark rounded">
              <p class="mb-0">등록된 파일이 없습니다.</p>
            </div>
          </c:otherwise>
        </c:choose>

      </article>
    </main>

  </div>
</div>

<script src="${pageContext.request.contextPath}/assets/js/post-detail.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/common.js"></script>
</body>
</html>