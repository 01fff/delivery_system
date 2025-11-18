// ============================================================================
// ORDERS PAGE - Listagem de pedidos do usuário
// ============================================================================

import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { Package, Calendar, DollarSign, Eye } from 'lucide-react';
import { ordersService } from '../services/api';
import type { Order } from '../types';
import toast from 'react-hot-toast';

const statusColors: Record<string, string> = {
  pendente: 'bg-yellow-100 text-yellow-800',
  confirmado: 'bg-blue-100 text-blue-800',
  preparando: 'bg-purple-100 text-purple-800',
  saiu_entrega: 'bg-indigo-100 text-indigo-800',
  entregue: 'bg-green-100 text-green-800',
  cancelado: 'bg-red-100 text-red-800',
};

const statusLabels: Record<string, string> = {
  pendente: 'Pendente',
  confirmado: 'Confirmado',
  preparando: 'Preparando',
  saiu_entrega: 'Saiu para Entrega',
  entregue: 'Entregue',
  cancelado: 'Cancelado',
};

const Orders: React.FC = () => {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadOrders();
  }, []);

  const loadOrders = async () => {
    try {
      const response = await ordersService.getMyOrders();
      if (response.success && response.data) {
        setOrders(response.data);
      }
    } catch (error) {
      toast.error('Erro ao carregar pedidos');
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('pt-BR', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 py-8">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="card animate-pulse">
                <div className="h-4 bg-gray-200 rounded w-1/4 mb-4"></div>
                <div className="h-4 bg-gray-200 rounded w-1/2"></div>
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  if (orders.length === 0) {
    return (
      <div className="min-h-screen bg-gray-50 py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <Package className="mx-auto text-gray-400 mb-4" size={64} />
            <h2 className="text-2xl font-bold text-gray-900 mb-2">
              Você ainda não fez pedidos
            </h2>
            <p className="text-gray-600 mb-6">
              Explore nossos produtos e faça seu primeiro pedido
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
          Meus Pedidos
        </h1>

        <div className="space-y-4">
          {orders.map((order) => (
            <div key={order.id} className="card hover:shadow-lg transition-shadow">
              <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                {/* Order Info */}
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-2">
                    <h3 className="text-lg font-semibold text-gray-900">
                      Pedido #{order.id}
                    </h3>
                    <span
                      className={`px-3 py-1 rounded-full text-xs font-medium ${
                        statusColors[order.status_pedido] || 'bg-gray-100 text-gray-800'
                      }`}
                    >
                      {statusLabels[order.status_pedido] || order.status_pedido}
                    </span>
                  </div>

                  {order.codigo_rastreamento && (
                    <p className="text-sm text-gray-600 mb-1">
                      Código: {order.codigo_rastreamento}
                    </p>
                  )}

                  <div className="flex flex-wrap gap-4 text-sm text-gray-600">
                    <div className="flex items-center gap-1">
                      <Calendar size={16} />
                      <span>{formatDate(order.data_pedido)}</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <DollarSign size={16} />
                      <span>R$ {order.valor_total.toFixed(2)}</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <Package size={16} />
                      <span>{order.itens?.length || 0} {order.itens?.length === 1 ? 'item' : 'itens'}</span>
                    </div>
                  </div>
                </div>

                {/* Actions */}
                <div className="flex gap-2">
                  <Link
                    to={`/orders/${order.id}`}
                    className="btn btn-secondary flex items-center gap-2"
                  >
                    <Eye size={16} />
                    Ver Detalhes
                  </Link>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

export default Orders;
