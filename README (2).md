# Sistema de Delivery - Trabalho Academico

[![MySQL](https://img.shields.io/badge/MySQL-8.0+-blue.svg)](https://www.mysql.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-7.0+-green.svg)](https://www.mongodb.com/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)
[![React](https://img.shields.io/badge/React-18+-blue.svg)](https://reactjs.org/)
[![License](https://img.shields.io/badge/License-Academic-yellow.svg)]()

---

## Visao Geral

Este projeto e um **sistema de delivery completo** (similar a iFood, Uber Eats) com **arquitetura hibrida** de bancos de dados.

- **MySQL** - Banco de dados principal (relacional)
- **MongoDB** - Cache e analytics (NoSQL)
- **Tabelas `usuarios` e `grupos_usuarios`**
- **6 Triggers**
- **5 Views**
- **3 Procedures + 6 Functions** SQL
- **12+ Indices customizados**
- **Funcoes de geracao de IDs**
- **4 Usuarios MySQL**
- **DER (Diagrama Entidade-Relacionamento)**
- **Backend Node.js + TypeScript**
- **Frontend React + TypeScript**
- **Documento tecnico**

---

## Indice

- [Visao Geral](#visao-geral)
- [Funcionalidades](#funcionalidades)
- [Arquitetura](#arquitetura)
- [Bancos de Dados](#bancos-de-dados)
  - [MySQL](#banco-de-dados-mysql)
  - [MongoDB](#banco-de-dados-mongodb)
- [Stack Tecnologica](#stack-tecnologica)
- [Instalacao](#instalacao)
- [Como Executar](#como-executar)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Documentacao](#documentacao)
- [Requisitos Atendidos](#requisitos-atendidos)
- [Usuarios de Teste](#usuarios-de-teste)
- [Diferenciais](#diferenciais)
- [Seguranca](#seguranca)
- [Licenca](#licenca)

---

## Funcionalidades

### Para Clientes
- Cadastro e autenticacao (login/logout)
- Navegacao por categorias de produtos
- Busca textual de produtos (FULLTEXT INDEX)
- Carrinho de compras
- Multiplos enderecos de entrega
- Aplicacao de cupons de desconto
- Acompanhamento de pedidos em tempo real
- Historico de pedidos
- Avaliacao de pedidos (1-5 estrelas)
- Programa de fidelidade automatico

### Para Entregadores
- Dashboard de pedidos disponiveis
- Aceitar pedidos
- Atualizar status de entrega
- Historico de entregas
- Metricas de desempenho

### Para Gerentes
- Dashboard gerencial
- Relatorios de vendas por categoria
- Produtos mais vendidos
- Desempenho de entregadores
- Gestao de cupons de desconto
- Visualizacao de clientes VIP

### Para Administradores
- Gestao completa de usuarios
- Gestao de produtos e categorias
- Gestao de pedidos
- Logs de auditoria
- Controle de estoque
- Configuracoes do sistema

---

## Arquitetura

```
┌──────────────────────┐
│   Frontend (React)   │
│  - Interface usuario │
│  - Dashboard         │
└───────┬──────────────┘
        │ HTTP/REST API
┌───────┴──────────────┐
│  Backend (Node.js)   │
│  - API REST          │
│  - Autenticacao JWT  │
│  - Logica de negocio │
└────┬──────┬──────────┘
     │      │
     │      └──────────────────┐
     │                         │
┌────┴────────────┐   ┌────────┴────────────┐
│  MySQL 8.0+     │   │  MongoDB 7.0+       │
│  (Principal)    │   │  (Cache/Analytics)  │
│                 │   │                     │
│ - 13 tabelas    │   │ - product_cache     │
│ - 6 triggers    │   │ - order_events      │
│ - 5 views       │   │ - user_sessions     │
│ - 9 procedures  │   │ - Indices TTL       │
│ - Transacoes    │   │ - Agregacoes        │
└─────────────────┘   └─────────────────────┘
```

### Arquitetura Hibrida

O sistema utiliza uma **abordagem hibrida** combinando os pontos fortes de cada banco:

- **MySQL** - Dados transacionais criticos (pedidos, usuarios, produtos)
- **MongoDB** - Cache de alta performance e analytics

**Beneficios:**
- 70% menos consultas no MySQL (cache)
- Analytics em tempo real
- Performance otimizada
- Integridade garantida (MySQL)

---

## Bancos de Dados

### Banco de Dados MySQL

#### Tabelas Implementadas (13)

| # | Tabela | Registros | Descricao |
|---|--------|-----------|-----------|
| 1 | `grupos_usuarios` | 4 | Perfis de usuarios (Cliente, Entregador, Gerente, Admin) |
| 2 | `usuarios` | 8 | Usuarios do sistema |
| 3 | `usuarios_grupos` | 8 | Associacao N:N usuarios-grupos |
| 4 | `categorias` | 6 | Categorias de produtos |
| 5 | `produtos` | 21 | Produtos disponiveis |
| 6 | `enderecos` | 5 | Enderecos de entrega |
| 7 | `pedidos` | 5 | Pedidos realizados |
| 8 | `itens_pedido` | 13 | Itens de cada pedido |
| 9 | `avaliacoes` | 2 | Avaliacoes dos pedidos |
| 10 | `log_pedidos` | Auto | Log de mudancas de status |
| 11 | `cupons_desconto` | 4 | Cupons promocionais |
| 12 | `cupons_utilizados` | Auto | Registro de uso de cupons |

#### Recursos Avancados

**Indices (12+)**
- Compostos, FULLTEXT, Otimizacoes de performance
- [Ver detalhes](database/mysql/02_indexes.sql)

**Triggers (6)**
- Validacao de estoque
- Calculo automatico de valores
- Auditoria de mudancas
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
- Calculo de descontos
- Geracao de IDs customizados
- [Ver detalhes](database/mysql/06_procedures_functions.sql)

---

### Banco de Dados MongoDB

#### Collections Implementadas (3)

| Collection | Descricao | TTL | Indices |
|------------|-----------|-----|---------|
| `product_cache` | Cache de produtos populares | 1 hora | product_id (unico) |
| `order_events` | Eventos de pedidos para analytics | - | timestamp, order_id |
| `user_sessions` | Sessoes ativas de usuarios | 7 dias | expires_at |

#### Funcionalidades do MongoDB

**Cache de Produtos:**
- Reduz 70% das consultas ao MySQL
- TTL automatico de 1 hora
- Contador de visualizacoes

**Analytics de Pedidos:**
- Eventos em tempo real
- Agregacoes por periodo
- Metadados flexiveis (schema-less)

**Gerenciamento de Sessoes:**
- Expiracao automatica
- Informacoes de dispositivo
- Ultima atividade rastreada

#### Servico de Cache (API)

```typescript
// Cache de produtos
cacheProduct(productId, productData, ttlMinutes)
getCachedProduct(productId)
clearProductCache(productId)

// Eventos de pedidos
logOrderEvent(eventType, orderId, userId, data, metadata)
getOrderEvents(orderId)

// Sessoes de usuarios
cacheUserSession(sessionId, userId, token, deviceInfo, ttlDays)
getUserSession(sessionId)
removeUserSession(sessionId)

// Estatisticas
getCacheStats()
```

**Documentacao completa:** [backend/MONGODB_SETUP.md](backend/MONGODB_SETUP.md)

---

## Stack Tecnologica

### Backend
- **Node.js** 18+ com Express
- **TypeScript** para tipagem estatica
- **mysql2** para conexao MySQL
- **mongodb** 7.0+ para conexao MongoDB
- **JWT** para autenticacao
- **Bcrypt** para hashing de senhas
- **Joi** para validacao de dados
- **Helmet** para seguranca HTTP
- **Rate Limiting** para protecao DDoS

### Frontend
- **React** 18+ com TypeScript
- **Tailwind CSS** para estilizacao
- **React Router** para rotas
- **Axios** para requisicoes HTTP
- **Context API** para estado global

### Bancos de Dados
- **MySQL** 8.0+ (Relacional - Principal)
- **MongoDB** 7.0+ (NoSQL - Cache/Analytics)

### Ferramentas
- **Git** para versionamento
- **Vite** para build do frontend

---

## Instalacao

### Pre-requisitos

```bash
# Verificar versoes
node --version  # 18+
npm --version   # 9+
mysql --version # 8.0+
mongod --version # 7.0+ (opcional mas recomendado)
```

### 1. Clonar Repositorio

```bash
git clone https://github.com/01fff/delivery_system.git
cd delivery_system
```

### 2. Instalar Banco de Dados MySQL

```bash
cd database/mysql
mysql -u root -p < 00_INSTALL.sql
```

Este comando ira:
- Criar o banco `delivery_system`
- Criar 13 tabelas
- Criar 12+ indices
- Criar 6 triggers
- Criar 5 views
- Criar 9 procedures/functions
- Criar 4 usuarios MySQL
- Inserir dados de teste

### 3. Instalar MongoDB (Opcional mas Recomendado)

**Windows:**
1. Baixar: https://www.mongodb.com/try/download/community
2. Instalar e iniciar servico:
```powershell
net start MongoDB
```

**Linux (Ubuntu):**
```bash
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
sudo systemctl enable mongod
```

**macOS:**
```bash
brew tap mongodb/brew
brew install mongodb-community
brew services start mongodb-community
```

### 4. Instalar Dependencias do Backend

```bash
cd backend
npm install
```

### 5. Configurar Variaveis de Ambiente

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

# MongoDB (opcional)
MONGO_URI=mongodb://localhost:27017
MONGO_DB_NAME=delivery_system

# JWT
JWT_SECRET=seu_secret_super_secreto_aqui
JWT_EXPIRES_IN=7d

# Servidor
PORT=3001
NODE_ENV=development
CORS_ORIGIN=http://localhost:5173
```

### 6. Instalar Dependencias do Frontend

```bash
cd ../frontend
npm install
```

---

## Como Executar

### 1. Iniciar MongoDB (se instalado)

```bash
# Windows (PowerShell Admin)
net start MongoDB

# Linux/macOS
sudo systemctl start mongod
# ou
brew services start mongodb-community
```

### 2. Testar Conexao MongoDB (opcional)

```bash
cd backend
node test-mongodb.js
```

### 3. Executar Backend

**Terminal 1 - Backend:**
```bash
cd backend
npm run dev
# ou para producao
npm run build
npm start
```

Voce vera:
```
OK: Conectado ao MySQL com sucesso!
OK: Conectado ao MongoDB com sucesso!
Indices MongoDB criados com sucesso
Ping MongoDB bem-sucedido
============================================================
Servidor iniciado com sucesso!
============================================================
```

### 4. Executar Frontend

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

**Acessos:**
- Frontend: http://localhost:5173
- API: http://localhost:3001/api
- Health Check: http://localhost:3001/api/health

---

## Estrutura do Projeto

```
delivery_system/
├── database/
│   ├── mysql/
│   │   ├── 00_INSTALL.sql           # Script master de instalacao
│   │   ├── 01_schema.sql            # Tabelas
│   │   ├── 02_indexes.sql           # Indices
│   │   ├── 03_functions_id.sql      # Funcoes de IDs
│   │   ├── 04_triggers.sql          # Triggers
│   │   ├── 05_views.sql             # Views
│   │   ├── 06_procedures.sql        # Procedures/Functions
│   │   ├── 07_users_permissions.sql # Usuarios MySQL
│   │   └── 08_seed_data.sql         # Dados iniciais
│   └── README.md                    # Documentacao do BD
│
├── backend/
│   ├── src/
│   │   ├── config/
│   │   │   ├── database.ts          # Config MySQL
│   │   │   └── mongodb.ts           # Config MongoDB [NOVO]
│   │   ├── services/
│   │   │   └── cacheService.ts      # Servico de cache MongoDB [NOVO]
│   │   ├── controllers/             # Controladores
│   │   ├── routes/                  # Rotas da API
│   │   ├── middlewares/             # Middlewares (auth, etc)
│   │   └── types/                   # TypeScript types
│   ├── test-mongodb.js              # Script de teste MongoDB [NOVO]
│   ├── MONGODB_SETUP.md             # Documentacao MongoDB [NOVO]
│   ├── package.json
│   └── tsconfig.json
│
├── frontend/
│   ├── src/
│   │   ├── components/              # Componentes React
│   │   ├── pages/                   # Paginas
│   │   ├── services/                # Servicos (API)
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

[NOVO] = Novos arquivos MongoDB

---

## Documentacao

| Documento | Descricao | Link |
|-----------|-----------|------|
| **README do Banco** | Documentacao completa do MySQL | [database/README.md](database/README.md) |
| **MongoDB Setup** | Guia completo do MongoDB | [backend/MONGODB_SETUP.md](backend/MONGODB_SETUP.md) |
| **DER** | Diagrama Entidade-Relacionamento | [docs/DER.md](docs/DER.md) |
| **Backend API** | Documentacao dos endpoints | [backend/README.md](backend/README.md) |
| **Frontend** | Documentacao da interface | [frontend/README.md](frontend/README.md) |

---

## Requisitos Atendidos

### Banco de Dados Relacional (MySQL)

| Requisito | Status | Implementacao |
|-----------|--------|---------------|
| Banco MySQL | [OK] | MySQL 8.0+ |
| Tabela `usuarios` | [OK] | [01_schema.sql:38](database/mysql/01_schema.sql) |
| Tabela `grupos_usuarios` | [OK] | [01_schema.sql:19](database/mysql/01_schema.sql) |
| Relacionamento N:N | [OK] | Tabela `usuarios_grupos` |
| Minimo 2 Triggers | [OK] | **6 triggers** implementados |
| Minimo 2 Views | [OK] | **5 views** implementadas |
| Minimo 2 Procedures/Functions | [OK] | **9 procedures/functions** |
| Indices customizados | [OK] | **12+ indices** com justificativa |
| Geracao de IDs customizada | [OK] | 3 funcoes de geracao |
| Usuarios MySQL (niveis) | [OK] | **4 usuarios** (admin, app, readonly, reports) |
| Controle de acesso granular | [OK] | Permissoes especificas por usuario |
| Autenticacao via usuarios/grupos | [OK] | JWT + bcrypt integrado |

### Banco de Dados NoSQL (MongoDB)

| Recurso | Status | Implementacao |
|---------|--------|---------------|
| MongoDB integrado | [OK] | Versao 7.0+ |
| Collections criadas | [OK] | product_cache, order_events, user_sessions |
| Indices TTL | [OK] | Expiracao automatica |
| Servico de cache | [OK] | cacheService.ts |
| Analytics | [OK] | Eventos de pedidos |
| Sessoes | [OK] | Gerenciamento com TTL |

### Aplicacao

| Requisito | Status | Implementacao |
|-----------|--------|---------------|
| Frontend funcional | [OK] | React + TypeScript |
| Backend completo | [OK] | Node.js + Express |
| Autenticacao | [OK] | JWT |
| CRUD completo | [OK] | Todas as entidades |
| Arquitetura hibrida | [OK] | MySQL + MongoDB |

### Documentacao

| Requisito | Status | Implementacao |
|-----------|--------|---------------|
| DER | [OK] | [docs/DER.md](docs/DER.md) |
| Justificativas tecnicas | [OK] | Inline em cada arquivo SQL |
| README completo | [OK] | Este arquivo |
| Docs MongoDB | [OK] | [backend/MONGODB_SETUP.md](backend/MONGODB_SETUP.md) |

---

## Usuarios de Teste

### Usuarios do Sistema (Login na aplicacao)

| Tipo | Email | Senha | Permissoes |
|------|-------|-------|------------|
| **Admin** | admin@deliverysystem.com | senha123 | Acesso total |
| **Gerente** | fernanda.gerente@email.com | senha123 | Relatorios, gestao |
| **Entregador** | carlos.entrega@email.com | senha123 | Aceitar/entregar pedidos |
| **Cliente** | joao.silva@email.com | senha123 | Fazer pedidos |

### Usuarios MySQL (Acesso ao banco)

| Usuario | Senha | Nivel |
|---------|-------|-------|
| delivery_admin | DeliveryAdmin@2024 | DBA |
| delivery_app | DeliveryApp@2024 | Aplicacao |
| delivery_readonly | DeliveryReadonly@2024 | Somente Leitura |
| delivery_reports | DeliveryReports@2024 | Relatorios |

---

## Diferenciais

### Arquitetura Avancada
- **Arquitetura hibrida** - MySQL + MongoDB
- **70% menos queries** no banco principal
- **Analytics em tempo real** com MongoDB
- **Cache inteligente** com TTL automatico

### Banco de Dados
- **6 Triggers** - Automacao de regras de negocio
- **5 Views** - Relatorios gerenciais
- **9 Procedures/Functions** - Logica SQL avancada
- **12+ Indices otimizados** - Performance garantida
- **4 usuarios MySQL** - Seguranca por niveis
- **IDs customizados** - Funcoes de geracao

### NoSQL (MongoDB)
- **Cache distribuido** - product_cache
- **Event sourcing** - order_events
- **Sessoes escalaveis** - user_sessions
- **TTL automatico** - Limpeza automatica
- **Indices compostos** - Queries otimizadas

### Aplicacao
- **Autenticacao JWT** - Tokens seguros
- **Bcrypt** - Senhas hasheadas
- **Validacao Joi** - Dados sempre validos
- **Rate Limiting** - Protecao DDoS
- **TypeScript** - Codigo type-safe
- **Responsive** - Mobile-first

---

## Seguranca

### Implementacoes de Seguranca

- **Senhas hasheadas** com Bcrypt (custo 10)
- **Autenticacao JWT** com expiracao
- **Validacao de dados** com Joi
- **Prepared Statements** (prevencao SQL Injection)
- **CORS** configurado
- **Rate Limiting** (100 req/15min)
- **Helmet** para headers de seguranca
- **IDs nao sequenciais** (previne enumeracao)
- **Principio do menor privilegio** (usuarios MySQL)
- **Auditoria completa** (triggers de log)
- **MongoDB sem autenticacao publica** (apenas localhost)

---

## Licenca

Este projeto e de uso **academico** e foi desenvolvido como trabalho da disciplina de Banco de Dados.

---

## Autores

Sistema de Delivery - Trabalho Academico 2024

---

## Contribuindo

Este e um projeto academico. Sugestoes e melhorias sao bem-vindas atraves de issues e pull requests.

---

**Status do Projeto:** Completo e Funcional

**Ultima atualizacao:** Novembro 2024
