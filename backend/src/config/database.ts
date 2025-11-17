import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

// Pool de conexões MySQL
export const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '3306'),
  user: process.env.DB_USER || 'delivery_app',
  password: process.env.DB_PASSWORD || 'DeliveryApp@2024',
  database: process.env.DB_NAME || 'delivery_system',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 0
});

// Testa a conexão
export const testConnection = async () => {
  try {
    const connection = await pool.getConnection();
    console.log('OK: Conectado ao MySQL com sucesso!');
    connection.release();
    return true;
  } catch (error) {
    console.error('ERRO: Erro ao conectar ao MySQL:', error);
    return false;
  }
};

// Função helper para executar queries
export const query = async (sql: string, params?: any[]) => {
  try {
    const [results] = await pool.execute(sql, params);
    return results;
  } catch (error) {
    console.error('Erro na query:', error);
    throw error;
  }
};

export default pool;
