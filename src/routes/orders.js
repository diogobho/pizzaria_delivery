import express from 'express';
import { authenticateToken, requireAdmin } from '../middleware/auth.js';

const router = express.Router();

// Pedidos em memória
let orders = [
  {
    id: '1',
    user_id: 'e9b38c00-457b-4e60-8b30-266f60806772',
    user_name: 'Cliente Teste',
    status: 'em_andamento',
    total: 95.0,
    valor_frete: 50.0,
    observacao: 'Entregar no portão',
    entregador: 'João Silva',
    created_at: '2025-01-11T10:30:00Z',
    items: [
      {
        id: '1',
        product_name: 'Pizza Margherita',
        quantidade: 2,
        preco_unit: 35.0,
        formato: 'inteira',
        sabor_1: 'Margherita',
        borda: 'Requeijão',
        observacao: 'Sem manjericão'
      },
      {
        id: '2',
        product_name: 'Coca-Cola 350ml',
        quantidade: 1,
        preco_unit: 25.0,
        formato: 'inteira'
      }
    ]
  },
  {
    id: '2',
    user_id: 'e9b38c00-457b-4e60-8b30-266f60806772',
    user_name: 'Cliente Teste',
    status: 'finalizado',
    total: 40.0,
    valor_frete: 0,
    observacao: '',
    entregador: '',
    created_at: '2025-01-10T19:15:00Z',
    items: [
      {
        id: '3',
        product_name: 'Pizza Frango Catupiry',
        quantidade: 1,
        preco_unit: 40.0,
        formato: 'inteira',
        sabor_1: 'Frango Catupiry'
      }
    ]
  }
];

// Listar pedidos do usuário
router.get('/my-orders', authenticateToken, (req, res) => {
  try {
    const userOrders = orders.filter(order => order.user_id === req.user.userId);
    res.json(userOrders);
  } catch (error) {
    console.error('Get user orders error:', error);
    res.status(500).json({ error: 'Erro ao buscar pedidos' });
  }
});

// Listar todos os pedidos (Admin only)
router.get('/', authenticateToken, requireAdmin, (req, res) => {
  try {
    res.json(orders);
  } catch (error) {
    console.error('Get all orders error:', error);
    res.status(500).json({ error: 'Erro ao buscar pedidos' });
  }
});

// Criar pedido
router.post('/', authenticateToken, (req, res) => {
  try {
    const { items, total, observacao, valor_frete, entregador } = req.body;

    if (!items || items.length === 0) {
      return res.status(400).json({ error: 'Pedido deve ter pelo menos 1 item' });
    }

    const newId = (orders.length + 1).toString();
    const newOrder = {
      id: newId,
      user_id: req.user.userId,
      user_name: req.user.email,
      status: 'nao_iniciado',
      total: parseFloat(total) || 0,
      valor_frete: parseFloat(valor_frete) || 0,
      observacao: observacao || '',
      entregador: entregador || '',
      created_at: new Date().toISOString(),
      items: items.map((item, index) => ({
        id: (index + 1).toString(),
        product_name: item.product_name,
        quantidade: parseInt(item.quantidade),
        preco_unit: parseFloat(item.preco_unit),
        formato: item.formato || 'inteira',
        sabor_1: item.sabor_1 || '',
        sabor_2: item.sabor_2 || '',
        borda: item.borda || '',
        adicionais: item.adicionais || [],
        observacao: item.observacao || ''
      }))
    };

    orders.push(newOrder);

    res.status(201).json({
      message: 'Pedido criado com sucesso',
      order: newOrder
    });
  } catch (error) {
    console.error('Create order error:', error);
    res.status(500).json({ error: 'Erro ao criar pedido' });
  }
});

// Atualizar status do pedido (Admin only)
router.patch('/:id/status', authenticateToken, requireAdmin, (req, res) => {
  try {
    const { id } = req.params;
    const { status, entregador } = req.body;

    const orderIndex = orders.findIndex(o => o.id === id);
    
    if (orderIndex === -1) {
      return res.status(404).json({ error: 'Pedido não encontrado' });
    }

    orders[orderIndex].status = status;
    if (entregador) {
      orders[orderIndex].entregador = entregador;
    }

    res.json({
      message: 'Status do pedido atualizado com sucesso',
      order: orders[orderIndex]
    });
  } catch (error) {
    console.error('Update order status error:', error);
    res.status(500).json({ error: 'Erro ao atualizar status do pedido' });
  }
});

export default router;
