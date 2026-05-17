import { Router } from 'express';
import { verifyToken } from '../middleware/auth';
import { getStats } from '../controllers/dashboard.controller';

const router = Router();

router.get('/stats', verifyToken, getStats);

export default router;