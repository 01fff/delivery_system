// ============================================================================
// CART CONTEXT - Gerenciamento do carrinho de compras
// ============================================================================

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import type { CartItem } from '../types';
import toast from 'react-hot-toast';

interface CartContextData {
  items: CartItem[];
  itemCount: number;
  subtotal: number;
  addItem: (item: CartItem) => void;
  removeItem: (produto_id: number) => void;
  updateQuantity: (produto_id: number, quantidade: number) => void;
  clearCart: () => void;
}

const CartContext = createContext<CartContextData>({} as CartContextData);

export const useCart = () => {
  const context = useContext(CartContext);
  if (!context) {
    throw new Error('useCart must be used within a CartProvider');
  }
  return context;
};

interface CartProviderProps {
  children: ReactNode;
}

export const CartProvider: React.FC<CartProviderProps> = ({ children }) => {
  const [items, setItems] = useState<CartItem[]>([]);

  // Carregar carrinho do localStorage
  useEffect(() => {
    const storedCart = localStorage.getItem('cart');
    if (storedCart) {
      try {
        setItems(JSON.parse(storedCart));
      } catch (error) {
        console.error('Erro ao carregar carrinho:', error);
      }
    }
  }, []);

  // Salvar carrinho no localStorage sempre que mudar
  useEffect(() => {
    localStorage.setItem('cart', JSON.stringify(items));
  }, [items]);

  const addItem = (newItem: CartItem) => {
    setItems((currentItems) => {
      const existingItem = currentItems.find(
        (item) => item.produto_id === newItem.produto_id
      );

      if (existingItem) {
        // Atualizar quantidade se o produto já existe
        toast.success('Quantidade atualizada no carrinho');
        return currentItems.map((item) =>
          item.produto_id === newItem.produto_id
            ? { ...item, quantidade: item.quantidade + newItem.quantidade }
            : item
        );
      } else {
        // Adicionar novo produto
        toast.success('Produto adicionado ao carrinho');
        return [...currentItems, newItem];
      }
    });
  };

  const removeItem = (produto_id: number) => {
    setItems((currentItems) =>
      currentItems.filter((item) => item.produto_id !== produto_id)
    );
    toast.success('Produto removido do carrinho');
  };

  const updateQuantity = (produto_id: number, quantidade: number) => {
    if (quantidade <= 0) {
      removeItem(produto_id);
      return;
    }

    setItems((currentItems) =>
      currentItems.map((item) =>
        item.produto_id === produto_id ? { ...item, quantidade } : item
      )
    );
  };

  const clearCart = () => {
    setItems([]);
    localStorage.removeItem('cart');
  };

  const itemCount = items.reduce((total, item) => total + item.quantidade, 0);
  const subtotal = items.reduce(
    (total, item) => total + item.produto_preco * item.quantidade,
    0
  );

  return (
    <CartContext.Provider
      value={{
        items,
        itemCount,
        subtotal,
        addItem,
        removeItem,
        updateQuantity,
        clearCart,
      }}
    >
      {children}
    </CartContext.Provider>
  );
};
