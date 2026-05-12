const express = require('express');
const router = express.Router();
const { verifyToken, requireRol } = require('../middleware/auth');
const ctrl = require('../controllers/solicitudes.controller');

// Public — visitants can create solicitudes
router.post('/', ctrl.crear);

// Protected — admin only routes
router.get('/',        verifyToken, requireRol('superadmin', 'admin_pais'), ctrl.listar);
router.get('/:id',     verifyToken, requireRol('superadmin', 'admin_pais'), ctrl.detalle);
router.patch('/:id/estado', verifyToken, requireRol('superadmin', 'admin_pais'), ctrl.cambiarEstado);
router.delete('/:id',  verifyToken, requireRol('superadmin', 'admin_pais'), ctrl.eliminar);

module.exports = router;