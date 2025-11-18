// ============================================================================
// CART PAGE - Página do carrinho de compras
// ============================================================================

import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Trash2, Plus, Minus, ShoppingBag } from 'lucide-react';
import { useCart } from '../contexts/CartContext';
import { useAuth } from '../contexts/AuthContext';

const Cart: React.FC = () => {
  const { items, updateQuantity, removeItem, subtotal, itemCount } = useCart();
  const { isAuthenticated } = useAuth();
  const navigate = useNavigate();

  const handleCheckout = () => {
    if (!isAuthenticated) {
      navigate('/login', { state: { from: { pathname: '/checkout' } } });
    } else {
      navigate('/checkout');
    }
  };

  if (items.length === 0) {
    return (
      <div className="min-h-screen bg-gray-50 py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <ShoppingBag className="mx-auto text-gray-400 mb-4" size={64} />
            <h2 className="text-2xl font-bold text-gray-900 mb-2">
              Seu carrinho está vazio
            </h2>
            <p className="text-gray-600 mb-6">
              Adicione produtos para continuar
            </p>
            <Link to="/products" className="btn btn-primary">
              Ver Produtos
            </Link>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">
          Carrinho de Compras
        </h1>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Cart Items */}
          <div className="lg:col-span-2 space-y-4">
            {items.map((item) => (
              <div key={item.produto_id} className="card flex gap-4">
                {/* Image */}
                <div className="w-24 h-24 bg-gray-200 rounded flex-shrink-0">
                  {item.produto_imagem ? (
                    <img
                      src={item.produto_imagem}
                      alt={item.produto_nome}
                      className="w-full h-full object-cover rounded"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center text-gray-400 text-xs">
                      Sem imagem
                    </div>
                  )}
                </div>

                {/* Info */}
                <div className="flex-1">
                  <h3 className="font-semibold text-gray-900 mb-1">
                    {item.produto_nome}
                  </h3>
                  <p className="text-lg font-bold text-primary-600">
                    R$ {item.produto_preco.toFixed(2)}
                  </p>

                  {item.observacoes && (
                    <p className="text-sm text-gray-600 mt-2">
                      Obs: {item.observacoes}
                    </p>
                  )}
                </div>

                {/* Quantity Controls */}
                <div className="flex flex-col items-end justify-between">
                  <button
                    onClick={() => removeItem(item.produto_id)}
                    className="text-red-600 hover:text-red-700 p-2"
                    title="Remover"
                  >
                    <Trash2 size={20} />
                  </button>

                  <div className="flex items-center gap-2">
                    <button
                      onClick={() => updateQuantity(item.produto_id, item.quantidade - 1)}
                      className="w-8 h-8 rounded-full bg-gray-200 hover:bg-gray-300 flex items-center justify-center"
                    >
                      <Minus size={16} />
                    </button>
                    <span className="w-12 text-center font-semibold">
                      {item.quantidade}
                    </span>
                    <button
                      onClick={() => updateQuantity(item.produto_id, item.quantidade + 1)}
                      className="w-8 h-8 rounded-full bg-primary-600 hover:bg-primary-700 text-white flex items-center justify-center"
                    >
                      <Plus size={16} />
                    </button>
                  </div>

                  <p className="text-sm text-gray-600">
                    Subtotal: R$ {(item.produto_preco * item.quantidade).toFixed(2)}
                  </p>
                </div>
              </div>
            ))}
          </div>

          {/* Order Summary */}
          <div className="lg:col-span-1">
            <div className="card sticky top-24">
              <h2 className="text-xl font-bold text-gray-900 mb-4">
                Resumo do Pedido
              </h2>

              <div className="space-y-3 mb-6">
                <div className="flex justify-between text-gray-600">
                  <span>Itens ({itemCount})</span>
                  <span>R$ {subtotal.toFixed(2)}</span>
                </div>
                <div className="flex justify-between text-gray-600">
                  <span>Taxa de entrega</span>
                  <span>A calcular</span>
                </div>
                <div className="border-t pt-3">
                  <div className="flex justify-between text-lg font-bold">
                    <span>Total</span>
                    <span className="text-primary-600">
                      R$ {subtotal.toFixed(2)}
                    </span>
                  </div>
                </div>
              </div>

              <button
                onClick={handleCheckout}
                className="btn btn-primary w-full"
              >
                Finalizar Pedido
              </button>

              <Link
                to="/products"
                className="btn btn-secondary w-full mt-3"
              >
                Continuar Comprando
              </Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Cart;
