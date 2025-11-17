-- ============================================================================
-- SISTEMA DE DELIVERY - DADOS INICIAIS (SEED)
-- ============================================================================
-- Descrição: Dados de exemplo para testes e demonstração do sistema
-- ============================================================================

USE delivery_system;

-- ============================================================================
-- 1. GRUPOS DE USUÁRIOS
-- ============================================================================
INSERT INTO grupos_usuarios (nome, descricao, nivel_acesso) VALUES
('Cliente', 'Usuários que fazem pedidos no sistema', 1),
('Entregador', 'Entregadores responsáveis pela entrega dos pedidos', 2),
('Gerente', 'Gerentes que supervisionam operações', 3),
('Administrador', 'Administradores do sistema com acesso total', 4);

-- ============================================================================
-- 2. USUÁRIOS
-- Senhas são bcrypt hash de: "senha123"
-- Hash: $2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy
-- ============================================================================
INSERT INTO usuarios (nome, email, senha_hash, telefone, cpf, ativo, email_verificado) VALUES
-- Clientes
('João Silva', 'joao.silva@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '(11) 98765-4321', '123.456.789-00', TRUE, TRUE),
('Maria Santos', 'maria.santos@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '(11) 98765-4322', '123.456.789-01', TRUE, TRUE),
('Pedro Oliveira', 'pedro.oliveira@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '(11) 98765-4323', '123.456.789-02', TRUE, TRUE),
('Ana Costa', 'ana.costa@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '(11) 98765-4324', '123.456.789-03', TRUE, TRUE),
-- Entregadores
('Carlos Entregador', 'carlos.entrega@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '(11) 98765-5001', '123.456.789-10', TRUE, TRUE),
('Roberto Motoboy', 'roberto.moto@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '(11) 98765-5002', '123.456.789-11', TRUE, TRUE),
-- Gerente
('Fernanda Gerente', 'fernanda.gerente@email.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '(11) 98765-6001', '123.456.789-20', TRUE, TRUE),
-- Administrador
('Admin Sistema', 'admin@deliverysystem.com', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', '(11) 98765-9999', '123.456.789-99', TRUE, TRUE);

-- ============================================================================
-- 3. ASSOCIAÇÃO USUÁRIOS <-> GRUPOS
-- ============================================================================
INSERT INTO usuarios_grupos (usuario_id, grupo_id) VALUES
-- Clientes
(1, 1), (2, 1), (3, 1), (4, 1),
-- Entregadores
(5, 2), (6, 2),
-- Gerente
(7, 3),
-- Admin
(8, 4);

-- ============================================================================
-- 4. CATEGORIAS
-- ============================================================================
INSERT INTO categorias (nome, descricao, ordem_exibicao, ativo) VALUES
('Pizzas', 'Pizzas artesanais com massa fina e ingredientes frescos', 1, TRUE),
('Hamburguer', 'Hamburgueres gourmet com carnes selecionadas', 2, TRUE),
('Bebidas', 'Bebidas geladas: refrigerantes, sucos e águas', 3, TRUE),
('Sobremesas', 'Sobremesas deliciosas para adoçar seu dia', 4, TRUE),
('Salgados', 'Salgados assados e fritos', 5, TRUE),
('Japonesa', 'Culinária japonesa: sushi, sashimi e yakissoba', 6, TRUE);

-- ============================================================================
-- 5. PRODUTOS
-- ============================================================================
INSERT INTO produtos (categoria_id, nome, descricao, preco, preco_promocional, estoque, estoque_minimo, ativo, destaque, tempo_preparo_minutos) VALUES
-- Pizzas
(1, 'Pizza Margherita', 'Molho de tomate, mussarela, tomate, manjericão e azeite', 45.90, NULL, 50, 5, TRUE, TRUE, 35),
(1, 'Pizza Calabresa', 'Molho de tomate, mussarela, calabresa e cebola', 42.90, NULL, 50, 5, TRUE, FALSE, 35),
(1, 'Pizza Portuguesa', 'Molho, mussarela, presunto, ovo, cebola, azeitona', 49.90, 44.90, 50, 5, TRUE, TRUE, 35),
(1, 'Pizza Quatro Queijos', 'Mussarela, provolone, gorgonzola e parmesão', 52.90, NULL, 50, 5, TRUE, FALSE, 35),
-- Hamburguer
(2, 'X-Burger Clássico', 'Hamburguer 180g, queijo, alface, tomate, cebola', 28.90, NULL, 30, 3, TRUE, FALSE, 25),
(2, 'X-Bacon', 'Hamburguer 180g, queijo, bacon crocante, molho especial', 32.90, 29.90, 30, 3, TRUE, TRUE, 25),
(2, 'X-Egg', 'Hamburguer 180g, queijo, ovo, alface, tomate', 30.90, NULL, 30, 3, TRUE, FALSE, 25),
(2, 'X-Tudo', 'Hamburguer 180g, queijo, bacon, ovo, presunto, salada', 38.90, NULL, 30, 3, TRUE, TRUE, 30),
-- Bebidas
(3, 'Coca-Cola 350ml', 'Refrigerante Coca-Cola lata 350ml', 5.90, NULL, 100, 20, TRUE, FALSE, 2),
(3, 'Guaraná Antarctica 350ml', 'Refrigerante Guaraná lata 350ml', 5.90, NULL, 100, 20, TRUE, FALSE, 2),
(3, 'Suco de Laranja 500ml', 'Suco natural de laranja 500ml', 8.90, NULL, 50, 10, TRUE, FALSE, 5),
(3, 'Água Mineral 500ml', 'Água mineral sem gás 500ml', 3.50, NULL, 100, 20, TRUE, FALSE, 1),
-- Sobremesas
(4, 'Petit Gateau', 'Bolinho de chocolate quente com sorvete', 18.90, NULL, 20, 3, TRUE, TRUE, 15),
(4, 'Pudim de Leite', 'Pudim caseiro de leite condensado', 12.90, NULL, 15, 2, TRUE, FALSE, 5),
(4, 'Mousse de Maracujá', 'Mousse cremoso de maracujá', 14.90, 12.90, 15, 2, TRUE, FALSE, 5),
-- Salgados
(5, 'Coxinha de Frango', 'Coxinha recheada com frango e catupiry (unidade)', 6.50, NULL, 40, 10, TRUE, FALSE, 15),
(5, 'Pastel de Carne', 'Pastel frito recheado com carne moída (unidade)', 7.50, NULL, 40, 10, TRUE, FALSE, 15),
(5, 'Esfiha de Carne', 'Esfiha aberta de carne temperada (unidade)', 6.00, NULL, 40, 10, TRUE, FALSE, 12),
-- Japonesa
(6, 'Combinado Sushi 20 peças', '20 peças variadas de sushi e sashimi', 68.90, 62.90, 15, 2, TRUE, TRUE, 40),
(6, 'Yakissoba de Frango', 'Yakissoba com legumes e frango', 35.90, NULL, 20, 3, TRUE, FALSE, 30),
(6, 'Hot Roll Filadélfia', '8 unidades de hot roll com salmão e cream cheese', 42.90, NULL, 15, 2, TRUE, FALSE, 25);

-- ============================================================================
-- 6. ENDEREÇOS
-- ============================================================================
INSERT INTO enderecos (usuario_id, titulo, cep, rua, numero, complemento, bairro, cidade, estado, principal, ativo) VALUES
-- João Silva
(1, 'Casa', '01310-100', 'Avenida Paulista', '1578', 'Apto 101', 'Bela Vista', 'São Paulo', 'SP', TRUE, TRUE),
(1, 'Trabalho', '01310-200', 'Rua Augusta', '2500', 'Sala 302', 'Jardins', 'São Paulo', 'SP', FALSE, TRUE),
-- Maria Santos
(2, 'Casa', '04543-011', 'Avenida Brigadeiro Faria Lima', '1461', 'Apto 52', 'Jardim Paulistano', 'São Paulo', 'SP', TRUE, TRUE),
-- Pedro Oliveira
(3, 'Casa', '05407-002', 'Rua Cardeal Arcoverde', '2365', NULL, 'Pinheiros', 'São Paulo', 'SP', TRUE, TRUE),
-- Ana Costa
(4, 'Casa', '02012-000', 'Avenida Cruzeiro do Sul', '1000', 'Bloco A Apto 10', 'Santana', 'São Paulo', 'SP', TRUE, TRUE);

-- ============================================================================
-- 7. CUPONS DE DESCONTO
-- ============================================================================
INSERT INTO cupons_desconto (codigo, descricao, tipo_desconto, valor_desconto, valor_minimo_pedido, quantidade_disponivel, data_inicio, data_fim, ativo) VALUES
('BEMVINDO', 'Cupom de boas-vindas para novos clientes', 'PERCENTUAL', 15.00, 30.00, 100, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 90 DAY), TRUE),
('PROMO10', 'Desconto de 10% em qualquer pedido', 'PERCENTUAL', 10.00, 50.00, 50, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), TRUE),
('FRETE5', 'R$ 5,00 de desconto', 'VALOR_FIXO', 5.00, 25.00, NULL, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 60 DAY), TRUE),
('PIZZA20', '20% OFF em pizzas', 'PERCENTUAL', 20.00, 40.00, 30, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 15 DAY), TRUE);


-- ============================================================================
-- 8. PEDIDOS E ITENS (Exemplos de diferentes status)
-- ============================================================================

-- Pedido 1: João Silva - ENTREGUE
INSERT INTO pedidos (usuario_id, endereco_id, entregador_id, data_pedido, status, valor_entrega, valor_desconto, forma_pagamento, data_confirmacao, data_entrega)
VALUES (1, 1, 5, DATE_SUB(NOW(), INTERVAL 5 DAY), 'ENTREGUE', 5.00, 0.00, 'PIX', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY));

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
(1, 1, 1, 45.90),  -- Pizza Margherita
(1, 9, 2, 5.90);   -- Coca-Cola

-- Pedido 2: Maria Santos - ENTREGUE
INSERT INTO pedidos (usuario_id, endereco_id, entregador_id, data_pedido, status, valor_entrega, valor_desconto, forma_pagamento, data_confirmacao, data_entrega)
VALUES (2, 3, 6, DATE_SUB(NOW(), INTERVAL 3 DAY), 'ENTREGUE', 5.00, 5.00, 'CARTAO_CREDITO', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY));

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
(2, 8, 2, 38.90),  -- X-Tudo
(2, 10, 2, 5.90),  -- Guaraná
(2, 13, 1, 18.90); -- Petit Gateau

-- Pedido 3: Pedro Oliveira - PREPARANDO
INSERT INTO pedidos (usuario_id, endereco_id, data_pedido, status, valor_entrega, valor_desconto, forma_pagamento, data_confirmacao)
VALUES (3, 4, DATE_SUB(NOW(), INTERVAL 1 HOUR), 'PREPARANDO', 5.00, 0.00, 'PIX', DATE_SUB(NOW(), INTERVAL 50 MINUTE));

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
(3, 19, 1, 62.90),  -- Combinado Sushi (promoção)
(3, 12, 1, 3.50);   -- Água

-- Pedido 4: Ana Costa - PENDENTE
INSERT INTO pedidos (usuario_id, endereco_id, data_pedido, status, valor_entrega, valor_desconto, forma_pagamento, observacoes)
VALUES (4, 5, DATE_SUB(NOW(), INTERVAL 15 MINUTE), 'PENDENTE', 5.00, 0.00, 'DINHEIRO', 'Troco para R$ 100,00');

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
(4, 3, 1, 44.90),  -- Pizza Portuguesa (promoção)
(4, 11, 1, 8.90);  -- Suco de Laranja

-- Pedido 5: João Silva - SAIU_ENTREGA
INSERT INTO pedidos (usuario_id, endereco_id, entregador_id, data_pedido, status, valor_entrega, valor_desconto, forma_pagamento, data_confirmacao)
VALUES (1, 1, 5, DATE_SUB(NOW(), INTERVAL 30 MINUTE), 'SAIU_ENTREGA', 5.00, 0.00, 'CARTAO_DEBITO', DATE_SUB(NOW(), INTERVAL 25 MINUTE));

INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
(5, 6, 1, 29.90),  -- X-Bacon (promoção)
(5, 16, 3, 6.50);  -- Coxinha

-- ============================================================================
-- 9. AVALIAÇÕES
-- ============================================================================
INSERT INTO avaliacoes (pedido_id, usuario_id, nota, comentario) VALUES
(1, 1, 5, 'Excelente! Pizza veio quentinha e muito saborosa.'),
(2, 2, 4, 'Hamburguer muito bom, mas demorou um pouco.');

-- ============================================================================
-- VERIFICAÇÃO DOS DADOS INSERIDOS
-- ============================================================================

-- Verificar grupos de usuários
-- SELECT * FROM grupos_usuarios;

-- Verificar usuários e seus grupos
-- SELECT u.nome, u.email, g.nome AS grupo
-- FROM usuarios u
-- INNER JOIN usuarios_grupos ug ON ug.usuario_id = u.id
-- INNER JOIN grupos_usuarios g ON g.id = ug.grupo_id;

-- Verificar produtos por categoria
-- SELECT c.nome AS categoria, p.nome AS produto, p.preco
-- FROM produtos p
-- INNER JOIN categorias c ON c.id = p.categoria_id
-- ORDER BY c.ordem_exibicao, p.nome;

-- Verificar pedidos
-- SELECT * FROM vw_pedidos_completos;

-- Verificar produtos mais vendidos
-- SELECT * FROM vw_produtos_mais_vendidos LIMIT 10;

-- Verificar vendas por categoria
-- SELECT * FROM vw_vendas_por_categoria;

-- ============================================================================
-- ESTATÍSTICAS DOS DADOS
-- ============================================================================

-- Total de usuários: 8 (4 clientes, 2 entregadores, 1 gerente, 1 admin)
-- Total de categorias: 6
-- Total de produtos: 21
-- Total de pedidos: 5 (1 pendente, 1 preparando, 1 saiu_entrega, 2 entregues)
-- Total de itens vendidos: 13
-- Total de avaliações: 2
-- Total de cupons: 4

-- ============================================================================
-- FIM DOS DADOS INICIAIS
-- ============================================================================
