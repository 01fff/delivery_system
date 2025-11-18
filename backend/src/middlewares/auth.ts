import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { JWTPayload } from '../types';

// Extende o tipo Request para incluir user
declare global {
  namespace Express {
    interface Request {
      user?: JWTPayload;
    }
  }
}

const JWT_SECRET = process.env.JWT_SECRET || 'secret_padrao_mude_em_producao';

/**
 * Middleware de autenticação JWT
 * Verifica se o token é válido e adiciona os dados do usuário na request
 */
export const authenticateToken = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    // Pega o token do header Authorization
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return res.status(401).json({
        success: false,
        error: 'Token não fornecido'
      });
    }

    // Verifica o token
    jwt.verify(token, JWT_SECRET, (err, decoded) => {
      if (err) {
        return res.status(403).json({
          success: false,
          error: 'Token inválido ou expirado'
        });
      }

      // Adiciona os dados do usuário na request
      req.user = decoded as JWTPayload;
      next();
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      error: 'Erro ao verificar token'
    });
  }
};

/**
 * Middleware para verificar nível de acesso mínimo
 */
export const requireRole = (nivelMinimo: number) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Usuário não autenticado'
      });
    }

    if (req.user.nivel_acesso < nivelMinimo) {
      return res.status(403).json({
        success: false,
        error: 'Permissão insuficiente'
      });
    }

    next();
  };
};

/**
 * Middleware para verificar se usuário pertence a um grupo específico
 */
export const requireGroup = (gruposPermitidos: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Usuário não autenticado'
      });
    }

    const temPermissao = req.user.grupos.some(grupo =>
      gruposPermitidos.includes(grupo)
    );

    if (!temPermissao) {
      return res.status(403).json({
        success: false,
        error: 'Você não tem permissão para acessar este recurso'
      });
    }

    next();
  };
};

/**
 * Gera um token JWT para o usuário
 */
export const generateToken = (payload: JWTPayload): string => {
  return jwt.sign(payload, JWT_SECRET, {
    expiresIn: '7d'
  });
};

/**
 * Verifica se o token é válido sem middleware
 */
export const verifyToken = (token: string): JWTPayload | null => {
  try {
    return jwt.verify(token, JWT_SECRET) as JWTPayload;
  } catch (error) {
    return null;
  }
};