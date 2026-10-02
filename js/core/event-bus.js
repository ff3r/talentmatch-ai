/**
 * TalentMatch AI - Bus de Eventos
 * Sistema publish/subscribe para comunicación entre componentes
 * Fecha: 2026-10-01
 * Nota de migración: Este archivo se mantiene intacto en la migración a PHP/Laravel Blade.
 */

const EventBus = (() => {
  const events = {};

  function on(eventName, callback) {
    if (!events[eventName]) {
      events[eventName] = [];
    }
    events[eventName].push(callback);
  }

  function off(eventName, callback) {
    if (!events[eventName]) return;
    events[eventName] = events[eventName].filter(cb => cb !== callback);
  }

  function emit(eventName, data) {
    if (!events[eventName]) return;
    events[eventName].forEach(callback => callback(data));
  }

  return { on, off, emit };
})();