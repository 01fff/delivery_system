// ============================================================================
// FOOTER COMPONENT - Rodapé do site
// ============================================================================

import React from 'react';
import { Link } from 'react-router-dom';
import { Github, Mail, Phone } from 'lucide-react';

const Footer: React.FC = () => {
  return (
    <footer className="bg-gray-900 text-gray-300 mt-auto">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* About */}
          <div>
            <h3 className="text-white font-bold text-lg mb-4">
              Delivery System
            </h3>
            <p className="text-sm text-gray-400">
              Sistema completo de delivery desenvolvido para fins acadêmicos.
              Inclui MySQL, Node.js, React e TypeScript.
            </p>
          </div>

          {/* Links */}
          <div>
            <h3 className="text-white font-bold text-lg mb-4">Links</h3>
            <ul className="space-y-2">
              <li>
                <Link to="/" className="text-sm hover:text-white transition-colors">
                  Início
                </Link>
              </li>
              <li>
                <Link to="/products" className="text-sm hover:text-white transition-colors">
                  Produtos
                </Link>
              </li>
              <li>
                <Link to="/orders" className="text-sm hover:text-white transition-colors">
                  Meus Pedidos
                </Link>
              </li>
            </ul>
          </div>

          {/* Contact */}
          <div>
            <h3 className="text-white font-bold text-lg mb-4">Contato</h3>
            <ul className="space-y-2">
              <li className="flex items-center gap-2 text-sm">
                <Mail size={16} />
                <span>contato@delivery.com</span>
              </li>
              <li className="flex items-center gap-2 text-sm">
                <Phone size={16} />
                <span>(11) 99999-9999</span>
              </li>
              <li className="flex items-center gap-2 text-sm">
                <Github size={16} />
                <a
                  href="https://github.com/01fff/delivery_system"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="hover:text-white transition-colors"
                >
                  GitHub
                </a>
              </li>
            </ul>
          </div>

          {/* Info */}
          <div>
            <h3 className="text-white font-bold text-lg mb-4">Informações</h3>
            <p className="text-sm text-gray-400 mb-2">
              Projeto Acadêmico - Banco de Dados II
            </p>
            <p className="text-sm text-gray-400">
              Desenvolvido com MySQL, Node.js, Express, React e TypeScript
            </p>
          </div>
        </div>

        <div className="border-t border-gray-800 mt-8 pt-8 text-center">
          <p className="text-sm text-gray-400">
            &copy; {new Date().getFullYear()} Delivery System. Todos os direitos reservados.
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
