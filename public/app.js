// ========================================
// بنسولتان - Main JavaScript
// ========================================

(function() {
  'use strict';

  // ========================================
  // DOM Elements
  // ========================================
  const header = document.getElementById('header');
  const navToggle = document.querySelector('.nav-toggle');
  const navMenu = document.getElementById('nav-menu');
  const navLinks = document.querySelectorAll('.nav-link');
  const contactForm = document.getElementById('contact-form');
  const formSuccess = document.getElementById('form-success');
  const resetFormBtn = document.getElementById('reset-form');
  const submitBtn = document.getElementById('submit-btn');
  const statNumbers = document.querySelectorAll('[data-count]');
  const milestoneNumbers = document.querySelectorAll('.milestone-number[data-count]');

  // ========================================
  // Header Scroll Effect
  // ========================================
  function handleHeaderScroll() {
    if (window.scrollY > 20) {
      header.classList.add('scrolled');
    } else {
      header.classList.remove('scrolled');
    }
  }

  window.addEventListener('scroll', handleHeaderScroll, { passive: true });
  handleHeaderScroll();

  // ========================================
  // Mobile Navigation Toggle
  // ========================================
  function toggleNavMenu() {
    const isExpanded = navToggle.getAttribute('aria-expanded') === 'true';
    navToggle.setAttribute('aria-expanded', !isExpanded);
    navMenu.classList.toggle('open');
    document.body.style.overflow = isExpanded ? '' : 'hidden';
  }

  navToggle.addEventListener('click', toggleNavMenu);

  // Close menu when clicking a link
  navLinks.forEach(link => {
    link.addEventListener('click', () => {
      if (navMenu.classList.contains('open')) {
        navToggle.setAttribute('aria-expanded', 'false');
        navMenu.classList.remove('open');
        document.body.style.overflow = '';
      }
    });
  });

  // Close menu on escape key
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && navMenu.classList.contains('open')) {
      navToggle.setAttribute('aria-expanded', 'false');
      navMenu.classList.remove('open');
      document.body.style.overflow = '';
      navToggle.focus();
    }
  });

  // ========================================
  // Smooth Scroll for Anchor Links
  // ========================================
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
      const targetId = this.getAttribute('href');
      if (targetId === '#') return;

      const target = document.querySelector(targetId);
      if (target) {
        e.preventDefault();
        const headerOffset = header.offsetHeight;
        const targetPosition = target.getBoundingClientRect().top + window.scrollY - headerOffset;

        window.scrollTo({
          top: targetPosition,
          behavior: 'smooth'
        });

        target.focus({ preventScroll: true });
      }
    });
  });

  // ========================================
  // Counter Animation (Intersection Observer)
  // ========================================
  function animateCounter(element, target) {
    const duration = 2000;
    const start = 0;
    const startTime = performance.now();

    function update(currentTime) {
      const elapsed = currentTime - startTime;
      const progress = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      const current = Math.floor(eased * (target - start) + start);
      element.textContent = current.toLocaleString('en-US');

      if (progress < 1) {
        requestAnimationFrame(update);
      } else {
        element.textContent = target.toLocaleString('en-US');
      }
    }

    requestAnimationFrame(update);
  }

  const counterObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        const target = parseInt(entry.target.dataset.count, 10);
        if (!isNaN(target)) {
          animateCounter(entry.target, target);
          counterObserver.unobserve(entry.target);
        }
      }
    });
  }, { threshold: 0.5, rootMargin: '0px 0px -50px 0px' });

  [...statNumbers, ...milestoneNumbers].forEach(el => counterObserver.observe(el));

  // ========================================
  // Form Validation & Submission
  // ========================================
  const validators = {
    name: (value) => value.trim().length >= 2 || 'الاسم يجب أن يكون حرفين على الأقل',
    email: (value) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value) || 'بريد إلكتروني غير صحيح',
    phone: (value) => !value || /^\+?[\d\s\-()]{8,}$/.test(value) || 'رقم هاتف غير صحيح',
    message: (value) => value.trim().length >= 20 || 'الرسالة يجب أن تكون 20 حرفاً على الأقل',
    privacy: (checked) => checked || 'يجب الموافقة على سياسة الخصوصية'
  };

  function showError(input, message) {
    const formGroup = input.closest('.form-group');
    const errorEl = formGroup.querySelector('.error-message');
    input.classList.add('error');
    input.setAttribute('aria-invalid', 'true');
    if (errorEl) errorEl.textContent = message;
  }

  function clearError(input) {
    const formGroup = input.closest('.form-group');
    const errorEl = formGroup.querySelector('.error-message');
    input.classList.remove('error');
    input.removeAttribute('aria-invalid');
    if (errorEl) errorEl.textContent = '';
  }

  function validateField(input) {
    const name = input.name;
    const validator = validators[name];
    if (!validator) return true;

    const value = input.type === 'checkbox' ? input.checked : input.value;
    const result = validator(value);

    if (result === true) {
      clearError(input);
      return true;
    } else {
      showError(input, result);
      return false;
    }
  }

  function validateForm() {
    const inputs = contactForm.querySelectorAll('input[required], select[required], textarea[required]');
    let isValid = true;

    inputs.forEach(input => {
      if (!validateField(input)) isValid = false;
    });

    return isValid;
  }

  // Real-time validation on blur
  contactForm.querySelectorAll('input, select, textarea').forEach(input => {
    input.addEventListener('blur', () => validateField(input));
    input.addEventListener('input', () => {
      if (input.classList.contains('error')) validateField(input);
    });
  });

  // Form submission
  contactForm.addEventListener('submit', async (e) => {
    e.preventDefault();

    if (!validateForm()) {
      const firstError = contactForm.querySelector('.error');
      if (firstError) firstError.focus();
      return;
    }

    // Show loading state
    submitBtn.disabled = true;
    submitBtn.classList.add('btn-loading');

    try {
      // Simulate API call
      await new Promise(resolve => setTimeout(resolve, 1500));

      // Success
      contactForm.hidden = true;
      formSuccess.hidden = false;
      formSuccess.focus();
    } catch (error) {
      // Error handling
      alert('حدث خطأ في الإرسال. يرجى المحاولة مرة أخرى أو التواصل عبر البريد الإلكتروني.');
    } finally {
      submitBtn.disabled = false;
      submitBtn.classList.remove('btn-loading');
    }
  });

  // Reset form
  resetFormBtn.addEventListener('click', () => {
    contactForm.reset();
    contactForm.hidden = false;
    formSuccess.hidden = true;
    contactForm.querySelectorAll('.error').forEach(el => {
      el.classList.remove('error');
      el.removeAttribute('aria-invalid');
    });
    contactForm.querySelectorAll('.error-message').forEach(el => el.textContent = '');
    contactForm.querySelector('input[name="name"]').focus();
  });

  // ========================================
  // Active Nav Link on Scroll
  // ========================================
  const sections = document.querySelectorAll('section[id]');
  const navLinkMap = {};

  navLinks.forEach(link => {
    const href = link.getAttribute('href');
    if (href && href !== '#') {
      const page = href.split('.html')[0] || 'index';
      navLinkMap[page] = link;
    }
  });

  function updateActiveNavLink() {
    const currentPage = window.location.pathname.split('/').pop().replace('.html', '') || 'index';
    navLinks.forEach(link => link.classList.remove('active'));

    const activeLink = navLinkMap[currentPage];
    if (activeLink) activeLink.classList.add('active');
  }

  updateActiveNavLink();

  // ========================================
  // Lazy Load Images (if any)
  // ========================================
  if ('loading' in HTMLImageElement.prototype) {
    document.querySelectorAll('img[loading="lazy"]').forEach(img => {
      img.loading = 'lazy';
    });
  } else {
    // Fallback for browsers without native lazy loading
    const lazyImages = document.querySelectorAll('img[data-src]');
    const imageObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;
          img.src = img.dataset.src;
          img.removeAttribute('data-src');
          imageObserver.unobserve(img);
        }
      });
    });

    lazyImages.forEach(img => imageObserver.observe(img));
  }

  // ========================================
  // Performance: Preload Critical Resources
  // ========================================
  function preloadCriticalResources() {
    const criticalPages = ['about.html', 'services.html', 'contact.html'];
    criticalPages.forEach(page => {
      const link = document.createElement('link');
      link.rel = 'prefetch';
      link.href = page;
      document.head.appendChild(link);
    });
  }

  // Prefetch on idle
  if ('requestIdleCallback' in window) {
    requestIdleCallback(preloadCriticalResources);
  } else {
    setTimeout(preloadCriticalResources, 2000);
  }

  // ========================================
  // Accessibility: Focus Visible Polyfill
  // ========================================
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Tab') {
      document.body.classList.add('keyboard-nav');
    }
  });

  document.addEventListener('mousedown', () => {
    document.body.classList.remove('keyboard-nav');
  });

  // ========================================
  // Console Branding
  // ========================================
  console.log('%cبنسولتان للتجارة الإلكترونية', 'font-size: 20px; font-weight: bold; color: #1e40af;');
  console.log('%cشريكك التجاري الموثوق في تونس', 'font-size: 14px; color: #64748b;');
  console.log('🌐 https://bensoltandecommerce.tn');
})();