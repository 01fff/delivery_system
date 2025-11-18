import { Request, Response } from 'express';
import bcrypt from 'bcrypt';
import { query } from '../config/database';
import { generateToken } from '../middlewares/auth';
import { LoginRequest, RegisterRequest, User, ApiResponse, JWTPayload } from '../types';

/**
 * POST /api/auth/register
 * Registra um novo usuário no sistema
 */
export const register = async (req: Request, res: Response) => {
  try {
    const { nome, email, senha, telefone, cpf }: RegisterRequest = req.body;

    // Verifica se o email já existe
    const existingUser: any = await query(
      'SELECT id FROM usuarios WHERE email = ?',
      [email]
    );

    if (Array.isArray(existingUser) && existingUser.length > 0) {
      return res.status(400).json({
        success: false,
        error: 'Email já cadastrado'
      } as ApiResponse);
    }

    // Hash da senha
    const senha_hash = await bcrypt.hash(senha, 10);

    // Insere o usuário
    const result: any = await query(
      `INSERT INTO usuarios (nome, email, senha_hash, telefone, cpf, ativo, email_verificado)
       VALUES (?, ?, ?, ?, ?, TRUE, FALSE)`,
      [nome, email, senha_hash, telefone || null, cpf || null]
    );

    const userId = result.insertId;

    // Associa o usuário ao grupo "Cliente" (ID 1)
    await query(
      'INSERT INTO usuarios_grupos (usuario_id, grupo_id) VALUES (?, ?)',
      [userId, 1]
    );

    // Busca os dados completos do usuário
    const user: any = await query(
      `SELECT u.id, u.nome, u.email, u.telefone, u.ativo
       FROM usuarios u
       WHERE u.id = ?`,
      [userId]
    );

    // Gera o token
    const token = generateToken({
      userId,
      email,
      grupos: ['Cliente'],
      nivel_acesso: 1
    });

    res.status(201).json({
      success: true,
      data: {
        user: user[0],
        token
      },
      message: 'Usuário cadastrado com sucesso'
    } as ApiResponse);
  } catch (error) {
    console.error('Erro no registro:', error);
    res.status(500).json({
      success: false,
      error: 'Erro ao registrar usuário'
    } as ApiResponse);
  }
};

/**
 * POST /api/auth/login
 * Autentica um usuário e retorna um token JWT
 */
export const login = async (req: Request, res: Response) => {
  try {
    const { email, senha }: LoginRequest = req.body;

    // Busca o usuário com seus grupos
    const users: any = await query(
      `SELECT
        u.id, u.nome, u.email, u.senha_hash, u.telefone, u.ativo,
        GROUP_CONCAT(g.nome) as grupos,
        MAX(g.nivel_acesso) as nivel_acesso
       FROM usuarios u
       INNER JOIN usuarios_grupos ug ON u.id = ug.usuario_id
       INNER JOIN grupos_usuarios g ON ug.grupo_id = g.id
       WHERE u.email = ? AND u.ativo = TRUE
       GROUP BY u.id, u.nome, u.email, u.senha_hash, u.telefone, u.ativo`,
      [email]
    );

    if (!Array.isArray(users) || users.length === 0) {
      return res.status(401).json({
        success: false,
        error: 'Email ou senha inválidos'
      } as ApiResponse);
    }

    const user = users[0];

    // Verifica a senha
    const senhaValida = await bcrypt.compare(senha, user.senha_hash);

    if (!senhaValida) {
      return res.status(401).json({
        success: false,
        error: 'Email ou senha inválidos'
      } as ApiResponse);
    }

    // Atualiza o último acesso
    await query(
      'UPDATE usuarios SET ultimo_acesso = NOW() WHERE id = ?',
      [user.id]
    );

    // Prepara os grupos
    const grupos = user.grupos ? user.grupos.split(',') : ['Cliente'];

    // Gera o token
    const token = generateToken({
      userId: user.id,
      email: user.email,
      grupos,
      nivel_acesso: user.nivel_acesso || 1
    });

    // Remove o hash da senha antes de retornar
    delete user.senha_hash;

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          nome: user.nome,
          email: user.email,
          telefone: user.telefone,
          grupos,
          nivel_acesso: user.nivel_acesso
        },
        token
      },
      message: 'Login realizado com sucesso'
    } as ApiResponse);
  } catch (error) {
    console.error('Erro no login:', error);
    res.status(500).json({
      success: false,
      error: 'Erro ao fazer login'
    } as ApiResponse);
  }
};

/**
 * GET /api/auth/me
 * Retorna os dados do usuário autenticado
 */
export const getMe = async (req: Request, res: Response) => {
  try {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: 'Não autenticado'
      } as ApiResponse);
    }

    const users: any = await query(
      `SELECT
        u.id, u.nome, u.email, u.telefone, u.cpf, u.ativo,
        u.foto_perfil_url, u.email_verificado,
        GROUP_CONCAT(g.nome) as grupos,
        MAX(g.nivel_acesso) as nivel_acesso
       FROM usuarios u
       INNER JOIN usuarios_grupos ug ON u.id = ug.usuario_id
       INNER JOIN grupos_usuarios g ON ug.grupo_id = g.id
       WHERE u.id = ?
       GROUP BY u.id, u.nome, u.email, u.telefone, u.cpf, u.ativo,
                u.foto_perfil_url, u.email_verificado`,
      [req.user.userId]
    );

    if (!Array.isArray(users) || users.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Usuário não encontrado'
      } as ApiResponse);
    }

    const user = users[0];
    user.grupos = user.grupos ? user.grupos.split(',') : [];

    res.json({
      success: true,
      data: user
    } as ApiResponse);
  } catch (error) {
    console.error('Erro ao buscar usuário:', error);
    res.status(500).json({
      success: false,
      error: 'Erro ao buscar dados do usuário'
    } as ApiResponse);
  }
};
