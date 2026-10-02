/**
 * TalentMatch AI - Almacén de Credenciales Simuladas
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