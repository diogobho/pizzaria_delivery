-- ====================================================================
-- MIGRATION FINAL: PIZZARIA RODRIGO'S - REGRAS DE NEGÓCIO COMPLETAS
-- ====================================================================

-- 1. EXTENSÕES NECESSÁRIAS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. VERIFICAR E CRIAR ENUMS APENAS SE NÃO EXISTIREM
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'order_status') THEN
        CREATE TYPE order_status AS ENUM ('pendente', 'em_preparo', 'pronto', 'entregue', 'cancelado');
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'product_category') THEN
        CREATE TYPE product_category AS ENUM (
            'tradicional', 'premium', 'especial', 
            'refrigerantes', 'bebidas'
        );
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_type') THEN
        CREATE TYPE user_type AS ENUM ('cliente', 'proprietario');
    END IF;
END $$;

-- 3. CRIAR TABELAS APENAS SE NÃO EXISTIREM

-- Tabela USERS
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    tipo VARCHAR(20) DEFAULT 'cliente',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela PRODUCTS
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    estoque INTEGER DEFAULT 0,
    imagem TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela BORDAS
CREATE TABLE IF NOT EXISTS bordas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(100) NOT NULL,
    preco_adicional DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela ADICIONAIS  
CREATE TABLE IF NOT EXISTS adicionais (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela ORDERS
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pendente',
    total DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela ORDER_ITEMS
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    product_name VARCHAR(255) NOT NULL,
    quantidade INTEGER NOT NULL,
    preco_unit DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Tabela CONFIGURACOES
CREATE TABLE IF NOT EXISTS configuracoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    chave VARCHAR(100) UNIQUE NOT NULL,
    valor TEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Tabela ENTREGADORES
CREATE TABLE IF NOT EXISTS entregadores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    telefone VARCHAR(20),
    ativo BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4. ADICIONAR COLUNAS DE REGRAS DE NEGÓCIO
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='products' AND column_name='tipo_produto') THEN
        ALTER TABLE products ADD COLUMN tipo_produto VARCHAR(20) DEFAULT 'pizza';
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='products' AND column_name='permite_meia') THEN
        ALTER TABLE products ADD COLUMN permite_meia BOOLEAN DEFAULT false;
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='products' AND column_name='categoria_display') THEN
        ALTER TABLE products ADD COLUMN categoria_display VARCHAR(100);
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='products' AND column_name='ordem_exibicao') THEN
        ALTER TABLE products ADD COLUMN ordem_exibicao INTEGER DEFAULT 0;
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='bordas' AND column_name='categoria_gratuita') THEN
        ALTER TABLE bordas ADD COLUMN categoria_gratuita TEXT[] DEFAULT '{}';
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='adicionais' AND column_name='preco_pizza') THEN
        ALTER TABLE adicionais ADD COLUMN preco_pizza DECIMAL(10,2) NOT NULL DEFAULT 0;
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='adicionais' AND column_name='preco_esfiha') THEN
        ALTER TABLE adicionais ADD COLUMN preco_esfiha DECIMAL(10,2) NOT NULL DEFAULT 0;
    END IF;
END $$;

-- Adicionar colunas na tabela orders
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='orders' AND column_name='valor_frete') THEN
        ALTER TABLE orders ADD COLUMN valor_frete DECIMAL(10,2) DEFAULT 0;
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='orders' AND column_name='observacao_cliente') THEN
        ALTER TABLE orders ADD COLUMN observacao_cliente TEXT;
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='orders' AND column_name='observacao_admin') THEN
        ALTER TABLE orders ADD COLUMN observacao_admin TEXT;
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='orders' AND column_name='entregador') THEN
        ALTER TABLE orders ADD COLUMN entregador VARCHAR(255);
    END IF;
END $$;

-- Adicionar colunas na tabela order_items para regras de montagem
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='order_items' AND column_name='formato') THEN
        ALTER TABLE order_items ADD COLUMN formato VARCHAR(20) DEFAULT 'inteira';
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='order_items' AND column_name='sabor_1') THEN
        ALTER TABLE order_items ADD COLUMN sabor_1 TEXT;
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='order_items' AND column_name='sabor_2') THEN
        ALTER TABLE order_items ADD COLUMN sabor_2 TEXT;
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='order_items' AND column_name='borda_nome') THEN
        ALTER TABLE order_items ADD COLUMN borda_nome VARCHAR(100);
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='order_items' AND column_name='borda_preco') THEN
        ALTER TABLE order_items ADD COLUMN borda_preco DECIMAL(10,2) DEFAULT 0;
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='order_items' AND column_name='adicionais_info') THEN
        ALTER TABLE order_items ADD COLUMN adicionais_info JSONB DEFAULT '[]';
    END IF;
END $$;

DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='order_items' AND column_name='observacao') THEN
        ALTER TABLE order_items ADD COLUMN observacao TEXT;
    END IF;
END $$;

-- 5. INSERIR DADOS APENAS SE NÃO EXISTIREM

-- Usuários padrão
INSERT INTO users (nome, email, senha, tipo) 
SELECT 'Cliente Teste', 'cliente@teste.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'cliente'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'cliente@teste.com');

INSERT INTO users (nome, email, senha, tipo) 
SELECT 'Rodrigo Admin', 'rodrigo@pizzaria.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'proprietario'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE email = 'rodrigo@pizzaria.com');

-- Bordas com regras de gratuidade
INSERT INTO bordas (nome, preco_adicional, categoria_gratuita) 
SELECT 'Sem borda', 0.00, '{}'
WHERE NOT EXISTS (SELECT 1 FROM bordas WHERE nome = 'Sem borda');

INSERT INTO bordas (nome, preco_adicional, categoria_gratuita) 
SELECT 'Requeijão', 2.00, '{"tradicional"}'
WHERE NOT EXISTS (SELECT 1 FROM bordas WHERE nome = 'Requeijão');

INSERT INTO bordas (nome, preco_adicional, categoria_gratuita) 
SELECT 'Catupiry', 3.00, '{"premium"}'
WHERE NOT EXISTS (SELECT 1 FROM bordas WHERE nome = 'Catupiry');

INSERT INTO bordas (nome, preco_adicional, categoria_gratuita) 
SELECT 'Cheddar', 3.00, '{"premium"}'
WHERE NOT EXISTS (SELECT 1 FROM bordas WHERE nome = 'Cheddar');

INSERT INTO bordas (nome, preco_adicional, categoria_gratuita) 
SELECT 'Chocolate', 4.00, '{}'
WHERE NOT EXISTS (SELECT 1 FROM bordas WHERE nome = 'Chocolate');

-- Adicionais com preços diferenciados
INSERT INTO adicionais (nome, preco_pizza, preco_esfiha) 
SELECT 'Bacon', 3.00, 2.00
WHERE NOT EXISTS (SELECT 1 FROM adicionais WHERE nome = 'Bacon');

INSERT INTO adicionais (nome, preco_pizza, preco_esfiha) 
SELECT 'Cream Cheese', 2.50, 2.00
WHERE NOT EXISTS (SELECT 1 FROM adicionais WHERE nome = 'Cream Cheese');

INSERT INTO adicionais (nome, preco_pizza, preco_esfiha) 
SELECT 'Requeijão Extra', 2.00, 1.50
WHERE NOT EXISTS (SELECT 1 FROM adicionais WHERE nome = 'Requeijão Extra');

INSERT INTO adicionais (nome, preco_pizza, preco_esfiha) 
SELECT 'Cheddar Extra', 2.50, 2.00
WHERE NOT EXISTS (SELECT 1 FROM adicionais WHERE nome = 'Cheddar Extra');

INSERT INTO adicionais (nome, preco_pizza, preco_esfiha) 
SELECT 'Azeitona', 1.50, 1.00
WHERE NOT EXISTS (SELECT 1 FROM adicionais WHERE nome = 'Azeitona');

INSERT INTO adicionais (nome, preco_pizza, preco_esfiha) 
SELECT 'Champignon', 2.00, 1.50
WHERE NOT EXISTS (SELECT 1 FROM adicionais WHERE nome = 'Champignon');

-- Configurações do sistema
INSERT INTO configuracoes (chave, valor) 
SELECT 'horario_relatorios', '08:00'
WHERE NOT EXISTS (SELECT 1 FROM configuracoes WHERE chave = 'horario_relatorios');

INSERT INTO configuracoes (chave, valor) 
SELECT 'taxa_entrega', '5.00'
WHERE NOT EXISTS (SELECT 1 FROM configuracoes WHERE chave = 'taxa_entrega');

INSERT INTO configuracoes (chave, valor) 
SELECT 'permite_meia_pizza', 'true'
WHERE NOT EXISTS (SELECT 1 FROM configuracoes WHERE chave = 'permite_meia_pizza');

INSERT INTO configuracoes (chave, valor) 
SELECT 'tempo_preparo_pizza', '30'
WHERE NOT EXISTS (SELECT 1 FROM configuracoes WHERE chave = 'tempo_preparo_pizza');

INSERT INTO configuracoes (chave, valor) 
SELECT 'tempo_preparo_esfiha', '20'
WHERE NOT EXISTS (SELECT 1 FROM configuracoes WHERE chave = 'tempo_preparo_esfiha');

-- Entregadores
INSERT INTO entregadores (nome, telefone, ativo) 
SELECT 'João Silva', '(11) 99999-1111', true
WHERE NOT EXISTS (SELECT 1 FROM entregadores WHERE nome = 'João Silva');

INSERT INTO entregadores (nome, telefone, ativo) 
SELECT 'Maria Santos', '(11) 99999-2222', true
WHERE NOT EXISTS (SELECT 1 FROM entregadores WHERE nome = 'Maria Santos');

INSERT INTO entregadores (nome, telefone, ativo) 
SELECT 'Pedro Costa', '(11) 99999-3333', true
WHERE NOT EXISTS (SELECT 1 FROM entregadores WHERE nome = 'Pedro Costa');

-- 6. ATUALIZAR PRODUTOS EXISTENTES COM REGRAS DE NEGÓCIO
UPDATE products SET 
    permite_meia = true,
    categoria_display = 'Pizzas Tradicionais',
    ordem_exibicao = 1,
    tipo_produto = 'pizza'
WHERE categoria = 'tradicional' 
  AND (tipo_produto IS NULL OR tipo_produto != 'pizza')
  AND categoria_display IS NULL;

UPDATE products SET 
    permite_meia = true,
    categoria_display = 'Pizzas Premium',
    ordem_exibicao = 2,
    tipo_produto = 'pizza'
WHERE categoria = 'premium' 
  AND (tipo_produto IS NULL OR tipo_produto != 'pizza')
  AND categoria_display IS NULL;

UPDATE products SET 
    permite_meia = true,
    categoria_display = 'Pizzas Especiais',
    ordem_exibicao = 3,
    tipo_produto = 'pizza'
WHERE categoria = 'especial' 
  AND (tipo_produto IS NULL OR tipo_produto != 'pizza')
  AND categoria_display IS NULL;

-- 7. INSERIR PRODUTOS EXEMPLO COMPLETOS
INSERT INTO products (nome, categoria, descricao, preco, estoque, tipo_produto, categoria_display, permite_meia, ordem_exibicao, imagem) 
SELECT * FROM (VALUES
    ('Pizza Margherita', 'tradicional', 'Molho de tomate, queijo mussarela e manjericão', 25.90, 50, 'pizza', 'Pizzas Tradicionais', true, 1, 'https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg'),
    ('Pizza Portuguesa', 'tradicional', 'Presunto, ovos, cebola, azeitona e queijo', 28.90, 45, 'pizza', 'Pizzas Tradicionais', true, 1, 'https://images.pexels.com/photos/708587/pexels-photo-708587.jpeg'),
    ('Pizza Calabresa', 'tradicional', 'Calabresa, cebola e queijo mussarela', 27.90, 40, 'pizza', 'Pizzas Tradicionais', true, 1, 'https://images.pexels.com/photos/5805755/pexels-photo-5805755.jpeg'),
    
    ('Pizza Quatro Queijos', 'premium', 'Mussarela, catupiry, parmesão e gorgonzola', 32.90, 35, 'pizza', 'Pizzas Premium', true, 2, 'https://images.pexels.com/photos/4394612/pexels-photo-4394612.jpeg'),
    ('Pizza Frango com Catupiry', 'premium', 'Frango desfiado com catupiry cremoso', 31.90, 38, 'pizza', 'Pizzas Premium', true, 2, 'https://images.pexels.com/photos/4349738/pexels-photo-4349738.jpeg'),
    
    ('Pizza Camarão', 'especial', 'Camarão refogado com temperos especiais', 39.90, 25, 'pizza', 'Pizzas Especiais', true, 3, 'https://images.pexels.com/photos/4349738/pexels-photo-4349738.jpeg'),
    
    ('Esfiha Carne', 'tradicional', 'Carne temperada com cebola e especiarias', 2.50, 100, 'esfiha', 'Esfihas Tradicionais', false, 4, 'https://images.pexels.com/photos/4253320/pexels-photo-4253320.jpeg'),
    ('Esfiha Frango', 'tradicional', 'Frango desfiado temperado', 2.50, 100, 'esfiha', 'Esfihas Tradicionais', false, 4, 'https://images.pexels.com/photos/4253319/pexels-photo-4253319.jpeg'),
    ('Esfiha Queijo', 'tradicional', 'Queijo derretido cremoso', 2.50, 100, 'esfiha', 'Esfihas Tradicionais', false, 4, 'https://images.pexels.com/photos/4253318/pexels-photo-4253318.jpeg'),
    
    ('Esfiha Carne com Queijo', 'premium', 'Carne temperada coberta com queijo', 3.00, 80, 'esfiha', 'Esfihas Premium', false, 5, 'https://images.pexels.com/photos/4253321/pexels-photo-4253321.jpeg'),
    ('Esfiha Frango com Catupiry', 'premium', 'Frango com catupiry cremoso', 3.00, 80, 'esfiha', 'Esfihas Premium', false, 5, 'https://images.pexels.com/photos/4253322/pexels-photo-4253322.jpeg'),
    
    ('Esfiha Camarão', 'especial', 'Camarão refogado com temperos especiais', 4.00, 60, 'esfiha', 'Esfihas Especiais', false, 6, 'https://images.pexels.com/photos/4253323/pexels-photo-4253323.jpeg'),
    
    ('Coca-Cola 350ml', 'bebidas', 'Refrigerante de cola gelado', 4.50, 200, 'bebida', 'Bebidas', false, 7, 'https://images.pexels.com/photos/50593/coca-cola-cold-drink-soft-drink-coke-50593.jpeg'),
    ('Guaraná 350ml', 'bebidas', 'Refrigerante de guaraná', 4.00, 150, 'bebida', 'Bebidas', false, 7, 'https://images.pexels.com/photos/2693447/pexels-photo-2693447.jpeg'),
    ('Água Mineral 500ml', 'bebidas', 'Água mineral natural', 2.50, 300, 'bebida', 'Bebidas', false, 7, 'https://images.pexels.com/photos/416528/pexels-photo-416528.jpeg')
) AS v(nome, categoria, descricao, preco, estoque, tipo_produto, categoria_display, permite_meia, ordem_exibicao, imagem)
WHERE NOT EXISTS (SELECT 1 FROM products WHERE nome = v.nome);

-- 8. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_products_categoria_tipo ON products(categoria, tipo_produto);
CREATE INDEX IF NOT EXISTS idx_products_ordem ON products(ordem_exibicao);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created ON orders(created_at);

-- 9. VERIFICAÇÃO FINAL
SELECT 
    COUNT(*) as total_produtos,
    COUNT(*) FILTER (WHERE tipo_produto = 'pizza') as pizzas,
    COUNT(*) FILTER (WHERE tipo_produto = 'esfiha') as esfihas,
    COUNT(*) FILTER (WHERE tipo_produto = 'bebida') as bebidas,
    COUNT(DISTINCT categoria) as categorias_unicas,
    (SELECT COUNT(*) FROM bordas) as bordas,
    (SELECT COUNT(*) FROM adicionais) as adicionais,
    (SELECT COUNT(*) FROM configuracoes) as configuracoes
FROM products;

COMMIT;
