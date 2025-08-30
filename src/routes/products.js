import express from 'express';
import { pool } from '../config/database.js';
import { authenticateToken, requireOwner } from '../middleware/auth.js';
import { body, validationResult } from 'express-validator';

const router = express.Router();

// Listar todos os produtos
router.get('/', async (req, res) => {
  try {
    const { categoria, tipo } = req.query;
    
    let query = 'SELECT * FROM products WHERE 1=1';
    const params = [];
    
    if (categoria) {
      query += ' AND categoria = $' + (params.length + 1);
      params.push(categoria);
    }
    
    if (tipo) {
      query += ' AND tipo_produto = $' + (params.length + 1);
      params.push(tipo);
    }
    
    query += ' ORDER BY categoria, nome';
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({ error: 'Erro ao buscar produtos' });
  }
});

// Buscar produto específico
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM products WHERE id = $1', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Produto não encontrado' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Get product error:', error);
    res.status(500).json({ error: 'Erro ao buscar produto' });
  }
});

// Criar produto (Owner only)
router.post('/', authenticateToken, requireOwner, [
  body('nome').trim().isLength({ min: 2 }).withMessage('Nome deve ter pelo menos 2 caracteres'),
  body('categoria').isIn(['tradicional', 'premium', 'especial', 'refrigerantes', 'esfihas_tradicional', 'esfihas_premium', 'esfihas_especial']).withMessage('Categoria inválida'),
  body('descricao').trim().isLength({ min: 5 }).withMessage('Descrição deve ter pelo menos 5 caracteres'),
  body('preco').isFloat({ min: 0.01 }).withMessage('Preço deve ser maior que 0'),
  body('estoque').isInt({ min: 0 }).withMessage('Estoque deve ser um número inteiro não negativo')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { nome, categoria, descricao, preco, estoque, imagem, tipo_produto } = req.body;

    const result = await pool.query(
      'INSERT INTO products (nome, categoria, descricao, preco, estoque, imagem, tipo_produto) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
      [nome, categoria, descricao, preco, estoque, imagem, tipo_produto || 'pizza']
    );

    res.status(201).json({
      message: 'Produto criado com sucesso',
      product: result.rows[0]
    });
  } catch (error) {
    console.error('Create product error:', error);
    res.status(500).json({ error: 'Erro ao criar produto' });
  }
});

export default router;
