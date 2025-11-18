# Sistema de Delivery - Trabalho Acadêmico

## Banco de Dados II - Projeto Completo

[![MySQL](https://img.shields.io/badge/MySQL-8.0+-blue.svg)](https://www.mysql.com/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)
[![React](https://img.shields.io/badge/React-18+-blue.svg)](https://reactjs.org/)
[![License](https://img.shields.io/badge/License-Academic-yellow.svg)]()

---

## Visão Geral

Este projeto é um **sistema de delivery completo** (similar a iFood, Uber Eats).

- **Banco MySQL** 
- **Tabelas `usuarios` e `grupos_usuarios`** 
- **6 Triggers** 
- **5 Views** 
- **3 Procedures + 6 Functions** SQL
- **12+ Índices customizados** 
- **Funções de geração de IDs**
- **4 Usuários MySQL** 
- **DER (Diagrama Entidade-Relacionamento)** 
- **Backend** 
- **Frontend** 
- **Documento técnico** 

---

## Índice

- [Visão Geral](#visão-geral)
- [Funcionalidades](#funcionalidades)
- [Arquitetura](#arquitetura)
- [Banco de Dados MySQL](#banco-de-dados-mysql)
- [Stack Tecnológica](#stack-tecnológica)
- [Instalação](#instalação)
- [Como Executar](#como-executar)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Documentação](#documentação)
- [Requisitos Atendidos](#requisitos-atendidos)
- [Usuários de Teste](#usuários-de-teste)
- [Diferenciais](#diferenciais)
- [Segurança](#segurança)
- [Licença](#licença)

---

## Funcionalidades

### Para Clientes
- Cadastro e autenticação (login/logout)
- Navegação por categorias de produtos
- Busca textual de produtos (FULLTEXT INDEX)
- Carrinho de compras
- Múltiplos endereços de entrega
- Aplicação de cupons de desconto
- Acompanhamento de pedidos em tempo real
- Histórico de pedidos
- Avaliação de pedidos (1-5 estrelas)
- Programa de fidelidade automático

### Para Entregadores
- Dashboard de pedidos disponíveis
- Aceitar pedidos
- Atualizar status de entrega
- Histórico de entregas
- Métricas de desempenho

### Para Gerentes
- Dashboard gerencial
- Relatórios de vendas por categoria
- Produtos mais vendidos
- Desempenho de entregadores
- Gestão de cupons de desconto
- Visualização de clientes VIP

### Para Administradores
- Gestão completa de usuários
- Gestão de produtos e categorias
- Gestão de pedidos
- Logs de auditoria
- Controle de estoque
- Configurações do sistema

---

## Arquitetura

```
┌──────────────────────┐
│   Frontend (React)   │
│  - Interface usuário │
│  - Dashboard         │
└───────┬──────────────┘
        │ HTTP/REST API
┌───────┴──────────────┐
│  Backend (Node.js)   │
│  - API REST          │
│  - Autenticação JWT  │
│  - Lógica de negócio │
└────┬──────┬──────────┘
     │      │
     │      └──────────────────┐
     │                         │
┌────┴──────────┐      ┌──────┴──────────┐
│  MySQL 8.0+   │      │  NoSQL          │
│ - 13 tabelas  │      │ - Cache sessões │
│ - 6 triggers  │      │ - Fila pedidos  │
│ - 5 views     │      │ - Cache produtos│
│ - 9 procedures│      │                 │
└───────────────┘      └─────────────────┘
```

---

## Banco de Dados MySQL

### Tabelas Implementadas (13)

| # | Tabela | Registros | Descrição |
|---|--------|-----------|-----------|
| 1 | `grupos_usuarios` | 4 | Perfis de usuários (Cliente, Entregador, Gerente, Admin) |
| 2 | `usuarios` | 8 | Usuários do sistema |
| 3 | `usuarios_grupos` | 8 | Associação N:N usuários-grupos |
| 4 | `categorias` | 6 | Categorias de produtos |
| 5 | `produtos` | 21 | Produtos disponíveis |
| 6 | `enderecos` | 5 | Endereços de entrega |
| 7 | `pedidos` | 5 | Pedidos realizados |
| 8 | `itens_pedido` | 13 | Itens de cada pedido |
| 9 | `avaliacoes` | 2 | Avaliações dos pedidos |
| 10 | `log_pedidos` | Auto | Log de mudanças de status |
| 11 | `cupons_desconto` | 4 | Cupons promocionais |
| 12 | `cupons_utilizados` | Auto | Registro de uso de cupons |

### Recursos Avançados

**Índices (12+)**
- Compostos, FULLTEXT, Otimizações de performance
- [Ver detalhes](database/mysql/02_indexes.sql)

**Triggers (6)**
- Validação de estoque
- Cálculo automático de valores
- Auditoria de mudanças
- [Ver detalhes](database/mysql/04_triggers.sql)

**Views (5)**
- Vendas por categoria
- Produtos mais vendidos
- Pedidos completos
- Desempenho de entregadores
- Clientes VIP
- [Ver detalhes](database/mysql/05_views.sql)

**Procedures + Functions (9)**
- Processamento de pedidos
- Cálculo de descontos
- Geração de IDs customizados
- [Ver detalhes](database/mysql/06_procedures_functions.sql)

---

## Stack Tecnológica

### Backend
- **Node.js** 18+ com Express
- **TypeScript** para tipagem estática
- **mysql2** para conexão MySQL
- **JWT** para autenticação
- **Bcrypt** para hashing de senhas
- **Joi** para validação de dados

### Frontend
- **React** 18+ com TypeScript
- **Tailwind CSS** para estilização
- **React Router** para rotas
- **Axios** para requisições HTTP
- **Context API** para estado global

### Bancos de Dados
- **MySQL** 8.0+ (Relacional)

### Ferramentas
- **Git** para versionamento
- **Vite** para build do frontend

---

## Instalação

### Pré-requisitos

```bash
# Verificar versões
node --version  # 18+
npm --version   # 9+
mysql --version # 8.0+
```

### 1. Clonar Repositório

```bash
git clone https://github.com/01fff/delivery_system.git
cd delivery_system/delivery_system
```

### 2. Instalar Banco de Dados MySQL

```bash
cd database/mysql
mysql -u root -p < 00_INSTALL.sql
```

Este comando irá:
- Criar o banco `delivery_system`
- Criar 13 tabelas
- Criar 12+ índices
- Criar 6 triggers
- Criar 5 views
- Criar 9 procedures/functions
- Criar 4 usuários MySQL
- Inserir dados de teste

### 3. Instalar Dependências do Backend

```bash
cd ../../backend
npm install
```

### 4. Configurar Variáveis de Ambiente

```bash
cp .env.example .env
```

Editar `.env`:
```env
# MySQL
DB_HOST=localhost
DB_PORT=3306
DB_NAME=delivery_system
DB_USER=delivery_app
DB_PASSWORD=DeliveryApp@2024

# JWT
JWT_SECRET=seu_secret_super_secreto_aqui
JWT_EXPIRES_IN=7d

# Servidor
PORT=3001
NODE_ENV=development
```

### 5. Instalar Dependências do Frontend

```bash
cd ../frontend
npm install
```

---

## Como Executar

### Executar Backend

**Terminal 1 - Backend:**
```bash
cd backend
npm run dev
```

### Executar Frontend

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

**Acessos:**
- Frontend: http://localhost:3000
- API: http://localhost:3001/api

---

## Estrutura do Projeto

```
academic_delivery_system/
├── database/
│   ├── mysql/
│   │   ├── 00_INSTALL.sql           # Script master de instalação
│   │   ├── 01_schema.sql            # Tabelas
│   │   ├── 02_indexes.sql           # Índices
│   │   ├── 03_functions_id.sql      # Funções de IDs
│   │   ├── 04_triggers.sql          # Triggers
│   │   ├── 05_views.sql             # Views
│   │   ├── 06_procedures.sql        # Procedures/Functions
│   │   ├── 07_users_permissions.sql # Usuários MySQL
│   │   └── 08_seed_data.sql         # Dados iniciais
│   └── README.md                    # Documentação do BD
│
├── backend/
│   ├── src/
│   │   ├── controllers/             # Controladores
│   │   ├── routes/                  # Rotas da API
│   │   ├── middlewares/             # Middlewares (auth, etc)
│   │   ├── services/                # Lógica de negócio
│   │   ├── config/                  # Configurações
│   │   └── types/                   # TypeScript types
│   ├── package.json
│   └── tsconfig.json
│
├── frontend/
│   ├── src/
│   │   ├── components/              # Componentes React
│   │   ├── pages/                   # Páginas
│   │   ├── services/                # Serviços (API)
│   │   ├── contexts/                # Context API
│   │   └── types/                   # TypeScript types
│   ├── public/
│   └── package.json
│
├── docs/
│   └── DER.md                       # Diagrama ER
│
└── README.md                        # Este arquivo
```

---

## Documentação

| Documento | Descrição | Link |
|-----------|-----------|------|
| **README do Banco** | Documentação completa do MySQL | [database/README.md](database/README.md) |
| **DER** | Diagrama Entidade-Relacionamento | [docs/DER.md](docs/DER.md) |
| **Backend API** | Documentação dos endpoints | [backend/README.md](backend/README.md) |
| **Frontend** | Documentação da interface | [frontend/README.md](frontend/README.md) |

---

## Requisitos Atendidos

### Banco de Dados Relacional (MySQL)

| Requisito | Status | Implementação |
|-----------|--------|---------------|
| Banco MySQL | OK | MySQL 8.0+ |
| Tabela `usuarios` | OK | [01_schema.sql:38](database/mysql/01_schema.sql) |
| Tabela `grupos_usuarios` | OK | [01_schema.sql:19](database/mysql/01_schema.sql) |
| Relacionamento N:N | OK | Tabela `usuarios_grupos` |
| Mínimo 2 Triggers | OK | **6 triggers** implementados |
| Mínimo 2 Views | OK | **5 views** implementadas |
| Mínimo 2 Procedures/Functions | OK | **9 procedures/functions** |
| Índices customizados | OK | **12+ índices** com justificativa |
| Geração de IDs customizada | OK | 3 funções de geração |
| Usuários MySQL (níveis) | OK | **4 usuários** (admin, app, readonly, reports) |
| Controle de acesso granular | OK | Permissões específicas por usuário |
| Autenticação via usuarios/grupos | OK | JWT + bcrypt integrado |

### Aplicação

| Requisito | Status | Implementação |
|-----------|--------|---------------|
| Frontend funcional | OK | React + TypeScript |
| Backend completo | OK | Node.js + Express |
| Autenticação | OK | JWT |
| CRUD completo | OK | Todas as entidades |

### Documentação

| Requisito | Status | Implementação |
|-----------|--------|---------------|
| DER | OK | [docs/DER.md](docs/DER.md) |
| Justificativas técnicas | OK | Inline em cada arquivo SQL |
| README completo | OK | Este arquivo |

---

### Usuários do Sistema (Login na aplicação)

| Tipo | Email | Senha | Permissões |
|------|-------|-------|------------|
| **Admin** | admin@deliverysystem.com | senha123 | Acesso total |
| **Gerente** | fernanda.gerente@email.com | senha123 | Relatórios, gestão |
| **Entregador** | carlos.entrega@email.com | senha123 | Aceitar/entregar pedidos |
| **Cliente** | joao.silva@email.com | senha123 | Fazer pedidos |

### Usuários MySQL (Acesso ao banco)

| Usuário | Senha | Nível |
|---------|-------|-------|
| delivery_admin | DeliveryAdmin@2024 | DBA |
| delivery_app | DeliveryApp@2024 | Aplicação |
| delivery_readonly | DeliveryReadonly@2024 | Somente Leitura |
| delivery_reports | DeliveryReports@2024 | Relatórios |

---

## Segurança

### Implementações de Segurança

- **Senhas hasheadas** 
- **Autenticação JWT** 
- **Validação de dados** 
- **Prepared Statements** 
- **CORS** 
- **Rate Limiting** 
- **IDs não sequenciais** 
- **Princípio do menor privilégio** 
- **Auditoria completa** 


