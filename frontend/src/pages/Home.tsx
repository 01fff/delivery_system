// ============================================================================
// HOME PAGE - Página inicial com produtos em destaque
// ============================================================================

import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, Star, Clock, Truck } from 'lucide-react';
import { productsService } from '../services/api';
import type { Product } from '../types';
import ProductCard from '../components/ProductCard';
import toast from 'react-hot-toast';

const Home: React.FC = () => {
  const [featuredProducts, setFeaturedProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadFeaturedProducts();
  }, []);

  const loadFeaturedProducts = async () => {
    try {
      const response = await productsService.getAll({ destaque: true });
      if (response.success && response.data) {
        setFeaturedProducts(response.data.slice(0, 6));
      }
    } catch (error) {
      toast.error('Erro ao carregar produtos em destaque');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-r from-primary-600 to-primary-700 text-white py-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h1 className="text-4xl md:text-6xl font-bold mb-6">
              Delivery System
            </h1>
            <p className="text-xl md:text-2xl mb-8 text-primary-100">
              Sistema completo de delivery com MySQL, Node.js e React
            </p>
            <Link to="/products" className="btn bg-white text-primary-600 hover:bg-gray-100 text-lg px-8 py-3">
              Ver Produtos
              <ArrowRight className="inline ml-2" size={20} />
            </Link>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="inline-flex items-center justify-center w-16 h-16 bg-primary-100 rounded-full mb-4">
                <Star className="text-primary-600" size={32} />
              </div>
              <h3 className="text-xl font-semibold mb-2">Produtos de Qualidade</h3>
              <p className="text-gray-600">
                Seleção cuidadosa dos melhores produtos
              </p>
            </div>

            <div className="text-center">
              <div className="inline-flex items-center justify-center w-16 h-16 bg-primary-100 rounded-full mb-4">
                <Clock className="text-primary-600" size={32} />
              </div>
              <h3 className="text-xl font-semibold mb-2">Entrega Rápida</h3>
              <p className="text-gray-600">
                Receba seu pedido no conforto da sua casa
              </p>
            </div>

            <div className="text-center">
              <div className="inline-flex items-center justify-center w-16 h-16 bg-primary-100 rounded-full mb-4">
                <Truck className="text-primary-600" size={32} />
              </div>
              <h3 className="text-xl font-semibold mb-2">Rastreamento</h3>
              <p className="text-gray-600">
                Acompanhe seu pedido em tempo real
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Products Section */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center mb-8">
            <h2 className="text-3xl font-bold text-gray-900">
              Produtos em Destaque
            </h2>
            <Link
              to="/products"
              className="text-primary-600 hover:text-primary-700 font-medium flex items-center gap-2"
            >
              Ver todos
              <ArrowRight size={20} />
            </Link>
          </div>

          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[...Array(6)].map((_, i) => (
                <div key={i} className="card animate-pulse">
                  <div className="h-48 bg-gray-200 rounded -mx-6 -mt-6 mb-4"></div>
                  <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
                  <div className="h-4 bg-gray-200 rounded w-1/2"></div>
                </div>
              ))}
            </div>
          ) : featuredProducts.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {featuredProducts.map((product) => (
                <ProductCard key={product.id} product={product} />
              ))}
            </div>
          ) : (
            <div className="text-center py-12">
              <p className="text-gray-500">Nenhum produto em destaque no momento</p>
            </div>
          )}
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-primary-600 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl font-bold mb-4">
            Pronto para fazer seu pedido?
          </h2>
          <p className="text-xl text-primary-100 mb-8">
            Cadastre-se agora e aproveite nossas ofertas
          </p>
          <div className="flex gap-4 justify-center">
            <Link to="/register" className="btn bg-white text-primary-600 hover:bg-gray-100">
              Criar Conta
            </Link>
            <Link to="/products" className="btn bg-primary-700 text-white hover:bg-primary-800">
              Explorar Produtos
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Home;
