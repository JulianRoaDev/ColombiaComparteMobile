import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import Usuario from '../models/Usuario';
import jwt, { SignOptions } from 'jsonwebtoken';

export const login = async (req: Request, res: Response): Promise<void> => {
    try {
        const { correo, password } = req.body as { correo: string; password: string };

        if (!correo || !password) {
            res.status(400).json({ message: 'Correo y contraseña son requeridos' });
            return;
        }

        const usuario = await Usuario.findOne({ correo })
            .populate('pais_asignado', 'nombre codigo _id');

        if (!usuario) {
            res.status(401).json({ message: 'Credenciales incorrectas' });
            return;
        }

        const passwordValido = await bcrypt.compare(password, usuario.password_hash);
        if (!passwordValido) {
            res.status(401).json({ message: 'Credenciales incorrectas' });
            return;
        }

        const payload = {
            id: usuario._id.toString(),
            nombre: usuario.nombre,
            correo: usuario.correo,
            rol: usuario.rol,
            pais_asignado: usuario.pais_asignado
        };

        const secret = process.env.JWT_SECRET as string;
        const options: SignOptions = {
            expiresIn: (process.env.JWT_EXPIRES_IN ?? '24h') as SignOptions['expiresIn']
        };

        const token = jwt.sign(payload, secret, options);

        res.status(200).json({ token, usuario: payload });
    } catch (error) {
        console.error('Error en login:', error);
        res.status(500).json({ message: 'Error interno del servidor' });
    }
};