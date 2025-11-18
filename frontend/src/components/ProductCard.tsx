// ============================================================================
// PRODUCT CARD COMPONENT - Card de exibição de produto
// ============================================================================

import React from 'react';
import { Link } from 'react-router-dom';
import { ShoppingCart, Clock, Star } from 'lucide-react';
import type { Product } from '../types';
import { useCart } from '../contexts/CartContext';

interface ProductCardProps {
  product: Product;
}

const ProductCard: React.FC<ProductCardProps> = ({ product }) => {
  const { addItem } = useCart();

  const precoNumber =
    typeof product.preco === 'number'
      ? product.preco
      : Number(product.preco ?? 0);

  const isAvailable =
    (product as any).disponivel !== undefined
      ? (product as any).disponivel
      : (product as any).ativo !== false && (product.estoque ?? 0) > 0;

  const handleAddToCart = (e: React.MouseEvent) => {
    e.preventDefault();
    addItem({
      produto_id: product.id,
      produto_nome: product.nome,
      produto_preco: precoNumber,
      produto_imagem: product.imagem_url,
      quantidade: 1,
    });
  };

  return (
    <Link to={`/products/${product.id}`} className="block">
      <div className="card hover:shadow-lg transition-shadow duration-200 h-full flex flex-col">
        <div className="relative h-48 bg-gray-200 rounded-t-lg overflow-hidden -mx-6 -mt-6 mb-4">
          {product.imagem_url ? (
            <img
              src={product.imagem_url}
              alt={product.nome}
              className="w-full h-full object-cover"
            />
          ) : (
            <div className="w-full h-full flex items-center justify-center text-gray-400">
              Sem imagem
            </div>
          )}

          {product.destaque && (
            <div className="absolute top-2 right-2 bg-primary-600 text-white px-2 py-1 rounded text-xs font-bold">
              Destaque
            </div>
          )}

          {!isAvailable && (
            <div className="absolute inset-0 bg-black bg-opacity-50 flex items-center justify-center">
              <span className="text-white font-bold text-lg">Indisponível</span>
            </div>
          )}
        </div>

        <div className="flex-1 flex flex-col">
          {product.categoria_nome && (
            <span className="text-xs text-primary-600 font-medium mb-1">
              {product.categoria_nome}
            </span>
          )}

          <h3 className="text-lg font-semibold text-gray-900 mb-2 line-clamp-2">
            {product.nome}
          </h3>

          {product.descricao && (
            <p className="text-sm text-gray-600 mb-3 line-clamp-2 flex-1">
              {product.descricao}
            </p>
          )}

          <div className="flex items-center gap-3 text-xs text-gray-500 mb-3">
            {product.tempo_preparo_minutos && (
              <div className="flex items-center gap-1">
                <Clock size={14} />
                <span>{product.tempo_preparo_minutos} min</span>
              </div>
            )}
            {product.calorias && (
              <div className="flex items-center gap-1">
                <Star size={14} />
                <span>{product.calorias} cal</span>
              </div>
            )}
          </div>

          <div className="flex items-center justify-between mt-auto pt-3 border-t">
            <div>
              <span className="text-2xl font-bold text-gray-900">
                R$ {precoNumber.toFixed(2)}
              </span>
            </div>

            <button
              onClick={handleAddToCart}
              disabled={!isAvailable || (product.estoque ?? 0) <= 0}
              className="btn btn-primary flex items-center gap-2 text-sm"
            >
              <ShoppingCart size={16} />
              Adicionar
            </button>
          </div>

          {isAvailable && product.estoque <= 5 && product.estoque > 0 && (
            <p className="text-xs text-orange-600 mt-2">
              Apenas {product.estoque} unidades disponíveis
            </p>
          )}
        </div>
      </div>
    </Link>
  );
};

export default ProductCard;
