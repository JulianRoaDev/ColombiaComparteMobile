import { Router } from 'express';
import { verifyToken } from '../middleware/auth';
import {
  listar, crear, editar, cambiarEstado, eliminar
} from '../controllers/testimonios.controller';

const router = Router();

router.get('/',             verifyToken, listar);
router.post('/',            verifyToken, crear);
router.put('/:id',          verifyToken, editar);
router.patch('/:id/estado', verifyToken, cambiarEstado);
router.delete('/:id',       verifyToken, eliminar);

export default router;