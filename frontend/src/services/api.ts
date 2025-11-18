// ============================================================================
// API SERVICE - Camada de comunicação com o backend
// ============================================================================

import axios, { AxiosError } from 'axios';
import type {
  ApiResponse,
  AuthResponse,
  LoginCredentials,
  RegisterData,
  Product,
  Category,
  Order,
  CreateOrderData,
  Address,
  User,
} from '../types';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001/api';

// Criar instância do axios com configurações padrão
const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor para adicionar token em todas as requisições
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor para tratar erros de autenticação
api.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      // Token inválido ou expirado
      localStorage.removeItem('token');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

// ============================================================================
// AUTENTICAÇÃO
// ============================================================================

export const authService = {
  async register(data: RegisterData): Promise<AuthResponse> {
    const response = await api.post<AuthResponse>('/auth/register', data);
    return response.data;
  },

  async login(credentials: LoginCredentials): Promise<AuthResponse> {
    const response = await api.post<AuthResponse>('/auth/login', credentials);
    return response.data;
  },

  async getMe(): Promise<ApiResponse<User>> {
    const response = await api.get<ApiResponse<User>>('/auth/me');
    return response.data;
  },

  logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
  },
};

// ============================================================================
// PRODUTOS
// ============================================================================

export const productsService = {
  async getAll(params?: {
    categoria_id?: number;
    search?: string;
    destaque?: boolean;
  }): Promise<ApiResponse<Product[]>> {
    const response = await api.get<ApiResponse<Product[]>>('/products', { params });
    return response.data;
  },

  async getById(id: number): Promise<ApiResponse<Product>> {
    const response = await api.get<ApiResponse<Product>>(`/products/${id}`);
    return response.data;
  },

  async getCategories(): Promise<ApiResponse<Category[]>> {
    const response = await api.get<ApiResponse<Category[]>>('/products/categories/all');
    return response.data;
  },
};

// ============================================================================
// PEDIDOS
// ============================================================================

export const ordersService = {
  async create(orderData: CreateOrderData): Promise<ApiResponse<Order>> {
    const response = await api.post<ApiResponse<Order>>('/orders', orderData);
    return response.data;
  },

  async getMyOrders(): Promise<ApiResponse<Order[]>> {
    const response = await api.get<ApiResponse<Order[]>>('/orders');
    return response.data;
  },

  async getById(id: number): Promise<ApiResponse<Order>> {
    const response = await api.get<ApiResponse<Order>>(`/orders/${id}`);
    return response.data;
  },

  async cancel(id: number): Promise<ApiResponse<Order>> {
    const response = await api.post<ApiResponse<Order>>(`/orders/${id}/cancel`);
    return response.data;
  },

  async updateStatus(
    id: number,
    status: string
  ): Promise<ApiResponse<Order>> {
    const response = await api.patch<ApiResponse<Order>>(`/orders/${id}/status`, {
      novo_status: status,
    });
    return response.data;
  },
};

// ============================================================================
// ENDEREÇOS
// ============================================================================

export const addressService = {
  async getMyAddresses(): Promise<ApiResponse<Address[]>> {
    const response = await api.get<ApiResponse<Address[]>>('/addresses');
    return response.data;
  },

  async create(address: Omit<Address, 'id' | 'usuario_id'>): Promise<ApiResponse<Address>> {
    const response = await api.post<ApiResponse<Address>>('/addresses', address);
    return response.data;
  },

  async update(id: number, address: Partial<Address>): Promise<ApiResponse<Address>> {
    const response = await api.put<ApiResponse<Address>>(`/addresses/${id}`, address);
    return response.data;
  },

  async delete(id: number): Promise<ApiResponse<void>> {
    const response = await api.delete<ApiResponse<void>>(`/addresses/${id}`);
    return response.data;
  },
};

export default api;
