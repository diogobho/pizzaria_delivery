-- =====================================================
-- MIGRAÇÕES PIZZARIA RODRIGO'S - ESTRUTURA COMPLETA
-- =====================================================

-- Extensão UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. CRIAR ENUM PARA STATUS DE PEDIDOS
CREATE TYPE order_status AS ENUM ('nao_iniciado', 'em_andamento', 'finalizado');

-- 2. CRIAR ENUM PARA CATEGORIAS (incluindo esfihas)
CREATE TYPE product_category AS ENUM (
  'tradicional', 'premium', 'especial', 'refrigerantes',
  'esfihas_tradicional', 'esfihas_premium', 'esfihas_especial'
);

-- 3. CRIAR ENUM PARA TIPO DE USUÁRIO
CREATE TYPE user_type AS ENUM ('cliente', 'proprietario');

-- 4. TABELA DE USUÁRIOS
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nome VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  senha VARCHAR(255) NOT NULL,
  tipo user_type DEFAULT 'cliente',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 5. TABELA DE PRODUTOS (pizzas, esfihas, bebidas)
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nome VARCHAR(255) NOT NULL,
  categoria product_category NOT NULL,
  descricao TEXT,
  preco DECIMAL(10,2) NOT NULL,
  estoque INTEGER DEFAULT 0,
  imagem TEXT,
  tipo_produto VARCHAR(20) DEFAULT 'pizza', -- 'pizza', 'esfiha', 'bebida'
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 6. TABELA DE BORDAS (somente para pizzas)
CREATE TABLE bordas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nome VARCHAR(100) NOT NULL,
  preco_adicional DECIMAL(10,2) DEFAULT 0,
  gratis_categoria TEXT[] DEFAULT '{}', -- categorias onde é grátis
  created_at TIMESTAMP DEFAULT NOW()
);

-- 7. TABELA DE ADICIONAIS
CREATE TABLE adicionais (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nome VARCHAR(100) NOT NULL,
  preco DECIMAL(10,2) NOT NULL,
  categoria_produto TEXT NOT NULL, -- 'pizza' ou 'esfiha'
  created_at TIMESTAMP DEFAULT NOW()
);

-- 8. TABELA DE PEDIDOS
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  status order_status DEFAULT 'nao_iniciado',
  total DECIMAL(10,2) NOT NULL,
  valor_frete DECIMAL(10,2) DEFAULT 0,
  observacao TEXT,
  entregador VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 9. TABELA DE ITENS DO PEDIDO
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  product_name VARCHAR(255) NOT NULL,
  quantidade INTEGER NOT NULL,
  preco_unit DECIMAL(10,2) NOT NULL,
  observacao TEXT,
  formato VARCHAR(20) DEFAULT 'inteira', -- 'inteira' ou 'meia'
  sabor_1 TEXT,
  sabor_2 TEXT, -- para meia a meia
  borda_id UUID REFERENCES bordas(id),
  adicionais_ids UUID[] DEFAULT '{}',
  tipo_adicional VARCHAR(10) DEFAULT 'inteira', -- 'inteira' ou 'meia'
  created_at TIMESTAMP DEFAULT NOW()
);

-- 10. TABELA DE CONFIGURAÇÕES
CREATE TABLE configuracoes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chave VARCHAR(100) UNIQUE NOT NULL,
  valor TEXT NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 11. TABELA DE ENTREGADORES
CREATE TABLE entregadores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nome VARCHAR(255) NOT NULL,
  telefone VARCHAR(20),
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 12. POPULAR DADOS INICIAIS

-- Usuários padrão
INSERT INTO users (nome, email, senha, tipo) VALUES
('Cliente Teste', 'cliente@teste.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'cliente'), -- senha: password
('Rodrigo', 'rodrigo@pizzaria.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'proprietario'); -- senha: password

-- Bordas para pizzas
INSERT INTO bordas (nome, preco_adicional, gratis_categoria) VALUES
('Sem borda', 0, '{}'),
('Requeijão', 2.00, '{"tradicional"}'), 
('Catupiry', 3.00, '{"premium"}'), 
('Cheddar', 3.00, '{"premium"}'), 
('Chocolate', 4.00, '{}');

-- Adicionais
INSERT INTO adicionais (nome, preco, categoria_produto) VALUES
('Bacon', 3.00, 'pizza'),
('Bacon', 2.00, 'esfiha'),
('Cream Cheese', 2.50, 'pizza'),
('Cream Cheese', 2.00, 'esfiha'),
('Requeijão Extra', 2.00, 'pizza'),
('Requeijão Extra', 1.50, 'esfiha'),
('Cheddar Extra', 2.50, 'pizza'),
('Cheddar Extra', 2.00, 'esfiha');

-- Configurações
INSERT INTO configuracoes (chave, valor) VALUES 
('horario_relatorios', '08:00'),
('taxa_entrega', '5.00');

-- Entregadores
INSERT INTO entregadores (nome, telefone) VALUES
('João Silva', '(11) 99999-1111'),
('Maria Santos', '(11) 99999-2222'),
('Pedro Costa', '(11) 99999-3333');
