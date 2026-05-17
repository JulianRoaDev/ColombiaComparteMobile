import { Request, Response } from 'express';
import Pais from '../models/Pais';

export const listarPaises = async (_req: Request, res: Response): Promise<void> => {
  try {
    const paises = await Pais.find({});
    res.status(200).json(paises);
  } catch (error) {
    console.error('Error listando países:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};