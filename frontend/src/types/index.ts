// ============================================================================
// TYPES E INTERFACES - Sistema de Delivery
// ============================================================================

export interface User {
  id: number;
  nome: string;
  email: string;
  telefone?: string;
  ativo: boolean;
  data_cadastro: string;
  ultimo_acesso?: string;
  grupos?: string[];
  nivel_acesso?: number;
}

export interface AuthResponse {
  success: boolean;
  user: User;
  token: string;
}

export interface LoginCredentials {
  email: string;
  senha: string;
}

export interface RegisterData {
  nome: string;
  email: string;
  senha: string;
  telefone?: string;
}

export interface Product {
  id: number;
  nome: string;
  descricao?: string;
  preco: number;
  categoria_id: number;
  categoria_nome?: string;
  imagem_url?: string;
  disponivel: boolean;
  estoque: number;
  destaque: boolean;
  tempo_preparo_minutos?: number;
  calorias?: number;
  ingredientes?: string;
}

export interface Category {
  id: number;
  nome: string;
  descricao?: string;
  icone?: string;
  ordem_exibicao: number;
  ativa: boolean;
}

export interface CartItem {
  produto_id: number;
  produto_nome: string;
  produto_preco: number;
  produto_imagem?: string;
  quantidade: number;
  observacoes?: string;
}

export interface Address {
  id: number;
  usuario_id: number;
  tipo_endereco: 'residencial' | 'comercial' | 'outro';
  logradouro: string;
  numero: string;
  complemento?: string;
  bairro: string;
  cidade: string;
  estado: string;
  cep: string;
  ponto_referencia?: string;
  principal: boolean;
}

export interface Order {
  id: number;
  usuario_id: number;
  endereco_id: number;
  valor_subtotal: number;
  valor_desconto: number;
  valor_entrega: number;
  valor_total: number;
  forma_pagamento: string;
  status_pedido: string;
  data_pedido: string;
  data_entrega_prevista?: string;
  data_entrega_realizada?: string;
  codigo_rastreamento?: string;
  observacoes?: string;
  avaliacao?: number;
  itens?: OrderItem[];
  endereco?: Address;
}

export interface OrderItem {
  id: number;
  pedido_id: number;
  produto_id: number;
  produto_nome: string;
  quantidade: number;
  preco_unitario: number;
  subtotal: number;
  observacoes?: string;
}

export interface CreateOrderData {
  endereco_id: number;
  forma_pagamento: 'dinheiro' | 'cartao_credito' | 'cartao_debito' | 'pix' | 'vale_refeicao';
  observacoes?: string;
  codigo_cupom?: string;
  itens: {
    produto_id: number;
    quantidade: number;
    observacoes?: string;
  }[];
}

export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}
