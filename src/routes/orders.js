import express from 'express';
import { pool } from '../config/database.js';
import { authenticateToken, requireOwner } from '../middleware/auth.js';
import { body, validationResult } from 'express-validator';
import PDFDocument from 'pdfkit';

const router = express.Router();

// Listar pedidos do usuário
router.get('/my-orders', authenticateToken, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT o.*, 
             json_agg(
               json_build_object(
                 'id', oi.id,
                 'product_name', oi.product_name,
                 'quantidade', oi.quantidade,
                 'preco_unit', oi.preco_unit,
                 'observacao', oi.observacao,
                 'formato', oi.formato,
                 'sabor_1', oi.sabor_1,
                 'sabor_2', oi.sabor_2
               )
             ) as items
      FROM orders o
      LEFT JOIN order_items oi ON o.id = oi.order_id
      WHERE o.user_id = $1
      GROUP BY o.id
      ORDER BY o.created_at DESC
    `, [req.user.id]);

    res.json(result.rows);
  } catch (error) {
    console.error('Get user orders error:', error);
    res.status(500).json({ error: 'Erro ao buscar pedidos' });
  }
});

// Listar todos os pedidos (Owner only)
router.get('/', authenticateToken, requireOwner, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT o.*, u.nome as user_name, u.email as user_email,
             json_agg(
               json_build_object(
                 'id', oi.id,
                 'product_name', oi.product_name,
                 'quantidade', oi.quantidade,
                 'preco_unit', oi.preco_unit,
                 'observacao', oi.observacao,
                 'formato', oi.formato,
                 'sabor_1', oi.sabor_1,
                 'sabor_2', oi.sabor_2
               )
             ) as items
      FROM orders o
      LEFT JOIN users u ON o.user_id = u.id
      LEFT JOIN order_items oi ON o.id = oi.order_id
      GROUP BY o.id, u.nome, u.email
      ORDER BY o.created_at DESC
    `);

    res.json(result.rows);
  } catch (error) {
    console.error('Get all orders error:', error);
    res.status(500).json({ error: 'Erro ao buscar pedidos' });
  }
});

// Criar pedido
router.post('/', authenticateToken, [
  body('items').isArray({ min: 1 }).withMessage('Pedido deve ter pelo menos 1 item'),
  body('total').isFloat({ min: 0.01 }).withMessage('Total deve ser maior que 0')
], async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      await client.query('ROLLBACK');
      return res.status(400).json({ errors: errors.array() });
    }

    const { items, total, observacao, valor_frete } = req.body;

    // Criar pedido
    const orderResult = await client.query(
      'INSERT INTO orders (user_id, total, observacao, valor_frete) VALUES ($1, $2, $3, $4) RETURNING *',
      [req.user.id, total, observacao || null, valor_frete || 0]
    );

    const orderId = orderResult.rows[0].id;

    // Inserir itens do pedido
    for (const item of items) {
      await client.query(`
        INSERT INTO order_items (
          order_id, product_id, product_name, quantidade, preco_unit, 
          observacao, formato, sabor_1, sabor_2
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      `, [
        orderId, item.product_id, item.product_name, item.quantidade, 
        item.preco_unit, item.observacao, item.formato || 'inteira',
        item.sabor_1, item.sabor_2
      ]);

      // Decrementar estoque
      await client.query(
        'UPDATE products SET estoque = GREATEST(0, estoque - $1) WHERE id = $2',
        [item.quantidade, item.product_id]
      );
    }

    await client.query('COMMIT');

    res.status(201).json({
      message: 'Pedido criado com sucesso',
      order: orderResult.rows[0]
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Create order error:', error);
    res.status(500).json({ error: 'Erro ao criar pedido' });
  } finally {
    client.release();
  }
});

// Atualizar status do pedido (Owner only)
router.patch('/:id/status', authenticateToken, requireOwner, [
  body('status').isIn(['nao_iniciado', 'em_andamento', 'finalizado']).withMessage('Status inválido')
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { id } = req.params;
    const { status, entregador } = req.body;

    const result = await pool.query(
      'UPDATE orders SET status = $1, entregador = $2, updated_at = NOW() WHERE id = $3 RETURNING *',
      [status, entregador || null, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Pedido não encontrado' });
    }

    res.json({
      message: 'Status do pedido atualizado com sucesso',
      order: result.rows[0]
    });
  } catch (error) {
    console.error('Update order status error:', error);
    res.status(500).json({ error: 'Erro ao atualizar status do pedido' });
  }
});

export default router;
