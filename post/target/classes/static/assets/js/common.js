document.addEventListener("DOMContentLoaded", () => {
  // 데모 폼 처리 (필요시 유지)
  document.querySelectorAll("[data-demo-form]").forEach((form) => {
    form.addEventListener("submit", (event) => {
      event.preventDefault();
      const message = form.dataset.message || "데모 화면이므로 실제 서버에는 저장되지 않습니다.";
      window.alert(message);

      const redirect = form.dataset.redirect;
      if (redirect) window.location.href = redirect;
    });
  });

  // 공통 파일 업로드 미리보기 기능 (존재하는 경우에만 작동)
  const uploadInput = document.querySelector("[data-upload-input]");
  const uploadPreview = document.querySelector("[data-upload-preview]");
  if (uploadInput && uploadPreview) {
    uploadInput.addEventListener("change", () => {
      const file = uploadInput.files?.[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = () => {
        uploadPreview.innerHTML = `<img src="${reader.result}" alt="업로드 미리보기" class="w-100 h-100 object-fit-cover rounded-3">`;
      };
      reader.readAsDataURL(file);
    });
  }
});

// HTML 특수문자 이스케이프 유틸 함수
function escapeHtml(value) {
  if (!value) return ''; // [안전장치 추가] 값이 없을 경우 빈 문자열 반환
  return value.replace(/[&<>"']/g, (character) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#039;"
  }[character]));
}

// ==========================================
// 상세 페이지 이미지 슬라이더 이동 전역 함수
// ==========================================
let currentSlideIndex = 0;

function moveSlide(direction) {
  const slides = document.querySelectorAll('.slide-item');
  if (slides.length === 0) return;

  // 현재 슬라이드 숨기기 (안전 처리)
  if (slides[currentSlideIndex]) {
    slides[currentSlideIndex].style.display = 'none';
  }

  // 다음 인덱스 계산 (순환 구조)
  currentSlideIndex = (currentSlideIndex + direction + slides.length) % slides.length;

  // 새로운 슬라이드 표시 (안전 처리)
  if (slides[currentSlideIndex]) {
    slides[currentSlideIndex].style.display = 'flex';
  }

  // 현재 카운트 텍스트 업데이트 (존재하는 경우)
  const currentIndexSpan = document.getElementById('current-index');
  if (currentIndexSpan) {
    currentIndexSpan.textContent = currentSlideIndex + 1;
  }
}