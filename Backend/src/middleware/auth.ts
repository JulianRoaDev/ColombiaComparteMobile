import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

export const verifyToken = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const authHeader = req.headers['authorization'];

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    res.status(401).json({ message: 'Token de acceso requerido' });
    return;
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET ?? '') as Express.Request['user'];
    req.user = decoded;
    next();
  } catch (error) {
    if ((error as Error).name === 'TokenExpiredError') {
      res.status(401).json({ message: 'Token expirado, inicia sesión nuevamente' });
      return;
    }
    res.status(401).json({ message: 'Token inválido' });
  }
};

export const requireRol = (...roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user || !roles.includes(req.user.rol)) {
      res.status(403).json({
        message: `Acceso denegado. Se requiere rol: ${roles.join(' o ')}`
      });
      return;
    }
    next();
  };
};