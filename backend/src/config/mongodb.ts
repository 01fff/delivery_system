import { MongoClient, Db } from 'mongodb';
import dotenv from 'dotenv';

dotenv.config();

let db: Db;
let client: MongoClient;

/**
 * Conecta ao MongoDB e inicializa o banco de dados
 */
export const connectMongoDB = async (): Promise<Db> => {
  try {
    const uri = process.env.MONGO_URI || 'mongodb://localhost:27017';
    client = new MongoClient(uri);

    await client.connect();
    db = client.db(process.env.MONGO_DB_NAME || 'delivery_system');

    console.log('✓ OK: Conectado ao MongoDB com sucesso!');

    // Criar índices necessários
    await createIndexes();

    return db;
  } catch (error) {
    console.error('✗ ERRO: Erro ao conectar ao MongoDB:', error);
    throw error;
  }
};

/**
 * Cria os índices necessários para as collections
 */
const createIndexes = async (): Promise<void> => {
  try {
    // TTL index para cache de produtos (expira automaticamente após 1 hora)
    await db.collection('product_cache').createIndex(
      { expires_at: 1 },
      { expireAfterSeconds: 0 }
    );

    // Índice para buscar produtos por ID
    await db.collection('product_cache').createIndex(
      { product_id: 1 },
      { unique: true }
    );

    // TTL index para sessões de usuários
    await db.collection('user_sessions').createIndex(
      { expires_at: 1 },
      { expireAfterSeconds: 0 }
    );

    // Índice para eventos de pedidos (ordenado por timestamp)
    await db.collection('order_events').createIndex(
      { timestamp: -1 }
    );

    // Índice composto para buscar eventos por pedido
    await db.collection('order_events').createIndex(
      { order_id: 1, timestamp: -1 }
    );

    console.log('✓ Índices MongoDB criados com sucesso');
  } catch (error) {
    console.error('✗ Erro ao criar índices MongoDB:', error);
    // Não lança erro para não interromper a aplicação
  }
};

/**
 * Retorna a instância do banco de dados MongoDB
 */
export const getMongoDB = (): Db => {
  if (!db) {
    throw new Error('MongoDB não está conectado. Execute connectMongoDB() primeiro.');
  }
  return db;
};

/**
 * Fecha a conexão com o MongoDB
 */
export const closeMongoDB = async (): Promise<void> => {
  if (client) {
    await client.close();
    console.log('✓ MongoDB desconectado');
  }
};

/**
 * Testa a conexão com MongoDB
 */
export const testMongoConnection = async (): Promise<boolean> => {
  try {
    await client.db().admin().ping();
    console.log('✓ Ping MongoDB bem-sucedido');
    return true;
  } catch (error) {
    console.error('✗ Erro no ping MongoDB:', error);
    return false;
  }
};

export default { connectMongoDB, getMongoDB, closeMongoDB, testMongoConnection };