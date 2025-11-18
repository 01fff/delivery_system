# Backend - Sistema de Delivery

API RESTful completa para sistema de delivery com autenticação JWT e integração MySQL.

## Tecnologias

- Node.js 18+
- TypeScript
- Express
- MySQL2
- JWT (jsonwebtoken)
- Bcrypt
- Joi (validação)
- Helmet (segurança)
- CORS

## Instalação

```bash
cd backend
npm install
```

## Configuração

Copie o arquivo `.env.example` para `.env`:

```bash
cp .env.example .env
```

Edite o `.env` com suas configurações:

```env
PORT=3001
DB_HOST=localhost
DB_USER=delivery_app
DB_PASSWORD=DeliveryApp@2024
DB_NAME=delivery_system
JWT_SECRET=seu_secret_aqui
```

## Banco de Dados

Certifique-se de ter executado o script de instalação do MySQL:

```bash
cd ../database/mysql
mysql -u root -p < 00_INSTALL.sql
```

## Executar

### Desenvolvimento
```bash
npm run dev
```

### Produção
```bash
npm run build
npm start
```

## Rotas da API

### Autenticação

- `POST /api/auth/register` - Registrar novo usuário
- `POST /api/auth/login` - Login
- `GET /api/auth/me` - Dados do usuário autenticado (requer token)

### Produtos

- `GET /api/products` - Listar produtos
- `GET /api/products/:id` - Detalhes do produto
- `GET /api/products/categories/all` - Listar categorias

### Pedidos

- `POST /api/orders` - Criar pedido (requer token)
- `GET /api/orders` - Meus pedidos (requer token)
- `GET /api/orders/:id` - Detalhes do pedido (requer token)
- `PATCH /api/orders/:id/status` - Atualizar status (requer token + nível 3)
- `POST /api/orders/:id/cancel` - Cancelar pedido (requer token)

## Autenticação

Inclua o token JWT no header Authorization:

```
Authorization: Bearer seu_token_aqui
```

## Estrutura

```
backend/
├── src/
│   ├── config/         # Configurações (DB)
│   ├── controllers/    # Controllers da API
│   ├── middlewares/    # Middlewares (auth, validação)
│   ├── routes/         # Rotas Express
│   ├── types/          # TypeScript types
│   └── server.ts       # Servidor principal
├── package.json
└── tsconfig.json
```

## Funcionalidades

- Autenticação JWT completa
- Validação de dados com Joi
- Rate limiting
- CORS configurável
- Integração com stored procedures MySQL
- TypeScript para type safety
- Tratamento de erros global
- Segurança com Helmet
