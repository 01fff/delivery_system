import { Router } from 'express';
import { getAllProducts, getProductById, getAllCategories } from '../controllers/productsController';

const router = Router();

// Rotas públicas de produtos
router.get('/', getAllProducts);
router.get('/:id', getProductById);

// Rotas de categorias
router.get('/categories/all', getAllCategories);

export default router;
