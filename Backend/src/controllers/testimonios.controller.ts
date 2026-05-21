import { Request, Response } from 'express';
import Testimonio from '../models/Testimonio';

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
      // View all testimonies, optionally filter by country
      if (req.query.pais) filter.pais = req.query.pais;

    } else if (user.rol === 'admin_pais') {
      // View all testimonies of their assigned country
      filter.pais = user.pais_asignado?._id;

    } else {
      // editor & usuario_general:
      // - Testimonies from their country that are published
      // - Their own testimonies regardless of state
      const paisId = user.pais_asignado?._id;
      filter = {
        $or: [
          { estado: 'publicado', pais: paisId },
          { creador: user.id }
        ]
      };
    }

    const testimonios = await Testimonio.find(filter)
      .populate('pais', 'nombre codigo')
      .sort({ fecha_creacion: -1 });

    res.status(200).json(testimonios);
  } catch (error) {
    res.status(500).json({ message: 'Error al listar testimonios' });
  }
};

export const crear = async (req: Request, res: Response): Promise<void> => {
  try {
    const { nombre, foto_url, testimonio, pais, instagram_url, facebook_url, estado } =
      req.body as {
        nombre: string; foto_url: string; testimonio: string; pais: string;
        instagram_url?: string; facebook_url?: string; estado?: string;
      };

    if (!nombre || !foto_url || !testimonio || !pais) {
      res.status(400).json({ message: 'nombre, foto_url, testimonio y pais son requeridos' });
      return;
    }

    if (req.user?.rol !== 'superadmin') {
      const paisId = req.user?.pais_asignado?._id?.toString();
      if (pais !== paisId) {
        res.status(403).json({ message: 'Solo puedes crear testimonios de tu país' });
        return;
      }
    }

    const nuevo = await Testimonio.create({
      nombre, foto_url, testimonio, pais,
      creador: req.user?.id ?? null,
      instagram_url: instagram_url ?? null,
      facebook_url: facebook_url ?? null,
      estado: estado ?? 'borrador'
    });
    const populated = await nuevo.populate('pais', 'nombre codigo');
    res.status(201).json(populated);
  } catch (error) {
    res.status(500).json({ message: 'Error al crear testimonio' });
  }
};

export const editar = async (req: Request, res: Response): Promise<void> => {
  try {
    const testimonio = await Testimonio.findById(req.params.id);
    if (!testimonio) {
      res.status(404).json({ message: 'Testimonio no encontrado' });
      return;
    }

    const user = req.user!;

    // usuario_general solo puede editar sus propios testimonios
    if (user.rol === 'usuario_general') {
      if (testimonio.creador?.toString() !== user.id) {
        res.status(403).json({ message: 'Solo puedes editar tus propios testimonios' });
        return;
      }
    } else if (user.rol !== 'superadmin') {
      const paisId = user.pais_asignado?._id?.toString();
      if (testimonio.pais.toString() !== paisId) {
        res.status(403).json({ message: 'No puedes editar testimonios de otro país' });
        return;
      }
    }

    const actualizado = await Testimonio.findByIdAndUpdate(
      req.params.id, req.body, { new: true }
    ).populate('pais', 'nombre codigo');
    res.status(200).json(actualizado);
  } catch (error) {
    res.status(500).json({ message: 'Error al editar testimonio' });
  }
};

export const cambiarEstado = async (req: Request, res: Response): Promise<void> => {
  try {
    const { estado } = req.body as { estado: string };
    if (!['borrador', 'publicado', 'despublicado'].includes(estado)) {
      res.status(400).json({ message: 'Estado no válido' });
      return;
    }
    const actualizado = await Testimonio.findByIdAndUpdate(
      req.params.id, { estado }, { new: true }
    ).populate('pais', 'nombre codigo');
    if (!actualizado) {
      res.status(404).json({ message: 'Testimonio no encontrado' });
      return;
    }
    res.status(200).json(actualizado);
  } catch (error) {
    res.status(500).json({ message: 'Error al cambiar estado' });
  }
};

export const eliminar = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = req.user!;

    if (user.rol === 'editor') {
      res.status(403).json({ message: 'Los editores no pueden eliminar testimonios' });
      return;
    }

    const testimonio = await Testimonio.findById(req.params.id);
    if (!testimonio) {
      res.status(404).json({ message: 'Testimonio no encontrado' });
      return;
    }

    if (user.rol === 'admin_pais') {
      const paisId = user.pais_asignado?._id?.toString();
      if (testimonio.pais.toString() !== paisId) {
        res.status(403).json({ message: 'No puedes eliminar testimonios de otro país' });
        return;
      }
    }

    if (user.rol === 'usuario_general') {
      res.status(403).json({ message: 'No tienes permisos para eliminar testimonios' });
      return;
    }

    await Testimonio.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: 'Testimonio eliminado' });
  } catch (error) {
    res.status(500).json({ message: 'Error al eliminar testimonio' });
  }
};