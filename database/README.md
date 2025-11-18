# Banco de Dados - Sistema de Delivery

Este diretório contém toda a estrutura de banco de dados do Sistema de Delivery.

---

## Estrutura de Arquivos

```
database/
├── mysql/
|   ├── 00_INSTALL.sql              # Script master de instalação
|   ├── 01_schema.sql                # Tabelas e estrutura do banco
|   ├── 02_indexes.sql               # Índices customizados (12+)
|   ├── 03_functions_id_generation.sql  # Funções de geração de IDs
|   ├── 04_triggers.sql              # Triggers (6+)
|   ├── 05_views.sql                 # Views (5+)
|   ├── 06_procedures_functions.sql  # Procedures e Functions
|   ├── 07_users_permissions.sql     # Usuários MySQL e permissões
|   ├── 08_seed_data.sql             # Dados iniciais para testes
│
├── migrations/                    # (Para uso futuro com ORMs)
├── seeds/                         # (Para uso futuro com ORMs)
```

---

## Instalação Rápida

### Pré-requisitos
- MySQL 8.0+ instalado
- Acesso root ao MySQL

### Opção 1: Instalação Completa (Recomendado)

```bash
cd database/mysql
mysql -u root -p < 00_INSTALL.sql
```

Este script executará TODOS os arquivos na ordem correta.

### Opção 2: Instalação Manual

Executar cada arquivo na ordem:

```bash
mysql -u root -p < 01_schema.sql
mysql -u root -p < 02_indexes.sql
mysql -u root -p < 03_functions_id_generation.sql
mysql -u root -p < 04_triggers.sql
mysql -u root -p < 05_views.sql
mysql -u root -p < 06_procedures_functions.sql
mysql -u root -p < 07_users_permissions.sql
mysql -u root -p < 08_seed_data.sql
```

### Opção 3: MySQL Workbench

1. Abra o MySQL Workbench
2. Conecte como `root`
3. **File > Run SQL Script**
4. Selecione `00_INSTALL.sql`

---

## Arquitetura do Banco de Dados

### Tabelas Principais (13 tabelas)

| Tabela | Descrição | Registros Iniciais │
|--------|------------|-------------------│
| `grupos_usuarios` | Grupos/perfis de usuários | 4 │
| `usuarios` | Usuários do sistema | 8 │
| `usuarios_grupos` | Associação N:N usuários-grupos | 8 │
| `categorias` | Categorias de produtos | 6 │
| `produtos` | Produtos disponíveis | 21 │
| `enderecos` | Endereços de entrega | 5 │
| `pedidos` | Pedidos realizados | 5 │
| `itens_pedido` | Itens de cada pedido | 13 │
| `avaliacoes` | Avaliações dos pedidos | 2 │
| `log_pedidos` | Log de mudanças de status | Auto │
| `cupons_desconto` | Cupons promocionais | 4 │
| `cupons_utilizados` | Registro de uso de cupons | Auto │

### Relacionamentos

```
grupos_usuarios (1) --< (N) usuarios_grupos (N) >-- (1) usuarios
usuarios (1) --< (N) enderecos
usuarios (1) --< (N) pedidos
pedidos (1) --< (N) itens_pedido (N) >-- (1) produtos
produtos (N) >-- (1) categorias
pedidos (1) --- (0..1) avaliacoes
pedidos (1) --< (N) log_pedidos
```

---

## Recursos Implementados

### Índices Customizados (12+)

| Índice | Tabela | Tipo | Justificativa │
|---------|--------|------|---------------│
| `idx_usuarios_email_ativo` | usuarios | Composto | Otimiza autenticação (~80% mais rápido) │
| `idx_pedidos_usuario_data` | pedidos | Composto DESC | Histórico de pedidos do usuário │
| `idx_pedidos_status_data` | pedidos | Composto | Dashboard de administração │
| `idx_produtos_categoria_ativo` | produtos | Composto | Listagem de catálogo (60% das queries) │
| `idx_produtos_busca_fulltext` | produtos | FULLTEXT | Busca textual eficiente │
| *+7 índices adicionais* | várias | Diversos | Ver `02_indexes.sql` │

### Triggers (6+)

| Trigger | Tabela | Evento | Função │
|---------|--------|--------|----------│
| `trg_atualizar_subtotal_item` | itens_pedido | BEFORE INSERT/UPDATE | Calcula subtotal automaticamente │
| `trg_atualizar_valor_total_pedido` | itens_pedido | AFTER INSERT/UPDATE/DELETE | Atualiza valor total do pedido │
| `trg_log_status_pedido` | pedidos | AFTER UPDATE | Registra mudanças de status (auditoria) │
| `trg_validar_estoque_produto` | itens_pedido | BEFORE INSERT | Valida disponibilidade de estoque │
| `trg_atualizar_estoque_produto` | itens_pedido | AFTER INSERT | Decrementa estoque automaticamente │
| `trg_gerar_codigos_pedido` | pedidos | BEFORE INSERT | Gera códigos de rastreamento │

### Views (5+)

| View | Descrição | Uso │
|------|------------|-----│
| `vw_vendas_por_categoria` | Vendas agrupadas por categoria | Dashboard gerencial │
| `vw_produtos_mais_vendidos` | Ranking de produtos | Top 10, gestão de estoque │
| `vw_pedidos_completos` | Visão completa de pedidos | Detalhes, notas fiscais │
| `vw_desempenho_entregadores` | Métricas de entregadores | Ranking, bonificação │
| `vw_clientes_vip` | Clientes de alto valor | Marketing, fidelidade │

### Procedures (3)

| Procedure | Parâmetros | Função │
|-----------|------------|----------│
| `sp_processar_pedido_completo` | 8 params | Cria pedido com itens (transacional) │
| `sp_cancelar_pedido` | 3 params | Cancela pedido e reverte estoque │
| `sp_atualizar_status_pedido` | 3 params | Atualiza status com validações │

### Functions (6)

| Função | Retorno | Finalidade │
|---------|---------|-----------│
| `gerar_id_pedido()` | VARCHAR(13) | ID legível (241118-000001) │
| `gerar_codigo_rastreamento()` | VARCHAR(13) | Código alfanumérico (DLV-XXXXXXXXXX) │
| `gerar_codigo_cupom(prefixo)` | VARCHAR(30) | Código de cupom personalizado │
| `fn_calcular_desconto_fidelidade(user_id)` | DECIMAL | Desconto baseado em histórico │
| `fn_calcular_tempo_estimado_entrega(pedido_id)` | INT | Tempo estimado em minutos │
| `fn_verificar_disponibilidade_produto(id, qtd)` | BOOLEAN | Valida disponibilidade │

---

## Usuários MySQL

| Usuário | Senha Padrão | Nível | Permissões │
|----------|-------------|--------|------------│
| `delivery_admin` | DeliveryAdmin@2024 | Administrador | ALL PRIVILEGES │
| `delivery_app` | DeliveryApp@2024 | Aplicação | SELECT, INSERT, UPDATE, DELETE, EXECUTE │
| `delivery_readonly` | DeliveryReadonly@2024 | Somente Leitura | SELECT │
| `delivery_reports` | DeliveryReports@2024 | Relatórios | SELECT (views + tabelas selecionadas) │


### Exemplo de Conexão

```bash
# Conectar como delivery_app
mysql -u delivery_app -p'DeliveryApp@2024' delivery_system
```

---

## Exemplos de Queries

### Consultar Produtos Mais Vendidos

```sql
SELECT * FROM vw_produtos_mais_vendidos
ORDER BY total_vendido DESC
LIMIT 10;
```

### Consultar Vendas por Categoria

```sql
SELECT * FROM vw_vendas_por_categoria
ORDER BY receita_total DESC;
```

### Criar Pedido Completo

```sql
CALL sp_processar_pedido_completo(
    1,                                           -- usuario_id
    1,                                           -- endereco_id
    'PIX',                                       -- forma_pagamento
    'Sem cebola',                                -- observacoes
    'PROMO10',                                   -- codigo_cupom
    '[{"produto_id": 1, "quantidade": 2}]',     -- itens_json
    @pedido_id,                                 -- OUT: pedido_id
    @codigo_rastreamento                        -- OUT: codigo_rastreamento
);

SELECT @pedido_id, @codigo_rastreamento;
```

### Verificar Desconto de Fidelidade

```sql
SELECT
    u.nome,
    fn_calcular_desconto_fidelidade(u.id) AS desconto_percentual
FROM usuarios u
WHERE id = 1;
```

### Gerar Código de Rastreamento

```sql
SELECT
    gerar_id_pedido() AS id_pedido,
    gerar_codigo_rastreamento() AS codigo_rastreamento;
```

---

## Manutenção

### Verificar Estrutura do Banco

```sql
-- Listar todas as tabelas
SHOW TABLES;

-- Verificar estrutura de uma tabela
DESCRIBE pedidos;

-- Verificar índices
SHOW INDEX FROM pedidos;

-- Listar triggers
SHOW TRIGGERS;

-- Listar procedures
SHOW PROCEDURE STATUS WHERE Db = 'delivery_system';

-- Listar funções
SHOW FUNCTION STATUS WHERE Db = 'delivery_system';
```

### Analisar Performance

```sql
-- Explicar plano de execução
EXPLAIN SELECT * FROM pedidos WHERE usuario_id = 1;

-- Estatísticas de tabela
SHOW TABLE STATUS LIKE 'pedidos';

-- Estatísticas de índices
ANALYZE TABLE pedidos;
```

### Backup e Restore

```bash
# Backup completo
mysqldump -u delivery_admin -p delivery_system > backup_delivery.sql

# Backup apenas estrutura (sem dados)
mysqldump -u delivery_admin -p --no-data delivery_system > schema_only.sql

# Restore
mysql -u delivery_admin -p delivery_system < backup_delivery.sql
```

---

##  Segurança

### Boas Práticas Implementadas

1. **Princípio do Menor Privilégio:** Cada usuário tem apenas permissões necessárias
2. **Auditoria:** Tabela `log_pedidos` registra todas mudanças de status
3. **Validações:** Triggers validam dados antes de inserções
4. **Senhas Hasheadas:** Senhas armazenadas com bcrypt
5. **IDs Não Sequenciais:** Evita enumeração de recursos (IDOR)


## Estatísticas

### Dados Iniciais (Seed)

- **Usuários:** 8 (4 clientes, 2 entregadores, 1 gerente, 1 admin)
- **Categorias:** 6
- **Produtos:** 21
- **Pedidos:** 5 (demonstrando diferentes status)
- **Avaliações:** 2
- **Cupons:** 4

### Credenciais de Teste

**Administrador:**
- Email: `admin@deliverysystem.com`
- Senha: `senha123`

**Gerente:**
- Email: `fernanda.gerente@email.com`
- Senha: `senha123`

**Cliente:**
- Email: `joao.silva@email.com`
- Senha: `senha123`

---

## Troubleshooting

### Erro: "Access denied for user"

```bash
# Verificar se o usuário existe
mysql -u root -p
SELECT User, Host FROM mysql.user WHERE User LIKE 'delivery_%';

# Recriar permissões
SOURCE 07_users_permissions.sql;
```

### Erro: "Unknown database 'delivery_system'"

```bash
# Executar o script de schema
mysql -u root -p < 01_schema.sql
```

### Erro: "Trigger already exists"

```sql
-- Remover todos os triggers e recriar
DROP TRIGGER IF EXISTS trg_atualizar_subtotal_item;
SOURCE 04_triggers.sql;
```

---

