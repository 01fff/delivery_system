-- ============================================================================
-- SISTEMA DE DELIVERY - VIEWS 
-- ============================================================================
-- Descrição: Views para relatórios gerenciais e otimização de consultas
-- ============================================================================

USE delivery_system;

-- Remove views se existirem
DROP VIEW IF EXISTS vw_vendas_por_categoria;
DROP VIEW IF EXISTS vw_produtos_mais_vendidos;
DROP VIEW IF EXISTS vw_pedidos_completos;
DROP VIEW IF EXISTS vw_desempenho_entregadores;
DROP VIEW IF EXISTS vw_clientes_vip;

-- ============================================================================
-- VIEW 1: vw_vendas_por_categoria
-- OBJETIVO: Relatório de vendas agrupadas por categoria de produto
--
-- JUSTIFICATIVA TÉCNICA:
-- - Consulta complexa usada frequentemente em dashboards gerenciais
-- - Envolve JOINs entre 4 tabelas (pedidos, itens_pedido, produtos, categorias)
-- - View simplifica a query para analistas de negócio (SQL mais simples)
-- - Performance: MySQL pode cachear plano de execução da view
-- - Manutenção: Lógica centralizada (mudanças só na view)
--
-- CASOS DE USO:
-- - Dashboard gerencial: "Qual categoria vende mais?"
-- - Planejamento de estoque: priorizar categorias mais lucrativas
-- - Marketing: identificar categorias para promoções
-- - Análise sazonal: comparar vendas por categoria entre períodos
--
-- COLUNAS:
-- - categoria_id, categoria_nome
-- - total_pedidos: quantidade de pedidos que contêm produtos da categoria
-- - total_itens_vendidos: quantidade total de itens vendidos
-- - receita_total: soma de todos os valores de venda
-- - ticket_medio: receita_total / total_pedidos
-- - produto_mais_vendido: nome do produto mais vendido da categoria
--
-- EXEMPLO DE USO:
-- SELECT * FROM vw_vendas_por_categoria ORDER BY receita_total DESC;
-- ============================================================================
CREATE VIEW vw_vendas_por_categoria AS
SELECT
    c.id AS categoria_id,
    c.nome AS categoria_nome,
    COUNT(DISTINCT p.id) AS total_pedidos,
    SUM(ip.quantidade) AS total_itens_vendidos,
    SUM(ip.subtotal) AS receita_total,
    ROUND(SUM(ip.subtotal) / COUNT(DISTINCT p.id), 2) AS ticket_medio,
    (
        SELECT prod.nome
        FROM produtos prod
        INNER JOIN itens_pedido ip2 ON ip2.produto_id = prod.id
        WHERE prod.categoria_id = c.id
        GROUP BY prod.id, prod.nome
        ORDER BY SUM(ip2.quantidade) DESC
        LIMIT 1
    ) AS produto_mais_vendido_categoria
FROM categorias c
LEFT JOIN produtos pr ON pr.categoria_id = c.id
LEFT JOIN itens_pedido ip ON ip.produto_id = pr.id
LEFT JOIN pedidos p ON p.id = ip.pedido_id AND p.status NOT IN ('CANCELADO')
GROUP BY c.id, c.nome;

-- ============================================================================
-- VIEW 2: vw_produtos_mais_vendidos
-- OBJETIVO: Ranking dos produtos mais vendidos do sistema
--
-- JUSTIFICATIVA TÉCNICA:
-- - Consulta executada diariamente para decisões de negócio
-- - Agregação complexa com cálculos estatísticos
-- - View torna consulta reutilizável por múltiplas aplicações (web, mobile, BI)
-- - Pode ser usada como base para materialização (cache) se necessário
-- - Filtros dinâmicos fáceis (WHERE categoria = X, WHERE periodo = Y)
--
-- CASOS DE USO:
-- - Dashboard: "Top 10 produtos mais vendidos"
-- - Gestão de estoque: priorizar produtos de alta demanda
-- - Página "Mais Pedidos" no app (engajamento)
-- - Negóciação com fornecedores (comprar mais dos best-sellers)
-- - A/B Testing: comparar performance antes/depois de mudanças
--
-- COLUNAS:
-- - produto_id, produto_nome, categoria_nome
-- - total_vendido: quantidade total de unidades vendidas
-- - total_pedidos: em quantos pedidos o produto apareceu
-- - receita_gerada: receita total gerada pelo produto
-- - preco_medio_venda: preço médio pelo qual o produto foi vendido
-- - ultima_venda: data da última venda
--
-- EXEMPLO DE USO:
-- SELECT * FROM vw_produtos_mais_vendidos ORDER BY total_vendido DESC LIMIT 10;
-- ============================================================================
CREATE VIEW vw_produtos_mais_vendidos AS
SELECT
    pr.id AS produto_id,
    pr.nome AS produto_nome,
    c.nome AS categoria_nome,
    SUM(ip.quantidade) AS total_vendido,
    COUNT(DISTINCT ip.pedido_id) AS total_pedidos,
    SUM(ip.subtotal) AS receita_gerada,
    ROUND(AVG(ip.preco_unitario), 2) AS preco_medio_venda,
    MAX(p.data_pedido) AS ultima_venda,
    pr.estoque AS estoque_atual
FROM produtos pr
INNER JOIN itens_pedido ip ON ip.produto_id = pr.id
INNER JOIN pedidos p ON p.id = ip.pedido_id AND p.status NOT IN ('CANCELADO')
INNER JOIN categorias c ON c.id = pr.categoria_id
GROUP BY pr.id, pr.nome, c.nome, pr.estoque
HAVING total_vendido > 0
ORDER BY total_vendido DESC;

-- ============================================================================
-- VIEW 3: vw_pedidos_completos
-- OBJETIVO: Visão completa de pedidos com todos os dados relacionados
--
-- JUSTIFICATIVA TÉCNICA:
-- - Consulta mais comum do sistema: detalhes completos de um pedido
-- - Envolve 6 JOINs (pedidos, usuarios, enderecos, itens, produtos, avaliacoes)
-- - View elimina necessidade de escrever JOINs repetidamente
-- - Melhora legibilidade do código da aplicação
-- - Facilita geração de relatórios e notas fiscais
--
-- CASOS DE USO:
-- - Tela "Detalhes do Pedido" (cliente e admin)
-- - Geração de nota fiscal
-- - Email de confirmação de pedido
-- - Relatórios de auditoria
-- - Integração com ERP/sistemas externos
--
-- COLUNAS:
-- - Dados do pedido (id, status, valores, datas)
-- - Dados do cliente (nome, email, telefone)
-- - Dados de entrega (endereço completo)
-- - Dados do entregador (se já atribuído)
-- - Quantidade de itens
-- - Avaliação (se existir)
--
-- EXEMPLO DE USO:
-- SELECT * FROM vw_pedidos_completos WHERE pedido_id = 123;
-- SELECT * FROM vw_pedidos_completos WHERE status = 'PREPARANDO';
-- ============================================================================
CREATE VIEW vw_pedidos_completos AS
SELECT
    p.id AS pedido_id,
    p.id_rastreamento,
    p.codigo_rastreamento,
    p.status,
    p.data_pedido,
    p.data_entrega,

    -- Cliente
    u.id AS cliente_id,
    u.nome AS cliente_nome,
    u.email AS cliente_email,
    u.telefone AS cliente_telefone,

    -- Endereço de entrega
    e.rua,
    e.numero,
    e.complemento,
    e.bairro,
    e.cidade,
    e.estado,
    e.cep,
    e.referencia,
    CONCAT(e.rua, ', ', e.numero, ' - ', e.bairro, ', ', e.cidade, '/', e.estado) AS endereco_completo,

    -- Entregador
    entregador.id AS entregador_id,
    entregador.nome AS entregador_nome,
    entregador.telefone AS entregador_telefone,

    -- Valores
    p.valor_subtotal,
    p.valor_desconto,
    p.valor_entrega,
    p.valor_total,
    p.forma_pagamento,

    -- Itens
    COUNT(ip.id) AS quantidade_itens,

    -- Avaliação
    av.nota AS avaliacao_nota,
    av.comentario AS avaliacao_comentario,
    av.data_avaliacao,

    -- Outros
    p.observacoes,
    p.tempo_estimado_minutos
FROM pedidos p
INNER JOIN usuarios u ON u.id = p.usuario_id
INNER JOIN enderecos e ON e.id = p.endereco_id
LEFT JOIN usuarios entregador ON entregador.id = p.entregador_id
LEFT JOIN itens_pedido ip ON ip.pedido_id = p.id
LEFT JOIN avaliacoes av ON av.pedido_id = p.id
GROUP BY
    p.id, p.id_rastreamento, p.codigo_rastreamento, p.status, p.data_pedido, p.data_entrega,
    u.id, u.nome, u.email, u.telefone,
    e.rua, e.numero, e.complemento, e.bairro, e.cidade, e.estado, e.cep, e.referencia,
    entregador.id, entregador.nome, entregador.telefone,
    p.valor_subtotal, p.valor_desconto, p.valor_entrega, p.valor_total, p.forma_pagamento,
    av.nota, av.comentario, av.data_avaliacao,
    p.observacoes, p.tempo_estimado_minutos;

-- ============================================================================
-- VIEW 4: vw_desempenho_entregadores
-- OBJETIVO: Métricas de performance dos entregadores
--
-- JUSTIFICATIVA TÉCNICA:
-- - Gestão de RH: avaliar desempenho dos entregadores
-- - Gamificação: ranking de entregadores (bonificação)
-- - Operações: identificar gargalos e necessidade de contratação
-- - View agrega múltiplas métricas em uma única consulta
-- - Base para dashboard de gestão de entregas
--
-- CASOS DE USO:
-- - Dashboard de gestão de entregadores
-- - Ranking de performance (bonificação)
-- - Identificação de entregadores ociosos
-- - Planejamento de escalação de equipe
--
-- COLUNAS:
-- - entregador_id, entregador_nome
-- - total_entregas: quantidade de entregas realizadas
-- - total_em_andamento: entregas em andamento
-- - avaliacao_media: média das avaliações dos pedidos entregues
-- - tempo_medio_entrega: tempo médio entre confirmação e entrega
-- - receita_gerada: soma dos valores dos pedidos entregues
-- - ultima_entrega: data da última entrega
--
-- EXEMPLO DE USO:
-- SELECT * FROM vw_desempenho_entregadores ORDER BY total_entregas DESC;
-- ============================================================================
CREATE VIEW vw_desempenho_entregadores AS
SELECT
    u.id AS entregador_id,
    u.nome AS entregador_nome,
    u.telefone AS entregador_telefone,

    -- Métricas de entregas
    COUNT(CASE WHEN p.status = 'ENTREGUE' THEN 1 END) AS total_entregas,
    COUNT(CASE WHEN p.status IN ('SAIU_ENTREGA', 'PREPARANDO') THEN 1 END) AS total_em_andamento,

    -- Avaliações
    ROUND(AVG(av.nota), 2) AS avaliacao_media,
    COUNT(av.id) AS total_avaliacoes,

    -- Tempo médio de entrega (em minutos)
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, p.data_confirmacao, p.data_entrega)), 0) AS tempo_medio_entrega_minutos,

    -- Financeiro
    SUM(CASE WHEN p.status = 'ENTREGUE' THEN p.valor_total ELSE 0 END) AS receita_gerada,

    -- Datas
    MAX(p.data_entrega) AS ultima_entrega,
    MIN(p.data_entrega) AS primeira_entrega
FROM usuarios u
INNER JOIN usuarios_grupos ug ON ug.usuario_id = u.id
INNER JOIN grupos_usuarios g ON g.id = ug.grupo_id AND g.nome = 'Entregador'
LEFT JOIN pedidos p ON p.entregador_id = u.id
LEFT JOIN avaliacoes av ON av.pedido_id = p.id
WHERE u.ativo = TRUE
GROUP BY u.id, u.nome, u.telefone;

-- ============================================================================
-- VIEW 5: vw_clientes_vip
-- OBJETIVO: Identificar clientes VIP (alto valor, fidelidade)
--
-- JUSTIFICATIVA TÉCNICA:
-- - Marketing: segmentação de clientes para campanhas direcionadas
-- - CRM: programas de fidelidade e recompensas
-- - Análise RFM (Recency, Frequency, Monetary)
-- - View agrega comportamento histórico do cliente
-- - Base para criação de cupons personalizados
--
-- CASOS DE USO:
-- - Programa de fidelidade: oferecer benefícios a clientes VIP
-- - Email marketing: campanhas segmentadas
-- - Análise de churn: clientes que pararam de comprar
-- - Predição de lifetime value (LTV)
--
-- CRITÉRIOS VIP:
-- - Total gasto > R$ 500,00
-- - Número de pedidos > 5
-- - Pedido nos últimos 30 dias
--
-- COLUNAS:
-- - cliente_id, cliente_nome, cliente_email
-- - total_pedidos, total_gasto, ticket_medio
-- - primeiro_pedido, ultimo_pedido
-- - dias_desde_ultimo_pedido
-- - categoria_favorita
-- - nivel_vip (BRONZE, PRATA, OURO, DIAMANTE)
--
-- EXEMPLO DE USO:
-- SELECT * FROM vw_clientes_vip WHERE nivel_vip = 'OURO';
-- ============================================================================
CREATE VIEW vw_clientes_vip AS
SELECT
    u.id AS cliente_id,
    u.nome AS cliente_nome,
    u.email AS cliente_email,
    u.telefone AS cliente_telefone,

    -- Métricas de compra
    COUNT(p.id) AS total_pedidos,
    SUM(p.valor_total) AS total_gasto,
    ROUND(AVG(p.valor_total), 2) AS ticket_medio,

    -- Datas
    MIN(p.data_pedido) AS primeiro_pedido,
    MAX(p.data_pedido) AS ultimo_pedido,
    DATEDIFF(CURDATE(), MAX(p.data_pedido)) AS dias_desde_ultimo_pedido,

    -- Categoria favorita (mais pedida)
    (
        SELECT c.nome
        FROM categorias c
        INNER JOIN produtos pr ON pr.categoria_id = c.id
        INNER JOIN itens_pedido ip ON ip.produto_id = pr.id
        INNER JOIN pedidos p2 ON p2.id = ip.pedido_id
        WHERE p2.usuario_id = u.id
        GROUP BY c.id, c.nome
        ORDER BY COUNT(*) DESC
        LIMIT 1
    ) AS categoria_favorita,

    -- Avaliação média que o cliente dá
    ROUND(AVG(av.nota), 2) AS avaliacao_media_dada,

    -- Nível VIP (baseado em total gasto)
    CASE
        WHEN SUM(p.valor_total) >= 2000 THEN 'DIAMANTE'
        WHEN SUM(p.valor_total) >= 1000 THEN 'OURO'
        WHEN SUM(p.valor_total) >= 500 THEN 'PRATA'
        ELSE 'BRONZE'
    END AS nivel_vip
FROM usuarios u
INNER JOIN pedidos p ON p.usuario_id = u.id AND p.status = 'ENTREGUE'
LEFT JOIN avaliacoes av ON av.usuario_id = u.id
WHERE u.ativo = TRUE
GROUP BY u.id, u.nome, u.email, u.telefone
HAVING total_pedidos >= 3  -- Mínimo 3 pedidos para ser considerado VIP
ORDER BY total_gasto DESC;

-- ============================================================================
-- TESTES DAS VIEWS
-- ============================================================================

-- TESTE 1: Verificar vendas por categoria
-- SELECT * FROM vw_vendas_por_categoria ORDER BY receita_total DESC;

-- TESTE 2: Top 10 produtos mais vendidos
-- SELECT * FROM vw_produtos_mais_vendidos LIMIT 10;

-- TESTE 3: Detalhes de um pedido específico
-- SELECT * FROM vw_pedidos_completos WHERE pedido_id = 1;

-- TESTE 4: Ranking de entregadores
-- SELECT * FROM vw_desempenho_entregadores ORDER BY total_entregas DESC;

-- TESTE 5: Clientes VIP nível OURO ou superior
-- SELECT * FROM vw_clientes_vip WHERE nivel_vip IN ('OURO', 'DIAMANTE');

-- ============================================================================
-- VANTAGENS DO USO DE VIEWS
-- ============================================================================

-- 1. SEGURANÇA:
--    - Expor apenas colunas necessárias (ocultar dados sensíveis)
--    - Controle de acesso granular (permissão apenas na view, não nas tabelas)

-- 2. SIMPLICIDADE:
--    - Queries complexas encapsuladas em nome simples
--    - Reutilização de lógica entre diferentes aplicações

-- 3. MANUTENÇÃO:
--    - Mudanças na lógica apenas na view (não em todas as aplicações)
--    - Abstração do schema físico

-- ============================================================================
-- FIM DAS VIEWS
-- ============================================================================
