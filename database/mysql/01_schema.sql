-- ============================================================================
-- SISTEMA DE DELIVERY - BANCO DE DADOS MYSQL
-- ============================================================================
-- Descrição: Schema completo do sistema de delivery com todas as tabelas,
--              relacionamentos, constraints e configurações necessárias
-- ============================================================================

-- Remove o banco se existir e cria novamente
DROP DATABASE IF EXISTS delivery_system;
CREATE DATABASE delivery_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE delivery_system;

-- ============================================================================
-- TABELA: grupos_usuarios
-- Descrição: Armazena os diferentes grupos/perfis de usuários do sistema
-- ============================================================================
CREATE TABLE grupos_usuarios (
    id BIGINT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao VARCHAR(255),
    nivel_acesso TINYINT NOT NULL DEFAULT 1 COMMENT '1=Cliente, 2=Entregador, 3=Gerente, 4=Admin',
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB COMMENT='Grupos/perfis de usuários do sistema';

-- ============================================================================
-- TABELA: usuarios
-- Descrição: Armazena os usuários do sistema (clientes, entregadores, admins)
-- IMPORTANTE: Tabela central para autenticação 
-- ============================================================================
CREATE TABLE usuarios (
    id BIGINT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    cpf VARCHAR(14) UNIQUE,
    data_nascimento DATE,
    foto_perfil_url VARCHAR(500),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    email_verificado BOOLEAN NOT NULL DEFAULT FALSE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    ultimo_acesso TIMESTAMP NULL,
    PRIMARY KEY (id)
) ENGINE=InnoDB COMMENT='Usuários do sistema (clientes, entregadores, administradores)';

-- ============================================================================
-- TABELA: usuarios_grupos (Tabela Associativa - Relacionamento N:N)
-- Descrição: Relaciona usuários com seus grupos/perfis
-- Um usuário pode ter múltiplos perfis (ex: Cliente e Entregador)
-- ============================================================================
CREATE TABLE usuarios_grupos (
    usuario_id BIGINT NOT NULL,
    grupo_id BIGINT NOT NULL,
    data_associacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (usuario_id, grupo_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (grupo_id) REFERENCES grupos_usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Associação entre usuários e grupos (relacionamento N:N)';

-- ============================================================================
-- TABELA: categorias
-- Descrição: Categorias de produtos (Lanches, Bebidas, Sobremesas, etc.)
-- ============================================================================
CREATE TABLE categorias (
    id BIGINT NOT NULL AUTO_INCREMENT,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao TEXT,
    imagem_url VARCHAR(500),
    ordem_exibicao INT NOT NULL DEFAULT 0,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB COMMENT='Categorias de produtos do sistema';

-- ============================================================================
-- TABELA: produtos
-- Descrição: Produtos disponíveis para venda no sistema
-- ============================================================================
CREATE TABLE produtos (
    id BIGINT NOT NULL AUTO_INCREMENT,
    categoria_id BIGINT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL CHECK (preco >= 0),
    preco_promocional DECIMAL(10,2) CHECK (preco_promocional >= 0),
    estoque INT NOT NULL DEFAULT 0 CHECK (estoque >= 0),
    estoque_minimo INT NOT NULL DEFAULT 5,
    imagem_url VARCHAR(500),
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    destaque BOOLEAN NOT NULL DEFAULT FALSE,
    tempo_preparo_minutos INT DEFAULT 30,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (categoria_id) REFERENCES categorias(id) ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='Produtos disponíveis para venda';

-- ============================================================================
-- TABELA: enderecos
-- Descrição: Endereços de entrega dos usuários
-- Um usuário pode ter múltiplos endereços
-- ============================================================================
CREATE TABLE enderecos (
    id BIGINT NOT NULL AUTO_INCREMENT,
    usuario_id BIGINT NOT NULL,
    titulo VARCHAR(50) COMMENT 'Casa, Trabalho, etc.',
    cep VARCHAR(9) NOT NULL,
    rua VARCHAR(255) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    complemento VARCHAR(100),
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado CHAR(2) NOT NULL,
    referencia TEXT,
    principal BOOLEAN NOT NULL DEFAULT FALSE,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Endereços de entrega dos usuários';

-- ============================================================================
-- TABELA: pedidos
-- Descrição: Pedidos realizados no sistema
-- Status: PENDENTE, CONFIRMADO, PREPARANDO, SAIU_ENTREGA, ENTREGUE, CANCELADO
-- ============================================================================
CREATE TABLE pedidos (
    id BIGINT NOT NULL AUTO_INCREMENT,
    usuario_id BIGINT NOT NULL,
    endereco_id BIGINT NOT NULL,
    entregador_id BIGINT NULL COMMENT 'ID do usuário entregador',
    data_pedido TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PENDENTE', 'CONFIRMADO', 'PREPARANDO', 'SAIU_ENTREGA', 'ENTREGUE', 'CANCELADO') NOT NULL DEFAULT 'PENDENTE',
    valor_subtotal DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (valor_subtotal >= 0),
    valor_desconto DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (valor_desconto >= 0),
    valor_entrega DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (valor_entrega >= 0),
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (valor_total >= 0),
    forma_pagamento ENUM('DINHEIRO', 'CARTAO_CREDITO', 'CARTAO_DEBITO', 'PIX', 'VALE_REFEICAO') NOT NULL,
    observacoes TEXT,
    tempo_estimado_minutos INT DEFAULT 45,
    data_confirmacao TIMESTAMP NULL,
    data_entrega TIMESTAMP NULL,
    data_cancelamento TIMESTAMP NULL,
    motivo_cancelamento TEXT,
    PRIMARY KEY (id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE RESTRICT,
    FOREIGN KEY (endereco_id) REFERENCES enderecos(id) ON DELETE RESTRICT,
    FOREIGN KEY (entregador_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='Pedidos realizados no sistema';

-- ============================================================================
-- TABELA: itens_pedido
-- Descrição: Itens individuais de cada pedido
-- Relacionamento 1:N com pedidos
-- ============================================================================
CREATE TABLE itens_pedido (
    id BIGINT NOT NULL AUTO_INCREMENT,
    pedido_id BIGINT NOT NULL,
    produto_id BIGINT NOT NULL,
    quantidade INT NOT NULL DEFAULT 1 CHECK (quantidade > 0),
    preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario >= 0),
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (subtotal >= 0),
    observacoes VARCHAR(255),
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (produto_id) REFERENCES produtos(id) ON DELETE RESTRICT
) ENGINE=InnoDB COMMENT='Itens individuais de cada pedido';

-- ============================================================================
-- TABELA: avaliacoes
-- Descrição: Avaliações dos pedidos feitas pelos clientes
-- Nota de 1 a 5 estrelas
-- ============================================================================
CREATE TABLE avaliacoes (
    id BIGINT NOT NULL AUTO_INCREMENT,
    pedido_id BIGINT NOT NULL UNIQUE,
    usuario_id BIGINT NOT NULL,
    nota TINYINT NOT NULL CHECK (nota BETWEEN 1 AND 5),
    comentario TEXT,
    data_avaliacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Avaliações dos pedidos pelos clientes';

-- ============================================================================
-- TABELA: log_pedidos
-- Descrição: Log de mudanças de status dos pedidos para auditoria
-- Será alimentada automaticamente via TRIGGER
-- ============================================================================
CREATE TABLE log_pedidos (
    id BIGINT NOT NULL AUTO_INCREMENT,
    pedido_id BIGINT NOT NULL,
    status_anterior VARCHAR(20),
    status_novo VARCHAR(20) NOT NULL,
    usuario_responsavel_id BIGINT NULL COMMENT 'Usuário que alterou o status',
    observacao TEXT,
    data_mudanca TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_responsavel_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB COMMENT='Log de mudanças de status dos pedidos (auditoria)';

-- ============================================================================
-- TABELA: cupons_desconto
-- Descrição: Cupons de desconto para promoções
-- ============================================================================
CREATE TABLE cupons_desconto (
    id BIGINT NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    descricao VARCHAR(255),
    tipo_desconto ENUM('PERCENTUAL', 'VALOR_FIXO') NOT NULL,
    valor_desconto DECIMAL(10,2) NOT NULL CHECK (valor_desconto > 0),
    valor_minimo_pedido DECIMAL(10,2) DEFAULT 0,
    quantidade_disponivel INT,
    quantidade_usada INT NOT NULL DEFAULT 0,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=InnoDB COMMENT='Cupons de desconto para promoções';

-- ============================================================================
-- TABELA: cupons_utilizados
-- Descrição: Registro de cupons utilizados pelos usuários
-- ============================================================================
CREATE TABLE cupons_utilizados (
    id BIGINT NOT NULL AUTO_INCREMENT,
    cupom_id BIGINT NOT NULL,
    pedido_id BIGINT NOT NULL UNIQUE,
    usuario_id BIGINT NOT NULL,
    valor_desconto_aplicado DECIMAL(10,2) NOT NULL,
    data_utilizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (cupom_id) REFERENCES cupons_desconto(id) ON DELETE CASCADE,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='Registro de uso de cupons de desconto';

-- ============================================================================
-- FIM DO SCHEMA
-- ============================================================================
