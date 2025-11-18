import { Router } from 'express';
import { register, login, getMe } from '../controllers/authController';
import { authenticateToken } from '../middlewares/auth';
import { validate, registerSchema, loginSchema } from '../middlewares/validator';

const router = Router();

// Rotas públicas
router.post('/register', validate(registerSchema), register);
router.post('/login', validate(loginSchema), login);

// Rotas protegidas
router.get('/me', authenticateToken, getMe);

export default router;
