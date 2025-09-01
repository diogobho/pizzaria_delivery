import express from 'express';

const router = express.Router();

// Bordas para pizzas
const bordas = [
  { id: '1', nome: 'Sem borda', preco_adicional: 0, gratis_categoria: [] },
  { id: '2', nome: 'Requeijão', preco_adicional: 20.0, gratis_categoria: ['tradicional'] },
  { id: '3', nome: 'Catupiry', preco_adicional: 30.0, gratis_categoria: ['premium'] },
  { id: '4', nome: 'Cheddar', preco_adicional: 30.0, gratis_categoria: ['premium'] },
  { id: '5', nome: 'Chocolate', preco_adicional: 40.0, gratis_categoria: [] }
];

// Adicionais
const adicionais = [
  { id: '1', nome: 'Bacon', preco_pizza: 30.0, preco_esfiha: 20.0 },
  { id: '2', nome: 'Cream Cheese', preco_pizza: 25.0, preco_esfiha: 20.0 },
  { id: '3', nome: 'Requeijão Extra', preco_pizza: 20.0, preco_esfiha: 15.0 },
  { id: '4', nome: 'Cheddar Extra', preco_pizza: 25.0, preco_esfiha: 20.0 }
];

// Entregadores
const entregadores = [
  { id: '1', nome: 'João Silva', telefone: '(11) 99999-1111', ativo: true },
  { id: '2', nome: 'Maria Santos', telefone: '(11) 99999-2222', ativo: true },
  { id: '3', nome: 'Pedro Costa', telefone: '(11) 99999-3333', ativo: true }
];

// Listar bordas
router.get('/bordas', (req, res) => {
  res.json(bordas);
});

// Listar adicionais
router.get('/adicionais', (req, res) => {
  const { tipo } = req.query;
  
  let result = adicionais.map(adicional => ({
    ...adicional,
    preco: tipo === 'esfiha' ? adicional.preco_esfiha : adicional.preco_pizza
  }));
  
  res.json(result);
});

// Listar entregadores
router.get('/entregadores', (req, res) => {
  res.json(entregadores.filter(e => e.ativo));
});

// Configurações
router.get('/configuracoes', (req, res) => {
  res.json({
    horario_relatorios: '08:00',
    taxa_entrega: 50.0
  });
});

export default router;
