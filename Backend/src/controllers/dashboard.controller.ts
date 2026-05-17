//import { Request, Response } from 'mongoose';
import { Request as ExpressRequest, Response } from 'express';
import Solicitud  from '../models/Solicitud';
import Testimonio from '../models/Testimonio';
import Noticia    from '../models/Noticia';
import Pais       from '../models/Pais';

export const getStats = async (req: ExpressRequest, res: Response): Promise<void> => {
  try {
    const user = req.user!;

    if (user.rol === 'superadmin') {
      const paises = await Pais.find({ activo: true });

      const statsPorPais = await Promise.all(
        paises.map(async (pais) => {
          const [solicitudesPendientes, testimoniosPublicados, noticiasActivas] =
            await Promise.all([
              Solicitud.countDocuments({ pais: pais._id, estado: 'pendiente' }),
              Testimonio.countDocuments({ pais: pais._id, estado: 'publicado' }),
              Noticia.countDocuments({ pais: pais._id, estado: 'publicado' })
            ]);

          return {
            pais: { _id: pais._id, nombre: pais.nombre, codigo: pais.codigo },
            solicitudesPendientes,
            testimoniosPublicados,
            noticiasActivas
          };
        })
      );

      res.status(200).json({ rol: 'superadmin', stats: statsPorPais });
      return;
    }

    if (!user.pais_asignado) {
      res.status(400).json({ message: 'Usuario sin país asignado' });
      return;
    }

    const paisId = user.pais_asignado._id;

    const [solicitudesPendientes, testimoniosPublicados, noticiasActivas] =
      await Promise.all([
        Solicitud.countDocuments({ pais: paisId, estado: 'pendiente' }),
        Testimonio.countDocuments({ pais: paisId, estado: 'publicado' }),
        Noticia.countDocuments({ pais: paisId, estado: 'publicado' })
      ]);

    res.status(200).json({
      rol: user.rol,
      stats: {
        pais: user.pais_asignado,
        solicitudesPendientes,
        testimoniosPublicados,
        noticiasActivas
      }
    });
  } catch (error) {
    console.error('Error en dashboard stats:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};