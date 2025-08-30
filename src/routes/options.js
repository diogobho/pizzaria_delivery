import express from 'express';
import { pool } from '../config/database.js';

const router = express.Router();

// Listar bordas
router.get('/bordas', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM bordas ORDER BY preco_adicional');
    res.json(result.rows);
  } catch (error) {
    console.error('Get bordas error:', error);
    res.status(500).json({ error: 'Erro ao buscar bordas' });
  }
});

// Listar adicionais
router.get('/adicionais', async (req, res) => {
  try {
    const { categoria } = req.query;
    
    let query = 'SELECT * FROM adicionais';
    const params = [];
    
    if (categoria) {
      query += ' WHERE categoria_produto = $1';
      params.push(categoria);
    }
    
    query += ' ORDER BY categoria_produto, nome';
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error('Get adicionais error:', error);
    res.status(500).json({ error: 'Erro ao buscar adicionais' });
  }
});

// Listar entregadores
router.get('/entregadores', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM entregadores WHERE ativo = true ORDER BY nome');
    res.json(result.rows);
  } catch (error) {
    console.error('Get entregadores error:', error);
    res.status(500).json({ error: 'Erro ao buscar entregadores' });
  }
});

export default router;
