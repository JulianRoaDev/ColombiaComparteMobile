import { Router } from 'express';
import { verifyToken, requireRol } from '../middleware/auth';
import { listarPaises } from '../controllers/paises.controller';

const router = Router();

router.get('/publico', listarPaises);
router.get('/', verifyToken, requireRol('superadmin'), listarPaises);

export default router;