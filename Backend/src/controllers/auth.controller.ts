import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt, { SignOptions } from 'jsonwebtoken';
import Usuario from '../models/Usuario';

// ── Helper: construye el payload JWT de forma consistente ─────────────────────
const buildPayload = (usuario: any) => ({
  id:            usuario._id.toString(),
  nombre:        usuario.nombre,
  correo:        usuario.correo,
  foto_url:      usuario.foto_url ?? null,
  rol:           usuario.rol,
  pais_asignado: usuario.pais_asignado ?? null
});

const signToken = (payload: object): string => {
  const secret  = process.env.JWT_SECRET as string;
  const options: SignOptions = {
    expiresIn: (process.env.JWT_EXPIRES_IN ?? '24h') as SignOptions['expiresIn']
  };
  return jwt.sign(payload, secret, options);
};

// ── Login ─────────────────────────────────────────────────────────────────────
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

    const payload = buildPayload(usuario);
    const token   = signToken(payload);

    res.status(200).json({ token, usuario: payload });
  } catch (error) {
    console.error('Error en login:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

// ── Registro público ──────────────────────────────────────────────────────────
export const register = async (req: Request, res: Response): Promise<void> => {
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

    if (!['editor', 'usuario_general'].includes(rol)) {
      res.status(400).json({ message: 'Rol no permitido en registro público' });
      return;
    }

    const existente = await Usuario.findOne({ correo });
    if (existente) {
      res.status(400).json({ message: 'El correo ya está registrado' });
      return;
    }

    if (password.length < 6) {
      res.status(400).json({ message: 'La contraseña debe tener al menos 6 caracteres' });
      return;
    }

    const salt          = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    const nuevo = await Usuario.create({
      nombre, correo, password_hash, rol,
      pais_asignado: pais_asignado ?? null
    });

    res.status(201).json({
      message: 'Cuenta creada exitosamente',
      usuario: {
        id:     nuevo._id.toString(),
        nombre: nuevo.nombre,
        correo: nuevo.correo,
        rol:    nuevo.rol
      }
    });
  } catch (error) {
    console.error('Error en registro:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

// ── Actualizar perfil ─────────────────────────────────────────────────────────
export const actualizarPerfil = async (req: Request, res: Response): Promise<void> => {
  try {
    const userId = req.user?.id;

    const { nombre, foto_url } =
      req.body as { nombre?: string; foto_url?: string | null };

    if (!nombre || nombre.trim() === '') {
      res.status(400).json({ message: 'El nombre es requerido' });
      return;
    }

    // Construir el objeto de actualización explícitamente
    // $set garantiza que solo se actualizan los campos enviados
    const updateFields: Record<string, string | null> = {
      nombre: nombre.trim()
    };

    // foto_url solo se actualiza si el cliente la envió en el body
    // (puede ser string o null para borrarla)
    if ('foto_url' in req.body) {
      updateFields.foto_url = foto_url ?? null;
    }

    const usuario = await Usuario.findByIdAndUpdate(
      userId,
      { $set: updateFields },           // ← $set es más explícito que un objeto plano
      { new: true, runValidators: true }
    ).populate('pais_asignado', 'nombre codigo _id');

    if (!usuario) {
      res.status(404).json({ message: 'Usuario no encontrado' });
      return;
    }

    const payload = buildPayload(usuario);
    const token   = signToken(payload);

    res.status(200).json({ token, usuario: payload });
  } catch (error) {
    console.error('Error al actualizar perfil:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};