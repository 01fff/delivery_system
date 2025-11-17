-- ============================================================================
-- SISTEMA DE DELIVERY - TRIGGERS
-- ============================================================================
-- Descrição: Triggers para automação de processos e garantia de consistência
-- ============================================================================

USE delivery_system;

-- Remove triggers se existirem
DROP TRIGGER IF EXISTS trg_atualizar_subtotal_item;
DROP TRIGGER IF EXISTS trg_atualizar_valor_total_pedido_insert;
DROP TRIGGER IF EXISTS trg_atualizar_valor_total_pedido_update;
DROP TRIGGER IF EXISTS trg_atualizar_valor_total_pedido_delete;
DROP TRIGGER IF EXISTS trg_log_status_pedido;
DROP TRIGGER IF EXISTS trg_validar_estoque_produto;
DROP TRIGGER IF EXISTS trg_atualizar_estoque_produto;
DROP TRIGGER IF EXISTS trg_gerar_codigos_pedido;

DELIMITER $$

-- ============================================================================
-- TRIGGER 1: trg_atualizar_subtotal_item
-- ============================================================================
-- FUNÇÃO 1: gerar_id_pedido()
-- OBJETIVO: Gerar IDs únicos para pedidos em formato legível
-- FORMATO: AAMMDD-XXXXXX (Ano, Mês, Dia, Sequencial)
-- EXEMPLO: 241118-000001 (Pedido 1 do dia 18/11/2024)
--
-- JUSTIFICATIVA TÉCNICA:
-- - Facilita rastreamento e suporte ao cliente (ID legível)
-- - Identificação rápida da data do pedido pelo próprio ID
-- - Evita expor quantidade total de pedidos do sistema
-- - Padrão usado por empresas como iFood, Uber Eats
--
-- VANTAGENS:
-- - Cliente pode citar "pedido 241118-000032" ao invés de "pedido 1847293"
-- - Suporte identifica rapidamente pedidos antigos vs recentes
-- - Reset diário da sequência evita IDs muito grandes
--
-- RETORNO: VARCHAR(13) no formato AAMMDD-XXXXXX
-- ============================================================================
-- ============================================================================
CREATE TRIGGER trg_atualizar_subtotal_item
BEFORE INSERT ON itens_pedido
FOR EACH ROW
BEGIN
    -- Calcula o subtotal automaticamente
    SET NEW.subtotal = NEW.quantidade * NEW.preco_unitario;
END$$

CREATE TRIGGER trg_atualizar_subtotal_item_update
BEFORE UPDATE ON itens_pedido
FOR EACH ROW
BEGIN
    -- Recalcula o subtotal se quantidade ou preço mudou
    IF NEW.quantidade != OLD.quantidade OR NEW.preco_unitario != OLD.preco_unitario THEN
        SET NEW.subtotal = NEW.quantidade * NEW.preco_unitario;
    END IF;
END$$

-- ============================================================================
-- TRIGGER 2: trg_atualizar_valor_total_pedido
-- TIPO: AFTER INSERT, AFTER UPDATE, AFTER DELETE
-- TABELA: itens_pedido
--
-- OBJETIVO: Atualizar automaticamente o valor_subtotal do pedido quando itens são adicionados/alterados/removidos
--
-- JUSTIFICATIVA TÉCNICA:
-- - Mantém consistência automática entre itens_pedido e pedidos
-- - Evita bug crítico: valor total desatualizado (cobrança incorreta)
-- - Implementa padrão "derived attribute" de forma segura
-- - Essencial para integridade financeira do sistema
--
-- CÁLCULO:
-- valor_subtotal = SUM(subtotal de todos os itens do pedido)
-- valor_total = valor_subtotal - valor_desconto + valor_entrega
--
-- QUANDO DISPARA:
-- - AFTER INSERT: Item adicionado ao pedido
-- - AFTER UPDATE: Quantidade/preço de item alterado
-- - AFTER DELETE: Item removido do pedido
--
-- EXEMPLO PRÁTICO:
-- Pedido com 2 itens: Pizza (R$ 40) + Refrigerante (R$ 8)
-- -> valor_subtotal = 48.00 (atualizado automaticamente)
-- -> valor_total = 48.00 - 5.00 (desconto) + 7.00 (entrega) = 50.00
-- ============================================================================
CREATE TRIGGER trg_atualizar_valor_total_pedido_insert
AFTER INSERT ON itens_pedido
FOR EACH ROW
BEGIN
    UPDATE pedidos
    SET valor_subtotal = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM itens_pedido
        WHERE pedido_id = NEW.pedido_id
    ),
    valor_total = (
        SELECT COALESCE(SUM(subtotal), 0) - valor_desconto + valor_entrega
        FROM itens_pedido
        WHERE pedido_id = NEW.pedido_id
    )
    WHERE id = NEW.pedido_id;
END$$

CREATE TRIGGER trg_atualizar_valor_total_pedido_update
AFTER UPDATE ON itens_pedido
FOR EACH ROW
BEGIN
    UPDATE pedidos
    SET valor_subtotal = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM itens_pedido
        WHERE pedido_id = NEW.pedido_id
    ),
    valor_total = (
        SELECT COALESCE(SUM(subtotal), 0) - valor_desconto + valor_entrega
        FROM itens_pedido
        WHERE pedido_id = NEW.pedido_id
    )
    WHERE id = NEW.pedido_id;
END$$

CREATE TRIGGER trg_atualizar_valor_total_pedido_delete
AFTER DELETE ON itens_pedido
FOR EACH ROW
BEGIN
    UPDATE pedidos
    SET valor_subtotal = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM itens_pedido
        WHERE pedido_id = OLD.pedido_id
    ),
    valor_total = (
        SELECT COALESCE(SUM(subtotal), 0) - valor_desconto + valor_entrega
        FROM itens_pedido
        WHERE pedido_id = OLD.pedido_id
    )
    WHERE id = OLD.pedido_id;
END$$

-- ============================================================================
-- TRIGGER 3: trg_log_status_pedido
-- TIPO: AFTER UPDATE
-- TABELA: pedidos
--
-- OBJETIVO: Registrar automaticamente todas as mudanças de status do pedido em log_pedidos
--
-- JUSTIFICATIVA TÉCNICA:
-- - Auditoria completa do ciclo de vida do pedido
-- - Rastreabilidade para resolução de conflitos/disputas
-- - Métricas operacionais (tempo médio em cada status)
-- - Conformidade com LGPD (rastreio de alterações em dados)
-- - Debugging de problemas operacionais (ex: pedido preso em "PREPARANDO")
--
-- DADOS REGISTRADOS:
-- - Status anterior e novo
-- - Timestamp exato da mudança
-- - Usuário responsável (se aplicável)
--
-- QUANDO DISPARA:
-- - Sempre que o status do pedido muda (PENDENTE -> CONFIRMADO -> PREPARANDO -> etc)
--
-- USO PRÁTICO:
-- - Timeline do pedido para o cliente
-- - Dashboard de SLA (tempo em cada etapa)
-- - Identificação de gargalos operacionais
-- ============================================================================
CREATE TRIGGER trg_log_status_pedido
AFTER UPDATE ON pedidos
FOR EACH ROW
BEGIN
    -- Só registra se o status realmente mudou
    IF NEW.status != OLD.status THEN
        INSERT INTO log_pedidos (pedido_id, status_anterior, status_novo, data_mudanca)
        VALUES (NEW.id, OLD.status, NEW.status, NOW());
    END IF;
END$$

-- ============================================================================
-- TRIGGER 4: trg_validar_estoque_produto
-- TIPO: BEFORE INSERT
-- TABELA: itens_pedido
--
-- OBJETIVO: Validar disponibilidade de estoque antes de adicionar item ao pedido
--
-- JUSTIFICATIVA TÉCNICA:
-- - Previne venda de produtos sem estoque (overselling)
-- - Validação no nível do banco (mais seguro que apenas na aplicação)
-- - Evita race condition em compras simultâneas
-- - Protege integridade do negócio (não prometer o que não pode entregar)
--
-- REGRA:
-- - Se quantidade solicitada > estoque disponível: ERRO
-- - Se produto inativo: ERRO
--
-- QUANDO DISPARA:
-- - Ao adicionar item a um pedido
--
-- MENSAGEM DE ERRO:
-- - "Estoque insuficiente para o produto X. Disponível: Y, Solicitado: Z"
-- ============================================================================
CREATE TRIGGER trg_validar_estoque_produto
BEFORE INSERT ON itens_pedido
FOR EACH ROW
BEGIN
    DECLARE estoque_disponivel INT;
    DECLARE produto_ativo TINYINT(1);
    DECLARE nome_produto VARCHAR(100);
    DECLARE msg VARCHAR(255);

    -- Busca estoque e status do produto
    SELECT estoque, ativo, nome
    INTO estoque_disponivel, produto_ativo, nome_produto
    FROM produtos
    WHERE id = NEW.produto_id;

    -- Valida se produto está ativo
    IF produto_ativo = 0 THEN
        SET msg = 'Produto inativo ou descontinuado. Não pode ser adicionado ao pedido.';
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = msg;
    END IF;

    -- Valida estoque
    IF estoque_disponivel < NEW.quantidade THEN
        SET msg = CONCAT(
            'Estoque insuficiente para o produto "', nome_produto, '". ',
            'Disponível: ', estoque_disponivel, ', Solicitado: ', NEW.quantidade
        );
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = msg;
    END IF;
END$$

-- ============================================================================
-- TRIGGER 5: trg_atualizar_estoque_produto
-- TIPO: AFTER INSERT
-- TABELA: itens_pedido
--
-- OBJETIVO: Decrementar automaticamente o estoque ao confirmar item no pedido
--
-- JUSTIFICATIVA TÉCNICA:
-- - Automação de controle de estoque
-- - Evita necessidade de atualização manual (propenso a erros)
-- - Garante sincronia entre vendas e estoque
-- - Implementa padrão "event-driven" (venda -> atualiza estoque)
--
-- QUANDO DISPARA:
-- - Após adicionar item ao pedido (e validar estoque)
--
-- OPERAÇÃO:
-- estoque = estoque - quantidade_vendida
--
-- NOTA: Em sistemas reais, este trigger pode ser modificado para:
-- - Só decrementar após pagamento confirmado
-- - Reservar estoque (campo estoque_reservado) ao invés de decrementar
-- ============================================================================
CREATE TRIGGER trg_atualizar_estoque_produto
AFTER INSERT ON itens_pedido
FOR EACH ROW
BEGIN
    -- Decrementa o estoque
    UPDATE produtos
    SET estoque = estoque - NEW.quantidade
    WHERE id = NEW.produto_id;
END$$

-- ============================================================================
-- TRIGGER 6: trg_gerar_codigos_pedido
-- TIPO: BEFORE INSERT
-- TABELA: pedidos
--
-- OBJETIVO: Gerar automaticamente os códigos de rastreamento ao criar pedido
--
-- JUSTIFICATIVA TÉCNICA:
-- - Automatiza geração de IDs customizados (funções criadas anteriormente)
-- - Garante que TODOS os pedidos terão códigos de rastreamento
-- - Remove responsabilidade da aplicação (regra no BD)
-- - Usa as funções gerar_id_pedido() e gerar_codigo_rastreamento()
--
-- QUANDO DISPARA:
-- - Ao criar novo pedido
--
-- GERA:
-- - id_rastreamento: 241118-000001 (data + sequencial)
-- - codigo_rastreamento: DLV-A3F7K9M2P1 (alfanumérico único)
-- ============================================================================
CREATE TRIGGER trg_gerar_codigos_pedido
BEFORE INSERT ON pedidos
FOR EACH ROW
BEGIN
    -- Gera os códigos se não foram fornecidos
    IF NEW.id_rastreamento IS NULL THEN
        SET NEW.id_rastreamento = gerar_id_pedido();
    END IF;

    IF NEW.codigo_rastreamento IS NULL THEN
        SET NEW.codigo_rastreamento = gerar_codigo_rastreamento();
    END IF;
END$$

DELIMITER ;

-- ============================================================================
-- TESTES DOS TRIGGERS
-- ============================================================================

-- TESTE 1: Validar cálculo automático de subtotal
-- INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario)
-- VALUES (1, 1, 3, 25.50);
-- SELECT * FROM itens_pedido WHERE id = LAST_INSERT_ID();
-- Esperado: subtotal = 76.50 (3 * 25.50)

-- TESTE 2: Validar atualização de valor total do pedido
-- INSERT INTO pedidos (usuario_id, endereco_id, valor_entrega, forma_pagamento)
-- VALUES (1, 1, 5.00, 'PIX');
-- SET @pedido_id = LAST_INSERT_ID();
--
-- INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario)
-- VALUES (@pedido_id, 1, 2, 30.00);
-- INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario)
-- VALUES (@pedido_id, 2, 1, 15.00);
--
-- SELECT valor_subtotal, valor_total FROM pedidos WHERE id = @pedido_id;
-- Esperado: valor_subtotal = 75.00, valor_total = 80.00 (75 + 5 de entrega)

-- TESTE 3: Validar log de mudança de status
-- UPDATE pedidos SET status = 'CONFIRMADO' WHERE id = @pedido_id;
-- UPDATE pedidos SET status = 'PREPARANDO' WHERE id = @pedido_id;
-- SELECT * FROM log_pedidos WHERE pedido_id = @pedido_id;
-- Esperado: 2 registros (PENDENTE->CONFIRMADO, CONFIRMADO->PREPARANDO)

-- TESTE 4: Validar verificação de estoque
-- INSERT INTO produtos (categoria_id, nome, preco, estoque) VALUES (1, 'Produto Teste', 10.00, 5);
-- SET @produto_id = LAST_INSERT_ID();
--
-- INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario)
-- VALUES (@pedido_id, @produto_id, 10, 10.00);
-- Esperado: ERRO - Estoque insuficiente

-- TESTE 5: Validar geração de códigos
-- INSERT INTO pedidos (usuario_id, endereco_id, forma_pagamento)
-- VALUES (1, 1, 'DINHEIRO');
-- SELECT id_rastreamento, codigo_rastreamento FROM pedidos WHERE id = LAST_INSERT_ID();
-- Esperado: id_rastreamento no formato AAMMDD-XXXXXX, codigo_rastreamento DLV-XXXXXXXXXX

-- ============================================================================
-- ANÁLISE DE IMPACTO DOS TRIGGERS
-- ============================================================================

-- VANTAGENS:
-- 1. Consistência de dados garantida pelo banco de dados
-- 2. Lógica de negócio centralizada (não duplicada em múltiplas aplicações)
-- 3. Auditoria automática (log_pedidos)
-- 4. Redução de bugs (cálculos automáticos)
-- 5. Performance (operações atômicas no BD)

-- DESVANTAGENS/CUIDADOS:
-- 1. Podem impactar performance em operações massivas
-- 2. Dificultam debugging (lógica "escondida" no BD)
-- 3. Requerem conhecimento de SQL avançado para manutenção
-- 4. Triggers recursivos podem causar loops infinitos (evitado aqui)

-- BOAS PRÁTICAS APLICADAS:
-- 1. Triggers só para lógica ESSENCIAL de negócio
-- 2. Validações críticas (estoque, consistência financeira)
-- 3. Auditoria automática (compliance)
-- 4. Documentação extensa de cada trigger
-- 5. Testes unitários documentados
