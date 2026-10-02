/**
 * TalentMatch AI - Módulo de Autenticación Simulada
 * Fecha: 2026-10-01
 * Nota de migración: Este archivo será eliminado en producción.
 * La autenticación se delegará al endpoint POST /api/auth/login del backend.
 */

const TM_CREDENTIALS = {
  "empresa@talentmatch.com": {
    password: "Empresa2026*",
    role: "empresa",
    name: "TechCorp Internacional S.A.",
    avatar: "TC",
    redirect: "empresa/dashboard.html"
  },
  "reclutador@talentmatch.com": {
    password: "Reclutador2026*",
    role: "reclutador",
    name: "Ana Patricia Martinez",
    avatar: "AM",
    redirect: "reclutador/dashboard.html"
  },
  "postulante@talentmatch.com": {
    password: "Postulante2026*",
    role: "postulante",
    name: "Carlos Eduardo Lopez",
    avatar: "CL",
    redirect: "postulante/dashboard.html"
  },
  "admin@talentmatch.com": {
    password: "Admin2026*",
    role: "admin",
    name: "Administrador del Sistema",
    avatar: "AS",
    redirect: "admin/dashboard.html"
  }
};

const AuthService = (() => {
  const SESSION_KEY = 'tm_session';

  function authenticate(email, password) {
    const user = TM_CREDENTIALS[email];

    if (!user || user.password !== password) {
      return { success: false, error: 'Credenciales inválidas' };
    }

    const session = {
      email: email,
      role: user.role,
      name: user.name,
      avatar: user.avatar,
      loginTimestamp: Date.now()
    };

    sessionStorage.setItem(SESSION_KEY, JSON.stringify(session));

    return { success: true, user: session };
  }

  function logout() {
    sessionStorage.removeItem(SESSION_KEY);
    window.location.href = 'auth/login.html';
  }

  function getCurrentUser() {
    const session = sessionStorage.getItem(SESSION_KEY);
    return session ? JSON.parse(session) : null;
  }

  function isAuthenticated() {
    return getCurrentUser() !== null;
  }

  function getUserRole() {
    const user = getCurrentUser();
    return user ? user.role : null;
  }

  return {
    authenticate,
    logout,
    getCurrentUser,
    isAuthenticated,
    getUserRole
  };
})();

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