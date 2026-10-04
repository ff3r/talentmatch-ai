/**
 * TalentMatch AI - Guardia de Autenticación
 * Fecha: 2026-10-01
 * Nota de migración: En producción, este archivo será reemplazado por middleware del backend.
 */

(function() {
  const publicPages = ['index.html', 'login.html', 'registro-empresa.html', 'registro-postulante.html'];
  const cleanPath = window.location.pathname.replace(/\\/g, '/');
  const pathSegments = cleanPath.split('/').filter(Boolean);
  const currentPage = pathSegments.length > 0 ? pathSegments[pathSegments.length - 1] : 'index.html';

  if (publicPages.includes(currentPage)) {
    return;
  }

  const currentSection = pathSegments.length > 1 ? pathSegments[pathSegments.length - 2] : '';
  const isSubdir = ['admin', 'empresa', 'reclutador', 'postulante', 'auth'].includes(currentSection);
  const prefix = isSubdir ? '../' : '';

  // Verificar sesión en sessionStorage
  let session = null;
  try {
    const raw = sessionStorage.getItem('tm_session');
    if (raw) session = JSON.parse(raw);
  } catch (e) {
    session = null;
  }

  // Si no está autenticado, redirigir al login
  if (!session) {
    window.location.href = prefix + 'auth/login.html';
    return;
  }

  const userRole = session.role;
  const roleSectionMap = {
    'empresa': 'empresa',
    'reclutador': 'reclutador',
    'postulante': 'postulante',
    'admin': 'admin'
  };

  // Si intenta acceder a una sección que no corresponde a su rol
  if (currentSection && roleSectionMap[userRole] && roleSectionMap[userRole] !== currentSection) {
    window.location.href = `${prefix}${roleSectionMap[userRole]}/dashboard.html`;
  }
})();