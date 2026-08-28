document.addEventListener("DOMContentLoaded", () => {
    const carousels = document.querySelectorAll(
        "[data-detail-carousel]"
    );

    carousels.forEach((carousel) => {
        const slides = carousel.querySelectorAll(
            ".zt-detail-slide"
        );
        const prevButton = carousel.querySelector(
            "[data-carousel-prev]"
        );
        const nextButton = carousel.querySelector(
            "[data-carousel-next]"
        );
        const currentNumber = carousel.querySelector(
            "[data-carousel-current]"
        );

        if (slides.length <= 1) {
            return;
        }

        let currentIndex = 0;

        function updateButtons() {
            prevButton.classList.toggle(
                "is-hidden",
                currentIndex === 0
            );

            nextButton.classList.toggle(
                "is-hidden",
                currentIndex === slides.length - 1
            );
        }

        function showSlide(index) {
            if (index < 0 || index >= slides.length) {
                return;
            }

            slides[currentIndex].classList.remove("is-active");

            currentIndex = index;

            slides[currentIndex].classList.add("is-active");
            currentNumber.textContent = String(currentIndex + 1);

            updateButtons();
        }

        prevButton.addEventListener("click", () => {
            showSlide(currentIndex - 1);
        });

        nextButton.addEventListener("click", () => {
            showSlide(currentIndex + 1);
        });

        updateButtons();
    });
});