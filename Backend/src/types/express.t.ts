export {};

declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        nombre: string;
        correo: string;
        rol: 'superadmin' | 'admin_pais' | 'editor';
        pais_asignado: {
          _id: string;
          nombre: string;
          codigo: string;
        } | null;
      };
    }
  }
}