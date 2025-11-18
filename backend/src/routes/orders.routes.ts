import { Router } from 'express';
import {
  createOrder,
  getMyOrders,
  getOrderById,
  updateOrderStatus,
  cancelOrder
} from '../controllers/ordersController';
import { authenticateToken, requireRole } from '../middlewares/auth';
import { validate, createOrderSchema, updateOrderStatusSchema } from '../middlewares/validator';

const router = Router();

// Todas as rotas de pedidos requerem autenticação
router.use(authenticateToken);

// Rotas de pedidos
router.post('/', validate(createOrderSchema), createOrder);
router.get('/', getMyOrders);
router.get('/:id', getOrderById);
router.patch('/:id/status', requireRole(3), validate(updateOrderStatusSchema), updateOrderStatus);
router.post('/:id/cancel', cancelOrder);

export default router;
