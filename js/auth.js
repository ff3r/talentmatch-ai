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

  function getRelativePrefix() {
    const path = window.location.pathname.replace(/\\/g, '/');
    const isSubdir = path.includes('/auth/') ||
                     path.includes('/empresa/') ||
                     path.includes('/reclutador/') ||
                     path.includes('/postulante/') ||
                     path.includes('/admin/');
    return isSubdir ? '../' : '';
  }

  function logout() {
    sessionStorage.removeItem(SESSION_KEY);
    const prefix = getRelativePrefix();
    window.location.href = prefix + 'auth/login.html';
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
    getUserRole,
    getRelativePrefix
  };
})();

// Compatibilidad global para botones con onclick="logout()"
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

  if (togglePasswordBtn && passwordInput) {
    togglePasswordBtn.addEventListener('click', () => {
      const type = passwordInput.getAttribute('type') === 'password' ? 'text' : 'password';
      passwordInput.setAttribute('type', type);
      togglePasswordBtn.setAttribute('aria-label',
        type === 'password' ? 'Mostrar contraseña' : 'Ocultar contraseña'
      );
    });
  }

  // Botones de Acceso Rápido Demo (1-Click)
  const quickLoginBtns = document.querySelectorAll('.tm-quick-login-btn');
  if (quickLoginBtns.length > 0) {
    const demoCreds = {
      'empresa': { email: 'empresa@talentmatch.com', pass: 'Empresa2026*' },
      'reclutador': { email: 'reclutador@talentmatch.com', pass: 'Reclutador2026*' },
      'postulante': { email: 'postulante@talentmatch.com', pass: 'Postulante2026*' },
      'admin': { email: 'admin@talentmatch.com', pass: 'Admin2026*' }
    };

    quickLoginBtns.forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.preventDefault();
        const role = btn.getAttribute('data-role');
        const cred = demoCreds[role];
        if (cred && emailInput && passwordInput) {
          emailInput.value = cred.email;
          passwordInput.value = cred.pass;
          if (emailError) emailError.textContent = '';
          if (passwordError) passwordError.textContent = '';
          
          quickLoginBtns.forEach(b => {
            b.classList.remove('tm-btn--primary');
            b.classList.add('tm-btn--ghost');
          });
          btn.classList.remove('tm-btn--ghost');
          btn.classList.add('tm-btn--primary');
        }
      });
    });
  }

  if (loginForm) {
    loginForm.addEventListener('submit', (e) => {
      e.preventDefault();

      if (emailError) emailError.textContent = '';
      if (passwordError) passwordError.textContent = '';

      const email = emailInput ? emailInput.value.trim() : '';
      const password = passwordInput ? passwordInput.value : '';

      let hasError = false;

      if (!email) {
        if (emailError) emailError.textContent = 'El correo electrónico es obligatorio';
        hasError = true;
      } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        if (emailError) emailError.textContent = 'Ingrese un correo electrónico válido';
        hasError = true;
      }

      if (!password) {
        if (passwordError) passwordError.textContent = 'La contraseña es obligatoria';
        hasError = true;
      }

      if (hasError) return;

      const result = AuthService.authenticate(email, password);

      if (result.success) {
        const user = AuthService.getCurrentUser();
        const prefix = AuthService.getRelativePrefix();
        const redirectMap = {
          'empresa': prefix + 'empresa/dashboard.html',
          'reclutador': prefix + 'reclutador/dashboard.html',
          'postulante': prefix + 'postulante/dashboard.html',
          'admin': prefix + 'admin/dashboard.html'
        };
        window.location.href = redirectMap[user.role] || (prefix + 'index.html');
      } else {
        if (passwordError) passwordError.textContent = result.error;
      }
    });
  }

  // Registro de Empresa
  const registerCompanyForm = document.getElementById('registerCompanyForm');
  if (registerCompanyForm) {
    registerCompanyForm.addEventListener('submit', (e) => {
      e.preventDefault();
      const companyName = document.getElementById('companyName')?.value.trim();
      const companyRuc = document.getElementById('companyRuc')?.value.trim();
      const companyEmail = document.getElementById('companyEmail')?.value.trim();
      const companyPassword = document.getElementById('companyPassword')?.value;

      let valid = true;
      const nameErr = document.getElementById('companyNameError');
      const rucErr = document.getElementById('companyRucError');
      const emailErr = document.getElementById('companyEmailError');
      const passErr = document.getElementById('passwordError');

      if (nameErr) nameErr.textContent = '';
      if (rucErr) rucErr.textContent = '';
      if (emailErr) emailErr.textContent = '';
      if (passErr) passErr.textContent = '';

      if (!companyName) {
        if (nameErr) nameErr.textContent = 'Ingrese el nombre de la empresa';
        valid = false;
      }
      if (!companyRuc) {
        if (rucErr) rucErr.textContent = 'Ingrese el RUC / NIT';
        valid = false;
      }
      if (!companyEmail) {
        if (emailErr) emailErr.textContent = 'Ingrese el correo corporativo';
        valid = false;
      }
      if (!companyPassword) {
        if (passErr) passErr.textContent = 'Ingrese una contraseña';
        valid = false;
      }

      if (!valid) return;

      const initials = companyName.substring(0, 2).toUpperCase() || 'TC';
      const session = {
        email: companyEmail,
        role: 'empresa',
        name: companyName,
        avatar: initials,
        loginTimestamp: Date.now()
      };
      sessionStorage.setItem('tm_session', JSON.stringify(session));
      const prefix = AuthService.getRelativePrefix();
      window.location.href = prefix + 'empresa/dashboard.html';
    });
  }

  // Registro de Postulante
  const registerCandidateForm = document.getElementById('registerCandidateForm');
  if (registerCandidateForm) {
    registerCandidateForm.addEventListener('submit', (e) => {
      e.preventDefault();
      const fullName = document.getElementById('fullName')?.value.trim();
      const interestArea = document.getElementById('interestArea')?.value;
      const email = document.getElementById('email')?.value.trim();
      const password = document.getElementById('password')?.value;

      let valid = true;
      const nameErr = document.getElementById('fullNameError');
      const areaErr = document.getElementById('interestAreaError');
      const emailErr = document.getElementById('emailError');
      const passErr = document.getElementById('passwordError');

      if (nameErr) nameErr.textContent = '';
      if (areaErr) areaErr.textContent = '';
      if (emailErr) emailErr.textContent = '';
      if (passErr) passErr.textContent = '';

      if (!fullName) {
        if (nameErr) nameErr.textContent = 'Ingrese su nombre completo';
        valid = false;
      }
      if (!interestArea) {
        if (areaErr) areaErr.textContent = 'Seleccione su área de interés';
        valid = false;
      }
      if (!email) {
        if (emailErr) emailErr.textContent = 'Ingrese su correo electrónico';
        valid = false;
      }
      if (!password) {
        if (passErr) passErr.textContent = 'Ingrese una contraseña';
        valid = false;
      }

      if (!valid) return;

      const names = fullName.split(' ');
      const initials = names.length >= 2 ? (names[0][0] + names[1][0]).toUpperCase() : fullName.substring(0, 2).toUpperCase();
      const session = {
        email: email,
        role: 'postulante',
        name: fullName,
        avatar: initials,
        interestArea: interestArea,
        loginTimestamp: Date.now()
      };
      sessionStorage.setItem('tm_session', JSON.stringify(session));
      const prefix = AuthService.getRelativePrefix();
      window.location.href = prefix + 'postulante/dashboard.html';
    });
  }
});