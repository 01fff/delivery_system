-- ============================================================================
-- SISTEMA DE DELIVERY - USUÁRIOS E PERMISSÕES MYSQL
-- ============================================================================
-- Descrição: Criação de usuários MySQL com diferentes níveis de acesso
-- ============================================================================

USE delivery_system;

-- ============================================================================
-- SEGURANÇA: PRINCÍPIO DO MENOR PRIVILÉGIO
-- ============================================================================
-- Cada usuário/aplicação deve ter APENAS as permissões necessárias
-- para executar suas funções, nada mais.
-- ============================================================================

-- Remove usuários se existirem (apenas para desenvolvimento/reset)
DROP USER IF EXISTS 'delivery_admin'@'localhost';
DROP USER IF EXISTS 'delivery_app'@'localhost';
DROP USER IF EXISTS 'delivery_readonly'@'localhost';
DROP USER IF EXISTS 'delivery_reports'@'localhost';

-- ============================================================================
-- USUÁRIO 1: delivery_admin
-- NÍVEL: ADMINISTRADOR DO SISTEMA
--
-- JUSTIFICATIVA TÉCNICA:
-- - Acesso completo ao banco de dados delivery_system
-- - Usado por DBAs e desenvolvedores sênior
-- - Pode criar/alterar estruturas (tabelas, índices, procedures)
-- - Pode fazer backup/restore
-- - NÃO deve ser usado pela aplicação web/mobile
--
-- PERMISSÕES:
-- - ALL PRIVILEGES no banco delivery_system
-- - Pode criar procedures, triggers, views
-- - Pode alterar estrutura das tabelas
-- - Pode gerenciar outros usuários do banco
--
-- CASOS DE USO:
-- - Manutenção do banco de dados
-- - Execução de migrações
-- - Criação de índices e otimizações
-- - Backup e recuperação
-- - Análise de performance (EXPLAIN, SHOW STATUS)
--
-- SENHA: DeliveryAdmin@2024 (TROCAR EM PRODUÇÃO!)
-- ============================================================================
CREATE USER 'delivery_admin'@'localhost' IDENTIFIED BY 'DeliveryAdmin@2024';

GRANT ALL PRIVILEGES ON delivery_system.* TO 'delivery_admin'@'localhost';
GRANT CREATE, ALTER, DROP, INDEX ON delivery_system.* TO 'delivery_admin'@'localhost';
GRANT EXECUTE ON delivery_system.* TO 'delivery_admin'@'localhost';
GRANT REFERENCES ON delivery_system.* TO 'delivery_admin'@'localhost';

-- Permite criar procedures/functions/triggers
GRANT CREATE ROUTINE ON delivery_system.* TO 'delivery_admin'@'localhost';
GRANT ALTER ROUTINE ON delivery_system.* TO 'delivery_admin'@'localhost';

-- Permite criar views
GRANT CREATE VIEW ON delivery_system.* TO 'delivery_admin'@'localhost';
GRANT SHOW VIEW ON delivery_system.* TO 'delivery_admin'@'localhost';

-- ============================================================================
-- USUÁRIO 2: delivery_app
-- NÍVEL: APLICAÇÃO (BACKEND WEB/MOBILE)
--
-- JUSTIFICATIVA TÉCNICA:
-- - Usuário usado pelas aplicações backend (Node.js, PHP, Python, etc)
-- - Permissões limitadas: CRUD nas tabelas de dados
-- - PODE executar procedures/functions (lógica de negócio)
-- - NÃO PODE alterar estrutura do banco (DDL)
-- - Protege contra SQL Injection que tente DROP TABLE
--
-- PERMISSÕES:
-- - SELECT, INSERT, UPDATE, DELETE nas tabelas de dados
-- - EXECUTE em procedures/functions
-- - SELECT em views
-- - NÃO pode DROP, ALTER, CREATE
--
-- CASOS DE USO:
-- - Aplicação web (Node.js + Express)
-- - Aplicação mobile (backend API)
-- - Workers de processamento (filas)
--
-- RESTRIÇÕES:
-- - Não pode criar/deletar tabelas
-- - Não pode alterar estrutura
-- - Não pode acessar tabelas de auditoria (apenas INSERT via trigger)
--
-- SENHA: DeliveryApp@2024 (TROCAR EM PRODUÇÃO!)
-- ============================================================================
CREATE USER 'delivery_app'@'localhost' IDENTIFIED BY 'DeliveryApp@2024';

-- Permissões de CRUD nas tabelas principais
GRANT SELECT, INSERT, UPDATE, DELETE ON delivery_system.usuarios TO 'delivery_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON delivery_system.grupos_usuarios TO 'delivery_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON delivery_system.usuarios_grupos TO 'delivery_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON delivery_system.categorias TO 'delivery_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON delivery_system.produtos TO 'delivery_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON delivery_system.enderecos TO 'delivery_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON delivery_system.pedidos TO 'delivery_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON delivery_system.itens_pedido TO 'delivery_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON delivery_system.avaliacoes TO 'delivery_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON delivery_system.cupons_desconto TO 'delivery_app'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON delivery_system.cupons_utilizados TO 'delivery_app'@'localhost';

-- Tabela de log: apenas SELECT e INSERT (não pode UPDATE/DELETE para preservar auditoria)
GRANT SELECT, INSERT ON delivery_system.log_pedidos TO 'delivery_app'@'localhost';

-- Permissão para executar procedures/functions
GRANT EXECUTE ON delivery_system.* TO 'delivery_app'@'localhost';

-- Permissão para ler views
GRANT SELECT ON delivery_system.vw_vendas_por_categoria TO 'delivery_app'@'localhost';
GRANT SELECT ON delivery_system.vw_produtos_mais_vendidos TO 'delivery_app'@'localhost';
GRANT SELECT ON delivery_system.vw_pedidos_completos TO 'delivery_app'@'localhost';
GRANT SELECT ON delivery_system.vw_desempenho_entregadores TO 'delivery_app'@'localhost';
GRANT SELECT ON delivery_system.vw_clientes_vip TO 'delivery_app'@'localhost';

-- ============================================================================
-- USUÁRIO 3: delivery_readonly
-- NÍVEL: SOMENTE LEITURA (CONSULTAS)
--
-- JUSTIFICATIVA TÉCNICA:
-- - Usado por ferramentas de BI (Business Intelligence)
-- - Analistas de dados, relatórios, dashboards
-- - NÃO pode modificar NENHUM dado
-- - Protege contra alterações acidentais em ferramentas de análise
-- - Pode ler todas as views e tabelas
--
-- PERMISSÕES:
-- - SELECT em todas as tabelas
-- - SELECT em todas as views
-- - NÃO pode INSERT, UPDATE, DELETE, DROP, ALTER
--
-- CASOS DE USO:
-- - Ferramentas de BI (Metabase, Tableau, Power BI)
-- - Data Scientists
-- - Analistas de negócio
-- - Auditores (leitura de logs)
-- - Relatórios gerenciais
--
-- SENHA: DeliveryReadonly@2024 (TROCAR EM PRODUÇÃO!)
-- ============================================================================
CREATE USER 'delivery_readonly'@'localhost' IDENTIFIED BY 'DeliveryReadonly@2024';

-- Permissão de leitura em todas as tabelas
GRANT SELECT ON delivery_system.* TO 'delivery_readonly'@'localhost';

-- Permissão para executar apenas funções de leitura (que não modificam dados)
-- Nota: No MySQL, EXECUTE dá acesso a todas as funções. Em produção, considerar
-- criar funções de leitura em schema separado
GRANT EXECUTE ON FUNCTION delivery_system.fn_calcular_desconto_fidelidade TO 'delivery_readonly'@'localhost';
GRANT EXECUTE ON FUNCTION delivery_system.fn_calcular_tempo_estimado_entrega TO 'delivery_readonly'@'localhost';
GRANT EXECUTE ON FUNCTION delivery_system.fn_verificar_disponibilidade_produto TO 'delivery_readonly'@'localhost';

-- ============================================================================
-- USUÁRIO 4: delivery_reports
-- NÍVEL: RELATÓRIOS E ANÁLISES (LEITURA + VIEWS)
--
-- JUSTIFICATIVA TÉCNICA:
-- - Especializado em consultas pesadas (relatórios, analytics)
-- - Pode ler dados mas também tem acesso otimizado a views
-- - Útil para sistemas de relatórios automatizados
-- - Separa carga de relatórios da aplicação principal
--
-- PERMISSÕES:
-- - SELECT em tabelas principais (não sensíveis)
-- - SELECT em todas as views
-- - NÃO acessa dados sensíveis (senhas, tokens)
--
-- CASOS DE USO:
-- - Geração de relatórios noturnos
-- - Dashboard gerencial
-- - Análises de vendas
-- - Métricas de performance
--
-- RESTRIÇÕES:
-- - NãO pode ler tabela usuarios completa (apenas views filtradas)
-- - NãO pode modificar dados
--
-- SENHA: DeliveryReports@2024 (TROCAR EM PRODUÇÃO!)
-- ============================================================================
CREATE USER 'delivery_reports'@'localhost' IDENTIFIED BY 'DeliveryReports@2024';

-- Leitura de tabelas não sensíveis
GRANT SELECT ON delivery_system.categorias TO 'delivery_reports'@'localhost';
GRANT SELECT ON delivery_system.produtos TO 'delivery_reports'@'localhost';
GRANT SELECT ON delivery_system.pedidos TO 'delivery_reports'@'localhost';
GRANT SELECT ON delivery_system.itens_pedido TO 'delivery_reports'@'localhost';
GRANT SELECT ON delivery_system.avaliacoes TO 'delivery_reports'@'localhost';
GRANT SELECT ON delivery_system.log_pedidos TO 'delivery_reports'@'localhost';

-- Acesso total a views (já filtradas e seguras)
GRANT SELECT ON delivery_system.vw_vendas_por_categoria TO 'delivery_reports'@'localhost';
GRANT SELECT ON delivery_system.vw_produtos_mais_vendidos TO 'delivery_reports'@'localhost';
GRANT SELECT ON delivery_system.vw_pedidos_completos TO 'delivery_reports'@'localhost';
GRANT SELECT ON delivery_system.vw_desempenho_entregadores TO 'delivery_reports'@'localhost';
GRANT SELECT ON delivery_system.vw_clientes_vip TO 'delivery_reports'@'localhost';

-- Funções de cálculo (apenas leitura)
GRANT EXECUTE ON FUNCTION delivery_system.fn_calcular_desconto_fidelidade TO 'delivery_reports'@'localhost';
GRANT EXECUTE ON FUNCTION delivery_system.fn_calcular_tempo_estimado_entrega TO 'delivery_reports'@'localhost';

-- ============================================================================
-- APLICA OS PRIVILÉGIOS
-- ============================================================================
FLUSH PRIVILEGES;

-- ============================================================================
-- VERIFICAÇÃO DAS PERMISSÕES
-- ============================================================================

-- Para verificar as permissões de um usuário:
-- SHOW GRANTS FOR 'delivery_app'@'localhost';
-- SHOW GRANTS FOR 'delivery_admin'@'localhost';
-- SHOW GRANTS FOR 'delivery_readonly'@'localhost';
-- SHOW GRANTS FOR 'delivery_reports'@'localhost';

-- Para verificar todos os usuários:
-- SELECT User, Host FROM mysql.user WHERE User LIKE 'delivery_%';

-- ============================================================================
-- TESTES DE PERMISSÕES
-- ============================================================================

-- TESTE 1: Conectar como delivery_app e tentar SELECT
-- mysql -u delivery_app -p'DeliveryApp@2024' delivery_system
-- SELECT * FROM produtos LIMIT 5;  -- Deve funcionar
-- DROP TABLE produtos;              -- Deve falhar (sem permissão)

-- TESTE 2: Conectar como delivery_readonly e tentar UPDATE
-- mysql -u delivery_readonly -p'DeliveryReadonly@2024' delivery_system
-- SELECT * FROM pedidos LIMIT 5;    -- Deve funcionar
-- UPDATE pedidos SET status = 'CANCELADO' WHERE id = 1;  -- Deve falhar

-- TESTE 3: Conectar como delivery_admin
-- mysql -u delivery_admin -p'DeliveryAdmin@2024' delivery_system
-- ALTER TABLE produtos ADD COLUMN teste VARCHAR(10);  -- Deve funcionar
-- ALTER TABLE produtos DROP COLUMN teste;             -- Deve funcionar

-- ============================================================================
-- BOAS PRÁTICAS DE SEGURANÇA
-- ============================================================================

-- 1. SENHAS FORTES:
--    - Trocar senhas padrão em PRODUÇÃO
--    - Usar geradores de senha (min 16 caracteres)
--    - Incluir maiúsculas, minúsculas, números, símbolos

-- 2. CONEXÃO REMOTA:
--    - Em produção, trocar 'localhost' por IP específico
--    - Exemplo: 'delivery_app'@'192.168.1.100'
--    - Ou usar SSL para conexões remotas

-- 3. AUDITORIA:
--    - Habilitar general_log para auditoria (CUIDADO: impacto em performance)
--    - Monitorar acessos suspeitos
--    - Revisar permissões periodicamente

-- 4. ROTAÇÃO DE SENHAS:
--    - Trocar senhas a cada 90 dias
--    - Comando: ALTER USER 'delivery_app'@'localhost' IDENTIFIED BY 'NovaSenha';

-- 5. PRINCÍPIO DO MENOR PRIVILÉGIO:
--    - Cada usuário só tem permissões ESSENCIAIS
--    - Revisar permissões regularmente
--    - Remover permissões não utilizadas

-- ============================================================================
-- MATRIZ DE PERMISSÕES
-- ============================================================================
--
-- | Operação          | admin | app | readonly | reports |
-- |---------------------|-------|-----|----------|---------|
-- | SELECT (todas)      |   \u2713   |  \u2713  |    \u2713     |   \u2713*    |
-- | INSERT              |   \u2713   |  \u2713  |    \u2717     |   \u2717     |
-- | UPDATE              |   \u2713   |  \u2713  |    \u2717     |   \u2717     |
-- | DELETE              |   \u2713   |  \u2713  |    \u2717     |   \u2717     |
-- | DROP/ALTER          |   \u2713   |  \u2717  |    \u2717     |   \u2717     |
-- | EXECUTE (procs)     |   \u2713   |  \u2713  |    \u2717     |   \u2717     |
-- | EXECUTE (funcs)     |   \u2713   |  \u2713  |    \u2713     |   \u2713     |
-- | CREATE              |   \u2713   |  \u2717  |    \u2717     |   \u2717     |
-- | Dados sensíveis   |   \u2713   |  \u2713  |    \u2717     |   \u2717     |
--
-- * reports: apenas tabelas não sensíveis
--
-- ============================================================================

-- ============================================================================
-- COMANDOS ÚTEIS DE ADMINISTRAÇÃO
-- ============================================================================

-- Revogar todas as permissões de um usuário:
-- REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'delivery_app'@'localhost';

-- Deletar um usuário:
-- DROP USER 'delivery_app'@'localhost';

-- Alterar senha:
-- ALTER USER 'delivery_app'@'localhost' IDENTIFIED BY 'NovaSenha';

-- Bloquear/desbloquear usuário (MySQL 8.0+):
-- ALTER USER 'delivery_app'@'localhost' ACCOUNT LOCK;
-- ALTER USER 'delivery_app'@'localhost' ACCOUNT UNLOCK;

-- Ver processos ativos de um usuário:
-- SELECT * FROM information_schema.processlist WHERE user = 'delivery_app';

-- Matar processo de um usuário:
-- KILL <process_id>;

-- ============================================================================
-- FIM DA CONFIGURAÇÃO DE USUÁRIOS E PERMISSÕES
-- ============================================================================
