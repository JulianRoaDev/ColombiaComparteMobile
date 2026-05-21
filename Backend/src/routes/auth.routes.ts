import { Router } from 'express';
import { login, register, actualizarPerfil } from '../controllers/auth.controller';
import { verifyToken } from '../middleware/auth';

const router = Router();

router.post('/login', login);
router.post('/register', register);
router.patch('/perfil', verifyToken, actualizarPerfil);
router.post('/perfil', verifyToken, actualizarPerfil); // compatible con clientes antiguos

export default router;