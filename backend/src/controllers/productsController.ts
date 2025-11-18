import { Request, Response } from 'express';
import { query } from '../config/database';
import { ApiResponse } from '../types';

/**
 * GET /api/products
 * Lista todos os produtos ativos
 */
export const getAllProducts = async (req: Request, res: Response) => {
  try {
    const { categoria_id, destaque, search } = req.query;

    let sql = `
      SELECT p.*, c.nome as categoria_nome
      FROM produtos p
      INNER JOIN categorias c ON p.categoria_id = c.id
      WHERE p.ativo = TRUE
    `;
    const params: any[] = [];

    if (categoria_id) {
      sql += ' AND p.categoria_id = ?';
      params.push(categoria_id);
    }

    if (destaque) {
      sql += ' AND p.destaque = TRUE';
    }

    if (search) {
      sql += ' AND (p.nome LIKE ? OR p.descricao LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }

    sql += ' ORDER BY c.ordem_exibicao, p.nome';

    const products = await query(sql, params);

    res.json({
      success: true,
      data: products
    } as ApiResponse);
  } catch (error) {
    console.error('Erro ao buscar produtos:', error);
    res.status(500).json({
      success: false,
      error: 'Erro ao buscar produtos'
    } as ApiResponse);
  }
};


/**
 * GET /api/products/:id
 * Busca um produto por ID
 */
export const getProductById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const products: any = await query(
      `SELECT p.*, c.nome as categoria_nome
       FROM produtos p
       INNER JOIN categorias c ON p.categoria_id = c.id
       WHERE p.id = ? AND p.ativo = TRUE`,
      [id]
    );

    if (!Array.isArray(products) || products.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Produto não encontrado'
      } as ApiResponse);
    }

    res.json({
      success: true,
      data: products[0]
    } as ApiResponse);
  } catch (error) {
    console.error('Erro ao buscar produto:', error);
    res.status(500).json({
      success: false,
      error: 'Erro ao buscar produto'
    } as ApiResponse);
  }
};

/**
 * GET /api/categories
 * Lista todas as categorias ativas
 */
export const getAllCategories = async (req: Request, res: Response) => {
  try {
    const categories = await query(
      'SELECT * FROM categorias WHERE ativo = TRUE ORDER BY ordem_exibicao, nome'
    );

    res.json({
      success: true,
      data: categories
    } as ApiResponse);
  } catch (error) {
    console.error('Erro ao buscar categorias:', error);
    res.status(500).json({
      success: false,
      error: 'Erro ao buscar categorias'
    } as ApiResponse);
  }
};
