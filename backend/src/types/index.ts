// Tipos do Sistema de Delivery

export interface User {
  id: number;
  nome: string;
  email: string;
  senha_hash?: string;
  telefone?: string;
  cpf?: string;
  data_nascimento?: Date;
  foto_perfil_url?: string;
  ativo: boolean;
  email_verificado: boolean;
  data_criacao: Date;
  data_atualizacao: Date;
  ultimo_acesso?: Date;
}

export interface UserGroup {
  id: number;
  nome: string;
  descricao?: string;
  nivel_acesso: number;
  ativo: boolean;
}

export interface Product {
  id: number;
  categoria_id: number;
  nome: string;
  descricao?: string;
  preco: number;
  preco_promocional?: number;
  estoque: number;
  estoque_minimo: number;
  imagem_url?: string;
  ativo: boolean;
  destaque: boolean;
  tempo_preparo_minutos?: number;
}

export interface Category {
  id: number;
  nome: string;
  descricao?: string;
  imagem_url?: string;
  ordem_exibicao: number;
  ativo: boolean;
}

export interface Order {
  id: number;
  usuario_id: number;
  endereco_id: number;
  entregador_id?: number;
  id_rastreamento?: string;
  codigo_rastreamento?: string;
  data_pedido: Date;
  status: OrderStatus;
  valor_subtotal: number;
  valor_desconto: number;
  valor_entrega: number;
  valor_total: number;
  forma_pagamento: PaymentMethod;
  observacoes?: string;
  tempo_estimado_minutos?: number;
  data_confirmacao?: Date;
  data_entrega?: Date;
  data_cancelamento?: Date;
  motivo_cancelamento?: string;
}

export interface OrderItem {
  id: number;
  pedido_id: number;
  produto_id: number;
  quantidade: number;
  preco_unitario: number;
  subtotal: number;
  observacoes?: string;
}

export interface Address {
  id: number;
  usuario_id: number;
  titulo?: string;
  cep: string;
  rua: string;
  numero: string;
  complemento?: string;
  bairro: string;
  cidade: string;
  estado: string;
  referencia?: string;
  principal: boolean;
  ativo: boolean;
}

export type OrderStatus =
  | 'PENDENTE'
  | 'CONFIRMADO'
  | 'PREPARANDO'
  | 'SAIU_ENTREGA'
  | 'ENTREGUE'
  | 'CANCELADO';

export type PaymentMethod =
  | 'DINHEIRO'
  | 'CARTAO_CREDITO'
  | 'CARTAO_DEBITO'
  | 'PIX'
  | 'VALE_REFEICAO';

export interface JWTPayload {
  userId: number;
  email: string;
  grupos: string[];
  nivel_acesso: number;
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
}

export interface LoginRequest {
  email: string;
  senha: string;
}

export interface RegisterRequest {
  nome: string;
  email: string;
  senha: string;
  telefone?: string;
  cpf?: string;
}

export interface CreateOrderRequest {
  endereco_id: number;
  forma_pagamento: PaymentMethod;
  observacoes?: string;
  codigo_cupom?: string;
  itens: {
    produto_id: number;
    quantidade: number;
  }[];
}
