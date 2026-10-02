/**
 * TalentMatch AI - Router
 * Utilidades de navegación y detección de ruta activa
 * Fecha: 2026-10-01
 * Nota de migración: Este archivo se mantiene intacto en la migración a PHP/Laravel Blade.
 */

const Router = (() => {
  function getCurrentPath() {
    return window.location.pathname;
  }

  function getActiveSection() {
    const path = window.location.pathname;
    const segments = path.split('/').filter(s => s);
    return segments.length >= 2 ? segments[segments.length - 2] : null;
  }

  function navigateTo(path) {
    window.location.href = path;
  }

  function getQueryParam(name) {
    const params = new URLSearchParams(window.location.search);
    return params.get(name);
  }

  return {
    getCurrentPath,
    getActiveSection,
    navigateTo,
    getQueryParam
  };
})();