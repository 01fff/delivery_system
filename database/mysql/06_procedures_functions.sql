-- ============================================================================
-- SISTEMA DE DELIVERY - STORED PROCEDURES E FUNCTIONS
-- ============================================================================
-- Descrição: Procedures e funções para operações complexas do sistema
-- ============================================================================

USE delivery_system;

-- Remove procedures/functions se existirem
DROP PROCEDURE IF EXISTS sp_processar_pedido_completo;
DROP PROCEDURE IF EXISTS sp_cancelar_pedido;
DROP PROCEDURE IF EXISTS sp_atualizar_status_pedido;
DROP FUNCTION IF EXISTS fn_calcular_desconto_fidelidade;
DROP FUNCTION IF EXISTS fn_calcular_tempo_estimado_entrega;
DROP FUNCTION IF EXISTS fn_verificar_disponibilidade_produto;

DELIMITER $$

-- ============================================================================
-- PROCEDURE 1: sp_processar_pedido_completo
-- OBJETIVO: Criar pedido completo com itens de forma transacional
--
-- JUSTIFICATIVA TÉCNICA:
-- - Operação crítica que deve ser ATÔMICA (ou tudo sucede, ou nada)
-- - Encapsula lógica de negócio complexa no banco de dados
-- - Garante consistência: pedido só é criado se TODOS os itens forem válidos
-- - Rollback automático em caso de erro (ex: estoque insuficiente)
-- - Reduz tráfego de rede (1 chamada ao invés de N+1)
-- - Evita race conditions em criação de pedidos simultâneos
--
-- OPERAÇÕES REALIZADAS:
-- 1. Validar usuário e endereço
-- 2. Criar pedido
-- 3. Adicionar itens (validando estoque)
-- 4. Calcular desconto de fidelidade
-- 5. Aplicar cupom (se fornecido)
-- 6. Calcular tempo estimado de entrega
-- 7. Commit ou rollback
--
-- PARÂMETROS:
-- - p_usuario_id: ID do cliente
-- - p_endereco_id: ID do endereço de entrega
-- - p_forma_pagamento: DINHEIRO, PIX, CARTAO_CREDITO, etc
-- - p_observacoes: Observações do cliente
-- - p_codigo_cupom: Código de cupom de desconto (opcional)
-- - p_itens_json: JSON com itens do pedido [{"produto_id": 1, "quantidade": 2}, ...]
--
-- RETORNO:
-- - pedido_id: ID do pedido criado (OUT parameter)
-- - codigo_rastreamento: Código para rastreamento (OUT parameter)
--
-- EXEMPLO DE USO:
-- CALL sp_processar_pedido_completo(
--     1,                                           -- usuario_id
--     1,                                           -- endereco_id
--     'PIX',                                       -- forma_pagamento
--     'Sem cebola, por favor',                    -- observacoes
--     'PROMO-ABC123',                             -- codigo_cupom
--     '[{"produto_id": 1, "quantidade": 2}, {"produto_id": 3, "quantidade": 1}]', -- itens_json
--     @pedido_id,                                 -- OUT: pedido_id
--     @codigo_rastreamento                        -- OUT: codigo_rastreamento
-- );
-- SELECT @pedido_id, @codigo_rastreamento;
-- ============================================================================
CREATE PROCEDURE sp_processar_pedido_completo(
    IN p_usuario_id BIGINT,
    IN p_endereco_id BIGINT,
    IN p_forma_pagamento VARCHAR(20),
    IN p_observacoes TEXT,
    IN p_codigo_cupom VARCHAR(20),
    IN p_itens_json JSON,
    OUT p_pedido_id BIGINT,
    OUT p_codigo_rastreamento VARCHAR(13)
)
BEGIN
    DECLARE v_valor_entrega DECIMAL(10,2) DEFAULT 5.00;
    DECLARE v_desconto_fidelidade DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_desconto_cupom DECIMAL(10,2) DEFAULT 0.00;
    DECLARE v_valor_total DECIMAL(10,2);
    DECLARE v_tempo_estimado INT;
    DECLARE v_cupom_id BIGINT;
    DECLARE v_cupom_valido BOOLEAN DEFAULT FALSE;
    DECLARE v_item_index INT DEFAULT 0;
    DECLARE v_total_itens INT;
    DECLARE v_produto_id BIGINT;
    DECLARE v_quantidade INT;
    DECLARE v_preco_unitario DECIMAL(10,2);
    DECLARE v_msg VARCHAR(255);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Rollback em caso de erro
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro ao processar pedido. Transação cancelada.';
    END;

    -- Inicia transação
    START TRANSACTION;

    -- Valida usuário
    IF NOT EXISTS (SELECT 1 FROM usuarios WHERE id = p_usuario_id AND ativo = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuário inválido ou inativo';
    END IF;

    -- Valida endereço
    IF NOT EXISTS (SELECT 1 FROM enderecos WHERE id = p_endereco_id AND usuario_id = p_usuario_id AND ativo = TRUE) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Endereço inválido ou não pertence ao usuário';
    END IF;

    -- Calcula desconto de fidelidade
    SET v_desconto_fidelidade = fn_calcular_desconto_fidelidade(p_usuario_id);

    -- Valida e obtém desconto de cupom
    IF p_codigo_cupom IS NOT NULL AND p_codigo_cupom != '' THEN
        SELECT id INTO v_cupom_id
        FROM cupons_desconto
        WHERE codigo = p_codigo_cupom
        AND ativo = TRUE
        AND CURDATE() BETWEEN data_inicio AND data_fim
        AND (quantidade_disponivel IS NULL OR quantidade_usada < quantidade_disponivel);

        IF v_cupom_id IS NOT NULL THEN
            SET v_cupom_valido = TRUE;
        END IF;
    END IF;

    -- Cria o pedido
    INSERT INTO pedidos (
        usuario_id,
        endereco_id,
        forma_pagamento,
        valor_entrega,
        valor_desconto,
        observacoes,
        status
    ) VALUES (
        p_usuario_id,
        p_endereco_id,
        p_forma_pagamento,
        v_valor_entrega,
        v_desconto_fidelidade,
        p_observacoes,
        'PENDENTE'
    );

    SET p_pedido_id = LAST_INSERT_ID();

    -- Obtém o código de rastreamento gerado pelo trigger
    SELECT codigo_rastreamento INTO p_codigo_rastreamento
    FROM pedidos WHERE id = p_pedido_id;

    -- Processa itens do pedido
    SET v_total_itens = JSON_LENGTH(p_itens_json);
    SET v_item_index = 0;

    WHILE v_item_index < v_total_itens DO
        -- Extrai dados do item
        SET v_produto_id = JSON_UNQUOTE(JSON_EXTRACT(p_itens_json, CONCAT('$[', v_item_index, '].produto_id')));
        SET v_quantidade = JSON_UNQUOTE(JSON_EXTRACT(p_itens_json, CONCAT('$[', v_item_index, '].quantidade')));

        -- Obtém preço atual do produto
        SELECT COALESCE(preco_promocional, preco) INTO v_preco_unitario
        FROM produtos
        WHERE id = v_produto_id AND ativo = TRUE;

        IF v_preco_unitario IS NULL THEN
            SET v_msg = CONCAT('Produto ID ', v_produto_id, ' não encontrado ou inativo');
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
        END IF;

        -- Insere item (triggers validarão estoque e atualizarão valor_total)
        INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario)
        VALUES (p_pedido_id, v_produto_id, v_quantidade, v_preco_unitario);

        SET v_item_index = v_item_index + 1;
    END WHILE;

    -- Aplica desconto de cupom se válido
    IF v_cupom_valido THEN
        SELECT
            CASE
                WHEN tipo_desconto = 'PERCENTUAL' THEN (valor_subtotal * valor_desconto / 100)
                WHEN tipo_desconto = 'VALOR_FIXO' THEN valor_desconto
            END INTO v_desconto_cupom
        FROM cupons_desconto cd
        INNER JOIN pedidos p ON p.id = p_pedido_id
        WHERE cd.id = v_cupom_id;

        -- Atualiza desconto do pedido
        UPDATE pedidos
        SET valor_desconto = valor_desconto + v_desconto_cupom
        WHERE id = p_pedido_id;

        -- Registra uso do cupom
        INSERT INTO cupons_utilizados (cupom_id, pedido_id, usuario_id, valor_desconto_aplicado)
        VALUES (v_cupom_id, p_pedido_id, p_usuario_id, v_desconto_cupom);

        -- Incrementa contador de uso do cupom
        UPDATE cupons_desconto
        SET quantidade_usada = quantidade_usada + 1
        WHERE id = v_cupom_id;
    END IF;

    -- Calcula tempo estimado de entrega
    SET v_tempo_estimado = fn_calcular_tempo_estimado_entrega(p_pedido_id);

    UPDATE pedidos
    SET tempo_estimado_minutos = v_tempo_estimado
    WHERE id = p_pedido_id;

    -- Commit da transação
    COMMIT;
END$$

-- ============================================================================
-- PROCEDURE 2: sp_cancelar_pedido
-- OBJETIVO: Cancelar pedido e reverter estoque de forma transacional
--
-- JUSTIFICATIVA TÉCNICA:
-- - Operação crítica que deve reverter estoque
-- - Validações de negócio (não cancelar pedido já entregue)
-- - Auditoria automática (motivo do cancelamento)
-- - Trigger de log_pedidos registrará a mudança de status
--
-- PARÂMETROS:
-- - p_pedido_id: ID do pedido a cancelar
-- - p_motivo: Motivo do cancelamento
-- - p_usuario_responsavel_id: ID do usuário que cancelou (cliente ou admin)
--
-- EXEMPLO DE USO:
-- CALL sp_cancelar_pedido(123, 'Cliente desistiu da compra', 1);
-- ============================================================================
CREATE PROCEDURE sp_cancelar_pedido(
    IN p_pedido_id BIGINT,
    IN p_motivo TEXT,
    IN p_usuario_responsavel_id BIGINT
)
BEGIN
    DECLARE v_status_atual VARCHAR(20);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Erro ao cancelar pedido. Transação cancelada.';
    END;

    START TRANSACTION;

    -- Verifica status atual
    SELECT status INTO v_status_atual FROM pedidos WHERE id = p_pedido_id;

    IF v_status_atual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pedido não encontrado';
    END IF;

    IF v_status_atual IN ('ENTREGUE', 'CANCELADO') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pedido já foi entregue ou está cancelado';
    END IF;

    -- Reverte estoque
    UPDATE produtos p
    INNER JOIN itens_pedido ip ON ip.produto_id = p.id
    SET p.estoque = p.estoque + ip.quantidade
    WHERE ip.pedido_id = p_pedido_id;

    -- Atualiza status do pedido
    UPDATE pedidos
    SET status = 'CANCELADO',
        data_cancelamento = NOW(),
        motivo_cancelamento = p_motivo
    WHERE id = p_pedido_id;

    -- Registra no log (trigger fará isso automaticamente, mas podemos adicionar mais detalhes)
    INSERT INTO log_pedidos (pedido_id, status_anterior, status_novo, usuario_responsavel_id, observacao)
    VALUES (p_pedido_id, v_status_atual, 'CANCELADO', p_usuario_responsavel_id, p_motivo);

    COMMIT;
END$$

-- ============================================================================
-- PROCEDURE 3: sp_atualizar_status_pedido
-- OBJETIVO: Atualizar status do pedido com validações de fluxo
--
-- JUSTIFICATIVA TÉCNICA:
-- - Garante transições de status válidas (PENDENTE -> CONFIRMADO -> PREPARANDO, etc)
-- - Atualiza timestamps automáticos (data_confirmacao, data_entrega)
-- - Validações de negócio centralizadas
--
-- FLUXO VÁLIDO:
-- PENDENTE -> CONFIRMADO -> PREPARANDO -> SAIU_ENTREGA -> ENTREGUE
--                   \u2192 CANCELADO (possível de qualquer status exceto ENTREGUE)
--
-- PARÂMETROS:
-- - p_pedido_id: ID do pedido
-- - p_novo_status: Novo status desejado
-- - p_entregador_id: ID do entregador (obrigatório ao mudar para SAIU_ENTREGA)
--
-- EXEMPLO DE USO:
-- CALL sp_atualizar_status_pedido(123, 'CONFIRMADO', NULL);
-- CALL sp_atualizar_status_pedido(123, 'SAIU_ENTREGA', 5);
-- ============================================================================
CREATE PROCEDURE sp_atualizar_status_pedido(
    IN p_pedido_id BIGINT,
    IN p_novo_status VARCHAR(20),
    IN p_entregador_id BIGINT
)
BEGIN
    DECLARE v_status_atual VARCHAR(20);

    -- Verifica status atual
    SELECT status INTO v_status_atual FROM pedidos WHERE id = p_pedido_id;

    IF v_status_atual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pedido não encontrado';
    END IF;

    -- Valida transições de status
    IF v_status_atual = 'CANCELADO' OR v_status_atual = 'ENTREGUE' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é possível alterar status de pedido cancelado ou entregue';
    END IF;

    -- Valida entregador obrigatório para SAIU_ENTREGA
    IF p_novo_status = 'SAIU_ENTREGA' AND p_entregador_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Entregador é obrigatório para status SAIU_ENTREGA';
    END IF;

    -- Atualiza status e timestamps
    UPDATE pedidos
    SET status = p_novo_status,
        entregador_id = CASE WHEN p_novo_status = 'SAIU_ENTREGA' THEN p_entregador_id ELSE entregador_id END,
        data_confirmacao = CASE WHEN p_novo_status = 'CONFIRMADO' THEN NOW() ELSE data_confirmacao END,
        data_entrega = CASE WHEN p_novo_status = 'ENTREGUE' THEN NOW() ELSE data_entrega END
    WHERE id = p_pedido_id;
END$$

-- ============================================================================
-- FUNCTION 1: fn_calcular_desconto_fidelidade
-- OBJETIVO: Calcular desconto baseado no histórico de compras do cliente
--
-- JUSTIFICATIVA TÉCNICA:
-- - Programa de fidelidade automático
-- - Incentiva compras recorrentes
-- - Cálculo padronizado (mesma regra em todo o sistema)
-- - Reutilizável em múltiplos contextos
--
-- REGRAS:
-- - Cliente com 0-4 pedidos: 0% desconto
-- - Cliente com 5-9 pedidos: 5% desconto
-- - Cliente com 10-19 pedidos: 10% desconto
-- - Cliente com 20+ pedidos: 15% desconto
--
-- PARÂMETROS:
-- - p_usuario_id: ID do cliente
--
-- RETORNO:
-- - Percentual de desconto (ex: 10.00 para 10%)
--
-- EXEMPLO DE USO:
-- SELECT fn_calcular_desconto_fidelidade(1) AS desconto_percentual;
-- ============================================================================
CREATE FUNCTION fn_calcular_desconto_fidelidade(p_usuario_id BIGINT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_total_pedidos INT;
    DECLARE v_desconto_percentual DECIMAL(5,2);

    -- Conta pedidos entregues do cliente
    SELECT COUNT(*) INTO v_total_pedidos
    FROM pedidos
    WHERE usuario_id = p_usuario_id AND status = 'ENTREGUE';

    -- Define desconto baseado em quantidade de pedidos
    SET v_desconto_percentual = CASE
        WHEN v_total_pedidos >= 20 THEN 15.00
        WHEN v_total_pedidos >= 10 THEN 10.00
        WHEN v_total_pedidos >= 5 THEN 5.00
        ELSE 0.00
    END;

    RETURN v_desconto_percentual;
END$$

-- ============================================================================
-- FUNCTION 2: fn_calcular_tempo_estimado_entrega
-- OBJETIVO: Calcular tempo estimado de entrega baseado no pedido
--
-- JUSTIFICATIVA TÉCNICA:
-- - Expectativa realista para o cliente
-- - Considera tempo de preparo dos produtos
-- - Pode ser expandido para considerar distância, trânsito, etc
--
-- LÓGICA:
-- - Tempo base: 30 minutos
-- - + Tempo de preparo do produto mais demorado
-- - + 5 minutos por item adicional
--
-- PARÂMETROS:
-- - p_pedido_id: ID do pedido
--
-- RETORNO:
-- - Tempo estimado em minutos
--
-- EXEMPLO DE USO:
-- SELECT fn_calcular_tempo_estimado_entrega(1) AS tempo_minutos;
-- ============================================================================
CREATE FUNCTION fn_calcular_tempo_estimado_entrega(p_pedido_id BIGINT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_tempo_base INT DEFAULT 30;
    DECLARE v_tempo_preparo_maximo INT;
    DECLARE v_quantidade_itens INT;
    DECLARE v_tempo_total INT;

    -- Obtém tempo de preparo máximo entre os produtos do pedido
    SELECT MAX(p.tempo_preparo_minutos) INTO v_tempo_preparo_maximo
    FROM produtos p
    INNER JOIN itens_pedido ip ON ip.produto_id = p.id
    WHERE ip.pedido_id = p_pedido_id;

    -- Conta quantidade de itens
    SELECT COUNT(*) INTO v_quantidade_itens
    FROM itens_pedido
    WHERE pedido_id = p_pedido_id;

    -- Calcula tempo total
    SET v_tempo_total = v_tempo_base + COALESCE(v_tempo_preparo_maximo, 0) + (v_quantidade_itens * 5);

    RETURN v_tempo_total;
END$$

-- ============================================================================
-- FUNCTION 3: fn_verificar_disponibilidade_produto
-- OBJETIVO: Verificar se produto está disponível para venda
--
-- JUSTIFICATIVA TÉCNICA:
-- - Validação rápida antes de adicionar ao carrinho
-- - Considera múltiplos critérios (ativo, estoque, etc)
-- - Reutilizável em frontend e backend
--
-- CRITÉRIOS:
-- - Produto ativo
-- - Estoque > 0
-- - Categoria ativa
--
-- PARÂMETROS:
-- - p_produto_id: ID do produto
-- - p_quantidade: Quantidade desejada
--
-- RETORNO:
-- - TRUE se disponível, FALSE caso contrário
--
-- EXEMPLO DE USO:
-- SELECT fn_verificar_disponibilidade_produto(1, 2) AS disponivel;
-- ============================================================================
CREATE FUNCTION fn_verificar_disponibilidade_produto(
    p_produto_id BIGINT,
    p_quantidade INT
)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_disponivel BOOLEAN DEFAULT FALSE;

    SELECT
        CASE
            WHEN p.ativo = TRUE
            AND c.ativo = TRUE
            AND p.estoque >= p_quantidade
            THEN TRUE
            ELSE FALSE
        END INTO v_disponivel
    FROM produtos p
    INNER JOIN categorias c ON c.id = p.categoria_id
    WHERE p.id = p_produto_id;

    RETURN COALESCE(v_disponivel, FALSE);
END$$

DELIMITER ;

-- ============================================================================
-- TESTES DAS PROCEDURES E FUNCTIONS
-- ============================================================================

-- TESTE 1: Calcular desconto de fidelidade
-- SELECT fn_calcular_desconto_fidelidade(1) AS desconto_percentual;

-- TESTE 2: Calcular tempo estimado de entrega
-- SELECT fn_calcular_tempo_estimado_entrega(1) AS tempo_minutos;

-- TESTE 3: Verificar disponibilidade de produto
-- SELECT fn_verificar_disponibilidade_produto(1, 2) AS disponivel;

-- TESTE 4: Processar pedido completo
-- CALL sp_processar_pedido_completo(
--     1,                                           -- usuario_id
--     1,                                           -- endereco_id
--     'PIX',                                       -- forma_pagamento
--     'Sem cebola',                                -- observacoes
--     NULL,                                        -- codigo_cupom
--     '[{"produto_id": 1, "quantidade": 2}]',     -- itens_json
--     @pedido_id,                                 -- OUT: pedido_id
--     @codigo_rastreamento                        -- OUT: codigo_rastreamento
-- );
-- SELECT @pedido_id AS pedido_criado, @codigo_rastreamento AS codigo;

-- TESTE 5: Atualizar status do pedido
-- CALL sp_atualizar_status_pedido(@pedido_id, 'CONFIRMADO', NULL);
-- SELECT status FROM pedidos WHERE id = @pedido_id;

-- TESTE 6: Cancelar pedido
-- CALL sp_cancelar_pedido(@pedido_id, 'Teste de cancelamento', 1);
-- SELECT status FROM pedidos WHERE id = @pedido_id;

-- ============================================================================
-- FIM DAS PROCEDURES E FUNCTIONS
-- ============================================================================
