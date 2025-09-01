import jwt from 'jsonwebtoken';

export const authenticateToken = async (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Token de acesso necessário' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'pizzaria-rodrigos-super-secret-key-2024');
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(403).json({ error: 'Token inválido' });
  }
};

export const requireAdmin = (req, res, next) => {
  if (req.user.tipo !== 'proprietario') {
    return res.status(403).json({ error: 'Acesso negado. Apenas administradores.' });
  }
  next();
};
