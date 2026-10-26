/**
 * TalentMatch AI - Cliente de Conexión API REST (Backend PHP / MySQL)
 * Conecta los formularios del Frontend con los endpoints PDO de /api/
 */

const ApiClient = {
  // Ruta relativa base para resolver dinámicamente en cualquier subcarpeta
  getBaseUrl() {
    const origin = window.location.origin;
    const pathname = window.location.pathname;
    
    // Si estamos en un subdirectorio (ej. /auth/ o /empresa/)
    if (pathname.includes('/auth/') || pathname.includes('/empresa/') || pathname.includes('/reclutador/') || pathname.includes('/postulante/')) {
      return '../api';
    }
    return 'api';
  },

  /**
   * Verifica si el servidor PHP backend está activo
   */
  async checkHealth() {
    try {
      const res = await fetch(`${this.getBaseUrl()}/db.php`);
      return await res.json();
    } catch (e) {
      return { success: false, message: 'Servidor backend no disponible' };
    }
  },

  /**
   * Petición POST de Login contra MySQL
   */
  async login(email, password) {
    const res = await fetch(`${this.getBaseUrl()}/auth/login.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password })
    });
    return await res.json();
  },

  /**
   * Activación de cuenta de Reclutador
   */
  async activarCuenta(email, numeroDocumento, password, token = '') {
    const res = await fetch(`${this.getBaseUrl()}/auth/activar-cuenta.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, numero_documento: numeroDocumento, password, token })
    });
    return await res.json();
  },

  /**
   * Obtener equipo de reclutadores de MySQL
   */
  async getReclutadores(idEmpresa = 1) {
    const res = await fetch(`${this.getBaseUrl()}/empresa/reclutadores.php?id_empresa=${idEmpresa}`);
    return await res.json();
  },

  /**
   * Guardar invitación de reclutador en MySQL
   */
  async invitarReclutador(nombre, email, cargo = 'Reclutador', idEmpresa = 1) {
    const res = await fetch(`${this.getBaseUrl()}/empresa/reclutadores.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ nombre, email, cargo, id_empresa: idEmpresa })
    });
    return await res.json();
  },

  /**
   * Cambiar estado de reclutador en MySQL (activo / inactivo)
   */
  async toggleEstadoReclutador(idUsuario, nuevoEstado) {
    const res = await fetch(`${this.getBaseUrl()}/empresa/reclutadores.php`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id_usuario: idUsuario, estado: nuevoEstado })
    });
    return await res.json();
  },

  /**
   * Obtener ofertas laborales de MySQL
   */
  async getOfertas(idEmpresa = 1) {
    const res = await fetch(`${this.getBaseUrl()}/empresa/ofertas.php?id_empresa=${idEmpresa}`);
    return await res.json();
  },

  /**
   * Crear oferta laboral en MySQL con transacción
   */
  async crearOferta(ofertaData) {
    const res = await fetch(`${this.getBaseUrl()}/empresa/ofertas.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(ofertaData)
    });
    return await res.json();
  },

  /**
   * Obtener candidatos de MySQL
   */
  async getCandidatos() {
    const res = await fetch(`${this.getBaseUrl()}/reclutador/candidatos.php`);
    return await res.json();
  }
};

window.ApiClient = ApiClient;
