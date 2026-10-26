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
    redirect: "../empresa/dashboard.html"
  },
  "reclutador@talentmatch.com": {
    password: "Reclutador2026*",
    role: "reclutador",
    name: "Ana Patricia Martinez",
    avatar: "AM",
    redirect: "../reclutador/dashboard.html"
  },
  "postulante@talentmatch.com": {
    password: "Postulante2026*",
    role: "postulante",
    name: "Carlos Eduardo Lopez",
    avatar: "CL",
    redirect: "../postulante/dashboard.html"
  },
  "admin@talentmatch.com": {
    password: "Admin2026*",
    role: "admin",
    name: "Administrador del Sistema",
    avatar: "AS",
    redirect: "../admin/dashboard.html"
  }
};

const AuthService = (() => {
  const SESSION_KEY = 'tm_session';

  async function authenticate(email, password) {
    // 1. Intentar autenticación contra backend MySQL (POST /api/auth/login.php)
    try {
      if (typeof ApiClient !== 'undefined') {
        const response = await ApiClient.login(email, password);
        if (response && response.success && response.data) {
          const u = response.data.user;
          const roleName = (u.rol_nombre || '').toLowerCase();
          const initials = (u.nombre_completo || 'TM')
            .split(' ')
            .filter(Boolean)
            .map(n => n[0])
            .join('')
            .substring(0, 2)
            .toUpperCase();

          const session = {
            id_usuario: u.id_usuario,
            email: u.email,
            role: roleName,
            name: u.nombre_completo,
            avatar: initials,
            loginTimestamp: Date.now(),
            profile: response.data.profile
          };

          sessionStorage.setItem(SESSION_KEY, JSON.stringify(session));
          return { success: true, user: session, redirect: response.data.redirect };
        } else if (response && response.message) {
          return { success: false, error: response.message };
        }
      }
    } catch (err) {
      console.warn('Conexión backend no disponible, utilizando fallback local:', err);
    }

    // 2. Fallback local para entorno estático / GitHub Pages
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

    return { success: true, user: session, redirect: user.redirect };
  }

  function logout() {
    sessionStorage.removeItem(SESSION_KEY);
    window.location.href = '../auth/login.html';
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

if (typeof window !== 'undefined') {
  window.logout = AuthService.logout;
}

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
    loginForm.addEventListener('submit', async (e) => {
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

      // Deshabilitar botón temporalmente para prevenir doble envío
      const submitBtn = loginForm.querySelector('button[type="submit"]');
      if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.textContent = 'Validando acceso...';
      }

      try {
        const result = await AuthService.authenticate(email, password);

        if (result.success) {
          const user = AuthService.getCurrentUser();
          const redirectMap = {
            'empresa': '../empresa/dashboard.html',
            'reclutador': '../reclutador/dashboard.html',
            'postulante': '../postulante/dashboard.html',
            'admin': '../admin/dashboard.html'
          };
          window.location.href = result.redirect ? ('../' + result.redirect.replace(/^\.\.\//, '')) : redirectMap[user.role];
        } else {
          passwordError.textContent = result.error;
        }
      } catch (err) {
        passwordError.textContent = 'Error al comunicarse con el servidor';
      } finally {
        if (submitBtn) {
          submitBtn.disabled = false;
          submitBtn.textContent = 'Iniciar Sesión';
        }
      }
    });
  }
});