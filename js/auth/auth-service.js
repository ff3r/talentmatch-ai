/**
 * TalentMatch AI - Servicio de Autenticación
 * Fecha: 2026-10-01
 * Nota de migración: En producción, este módulo realizará llamadas HTTP al backend.
 */

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

    if (typeof EventBus !== 'undefined') {
      EventBus.emit('auth:login', { user: session });
    }

    return { success: true, user: session };
  }

  function logout() {
    sessionStorage.removeItem(SESSION_KEY);

    if (typeof EventBus !== 'undefined') {
      EventBus.emit('auth:logout');
    }

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