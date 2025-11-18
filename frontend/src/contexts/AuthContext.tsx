// ============================================================================
// AUTH CONTEXT - Gerenciamento de autenticação global
// ============================================================================

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { authService } from '../services/api';
import type { User, LoginCredentials, RegisterData } from '../types';
import toast from 'react-hot-toast';

interface AuthContextData {
  user: User | null;
  token: string | null;
  loading: boolean;
  isAuthenticated: boolean;
  login: (credentials: LoginCredentials) => Promise<void>;
  register: (data: RegisterData) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextData>({} as AuthContextData);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  // Carregar dados do usuário ao montar o componente
  useEffect(() => {
    const loadStoredData = async () => {
      const storedToken = localStorage.getItem('token');
      const storedUser = localStorage.getItem('user');

      if (storedToken && storedUser) {
        setToken(storedToken);
        setUser(JSON.parse(storedUser));

        // Validar token com o backend
        try {
          const response = await authService.getMe();
          if (response.success && response.data) {
            setUser(response.data);
            localStorage.setItem('user', JSON.stringify(response.data));
          }
        } catch (error) {
          // Token inválido
          localStorage.removeItem('token');
          localStorage.removeItem('user');
          setToken(null);
          setUser(null);
        }
      }

      setLoading(false);
    };

    loadStoredData();
  }, []);

    const login = async (credentials: LoginCredentials) => {
    try {
      const response = await authService.login(credentials);
      

      const { success, data, error } = response;

      if (!success || !data) {
        throw new Error(error || 'Credenciais inválidas');
      }

      const { user, token } = data;

      setUser(user);
      setToken(token);

      localStorage.setItem('token', token);
      localStorage.setItem('user', JSON.stringify(user));

      toast.success(`Bem-vindo, ${user.nome}!`);
    } catch (error: any) {
      const message =
        error.response?.data?.error ||
        error.message ||
        'Erro ao fazer login';
      toast.error(message);
      throw error;
    }
  };

  const register = async (data: RegisterData) => {
    try {
      const response = await authService.register(data);

      const { success, data: payload, error } = response;

      if (!success || !payload) {
        throw new Error(error || 'Erro ao criar conta');
      }

      const { user, token } = payload;

      setUser(user);
      setToken(token);

      localStorage.setItem('token', token);
      localStorage.setItem('user', JSON.stringify(user));

      toast.success('Conta criada com sucesso!');
    } catch (error: any) {
      const message =
        error.response?.data?.error ||
        error.message ||
        'Erro ao criar conta';
      toast.error(message);
      throw error;
    }
  };

  const logout = () => {
    authService.logout();
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    setUser(null);
    setToken(null);
    toast.success('Logout realizado com sucesso');
  };


  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        loading,
        isAuthenticated: !!user && !!token,
        login,
        register,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};
