import express from 'express';
import { pool } from '../config/database.js';
import { authenticateToken, requireAdmin } from '../middleware/auth.js';

const router = express.Router();

// Listar produtos (público)
router.get('/', async (req, res) => {
  try {
    const { categoria, tipo, incluir_estoque } = req.query;
    
    let query = 'SELECT * FROM products WHERE ativo = true';
    const params = [];
    
    if (categoria && categoria !== 'todos') {
      query += ' AND categoria = $' + (params.length + 1);
      params.push(categoria);
    }
    
    if (tipo) {
      query += ' AND tipo_produto = $' + (params.length + 1);
      params.push(tipo);
    }
    
    query += ' ORDER BY categoria, nome';
    
    const result = await pool.query(query, params);
    
    let products = result.rows;
    
    // Se não incluir estoque, remover essa informação para clientes
    if (incluir_estoque !== 'true') {
      products = products.map(({ estoque, ...product }) => product);
    }
    
    res.json(products);
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({ error: 'Erro ao buscar produtos' });
  }
});

// Buscar produto específico (público)
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT * FROM products WHERE id = $1 AND ativo = true', [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Produto não encontrado' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Get product error:', error);
    res.status(500).json({ error: 'Erro ao buscar produto' });
  }
});

// Listar produtos para admin (com estoque)
router.get('/admin/list', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT *, 
        CASE 
          WHEN estoque <= 5 THEN 'baixo'
          WHEN estoque <= 15 THEN 'medio'
          ELSE 'alto'
        END as status_estoque
      FROM products 
      ORDER BY tipo_produto, categoria, nome
    `);
    
    res.json(result.rows);
  } catch (error) {
    console.error('Get admin products error:', error);
    res.status(500).json({ error: 'Erro ao buscar produtos' });
  }
});

// Criar produto (Admin only)
router.post('/', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { nome, categoria, tipo_produto, preco, estoque, descricao, imagem } = req.body;
    
    if (!nome || !categoria || !tipo_produto || !preco) {
      return res.status(400).json({ error: 'Campos obrigatórios: nome, categoria, tipo_produto, preco' });
    }
    
    const result = await pool.query(`
      INSERT INTO products (nome, categoria, descricao, preco, estoque, imagem, tipo_produto)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `, [nome, categoria, descricao || '', parseFloat(preco), parseInt(estoque) || 0, imagem || '', tipo_produto]);
    
    res.status(201).json({
      message: 'Produto criado com sucesso',
      product: result.rows[0]
    });
  } catch (error) {
    console.error('Create product error:', error);
    res.status(500).json({ error: 'Erro ao criar produto' });
  }
});

// Atualizar produto (Admin only)
router.put('/:id', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { nome, categoria, tipo_produto, preco, estoque, descricao, imagem, ativo } = req.body;
    
    const result = await pool.query(`
      UPDATE products 
      SET nome = COALESCE($1, nome),
          categoria = COALESCE($2, categoria),
          tipo_produto = COALESCE($3, tipo_produto),
          preco = COALESCE($4, preco),
          estoque = COALESCE($5, estoque),
          descricao = COALESCE($6, descricao),
          imagem = COALESCE($7, imagem),
          ativo = COALESCE($8, ativo),
          updated_at = NOW()
      WHERE id = $9
      RETURNING *
    `, [nome, categoria, tipo_produto, preco ? parseFloat(preco) : null, 
        estoque !== undefined ? parseInt(estoque) : null, descricao, imagem, 
        ativo !== undefined ? ativo : null, id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Produto não encontrado' });
    }
    
    res.json({
      message: 'Produto atualizado com sucesso',
      product: result.rows[0]
    });
  } catch (error) {
    console.error('Update product error:', error);
    res.status(500).json({ error: 'Erro ao atualizar produto' });
  }
});

// Deletar produto (Admin only)
router.delete('/:id', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    
    // Soft delete
    const result = await pool.query(`
      UPDATE products 
      SET ativo = false, updated_at = NOW()
      WHERE id = $1
      RETURNING *
    `, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Produto não encontrado' });
    }
    
    res.json({
      message: 'Produto removido com sucesso',
      product: result.rows[0]
    });
  } catch (error) {
    console.error('Delete product error:', error);
    res.status(500).json({ error: 'Erro ao remover produto' });
  }
});

// Atualizar estoque (Admin only)
router.patch('/:id/estoque', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { estoque, operacao } = req.body;
    
    let query;
    let params;
    
    if (operacao === 'adicionar' || operacao === 'remover') {
      const sinal = operacao === 'adicionar' ? '+' : '-';
      query = `
        UPDATE products 
        SET estoque = GREATEST(0, estoque ${sinal} $1), updated_at = NOW()
        WHERE id = $2
        RETURNING *
      `;
      params = [parseInt(estoque), id];
    } else {
      query = `
        UPDATE products 
        SET estoque = $1, updated_at = NOW()
        WHERE id = $2
        RETURNING *
      `;
      params = [parseInt(estoque), id];
    }
    
    const result = await pool.query(query, params);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Produto não encontrado' });
    }
    
    res.json({
      message: 'Estoque atualizado com sucesso',
      product: result.rows[0]
    });
  } catch (error) {
    console.error('Update stock error:', error);
    res.status(500).json({ error: 'Erro ao atualizar estoque' });
  }
});

export default router;
