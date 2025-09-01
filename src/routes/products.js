import express from 'express';
import { authenticateToken, requireAdmin } from '../middleware/auth.js';

const router = express.Router();

// Produtos em memória (simulando banco de dados)
let products = [
  // Pizzas Tradicionais
  { id: '1', nome: 'Pizza Margherita', categoria: 'tradicional', tipo: 'pizza', preco: 35.0, estoque: 50, descricao: 'Molho de tomate, mussarela, manjericão', imagem: 'https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg?auto=compress&cs=tinysrgb&w=400' },
  { id: '2', nome: 'Pizza Calabresa', categoria: 'tradicional', tipo: 'pizza', preco: 35.0, estoque: 45, descricao: 'Molho de tomate, mussarela, calabresa, cebola', imagem: 'https://images.pexels.com/photos/2619967/pexels-photo-2619967.jpeg?auto=compress&cs=tinysrgb&w=400' },
  { id: '3', nome: 'Pizza Portuguesa', categoria: 'tradicional', tipo: 'pizza', preco: 35.0, estoque: 40, descricao: 'Molho de tomate, mussarela, presunto, ovos, cebola', imagem: 'https://images.pexels.com/photos/1049626/pexels-photo-1049626.jpeg?auto=compress&cs=tinysrgb&w=400' },
  
  // Pizzas Premium
  { id: '4', nome: 'Pizza Frango Catupiry', categoria: 'premium', tipo: 'pizza', preco: 40.0, estoque: 35, descricao: 'Molho de tomate, mussarela, frango desfiado, catupiry', imagem: 'https://images.pexels.com/photos/4394612/pexels-photo-4394612.jpeg?auto=compress&cs=tinysrgb&w=400' },
  { id: '5', nome: 'Pizza Bacon', categoria: 'premium', tipo: 'pizza', preco: 40.0, estoque: 30, descricao: 'Molho de tomate, mussarela, bacon crocante', imagem: 'https://images.pexels.com/photos/1049620/pexels-photo-1049620.jpeg?auto=compress&cs=tinysrgb&w=400' },
  
  // Pizzas Especiais
  { id: '6', nome: 'Pizza Quatro Queijos', categoria: 'especial', tipo: 'pizza', preco: 45.0, estoque: 25, descricao: 'Mussarela, parmesão, gorgonzola, catupiry', imagem: 'https://images.pexels.com/photos/4109111/pexels-photo-4109111.jpeg?auto=compress&cs=tinysrgb&w=400' },
  { id: '7', nome: 'Pizza Camarão', categoria: 'especial', tipo: 'pizza', preco: 45.0, estoque: 20, descricao: 'Molho branco, mussarela, camarão, catupiry', imagem: 'https://images.pexels.com/photos/3915906/pexels-photo-3915906.jpeg?auto=compress&cs=tinysrgb&w=400' },
  
  // Esfihas Tradicionais
  { id: '8', nome: 'Esfiha Carne', categoria: 'tradicional', tipo: 'esfiha', preco: 25.0, estoque: 80, descricao: 'Carne temperada com cebola e especiarias', imagem: 'https://images.pexels.com/photos/4253320/pexels-photo-4253320.jpeg?auto=compress&cs=tinysrgb&w=400' },
  { id: '9', nome: 'Esfiha Frango', categoria: 'tradicional', tipo: 'esfiha', preco: 25.0, estoque: 75, descricao: 'Frango desfiado temperado', imagem: 'https://images.pexels.com/photos/4253319/pexels-photo-4253319.jpeg?auto=compress&cs=tinysrgb&w=400' },
  
  // Esfihas Premium
  { id: '10', nome: 'Esfiha Carne com Queijo', categoria: 'premium', tipo: 'esfiha', preco: 30.0, estoque: 60, descricao: 'Carne temperada coberta com queijo derretido', imagem: 'https://images.pexels.com/photos/4253321/pexels-photo-4253321.jpeg?auto=compress&cs=tinysrgb&w=400' },
  { id: '11', nome: 'Esfiha Frango com Catupiry', categoria: 'premium', tipo: 'esfiha', preco: 30.0, estoque: 55, descricao: 'Frango desfiado com catupiry cremoso', imagem: 'https://images.pexels.com/photos/4253322/pexels-photo-4253322.jpeg?auto=compress&cs=tinysrgb&w=400' },
  
  // Esfihas Especiais
  { id: '12', nome: 'Esfiha Camarão', categoria: 'especial', tipo: 'esfiha', preco: 40.0, estoque: 40, descricao: 'Camarão refogado com temperos especiais', imagem: 'https://images.pexels.com/photos/4253323/pexels-photo-4253323.jpeg?auto=compress&cs=tinysrgb&w=400' },
  { id: '13', nome: 'Esfiha Salmão', categoria: 'especial', tipo: 'esfiha', preco: 45.0, estoque: 30, descricao: 'Salmão grelhado com cream cheese', imagem: 'https://images.pexels.com/photos/4253324/pexels-photo-4253324.jpeg?auto=compress&cs=tinysrgb&w=400' },
  
  // Bebidas
  { id: '14', nome: 'Coca-Cola 350ml', categoria: 'refrigerantes', tipo: 'bebida', preco: 25.0, estoque: 100, descricao: 'Refrigerante de cola gelado', imagem: 'https://images.pexels.com/photos/50593/coca-cola-cold-drink-soft-drink-coke-50593.jpeg?auto=compress&cs=tinysrgb&w=400' },
  { id: '15', nome: 'Guaraná Antarctica 350ml', categoria: 'refrigerantes', tipo: 'bebida', preco: 25.0, estoque: 80, descricao: 'Refrigerante de guaraná gelado', imagem: 'https://images.pexels.com/photos/1292294/pexels-photo-1292294.jpeg?auto=compress&cs=tinysrgb&w=400' }
];

// Listar produtos (público)
router.get('/', (req, res) => {
  try {
    const { categoria, tipo } = req.query;
    
    let filteredProducts = [...products];
    
    if (categoria && categoria !== 'todos') {
      filteredProducts = filteredProducts.filter(p => p.categoria === categoria);
    }
    
    if (tipo) {
      filteredProducts = filteredProducts.filter(p => p.tipo === tipo);
    }
    
    res.json(filteredProducts);
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({ error: 'Erro ao buscar produtos' });
  }
});

// Buscar produto específico (público)
router.get('/:id', (req, res) => {
  try {
    const { id } = req.params;
    const product = products.find(p => p.id === id);
    
    if (!product) {
      return res.status(404).json({ error: 'Produto não encontrado' });
    }
    
    res.json(product);
  } catch (error) {
    console.error('Get product error:', error);
    res.status(500).json({ error: 'Erro ao buscar produto' });
  }
});

// Criar produto (Admin only)
router.post('/', authenticateToken, requireAdmin, (req, res) => {
  try {
    const { nome, categoria, tipo, preco, estoque, descricao, imagem } = req.body;
    
    if (!nome || !categoria || !tipo || !preco) {
      return res.status(400).json({ error: 'Campos obrigatórios: nome, categoria, tipo, preco' });
    }
    
    const newId = (Math.max(...products.map(p => parseInt(p.id))) + 1).toString();
    const newProduct = {
      id: newId,
      nome,
      categoria,
      tipo,
      preco: parseFloat(preco),
      estoque: parseInt(estoque) || 0,
      descricao: descricao || '',
      imagem: imagem || ''
    };
    
    products.push(newProduct);
    
    res.status(201).json({
      message: 'Produto criado com sucesso',
      product: newProduct
    });
  } catch (error) {
    console.error('Create product error:', error);
    res.status(500).json({ error: 'Erro ao criar produto' });
  }
});

// Atualizar produto (Admin only)
router.put('/:id', authenticateToken, requireAdmin, (req, res) => {
  try {
    const { id } = req.params;
    const { nome, categoria, tipo, preco, estoque, descricao, imagem } = req.body;
    
    const productIndex = products.findIndex(p => p.id === id);
    
    if (productIndex === -1) {
      return res.status(404).json({ error: 'Produto não encontrado' });
    }
    
    const updatedProduct = {
      ...products[productIndex],
      nome: nome || products[productIndex].nome,
      categoria: categoria || products[productIndex].categoria,
      tipo: tipo || products[productIndex].tipo,
      preco: preco ? parseFloat(preco) : products[productIndex].preco,
      estoque: estoque !== undefined ? parseInt(estoque) : products[productIndex].estoque,
      descricao: descricao !== undefined ? descricao : products[productIndex].descricao,
      imagem: imagem !== undefined ? imagem : products[productIndex].imagem
    };
    
    products[productIndex] = updatedProduct;
    
    res.json({
      message: 'Produto atualizado com sucesso',
      product: updatedProduct
    });
  } catch (error) {
    console.error('Update product error:', error);
    res.status(500).json({ error: 'Erro ao atualizar produto' });
  }
});

// Deletar produto (Admin only)
router.delete('/:id', authenticateToken, requireAdmin, (req, res) => {
  try {
    const { id } = req.params;
    const productIndex = products.findIndex(p => p.id === id);
    
    if (productIndex === -1) {
      return res.status(404).json({ error: 'Produto não encontrado' });
    }
    
    const deletedProduct = products[productIndex];
    products.splice(productIndex, 1);
    
    res.json({
      message: 'Produto deletado com sucesso',
      product: deletedProduct
    });
  } catch (error) {
    console.error('Delete product error:', error);
    res.status(500).json({ error: 'Erro ao deletar produto' });
  }
});

export default router;
