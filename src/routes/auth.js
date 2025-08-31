import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

const router = express.Router();

// Hash para password: $2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi
const users = [
  {
    id: 'e9b38c00-457b-4e60-8b30-266f60806772',
    nome: 'Cliente Teste', 
    email: 'cliente@teste.com',
    senha: '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    tipo: 'cliente'
  },
  {
    id: '01d47184-7aa7-49c7-89aa-acadaa6c3186',
    nome: 'Rodrigo',
    email: 'rodrigo@pizzaria.com', 
    senha: '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    tipo: 'proprietario'
  }
];

// Login
router.post('/login', async (req, res) => {
  try {
    console.log('Tentativa de login:', req.body);
    const { email, senha } = req.body;

    if (!email || !senha) {
      return res.status(400).json({ error: 'Email e senha são obrigatórios' });
    }

    const user = users.find(u => u.email === email);
    
    if (!user) {
      console.log('Usuário não encontrado:', email);
      return res.status(401).json({ error: 'Credenciais inválidas' });
    }

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
    
    const user = users.find(u => u.id === decoded.userId);
    
    if (!user) {
      return res.status(403).json({ error: 'Usuário não encontrado' });
    }

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
