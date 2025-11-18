# Frontend - Sistema de Delivery

Interface web completa em React + TypeScript para o sistema de delivery acadêmico.

## Tecnologias

- React 18
- TypeScript
- Vite (build tool)
- React Router DOM (rotas)
- Tailwind CSS (estilos)
- Axios (requisições HTTP)
- React Hot Toast (notificações)
- Lucide React (ícones)

## Instalação

```bash
cd frontend
npm install
```

## Configuração

Copie o arquivo `.env.example` para `.env`:

```bash
cp .env.example .env
```

Edite o `.env` conforme necessário:

```env
VITE_API_URL=http://localhost:3001/api
```

## Executar

### Desenvolvimento

```bash
npm run dev
```

A aplicação estará disponível em: http://localhost:3000

### Produção

```bash
npm run build
npm run preview
```

## Estrutura

```
frontend/
├── src/
│   ├── components/        # Componentes reutilizáveis
│   │   ├── Navbar.tsx
│   │   ├── Footer.tsx
│   │   ├── ProductCard.tsx
│   │   └── ProtectedRoute.tsx
│   ├── contexts/          # Contextos React (Auth, Cart)
│   │   ├── AuthContext.tsx
│   │   └── CartContext.tsx
│   ├── pages/             # Páginas da aplicação
│   │   ├── Home.tsx
│   │   ├── Login.tsx
│   │   ├── Register.tsx
│   │   ├── Products.tsx
│   │   ├── Cart.tsx
│   │   ├── Checkout.tsx
│   │   └── Orders.tsx
│   ├── services/          # Serviços de API
│   │   └── api.ts
│   ├── types/             # TypeScript types
│   │   └── index.ts
│   ├── App.tsx            # Componente principal
│   ├── main.tsx           # Ponto de entrada
│   └── index.css          # Estilos globais
├── public/
├── index.html
├── package.json
├── tsconfig.json
├── vite.config.ts
└── tailwind.config.js
```

## Funcionalidades

### Autenticação
- Login com JWT
- Registro de usuários
- Proteção de rotas privadas
- Persistência de sessão (localStorage)

### Produtos
- Listagem de produtos
- Filtros por categoria
- Busca de produtos
- Detalhes do produto

### Carrinho
- Adicionar/remover produtos
- Atualizar quantidades
- Persistência no localStorage
- Cálculo automático de totais

### Pedidos
- Finalização de compra
- Formulário de endereço
- Seleção de forma de pagamento
- Histórico de pedidos
- Rastreamento de pedidos

## Páginas

### Públicas
- `/` - Página inicial
- `/login` - Login
- `/register` - Cadastro
- `/products` - Listagem de produtos
- `/cart` - Carrinho de compras

### Privadas (requerem autenticação)
- `/checkout` - Finalização do pedido
- `/orders` - Meus pedidos
- `/orders/:id` - Detalhes do pedido

## Integração com Backend

A aplicação se comunica com o backend através de:

- **Base URL**: `http://localhost:3001/api`
- **Autenticação**: JWT Bearer Token
- **Headers**: `Authorization: Bearer <token>`

### Serviços disponíveis

```typescript
// Autenticação
authService.register(data)
authService.login(credentials)
authService.getMe()
authService.logout()

// Produtos
productsService.getAll(params)
productsService.getById(id)
productsService.getCategories()

// Pedidos
ordersService.create(orderData)
ordersService.getMyOrders()
ordersService.getById(id)
ordersService.cancel(id)
ordersService.updateStatus(id, status)
```

## Estilos

O projeto usa Tailwind CSS com classes utilitárias customizadas:

```css
/* Botões */
.btn - Botão base
.btn-primary - Botão primário
.btn-secondary - Botão secundário

/* Formulários */
.input - Input padrão

/* Layout */
.card - Card com sombra e padding
```

## Credenciais de Teste

```
Admin:
Email: admin@deliverysystem.com
Senha: senha123

Cliente:
Email: joao.silva@email.com
Senha: senha123
```

## Desenvolvimento

### Scripts úteis

```bash
npm run dev      # Servidor de desenvolvimento
npm run build    # Build para produção
npm run preview  # Preview do build
npm run lint     # Verificar erros
```

### Convenções

- Componentes React em PascalCase
- Arquivos de contexto com sufixo `Context`
- Páginas na pasta `pages/`
- Componentes reutilizáveis em `components/`
- Services para comunicação com API

## Melhorias Futuras

- [ ] Implementar paginação de produtos
- [ ] Adicionar filtros avançados
- [ ] Implementar avaliação de produtos
- [ ] Adicionar chat de suporte
- [ ] Implementar notificações em tempo real
- [ ] Adicionar modo escuro
- [ ] Implementar PWA
- [ ] Adicionar testes unitários

## Licença

Projeto acadêmico - Banco de Dados II
