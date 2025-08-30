import { createClient } from 'redis';
import dotenv from 'dotenv';

dotenv.config();

export const redisClient = createClient({
  url: process.env.REDIS_URL
});

redisClient.on('error', (err) => {
  console.error('❌ Erro no Redis:', err);
});

redisClient.on('connect', () => {
  console.log('📦 Conectado ao Redis');
});

// Conectar ao Redis
await redisClient.connect();
