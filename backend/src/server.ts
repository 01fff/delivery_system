import express, { Application, Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { testConnection } from './config/database';

// Importa as rotas
import authRoutes from './routes/auth.routes';
import productsRoutes from './routes/products.routes';
import ordersRoutes from './routes/orders.routes';

// Carrega variáveis de ambiente
dotenv.config();

const app: Application = express();
const PORT = process.env.PORT || 3001;

// ============================================================================
// MIDDLEWARES
// ============================================================================

// Helmet para segurança HTTP
app.use(helmet());

// CORS
app.use(cors({
  origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
  credentials: true
}));

// Parser de JSON
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate Limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000'), // 15 minutos
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'), // 100 requisições por janela
  message: {
    success: false,
    error: 'Muitas requisições. Tente novamente mais tarde.'
  },
  standardHeaders: true,
  legacyHeaders: false
});

app.use('/api/', limiter);

// ============================================================================
// ROTAS
// ============================================================================

// Rota de health check
app.get('/', (req: Request, res: Response) => {
  res.json({
    success: true,
    message: 'API do Sistema de Delivery - Funcionando!',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/api/health', (req: Request, res: Response) => {
  res.json({
    success: true,
    status: 'healthy',
    database: 'connected',
    timestamp: new Date().toISOString()
  });
});

// Rotas da API
app.use('/api/auth', authRoutes);
app.use('/api/products', productsRoutes);
app.use('/api/orders', ordersRoutes);

// ============================================================================
// TRATAMENTO DE ERROS
// ============================================================================

// Rota não encontrada
app.use((req: Request, res: Response) => {
  res.status(404).json({
    success: false,
    error: 'Rota não encontrada',
    path: req.path
  });
});

// Handler global de erros
app.use((error: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('Erro não tratado:', error);

  res.status(500).json({
    success: false,
    error: 'Erro interno do servidor',
    message: process.env.NODE_ENV === 'development' ? error.message : undefined
  });
});

// ============================================================================
// INICIALIZAÇÃO DO SERVIDOR
// ============================================================================

const startServer = async () => {
  try {
    // Testa a conexão com o banco de dados
    console.log('Testando conexão com MySQL...');
    const dbConnected = await testConnection();

    if (!dbConnected) {
      console.error('ERRO: Não foi possível conectar ao MySQL');
      console.error('   Verifique as configurações em .env');
      process.exit(1);
    }

    // Inicia o servidor
    app.listen(PORT, () => {
      console.log('');
      console.log('============================================================');
      console.log('Servidor iniciado com sucesso!');
      console.log('============================================================');
      console.log(`Servidor rodando em: http://localhost:${PORT}`);
      console.log(`Ambiente: ${process.env.NODE_ENV || 'development'}`);
      console.log(`CORS habilitado para: ${process.env.CORS_ORIGIN || 'http://localhost:3000'}`);
      console.log('');
      console.log('Rotas disponíveis:');
      console.log(`   GET  /                     - Health check`);
      console.log(`   GET  /api/health           - API health`);
      console.log(`   POST /api/auth/register    - Registrar usuário`);
      console.log(`   POST /api/auth/login       - Login`);
      console.log(`   GET  /api/auth/me          - Dados do usuário autenticado`);
      console.log(`   GET  /api/products         - Listar produtos`);
      console.log(`   GET  /api/products/:id     - Detalhes do produto`);
      console.log(`   POST /api/orders           - Criar pedido`);
      console.log(`   GET  /api/orders           - Meus pedidos`);
      console.log(`   GET  /api/orders/:id       - Detalhes do pedido`);
      console.log('============================================================');
      console.log('');
    });
  } catch (error) {
    console.error('ERRO: Erro ao iniciar o servidor:', error);
    process.exit(1);
  }
};

// Trata sinais de término
process.on('SIGTERM', () => {
  console.log('SIGTERM recebido. Encerrando servidor...');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT recebido. Encerrando servidor...');
  process.exit(0);
});

// Inicia o servidor
startServer();

export default app;
