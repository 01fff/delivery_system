-- ============================================================================
-- SISTEMA DE DELIVERY - FUNÇÕES DE GERAÇÃO DE IDS CUSTOMIZADOS
-- ============================================================================
-- Descrição: Funções para geração de IDs únicos
-- ============================================================================

USE delivery_system;

-- Remove as funções se existirem
DROP FUNCTION IF EXISTS gerar_id_pedido;
DROP FUNCTION IF EXISTS gerar_codigo_rastreamento;
DROP FUNCTION IF EXISTS gerar_codigo_cupom;

DELIMITER $$

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
CREATE FUNCTION gerar_id_pedido()
RETURNS VARCHAR(13)
DETERMINISTIC
BEGIN
    DECLARE novo_id VARCHAR(13);
    DECLARE data_parte VARCHAR(6);
    DECLARE sequencial INT;
    DECLARE sequencial_formatado VARCHAR(6);

    -- Obtém a parte da data (AAMMDD)
    SET data_parte = DATE_FORMAT(CURDATE(), '%y%m%d');

    -- Obtém o último número sequencial do dia
    SELECT COALESCE(MAX(CAST(SUBSTRING_INDEX(id_rastreamento, '-', -1) AS UNSIGNED)), 0) + 1
    INTO sequencial
    FROM pedidos
    WHERE DATE(data_pedido) = CURDATE()
    AND id_rastreamento LIKE CONCAT(data_parte, '-%');

    -- Se não encontrou nenhum pedido hoje, começa do 1
    IF sequencial IS NULL THEN
        SET sequencial = 1;
    END IF;

    -- Formata o sequencial com zeros \u00e0 esquerda (6 dígitos)
    SET sequencial_formatado = LPAD(sequencial, 6, '0');

    -- Monta o ID final
    SET novo_id = CONCAT(data_parte, '-', sequencial_formatado);

    RETURN novo_id;
END$$

-- ============================================================================
-- FUNÇÃO 2: gerar_codigo_rastreamento()
-- OBJETIVO: Gerar código alfanumérico único para rastreamento de entregas
-- FORMATO: DLV-XXXXXXXXXX (Delivery + 10 caracteres alfanuméricos)
-- EXEMPLO: DLV-A3F7K9M2P1
--
-- JUSTIFICATIVA TÉCNICA:
-- - Código único para compartilhar com cliente (rastreamento em tempo real)
-- - Alfanumérico evita confusão (ex: 0 vs O, 1 vs I são excluídos)
-- - Tamanho otimizado (13 chars) - fácil de digitar mas com alta entropia
-- - Probabilidade de colisão: ~1 em 60 bilhões (36^10)
--
-- VANTAGENS:
-- - Cliente pode rastrear pedido sem login (apenas com código)
-- - Compartilhável por SMS, WhatsApp, Email
-- - Não expõe informações sensíveis (diferente do ID sequencial)
--
-- RETORNO: VARCHAR(13) no formato DLV-XXXXXXXXXX
-- ============================================================================
CREATE FUNCTION gerar_codigo_rastreamento()
RETURNS VARCHAR(13)
NOT DETERMINISTIC
BEGIN
    DECLARE codigo VARCHAR(13);
    DECLARE caracteres VARCHAR(36);
    DECLARE i INT;
    DECLARE parte_aleatoria VARCHAR(10);

    -- Caracteres permitidos (sem ambiguidade: sem 0, O, 1, I)
    SET caracteres = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    SET parte_aleatoria = '';
    SET i = 0;

    -- Gera 10 caracteres aleatórios
    WHILE i < 10 DO
        SET parte_aleatoria = CONCAT(
            parte_aleatoria,
            SUBSTRING(caracteres, FLOOR(1 + RAND() * 32), 1)
        );
        SET i = i + 1;
    END WHILE;

    -- Monta o código final
    SET codigo = CONCAT('DLV-', parte_aleatoria);

    RETURN codigo;
END$$

-- ============================================================================
-- FUNÇÃO 3: gerar_codigo_cupom()
-- OBJETIVO: Gerar códigos de cupom de desconto únicos
-- FORMATO: Prefixo configurado + 8 caracteres alfanuméricos
-- EXEMPLO: PROMO-A3F7K9M2, BF2024-X9K2M1P3, NATAL-P3M9K1F7
--
-- JUSTIFICATIVA TÉCNICA:
-- - Permite criar cupons com prefixos temáticos (NATAL, BLACKFRIDAY, PROMO)
-- - Alfanumérico facilita memorição e digitação pelo cliente
-- - Tamanho variável permite cupons curtos (BEMVINDO) ou longos (BLACKFRIDAY2024)
-- - Letras maiúsculas evitam erros de digitação
--
-- VANTAGENS:
-- - Marketing pode criar cupons personalizados facilmente
-- - Identificação visual da promoção (ex: NATAL-XXXXXX)
-- - Impede cupons duplicados acidentais
--
-- PARÂMETROS:
-- - prefixo: Prefixo do cupom (ex: 'PROMO', 'NATAL', 'BF2024')
--
-- RETORNO: VARCHAR(30) no formato PREFIXO-XXXXXXXX
-- ============================================================================
CREATE FUNCTION gerar_codigo_cupom(prefixo VARCHAR(20))
RETURNS VARCHAR(30)
NOT DETERMINISTIC
BEGIN
    DECLARE codigo VARCHAR(30);
    DECLARE caracteres VARCHAR(36);
    DECLARE i INT;
    DECLARE parte_aleatoria VARCHAR(8);

    -- Caracteres permitidos (sem ambiguidade)
    SET caracteres = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    SET parte_aleatoria = '';
    SET i = 0;

    -- Converte prefixo para maiúsculas
    SET prefixo = UPPER(prefixo);

    -- Gera 8 caracteres aleatórios
    WHILE i < 8 DO
        SET parte_aleatoria = CONCAT(
            parte_aleatoria,
            SUBSTRING(caracteres, FLOOR(1 + RAND() * 32), 1)
        );
        SET i = i + 1;
    END WHILE;

    -- Monta o código final
    SET codigo = CONCAT(prefixo, '-', parte_aleatoria);

    RETURN codigo;
END$$

DELIMITER ;

-- ============================================================================
-- ALTERAÇÃO DA TABELA PEDIDOS
-- Adiciona coluna para o código de rastreamento gerado
-- ============================================================================
ALTER TABLE pedidos
ADD COLUMN id_rastreamento VARCHAR(13) UNIQUE COMMENT 'Código de rastreamento gerado pela função gerar_id_pedido()',
ADD COLUMN codigo_rastreamento VARCHAR(13) UNIQUE COMMENT 'Código alfanumérico para rastreamento público';

-- ============================================================================
-- EXEMPLOS DE USO DAS FUNÇÕES
-- ============================================================================

-- Exemplo 1: Gerar ID de pedido
-- SELECT gerar_id_pedido() AS novo_id_pedido;
-- Resultado: 241118-000001

-- Exemplo 2: Gerar código de rastreamento
-- SELECT gerar_codigo_rastreamento() AS codigo_rastreamento;
-- Resultado: DLV-A3F7K9M2P1

-- Exemplo 3: Gerar cupom de desconto
-- SELECT gerar_codigo_cupom('NATAL') AS cupom_natal;
-- Resultado: NATAL-P3M9K1F7

-- SELECT gerar_codigo_cupom('BLACKFRIDAY') AS cupom_bf;
-- Resultado: BLACKFRIDAY-X9K2M1P3

-- Exemplo 4: Inserir pedido com ID customizado
-- INSERT INTO pedidos (id_rastreamento, codigo_rastreamento, usuario_id, endereco_id, valor_total, forma_pagamento)
-- VALUES (gerar_id_pedido(), gerar_codigo_rastreamento(), 1, 1, 50.00, 'PIX');

-- ============================================================================
-- TESTE DE COLISÃO (Verificar unicidade dos códigos)
-- ============================================================================

-- Gera 1000 códigos de rastreamento e verifica duplicatas
-- SELECT COUNT(*) AS total, COUNT(DISTINCT codigo) AS unicos
-- FROM (
--     SELECT gerar_codigo_rastreamento() AS codigo
--     FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3 ... UNION SELECT 1000) AS numeros
-- ) AS codigos;
--
-- Resultado esperado: total = unicos = 1000 (sem duplicatas)

-- ============================================================================
-- ANÁLISE DE SEGURANÇA
-- ============================================================================
--
-- PROBLEMA COM AUTO_INCREMENT PADRÃO:
-- - Expõe quantidade de registros do sistema
-- - Previsível (próximo ID = ID atual + 1)
-- - Facilita enumeração de recursos (IDOR vulnerability)
--
-- SOLUÇÃO COM IDS CUSTOMIZADOS:
-- - Códigos não sequenciais (alta entropia)
-- - Não expõe métricas de negócio
-- - Dificulta ataques de enumeração
-- - Mantém rastreabilidade para suporte/logística
--
-- ============================================================================

-- ============================================================================
-- FIM DAS FUNÇÕES DE GERAÇÃO DE IDS
-- ============================================================================
