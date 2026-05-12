const jwt = require('jsonwebtoken');

// Verify token middleware: checks for the presence and validity of the JWT token in the Authorization header
const verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Token de acceso requerido' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // { id, nombre, correo, rol, pais_asignado }
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token expirado, inicia sesión nuevamente' });
    }
    return res.status(401).json({ message: 'Token inválido' });
  }
};

// Middleware de roles: uso -> requireRol('superadmin') o requireRol('superadmin', 'admin_pais')
const requireRol = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.rol)) {
      return res.status(403).json({
        message: `Acceso denegado. Se requiere rol: ${roles.join(' o ')}`
      });
    }
    next();
  };
};

module.exports = { verifyToken, requireRol };