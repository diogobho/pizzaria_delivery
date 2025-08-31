import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import session from 'express-session';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

// Importar rotas
import authRoutes from './src/routes/auth.js';
import productsRoutes from './src/routes/products.js';
import ordersRoutes from './src/routes/orders.js';
import optionsRoutes from './src/routes/options.js';

// Configurar __dirname para módulos ES
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// IMPORTANTE: Trust proxy para funcionar com Nginx
app.set('trust proxy', 1);

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100,
  message: { error: 'Muitas tentativas. Tente novamente em 15 minutos.' }
});

app.use(limiter);

// CORS
app.use(cors({
  origin: ['http://161.97.127.54:5000', 'http://161.97.127.54'],
  credentials: true
}));

// Body parser
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'Pizzaria Rodrigos API'
  });
});

// Rotas da API
app.use('/api/auth', authRoutes);
app.use('/api/products', productsRoutes);
app.use('/api/orders', ordersRoutes);
app.use('/api/options', optionsRoutes);

// Rota principal
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
  console.log('🍕 Pizzaria Rodrigo\'s API rodando na porta', PORT);
});
