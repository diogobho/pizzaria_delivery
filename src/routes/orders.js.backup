import express from 'express';
import { pool } from '../config/database.js';
import { authenticateToken, requireAdmin } from '../middleware/auth.js';

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
            'formato', oi.formato,
            'sabor_1', oi.sabor_1,
            'sabor_2', oi.sabor_2,
            'borda_nome', oi.borda_nome,
            'borda_preco', oi.borda_preco,
            'adicionais', oi.adicionais,
            'observacao', oi.observacao
          )
        ) as items
      FROM orders o
      LEFT JOIN order_items oi ON o.id = oi.order_id
      WHERE o.user_id = $1
      GROUP BY o.id
      ORDER BY o.created_at DESC
    `, [req.user.userId]);
    
    res.json(result.rows);
  } catch (error) {
    console.error('Get user orders error:', error);
    res.status(500).json({ error: 'Erro ao buscar pedidos' });
  }
});

// Listar todos os pedidos (Admin only)
router.get('/', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { status, data_inicio, data_fim } = req.query;
    
    let query = `
      SELECT o.*, u.nome as cliente_nome, u.email as cliente_email,
        json_agg(
          json_build_object(
            'id', oi.id,
            'product_name', oi.product_name,
            'quantidade', oi.quantidade,
            'preco_unit', oi.preco_unit,
            'formato', oi.formato,
            'sabor_1', oi.sabor_1,
            'sabor_2', oi.sabor_2,
            'borda_nome', oi.borda_nome,
            'borda_preco', oi.borda_preco,
            'adicionais', oi.adicionais,
            'observacao', oi.observacao
          )
        ) as items
      FROM orders o
      LEFT JOIN users u ON o.user_id = u.id
      LEFT JOIN order_items oi ON o.id = oi.order_id
      WHERE 1=1
    `;
    
    const params = [];
    
    if (status) {
      query += ` AND o.status = $${params.length + 1}`;
      params.push(status);
    }
    
    if (data_inicio) {
      query += ` AND o.created_at >= $${params.length + 1}`;
      params.push(data_inicio);
    }
    
    if (data_fim) {
      query += ` AND o.created_at <= $${params.length + 1}`;
      params.push(data_fim + ' 23:59:59');
    }
    
    query += ` GROUP BY o.id, u.nome, u.email ORDER BY o.created_at DESC`;
    
    const result = await pool.query(query, params);
    res.json(result.rows);
  } catch (error) {
    console.error('Get all orders error:', error);
    res.status(500).json({ error: 'Erro ao buscar pedidos' });
  }
});

// Buscar pedido específico
router.get('/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    
    let query = `
      SELECT o.*, u.nome as cliente_nome, u.email as cliente_email,
        json_agg(
          json_build_object(
            'id', oi.id,
            'product_name', oi.product_name,
            'quantidade', oi.quantidade,
            'preco_unit', oi.preco_unit,
            'formato', oi.formato,
            'sabor_1', oi.sabor_1,
            'sabor_2', oi.sabor_2,
            'borda_nome', oi.borda_nome,
            'borda_preco', oi.borda_preco,
            'adicionais', oi.adicionais,
            'observacao', oi.observacao
          )
        ) as items
      FROM orders o
      LEFT JOIN users u ON o.user_id = u.id
      LEFT JOIN order_items oi ON o.id = oi.order_id
      WHERE o.id = $1
    `;
    
    // Se não é admin, só pode ver seus próprios pedidos
    if (req.user.tipo !== 'proprietario') {
      query += ` AND o.user_id = $2`;
    }
    
    query += ` GROUP BY o.id, u.nome, u.email`;
    
    const params = req.user.tipo === 'proprietario' ? [id] : [id, req.user.userId];
    const result = await pool.query(query, params);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Pedido não encontrado' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    console.error('Get order error:', error);
    res.status(500).json({ error: 'Erro ao buscar pedido' });
  }
});

// Criar pedido
router.post('/', authenticateToken, async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const { items, observacao, endereco_entrega, telefone_contato } = req.body;

    if (!items || items.length === 0) {
      return res.status(400).json({ error: 'Pedido deve ter pelo menos 1 item' });
    }

    // Verificar estoque
    for (const item of items) {
      if (item.product_id) {
        const stockResult = await client.query(
          'SELECT estoque, nome FROM products WHERE id = $1',
          [item.product_id]
        );
        
        if (stockResult.rows.length === 0) {
          throw new Error(`Produto ${item.product_name} não encontrado`);
        }
        
        const produto = stockResult.rows[0];
        if (produto.estoque < item.quantidade) {
          throw new Error(`Estoque insuficiente para ${produto.nome}. Disponível: ${produto.estoque}`);
        }
      }
    }

    // Calcular totais
    let subtotal = 0;
    const processedItems = [];
    
    for (const item of items) {
      let itemTotal = item.preco_unit * item.quantidade;
      
      // Adicionar preço da borda
      if (item.borda_preco) {
        itemTotal += item.borda_preco * item.quantidade;
      }
      
      // Adicionar preço dos adicionais
      if (item.adicionais && Array.isArray(item.adicionais)) {
        for (const adicional of item.adicionais) {
          itemTotal += adicional.preco * item.quantidade;
        }
      }
      
      subtotal += itemTotal;
      processedItems.push({
        ...item,
        total_item: itemTotal
      });
    }

    // Taxa de entrega
    const configResult = await client.query(
      'SELECT valor FROM configuracoes WHERE chave = $1',
      ['taxa_entrega']
    );
    const taxa_entrega = configResult.rows.length > 0 ? parseFloat(configResult.rows[0].valor) : 5.00;
    
    const total = subtotal + taxa_entrega;

    // Criar pedido
    const orderResult = await client.query(`
      INSERT INTO orders (user_id, total, valor_frete, observacao, endereco_entrega, telefone_contato)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `, [req.user.userId, total, taxa_entrega, observacao || '', endereco_entrega || '', telefone_contato || '']);
    
    const order = orderResult.rows[0];

    // Criar itens do pedido
    for (const item of processedItems) {
      await client.query(`
        INSERT INTO order_items (
          order_id, product_id, product_name, quantidade, preco_unit, 
          observacao, formato, sabor_1, sabor_2, borda_id, borda_nome, 
          borda_preco, adicionais
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
      `, [
        order.id, item.product_id, item.product_name, item.quantidade, item.preco_unit,
        item.observacao || '', item.formato || 'inteira', item.sabor_1 || '', 
        item.sabor_2 || '', item.borda_id, item.borda_nome || '', 
        item.borda_preco || 0, JSON.stringify(item.adicionais || [])
      ]);
      
      // Reduzir estoque
      if (item.product_id) {
        await client.query(
          'UPDATE products SET estoque = estoque - $1 WHERE id = $2',
          [item.quantidade, item.product_id]
        );
      }
    }

    await client.query('COMMIT');

    // Buscar pedido completo para retorno
    const fullOrderResult = await pool.query(`
      SELECT o.*, 
        json_agg(
          json_build_object(
            'id', oi.id,
            'product_name', oi.product_name,
            'quantidade', oi.quantidade,
            'preco_unit', oi.preco_unit,
            'formato', oi.formato,
            'sabor_1', oi.sabor_1,
            'sabor_2', oi.sabor_2,
            'borda_nome', oi.borda_nome,
            'borda_preco', oi.borda_preco,
            'adicionais', oi.adicionais,
            'observacao', oi.observacao
          )
        ) as items
      FROM orders o
      LEFT JOIN order_items oi ON o.id = oi.order_id
      WHERE o.id = $1
      GROUP BY o.id
    `, [order.id]);

    res.status(201).json({
      message: 'Pedido criado com sucesso',
      order: fullOrderResult.rows[0]
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Create order error:', error);
    res.status(500).json({ error: error.message || 'Erro ao criar pedido' });
  } finally {
    client.release();
  }
});

// Atualizar pedido (Admin only)
router.put('/:id', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { id } = req.params;
    const { status, entregador, observacao_admin, valor_frete } = req.body;
    
    const result = await pool.query(`
      UPDATE orders 
      SET status = COALESCE($1, status),
          entregador = COALESCE($2, entregador),
          observacao_admin = COALESCE($3, observacao_admin),
          valor_frete = COALESCE($4, valor_frete),
          updated_at = NOW()
      WHERE id = $5
      RETURNING *
    `, [status, entregador, observacao_admin, valor_frete ? parseFloat(valor_frete) : null, id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Pedido não encontrado' });
    }
    
    res.json({
      message: 'Pedido atualizado com sucesso',
      order: result.rows[0]
    });
  } catch (error) {
    console.error('Update order error:', error);
    res.status(500).json({ error: 'Erro ao atualizar pedido' });
  }
});

// Cancelar pedido
router.patch('/:id/cancelar', authenticateToken, async (req, res) => {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const { id } = req.params;
    const { motivo } = req.body;
    
    // Verificar se o pedido pode ser cancelado
    const orderResult = await client.query(
      'SELECT * FROM orders WHERE id = $1',
      [id]
    );
    
    if (orderResult.rows.length === 0) {
      return res.status(404).json({ error: 'Pedido não encontrado' });
    }
    
    const order = orderResult.rows[0];
    
    // Verificar permissões
    if (req.user.tipo !== 'proprietario' && order.user_id !== req.user.userId) {
      return res.status(403).json({ error: 'Sem permissão para cancelar este pedido' });
    }
    
    if (order.status === 'finalizado') {
      return res.status(400).json({ error: 'Não é possível cancelar pedido finalizado' });
    }
    
    // Restaurar estoque
    const itemsResult = await client.query(
      'SELECT product_id, quantidade FROM order_items WHERE order_id = $1 AND product_id IS NOT NULL',
      [id]
    );
    
    for (const item of itemsResult.rows) {
      await client.query(
        'UPDATE products SET estoque = estoque + $1 WHERE id = $2',
        [item.quantidade, item.product_id]
      );
    }
    
    // Atualizar pedido
    await client.query(`
      UPDATE orders 
      SET status = 'cancelado', 
          observacao_admin = COALESCE(observacao_admin || ' | ', '') || 'Cancelado: ' || $1,
          updated_at = NOW()
      WHERE id = $2
    `, [motivo || 'Cancelado pelo ' + (req.user.tipo === 'proprietario' ? 'admin' : 'cliente'), id]);
    
    await client.query('COMMIT');
    
    res.json({ message: 'Pedido cancelado com sucesso' });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Cancel order error:', error);
    res.status(500).json({ error: 'Erro ao cancelar pedido' });
  } finally {
    client.release();
  }
});

// Gerar relatório (Admin only)
router.get('/admin/relatorio', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const { data_inicio, data_fim, status } = req.query;
    
    let query = `
      SELECT 
        DATE(created_at) as data,
        COUNT(*) as total_pedidos,
        SUM(total) as receita_total,
        AVG(total) as ticket_medio,
        COUNT(CASE WHEN status = 'finalizado' THEN 1 END) as pedidos_finalizados,
        COUNT(CASE WHEN status = 'cancelado' THEN 1 END) as pedidos_cancelados
      FROM orders 
      WHERE created_at >= $1 AND created_at <= $2
    `;
    
    const params = [
      data_inicio || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
      (data_fim || new Date().toISOString().split('T')[0]) + ' 23:59:59'
    ];
    
    if (status) {
      query += ` AND status = ${params.length + 1}`;
      params.push(status);
    }
    
    query += ` GROUP BY DATE(created_at) ORDER BY data DESC`;
    
    const result = await pool.query(query, params);
    
    // Produtos mais vendidos
    const topProductsResult = await pool.query(`
      SELECT 
        oi.product_name,
        SUM(oi.quantidade) as total_vendido,
        SUM(oi.quantidade * oi.preco_unit) as receita_produto
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      WHERE o.created_at >= $1 AND o.created_at <= $2 AND o.status = 'finalizado'
      GROUP BY oi.product_name
      ORDER BY total_vendido DESC
      LIMIT 10
    `, [params[0], params[1]]);
    
    res.json({
      relatorio_diario: result.rows,
      produtos_mais_vendidos: topProductsResult.rows,
      resumo: {
        total_pedidos: result.rows.reduce((sum, day) => sum + parseInt(day.total_pedidos), 0),
        receita_total: result.rows.reduce((sum, day) => sum + parseFloat(day.receita_total || 0), 0),
        ticket_medio: result.rows.length > 0 ? 
          result.rows.reduce((sum, day) => sum + parseFloat(day.receita_total || 0), 0) / 
          result.rows.reduce((sum, day) => sum + parseInt(day.total_pedidos), 0) : 0
      }
    });
  } catch (error) {
    console.error('Generate report error:', error);
    res.status(500).json({ error: 'Erro ao gerar relatório' });
  }
});

export default router;
