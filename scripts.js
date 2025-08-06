/*!
    * Start Bootstrap - Freelancer v7.0.7 (https://startbootstrap.com/theme/freelancer)
    * Copyright 2013-2023 Start Bootstrap
    * Licensed under MIT (https://github.com/StartBootstrap/startbootstrap-freelancer/blob/master/LICENSE)
    */
    // This script is adapted from the provided Bootstrap theme.

window.addEventListener('DOMContentLoaded', event => {

    // Navbar shrink function
    var navbarShrink = function () {
        const navbarCollapsible = document.body.querySelector('#mainNav');
        if (!navbarCollapsible) {
            return;
        }
        if (window.scrollY === 0) {
            navbarCollapsible.classList.remove('navbar-shrink')
        } else {
            navbarCollapsible.classList.add('navbar-shrink')
        }

    };

    // Shrink the navbar when page is loaded
    navbarShrink();

    // Shrink the navbar when page is scrolled
    document.addEventListener('scroll', navbarShrink);

    // Activate Bootstrap scrollspy on the main nav element
    const mainNav = document.body.querySelector('#mainNav');
    if (mainNav) {
        new bootstrap.ScrollSpy(document.body, {
            target: '#mainNav',
            rootMargin: '0px 0px -40%',
        });
    };

    // Collapse responsive navbar when toggler is visible
    const navbarToggler = document.body.querySelector('.navbar-toggler');
    const responsiveNavItems = [].slice.call(
        document.querySelectorAll('#navbarResponsive .nav-link')
    );
    responsiveNavItems.map(function (responsiveNavItem) {
        responsiveNavItem.addEventListener('click', () => {
            if (window.getComputedStyle(navbarToggler).display !== 'none') {
                navbarToggler.click();
            }
        });
    });

    // --- Added from your provided code ---
    // This is the function you had for redirection.
    // I've removed the search bar from the main HTML for a cleaner design.
    // If you still want it, you can add it back and use this function.
    function redirectToWebsite() {
        // This function is currently not used in the clean HTML,
        // but you can integrate it if you add a search input.
        const searchQuery = document.getElementById('lokendra-gaire-search').value.trim().toLowerCase();
        const keywords = ["Lokendra Gaire", "लोकेन्द्र गैरे"];
        if (keywords.includes(searchQuery)) {
            window.location.href = "https://lokendragaire.com.np"; // Corrected URL
        } else {
            alert("No matching result found. Try searching for 'Lokendra Gaire' or 'लोकेन्द्र गैरे'.");
        }
    }

});
