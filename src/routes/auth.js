import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { pool } from '../config/database.js';

const router = express.Router();

// Login
router.post('/login', async (req, res) => {
  try {
    console.log('Tentativa de login:', req.body);
    const { email, senha } = req.body;

    if (!email || !senha) {
      return res.status(400).json({ error: 'Email e senha são obrigatórios' });
    }

    const result = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    
    if (result.rows.length === 0) {
      console.log('Usuário não encontrado:', email);
      return res.status(401).json({ error: 'Credenciais inválidas' });
    }

    const user = result.rows[0];
    console.log('Usuário encontrado:', { id: user.id, email: user.email, tipo: user.tipo });

    const isValidPassword = await bcrypt.compare(senha, user.senha);
    
    if (!isValidPassword) {
      console.log('Senha inválida para:', user.email);
      return res.status(401).json({ error: 'Credenciais inválidas' });
    }

    const token = jwt.sign(
      { userId: user.id, email: user.email, tipo: user.tipo }, 
      process.env.JWT_SECRET || 'pizzaria-rodrigos-super-secret-key-2024', 
      { expiresIn: '24h' }
    );

    console.log('Login bem-sucedido para:', user.email);

    res.json({
      message: 'Login realizado com sucesso',
      token,
      user: {
        id: user.id,
        nome: user.nome,
        email: user.email,
        tipo: user.tipo
      }
    });
  } catch (error) {
    console.error('Erro no login:', error);
    res.status(500).json({ error: 'Erro interno do servidor' });
  }
});

// Verificar usuário atual
router.get('/me', async (req, res) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({ error: 'Token necessário' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'pizzaria-rodrigos-super-secret-key-2024');
    
    const result = await pool.query('SELECT * FROM users WHERE id = $1', [decoded.userId]);
    
    if (result.rows.length === 0) {
      return res.status(403).json({ error: 'Usuário não encontrado' });
    }

    const user = result.rows[0];

    res.json({ 
      user: {
        id: user.id,
        nome: user.nome,
        email: user.email,
        tipo: user.tipo
      }
    });
  } catch (error) {
    console.error('Erro ao verificar token:', error);
    res.status(403).json({ error: 'Token inválido' });
  }
});

export default router;
