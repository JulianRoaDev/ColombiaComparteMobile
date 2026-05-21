import { Request, Response } from 'express';
import Noticia from '../models/Noticia';

type PaisFilter = Record<string, unknown>;

const getPaisFilter = (user: Express.Request['user'], paisQuery?: string): PaisFilter => {
  if (user?.rol === 'superadmin') return paisQuery ? { pais: paisQuery } : {};
  return { pais: user?.pais_asignado?._id };
};

export const listar = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = req.user!;
    let filter: Record<string, unknown> = {};

    if (user.rol === 'superadmin') {
      if (req.query.pais)   filter.pais   = req.query.pais;
      if (req.query.estado) filter.estado = req.query.estado;

    } else if (user.rol === 'admin_pais') {
      filter.pais = user.pais_asignado?._id;
      if (req.query.estado) filter.estado = req.query.estado;

    } else {
      // editor y usuario_general:
      // - Noticias publicadas de su país
      // - Sus propias noticias (cualquier estado)
      const paisId = user.pais_asignado?._id;
      filter = {
        $or: [
          { estado: 'publicado', pais: paisId },
          { creador: user.id }
        ]
      };
    }

    const noticias = await Noticia.find(filter)
      .populate('pais', 'nombre codigo')
      .sort({ fecha_creacion: -1 });

    res.status(200).json(noticias);
  } catch (error) {
    res.status(500).json({ message: 'Error al listar noticias' });
  }
};

export const crear = async (req: Request, res: Response): Promise<void> => {
  try {
    const { titulo, resumen, contenido, autor, imagen_url, pais, estado } =
      req.body as {
        titulo: string; resumen: string; contenido: string;
        autor: string; imagen_url?: string; pais: string; estado?: string;
      };

    if (!titulo || !resumen || !contenido || !autor || !pais) {
      res.status(400).json({ message: 'titulo, resumen, contenido, autor y pais son requeridos' });
      return;
    }

    if (req.user?.rol !== 'superadmin') {
      const paisId = req.user?.pais_asignado?._id?.toString();
      if (pais !== paisId) {
        res.status(403).json({ message: 'Solo puedes crear noticias de tu país' });
        return;
      }
    }

    const nueva = await Noticia.create({
      titulo, resumen, contenido, autor,
      imagen_url: imagen_url ?? null,
      pais,
      creador: req.user?.id ?? null,
      estado: estado ?? 'borrador'
    });
    const populated = await nueva.populate('pais', 'nombre codigo');
    res.status(201).json(populated);
  } catch (error) {
    res.status(500).json({ message: 'Error al crear noticia' });
  }
};

export const editar = async (req: Request, res: Response): Promise<void> => {
  try {
    const noticia = await Noticia.findById(req.params.id);
    if (!noticia) {
      res.status(404).json({ message: 'Noticia no encontrada' });
      return;
    }

    if (req.user?.rol !== 'superadmin') {
      const paisId = req.user?.pais_asignado?._id?.toString();
      if (noticia.pais.toString() !== paisId) {
        res.status(403).json({ message: 'No puedes editar noticias de otro país' });
        return;
      }
    }

    const actualizada = await Noticia.findByIdAndUpdate(
      req.params.id, req.body, { new: true }
    ).populate('pais', 'nombre codigo');
    res.status(200).json(actualizada);
  } catch (error) {
    res.status(500).json({ message: 'Error al editar noticia' });
  }
};

export const cambiarEstado = async (req: Request, res: Response): Promise<void> => {
  try {
    const { estado } = req.body as { estado: string };
    if (!['borrador', 'publicado'].includes(estado)) {
      res.status(400).json({ message: 'Estado no válido' });
      return;
    }
    const actualizada = await Noticia.findByIdAndUpdate(
      req.params.id, { estado }, { new: true }
    ).populate('pais', 'nombre codigo');
    if (!actualizada) {
      res.status(404).json({ message: 'Noticia no encontrada' });
      return;
    }
    res.status(200).json(actualizada);
  } catch (error) {
    res.status(500).json({ message: 'Error al cambiar estado' });
  }
};

export const eliminar = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = req.user!;

    if (user.rol === 'editor') {
      res.status(403).json({ message: 'Los editores no pueden eliminar noticias' });
      return;
    }

    const noticia = await Noticia.findById(req.params.id);
    if (!noticia) {
      res.status(404).json({ message: 'Noticia no encontrada' });
      return;
    }

    if (user.rol === 'admin_pais') {
      const paisId = user.pais_asignado?._id?.toString();
      if (noticia.pais.toString() !== paisId) {
        res.status(403).json({ message: 'No puedes eliminar noticias de otro país' });
        return;
      }
    }

    await Noticia.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: 'Noticia eliminada' });
  } catch (error) {
    res.status(500).json({ message: 'Error al eliminar noticia' });
  }
};