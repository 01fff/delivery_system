// ============================================================================
// CHECKOUT PAGE - Finalização do pedido
// ============================================================================

import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { CreditCard, MapPin, FileText } from 'lucide-react';
import { useCart } from '../contexts/CartContext';
import { ordersService } from '../services/api';
import type { CreateOrderData } from '../types';
import toast from 'react-hot-toast';

const paymentMethods = [
  { value: 'pix', label: 'PIX' },
  { value: 'cartao_credito', label: 'Cartão de Crédito' },
  { value: 'cartao_debito', label: 'Cartão de Débito' },
  { value: 'dinheiro', label: 'Dinheiro' },
  { value: 'vale_refeicao', label: 'Vale Refeição' },
];

const Checkout: React.FC = () => {
  const { items, subtotal, clearCart } = useCart();
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);

  const [formData, setFormData] = useState({
    logradouro: '',
    numero: '',
    complemento: '',
    bairro: '',
    cidade: '',
    estado: '',
    cep: '',
    forma_pagamento: 'pix' as any,
    observacoes: '',
    codigo_cupom: '',
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      // Criar endereço temporário (ID 1 para teste)
      // Em produção, você criaria o endereço primeiro via addressService.create()
      const endereco_id = 1;

      const orderData: CreateOrderData = {
        endereco_id,
        forma_pagamento: formData.forma_pagamento,
        observacoes: formData.observacoes || undefined,
        codigo_cupom: formData.codigo_cupom || undefined,
        itens: items.map((item) => ({
          produto_id: item.produto_id,
          quantidade: item.quantidade,
          observacoes: item.observacoes,
        })),
      };

      const response = await ordersService.create(orderData);

      if (response.success && response.data) {
        toast.success('Pedido realizado com sucesso!');
        clearCart();
        navigate(`/orders/${response.data.id}`);
      }
    } catch (error: any) {
      const message = error.response?.data?.error || 'Erro ao processar pedido';
      toast.error(message);
    } finally {
      setLoading(false);
    }
  };

  if (items.length === 0) {
    navigate('/cart');
    return null;
  }

  const valorEntrega = 5.0;
  const total = subtotal + valorEntrega;

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">
          Finalizar Pedido
        </h1>

        <form onSubmit={handleSubmit}>
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            {/* Forms */}
            <div className="lg:col-span-2 space-y-6">
              {/* Endereço */}
              <div className="card">
                <div className="flex items-center gap-2 mb-4">
                  <MapPin className="text-primary-600" size={24} />
                  <h2 className="text-xl font-bold text-gray-900">
                    Endereço de Entrega
                  </h2>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      CEP *
                    </label>
                    <input
                      type="text"
                      name="cep"
                      required
                      value={formData.cep}
                      onChange={handleChange}
                      className="input"
                      placeholder="00000-000"
                    />
                  </div>

                  <div className="md:col-span-2">
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Logradouro *
                    </label>
                    <input
                      type="text"
                      name="logradouro"
                      required
                      value={formData.logradouro}
                      onChange={handleChange}
                      className="input"
                      placeholder="Rua, Avenida, etc."
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Número *
                    </label>
                    <input
                      type="text"
                      name="numero"
                      required
                      value={formData.numero}
                      onChange={handleChange}
                      className="input"
                      placeholder="123"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Complemento
                    </label>
                    <input
                      type="text"
                      name="complemento"
                      value={formData.complemento}
                      onChange={handleChange}
                      className="input"
                      placeholder="Apto, Bloco, etc."
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Bairro *
                    </label>
                    <input
                      type="text"
                      name="bairro"
                      required
                      value={formData.bairro}
                      onChange={handleChange}
                      className="input"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Cidade *
                    </label>
                    <input
                      type="text"
                      name="cidade"
                      required
                      value={formData.cidade}
                      onChange={handleChange}
                      className="input"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">
                      Estado *
                    </label>
                    <input
                      type="text"
                      name="estado"
                      required
                      value={formData.estado}
                      onChange={handleChange}
                      className="input"
                      placeholder="SP"
                      maxLength={2}
                    />
                  </div>
                </div>
              </div>

              {/* Pagamento */}
              <div className="card">
                <div className="flex items-center gap-2 mb-4">
                  <CreditCard className="text-primary-600" size={24} />
                  <h2 className="text-xl font-bold text-gray-900">
                    Forma de Pagamento
                  </h2>
                </div>

                <div className="space-y-3">
                  {paymentMethods.map((method) => (
                    <label
                      key={method.value}
                      className="flex items-center gap-3 p-3 border rounded-lg cursor-pointer hover:bg-gray-50"
                    >
                      <input
                        type="radio"
                        name="forma_pagamento"
                        value={method.value}
                        checked={formData.forma_pagamento === method.value}
                        onChange={handleChange}
                        className="w-4 h-4 text-primary-600"
                      />
                      <span className="font-medium">{method.label}</span>
                    </label>
                  ))}
                </div>
              </div>

              {/* Observações */}
              <div className="card">
                <div className="flex items-center gap-2 mb-4">
                  <FileText className="text-primary-600" size={24} />
                  <h2 className="text-xl font-bold text-gray-900">
                    Observações
                  </h2>
                </div>

                <textarea
                  name="observacoes"
                  value={formData.observacoes}
                  onChange={handleChange}
                  rows={3}
                  className="input"
                  placeholder="Alguma observação sobre o pedido?"
                />

                <div className="mt-4">
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Cupom de Desconto
                  </label>
                  <input
                    type="text"
                    name="codigo_cupom"
                    value={formData.codigo_cupom}
                    onChange={handleChange}
                    className="input"
                    placeholder="Digite o código do cupom"
                  />
                </div>
              </div>
            </div>

            {/* Summary */}
            <div className="lg:col-span-1">
              <div className="card sticky top-24">
                <h2 className="text-xl font-bold text-gray-900 mb-4">
                  Resumo do Pedido
                </h2>

                {/* Items */}
                <div className="space-y-2 mb-4 max-h-64 overflow-y-auto">
                  {items.map((item) => (
                    <div key={item.produto_id} className="flex justify-between text-sm">
                      <span className="text-gray-600">
                        {item.quantidade}x {item.produto_nome}
                      </span>
                      <span className="font-medium">
                        R$ {(item.produto_preco * item.quantidade).toFixed(2)}
                      </span>
                    </div>
                  ))}
                </div>

                {/* Totals */}
                <div className="space-y-2 border-t pt-4">
                  <div className="flex justify-between text-gray-600">
                    <span>Subtotal</span>
                    <span>R$ {subtotal.toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between text-gray-600">
                    <span>Taxa de entrega</span>
                    <span>R$ {valorEntrega.toFixed(2)}</span>
                  </div>
                  <div className="flex justify-between text-lg font-bold pt-2 border-t">
                    <span>Total</span>
                    <span className="text-primary-600">
                      R$ {total.toFixed(2)}
                    </span>
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={loading}
                  className="btn btn-primary w-full mt-6"
                >
                  {loading ? (
                    <span className="flex items-center justify-center gap-2">
                      <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                      Processando...
                    </span>
                  ) : (
                    'Confirmar Pedido'
                  )}
                </button>
              </div>
            </div>
          </div>
        </form>
      </div>
    </div>
  );
};

export default Checkout;
