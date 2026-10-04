/**
 * TalentMatch AI - Guardia de Autenticación
 * Fecha: 2026-10-01
 * Nota de migración: En producción, este archivo será reemplazado por middleware del backend.
 */

(function() {
  const publicPages = ['index.html', 'login.html', 'registro-empresa.html', 'registro-postulante.html'];
  const currentPage = window.location.pathname.split('/').pop();

  if (publicPages.includes(currentPage)) {
    return;
  }

  if (!AuthService.isAuthenticated()) {
    window.location.href = 'auth/login.html';
    return;
  }

  const userRole = AuthService.getUserRole();
  const pathSegments = window.location.pathname.split('/');
  const currentSection = pathSegments[pathSegments.length - 2];

  const roleSectionMap = {
    'empresa': 'empresa',
    'reclutador': 'reclutador',
    'postulante': 'postulante',
    'admin': 'admin'
  };

  if (currentSection && roleSectionMap[userRole] !== currentSection) {
    const user = AuthService.getCurrentUser();
    const redirectMap = {
      'empresa': 'empresa/dashboard.html',
      'reclutador': 'reclutador/dashboard.html',
      'postulante': 'postulante/dashboard.html',
      'admin': 'admin/dashboard.html'
    };
    window.location.href = redirectMap[userRole];
  }
})();