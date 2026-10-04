/**
 * TalentMatch AI - Punto de Entrada
 * Inicializa componentes y maneja la lógica del login
 * Fecha: 2026-10-01
 * Nota de migración: Este archivo se mantiene intacto en la migración a PHP/Laravel Blade.
 */

document.addEventListener('DOMContentLoaded', () => {
  const loginForm = document.getElementById('loginForm');
  const emailInput = document.getElementById('email');
  const passwordInput = document.getElementById('password');
  const emailError = document.getElementById('emailError');
  const passwordError = document.getElementById('passwordError');
  const togglePasswordBtn = document.querySelector('.tm-form__toggle-password');

  if (togglePasswordBtn) {
    togglePasswordBtn.addEventListener('click', () => {
      const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
      passwordInput.setAttribute('type', type);
      togglePasswordBtn.setAttribute('aria-label',
        type === 'password' ? 'Mostrar contraseña' : 'Ocultar contraseña'
      );
    });
  }

  if (loginForm) {
    loginForm.addEventListener('submit', (e) => {
      e.preventDefault();

      emailError.textContent = '';
      passwordError.textContent = '';

      const email = emailInput.value.trim();
      const password = passwordInput.value;

      let hasError = false;

      if (!email) {
        emailError.textContent = 'El correo electrónico es obligatorio';
        hasError = true;
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        emailError.textContent = 'Ingrese un correo electrónico válido';
        hasError = true;
      }

      if (!password) {
        passwordError.textContent = 'La contraseña es obligatoria';
        hasError = true;
      }

      const result = typeof AuthService !== 'undefined' ? AuthService.authenticate(email, password) : null;

      if (result && result.success) {
        const user = AuthService.getCurrentUser();
        const path = window.location.pathname.replace(/\\/g, '/');
        const isSubdir = path.includes('/auth/') ||
                         path.includes('/empresa/') ||
                         path.includes('/reclutador/') ||
                         path.includes('/postulante/') ||
                         path.includes('/admin/');
        const prefix = isSubdir ? '../' : '';
        const redirectMap = {
          'empresa': prefix + 'empresa/dashboard.html',
          'reclutador': prefix + 'reclutador/dashboard.html',
          'postulante': prefix + 'postulante/dashboard.html',
          'admin': prefix + 'admin/dashboard.html'
        };
        window.location.href = redirectMap[user.role] || (prefix + 'index.html');
      } else {
        passwordError.textContent = result ? result.error : 'Error al procesar solicitud';
      }
    });
  }
});