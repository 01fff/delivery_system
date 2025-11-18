import { Request, Response } from 'express';
import { query, pool } from '../config/database';
import { ApiResponse, CreateOrderRequest } from '../types';

/**
 * POST /api/orders
 * Cria um novo pedido usando a stored procedure
 */
export const createOrder = async (req: Request, res: Response) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Não autenticado'
      } as ApiResponse);
    }

    const { endereco_id, forma_pagamento, observacoes, codigo_cupom, itens }: CreateOrderRequest = req.body;
    const usuario_id = req.user.userId;

    // Converte itens para JSON
    const itensJson = JSON.stringify(itens);

    // Chama a stored procedure para criar o pedido
    const connection = await pool.getConnection();

    try {
      await connection.beginTransaction();

      // Executa a procedure
      const [result]: any = await connection.query(
        `CALL sp_processar_pedido_completo(?, ?, ?, ?, ?, ?, @pedido_id, @codigo_rastreamento)`,
        [usuario_id, endereco_id, forma_pagamento, observacoes || null, codigo_cupom || null, itensJson]
      );

      // Busca os valores de saída
      const [output]: any = await connection.query(
        'SELECT @pedido_id as pedido_id, @codigo_rastreamento as codigo_rastreamento'
      );

      await connection.commit();

      const pedidoId = output[0].pedido_id;
      const codigoRastreamento = output[0].codigo_rastreamento;

      // Busca os detalhes do pedido criado
      const [pedidos]: any = await connection.query(
        'SELECT * FROM vw_pedidos_completos WHERE pedido_id = ?',
        [pedidoId]
      );

      connection.release();

      res.status(201).json({
        success: true,
        data: {
          pedido: pedidos[0],
          codigo_rastreamento: codigoRastreamento
        },
        message: 'Pedido criado com sucesso'
      } as ApiResponse);
    } catch (error) {
      await connection.rollback();
      connection.release();
      throw error;
    }
  } catch (error: any) {
    console.error('Erro ao criar pedido:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Erro ao criar pedido'
    } as ApiResponse);
  }
};

/**
 * GET /api/orders
 * Lista os pedidos do usuário autenticado
 */
export const getMyOrders = async (req: Request, res: Response) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Não autenticado'
      } as ApiResponse);
    }

    const orders = await query(
      `SELECT * FROM vw_pedidos_completos
       WHERE cliente_id = ?
       ORDER BY data_pedido DESC`,
      [req.user.userId]
    );

    res.json({
      success: true,
      data: orders
    } as ApiResponse);
  } catch (error) {
    console.error('Erro ao buscar pedidos:', error);
    res.status(500).json({
      success: false,
      error: 'Erro ao buscar pedidos'
    } as ApiResponse);
  }
};

/**
 * GET /api/orders/:id
 * Busca um pedido específico
 */
export const getOrderById = async (req: Request, res: Response) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Não autenticado'
      } as ApiResponse);
    }

    const { id } = req.params;

    const orders: any = await query(
      `SELECT * FROM vw_pedidos_completos WHERE pedido_id = ?`,
      [id]
    );

    if (!Array.isArray(orders) || orders.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Pedido não encontrado'
      } as ApiResponse);
    }

    const order = orders[0];

    // Verifica se o usuário tem permissão para ver este pedido
    if (order.cliente_id !== req.user.userId && req.user.nivel_acesso < 3) {
      return res.status(403).json({
        success: false,
        error: 'Você não tem permissão para ver este pedido'
      } as ApiResponse);
    }

    // Busca os itens do pedido
    const itens = await query(
      `SELECT ip.*, p.nome as produto_nome, p.imagem_url
       FROM itens_pedido ip
       INNER JOIN produtos p ON ip.produto_id = p.id
       WHERE ip.pedido_id = ?`,
      [id]
    );

    res.json({
      success: true,
      data: {
        ...order,
        itens
      }
    } as ApiResponse);
  } catch (error) {
    console.error('Erro ao buscar pedido:', error);
    res.status(500).json({
      success: false,
      error: 'Erro ao buscar pedido'
    } as ApiResponse);
  }
};

/**
 * PATCH /api/orders/:id/status
 * Atualiza o status do pedido (apenas gerentes/admins)
 */
export const updateOrderStatus = async (req: Request, res: Response) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Não autenticado'
      } as ApiResponse);
    }

    const { id } = req.params;
    const { status, entregador_id } = req.body;

    // Chama a stored procedure para atualizar o status
    await query(
      'CALL sp_atualizar_status_pedido(?, ?, ?)',
      [id, status, entregador_id || null]
    );

    // Busca o pedido atualizado
    const orders: any = await query(
      'SELECT * FROM vw_pedidos_completos WHERE pedido_id = ?',
      [id]
    );

    res.json({
      success: true,
      data: orders[0],
      message: 'Status do pedido atualizado com sucesso'
    } as ApiResponse);
  } catch (error: any) {
    console.error('Erro ao atualizar status:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Erro ao atualizar status do pedido'
    } as ApiResponse);
  }
};

/**
 * POST /api/orders/:id/cancel
 * Cancela um pedido
 */
export const cancelOrder = async (req: Request, res: Response) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Não autenticado'
      } as ApiResponse);
    }

    const { id } = req.params;
    const { motivo } = req.body;

    // Chama a stored procedure para cancelar o pedido
    await query(
      'CALL sp_cancelar_pedido(?, ?, ?)',
      [id, motivo || 'Cliente solicitou cancelamento', req.user.userId]
    );

    res.json({
      success: true,
      message: 'Pedido cancelado com sucesso'
    } as ApiResponse);
  } catch (error: any) {
    console.error('Erro ao cancelar pedido:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Erro ao cancelar pedido'
    } as ApiResponse);
  }
};
