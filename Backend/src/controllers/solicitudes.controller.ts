import { Request, Response } from 'express';
import Solicitud from '../models/Solicitud';

type PaisFilter = Record<string, unknown>;

const getPaisFilter = (user: Express.Request['user'], paisQuery?: string): PaisFilter => {
  if (user?.rol === 'superadmin') {
    return paisQuery ? { pais: paisQuery } : {};
  }
  const paisId = user?.pais_asignado?._id;
  return { pais: paisId };
};

export const listar = async (req: Request, res: Response): Promise<void> => {
  try {
    const { estado, pais } = req.query as { estado?: string; pais?: string };
    const filter: PaisFilter = getPaisFilter(req.user, pais);
    if (estado) filter.estado = estado;

    const solicitudes = await Solicitud.find(filter)
      .populate('pais', 'nombre codigo')
      .sort({ fecha_creacion: -1 });

    res.status(200).json(solicitudes);
  } catch (error) {
    res.status(500).json({ message: 'Error al listar solicitudes' });
  }
};

export const detalle = async (req: Request, res: Response): Promise<void> => {
  try {
    const solicitud = await Solicitud.findById(req.params.id)
      .populate('pais', 'nombre codigo');
    if (!solicitud) {
      res.status(404).json({ message: 'Solicitud no encontrada' });
      return;
    }
    res.status(200).json(solicitud);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener solicitud' });
  }
};

export const cambiarEstado = async (req: Request, res: Response): Promise<void> => {
  try {
    const { estado } = req.body as { estado: string };
    const estadosValidos = ['pendiente', 'gestionada', 'respondida'];
    if (!estadosValidos.includes(estado)) {
      res.status(400).json({ message: 'Estado no válido' });
      return;
    }

    const solicitud = await Solicitud.findByIdAndUpdate(
      req.params.id, { estado }, { new: true }
    ).populate('pais', 'nombre codigo');

    if (!solicitud) {
      res.status(404).json({ message: 'Solicitud no encontrada' });
      return;
    }
    res.status(200).json(solicitud);
  } catch (error) {
    res.status(500).json({ message: 'Error al cambiar estado' });
  }
};

export const eliminar = async (req: Request, res: Response): Promise<void> => {
  try {
    const user = req.user!;

    if (user.rol === 'editor') {
      res.status(403).json({ message: 'Los editores no pueden eliminar solicitudes' });
      return;
    }

    const solicitud = await Solicitud.findById(req.params.id).populate('pais');
    if (!solicitud) {
      res.status(404).json({ message: 'Solicitud no encontrada' });
      return;
    }

    if (user.rol === 'admin_pais') {
      const paisId = user.pais_asignado?._id?.toString();
      const solicitudPaisId = (solicitud.pais as any)._id?.toString();
      if (solicitudPaisId !== paisId) {
        res.status(403).json({ message: 'No puedes eliminar solicitudes de otro país' });
        return;
      }
    }

    await Solicitud.findByIdAndDelete(req.params.id);
    res.status(200).json({ message: 'Solicitud eliminada' });
  } catch (error) {
    res.status(500).json({ message: 'Error al eliminar solicitud' });
  }
};

export const crearPublico = async (req: Request, res: Response): Promise<void> => {
  try {
    const { nombre, correo, telefono, finalidad, pais } =
      req.body as {
        nombre: string;
        correo: string;
        telefono: string;
        finalidad: string;
        pais: string;
      };

    if (!nombre || !correo || !telefono || !finalidad || !pais) {
      res.status(400).json({ message: 'Todos los campos son requeridos' });
      return;
    }

    const nueva = await Solicitud.create({ nombre, correo, telefono, finalidad, pais });
    res.status(201).json(nueva);
  } catch (error) {
    res.status(500).json({ message: 'Error al crear solicitud' });
  }
};