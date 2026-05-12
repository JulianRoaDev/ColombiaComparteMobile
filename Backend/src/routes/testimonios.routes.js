const express = require('express');
const router = express.Router();
const { verifyToken, requireRol } = require('../middleware/auth');
const ctrl = require('../controllers/testimonios.controller');

const todosLosRoles = requireRol('superadmin', 'admin_pais', 'editor');
const soloAdmins    = requireRol('superadmin', 'admin_pais');

router.get('/',               verifyToken, todosLosRoles, ctrl.listar);
router.post('/',              verifyToken, todosLosRoles, ctrl.crear);
router.put('/:id',            verifyToken, todosLosRoles, ctrl.actualizar);
router.patch('/:id/estado',   verifyToken, todosLosRoles, ctrl.cambiarEstado);
router.delete('/:id',         verifyToken, soloAdmins,    ctrl.eliminar);

module.exports = router;