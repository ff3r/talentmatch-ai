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

      if (hasError) return;

      const result = AuthService.authenticate(email, password);

      if (result.success) {
        const user = AuthService.getCurrentUser();
        const redirectMap = {
          'empresa': 'empresa/dashboard.html',
          'reclutador': 'reclutador/dashboard.html',
          'postulante': 'postulante/dashboard.html',
          'admin': 'admin/dashboard.html'
        };
        window.location.href = redirectMap[user.role];
      } else {
        passwordError.textContent = result.error;
      }
    });
  }
});