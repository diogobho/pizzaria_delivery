import pkg from 'pg';
import dotenv from 'dotenv';

const { Pool } = pkg;
dotenv.config();

export const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'pizzaria_rodrigos',
  user: process.env.DB_USER || 'app_user',
  password: process.env.DB_PASS || 'senha123!',
  ssl: false,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Test connection
pool.on('connect', () => {
  console.log('✅ Conectado ao PostgreSQL');
});

pool.on('error', (err) => {
  console.error('❌ Erro no PostgreSQL:', err);
});

// Verificar conexão inicial
async function testConnection() {
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW()');
    console.log('🕐 Banco conectado às:', result.rows[0].now);
    client.release();
  } catch (err) {
    console.error('❌ Erro na conexão inicial:', err);
  }
}

testConnection();
