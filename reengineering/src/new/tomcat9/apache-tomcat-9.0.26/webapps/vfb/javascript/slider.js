$(document).ready(function(){
    $('.img_slider').slick({
        adaptiveHeight: false,
        arrows: false,
        autoplay: true,
        autoplaySpeed: 3000,
        centerMode: true,
        cssEase: 'linear',
        dots: true,
        dotsClass: 'slick-dots',
        draggable: false,
        infinite: true,
        pauseOnHover: true,
        speed: 1800,
        variableWidth: true
    });
});