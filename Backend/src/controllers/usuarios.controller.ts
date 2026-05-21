import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import Usuario from '../models/Usuario';

export const listar = async (_req: Request, res: Response): Promise<void> => {
  try {
    const usuarios = await Usuario.find({}, '-password_hash')
      .populate('pais_asignado', 'nombre codigo')
      .sort({ createdAt: -1 });
    res.status(200).json(usuarios);
  } catch (error) {
    res.status(500).json({ message: 'Error al listar usuarios' });
  }
};

export const crear = async (req: Request, res: Response): Promise<void> => {
  try {
    const { nombre, correo, password, rol, pais_asignado } =
      req.body as {
        nombre: string; correo: string; password: string;
        rol: string; pais_asignado?: string;
      };

    if (!nombre || !correo || !password || !rol) {
      res.status(400).json({ message: 'Todos los campos son requeridos' });
      return;
    }

    const existente = await Usuario.findOne({ correo });
    if (existente) {
      res.status(400).json({ message: 'El correo ya está registrado' });
      return;
    }

    const salt          = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    const nuevo = await Usuario.create({
      nombre, correo, password_hash, rol,
      pais_asignado: pais_asignado ?? null
    });

    const populated = await nuevo.populate('pais_asignado', 'nombre codigo');
    const { password_hash: _, ...usuarioSinPassword } = populated.toObject();
    res.status(201).json(usuarioSinPassword);
  } catch (error) {
    res.status(500).json({ message: 'Error al crear usuario' });
  }
};

export const editar = async (req: Request, res: Response): Promise<void> => {
  try {
    const { nombre, rol, pais_asignado } =
      req.body as { nombre?: string; rol?: string; pais_asignado?: string };

    const actualizado = await Usuario.findByIdAndUpdate(
      req.params.id,
      { nombre, rol, pais_asignado: pais_asignado ?? null },
      { new: true, select: '-password_hash' }
    ).populate('pais_asignado', 'nombre codigo');

    if (!actualizado) {
      res.status(404).json({ message: 'Usuario no encontrado' });
      return;
    }
    res.status(200).json(actualizado);
  } catch (error) {
    res.status(500).json({ message: 'Error al editar usuario' });
  }
};

export const eliminar = async (req: Request, res: Response): Promise<void> => {
  try {
    // No permitir que el superadmin se elimine a sí mismo
    if (req.params.id === req.user?.id) {
      res.status(400).json({ message: 'No puedes eliminarte a ti mismo' });
      return;
    }

    const usuario = await Usuario.findByIdAndDelete(req.params.id);
    if (!usuario) {
      res.status(404).json({ message: 'Usuario no encontrado' });
      return;
    }
    res.status(200).json({ message: 'Usuario eliminado' });
  } catch (error) {
    res.status(500).json({ message: 'Error al eliminar usuario' });
  }
};