import { Router } from 'express';
import { verifyToken, requireRol } from '../middleware/auth';
import { listar, crear, editar, eliminar } from '../controllers/usuarios.controller';

const router = Router();

router.get('/', verifyToken, requireRol('superadmin'), listar);
router.post('/', verifyToken, requireRol('superadmin'), crear);
router.put('/:id', verifyToken, requireRol('superadmin'), editar);
router.delete('/:id',verifyToken, requireRol('superadmin'), eliminar);

export default router;