export {};

declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        nombre: string;
        correo: string;
        foto_url: string | null;
        rol: 'superadmin' | 'admin_pais' | 'editor' | 'usuario_general';
        pais_asignado: {
          _id: string;
          nombre: string;
          codigo: string;
        } | null;
      };
    }
  }
}