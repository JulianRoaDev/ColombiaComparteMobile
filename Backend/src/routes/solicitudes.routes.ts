import { Router } from 'express';
import { verifyToken, requireRol } from '../middleware/auth';
import {
  listar, detalle, cambiarEstado, eliminar, crearPublico
} from '../controllers/solicitudes.controller';

const router = Router();

router.post('/', crearPublico);
router.get('/',               verifyToken, requireRol('superadmin', 'admin_pais'), listar);
router.get('/:id',            verifyToken, requireRol('superadmin', 'admin_pais'), detalle);
router.patch('/:id/estado',   verifyToken, requireRol('superadmin', 'admin_pais'), cambiarEstado);
router.delete('/:id',         verifyToken, requireRol('superadmin', 'admin_pais'), eliminar);

export default router;