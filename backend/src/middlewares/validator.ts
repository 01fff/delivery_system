import { Request, Response, NextFunction } from 'express';
import Joi from 'joi';

/**
 * Middleware genérico de validação usando Joi
 */
export const validate = (schema: Joi.ObjectSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true
    });

    if (error) {
      const errors = error.details.map(detail => ({
        field: detail.path.join('.'),
        message: detail.message
      }));

      return res.status(400).json({
        success: false,
        error: 'Dados inválidos',
        details: errors
      });
    }

    next();
  };
};

// Schemas de validação

export const registerSchema = Joi.object({
  nome: Joi.string().min(3).max(100).required().messages({
    'string.empty': 'Nome é obrigatório',
    'string.min': 'Nome deve ter no mínimo 3 caracteres'
  }),
  email: Joi.string().email().required().messages({
    'string.empty': 'Email é obrigatório',
    'string.email': 'Email inválido'
  }),
  senha: Joi.string().min(6).required().messages({
    'string.empty': 'Senha é obrigatória',
    'string.min': 'Senha deve ter no mínimo 6 caracteres'
  }),
  telefone: Joi.string().optional(),
  cpf: Joi.string().optional()
});

export const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  senha: Joi.string().required()
});

export const createOrderSchema = Joi.object({
  endereco_id: Joi.number().integer().positive().required(),
  forma_pagamento: Joi.string()
    .valid('DINHEIRO', 'CARTAO_CREDITO', 'CARTAO_DEBITO', 'PIX', 'VALE_REFEICAO')
    .required(),
  observacoes: Joi.string().max(500).optional(),
  codigo_cupom: Joi.string().max(20).optional(),
  itens: Joi.array()
    .items(
      Joi.object({
        produto_id: Joi.number().integer().positive().required(),
        quantidade: Joi.number().integer().min(1).required()
      })
    )
    .min(1)
    .required()
});

export const createAddressSchema = Joi.object({
  titulo: Joi.string().max(50).optional(),
  cep: Joi.string().pattern(/^\d{5}-?\d{3}$/).required(),
  rua: Joi.string().max(255).required(),
  numero: Joi.string().max(10).required(),
  complemento: Joi.string().max(100).optional(),
  bairro: Joi.string().max(100).required(),
  cidade: Joi.string().max(100).required(),
  estado: Joi.string().length(2).required(),
  referencia: Joi.string().max(500).optional(),
  principal: Joi.boolean().optional()
});

export const updateOrderStatusSchema = Joi.object({
  status: Joi.string()
    .valid('PENDENTE', 'CONFIRMADO', 'PREPARANDO', 'SAIU_ENTREGA', 'ENTREGUE', 'CANCELADO')
    .required(),
  entregador_id: Joi.number().integer().positive().optional(),
  motivo_cancelamento: Joi.string().max(500).optional()
});
