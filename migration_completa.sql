-- =====================================================
-- MIGRATION: SISTEMA COMPLETO DE CATEGORIAS E MONTAGEM
-- =====================================================

-- 1. ATUALIZAR TABELA DE PRODUTOS
ALTER TABLE products ADD COLUMN IF NOT EXISTS permite_meia BOOLEAN DEFAULT false;
ALTER TABLE products ADD COLUMN IF NOT EXISTS categoria_display VARCHAR(50);
ALTER TABLE products ADD COLUMN IF NOT EXISTS ordem_exibicao INTEGER DEFAULT 0;

-- 2. ATUALIZAR TABELA DE BORDAS
ALTER TABLE bordas ADD COLUMN IF NOT EXISTS categoria_gratuita TEXT[] DEFAULT '{}';
ALTER TABLE bordas DROP COLUMN IF EXISTS gratis_categoria;

-- 3. ATUALIZAR TABELA DE ADICIONAIS
ALTER TABLE adicionais ADD COLUMN IF NOT EXISTS preco_pizza DECIMAL(10,2) NOT NULL DEFAULT 0;
ALTER TABLE adicionais ADD COLUMN IF NOT EXISTS preco_esfiha DECIMAL(10,2) NOT NULL DEFAULT 0;
ALTER TABLE adicionais DROP COLUMN IF EXISTS preco;
ALTER TABLE adicionais DROP COLUMN IF EXISTS categoria_produto;

-- 4. ATUALIZAR TABELA ORDER_ITEMS
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS borda_nome VARCHAR(100);
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS borda_preco DECIMAL(10,2) DEFAULT 0;
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS adicionais_info JSONB DEFAULT '[]';

-- 5. LIMPAR E INSERIR BORDAS ATUALIZADAS
DELETE FROM bordas;
INSERT INTO bordas (id, nome, preco_adicional, categoria_gratuita) VALUES
(uuid_generate_v4(), 'Sem borda', 0.00, '{}'),
(uuid_generate_v4(), 'Requeijão', 2.00, '{"tradicional"}'),
(uuid_generate_v4(), 'Catupiry', 3.00, '{"premium"}'),
(uuid_generate_v4(), 'Cheddar', 3.00, '{"premium"}'),
(uuid_generate_v4(), 'Chocolate', 4.00, '{}');

-- 6. LIMPAR E INSERIR ADICIONAIS ATUALIZADOS
DELETE FROM adicionais;
INSERT INTO adicionais (id, nome, preco_pizza, preco_esfiha) VALUES
(uuid_generate_v4(), 'Bacon', 3.00, 2.00),
(uuid_generate_v4(), 'Cream Cheese', 2.50, 2.00),
(uuid_generate_v4(), 'Requeijão Extra', 2.00, 1.50),
(uuid_generate_v4(), 'Cheddar Extra', 2.50, 2.00),
(uuid_generate_v4(), 'Azeitona', 1.50, 1.00),
(uuid_generate_v4(), 'Champignon', 2.00, 1.50);

-- 7. ATUALIZAR PRODUTOS EXISTENTES COM NOVAS CATEGORIAS
UPDATE products SET 
    permite_meia = true,
    categoria_display = 'Pizzas Tradicionais',
    ordem_exibicao = 1
WHERE categoria = 'tradicional' AND tipo_produto = 'pizza';

UPDATE products SET 
    permite_meia = true,
    categoria_display = 'Pizzas Premium',
    ordem_exibicao = 2
WHERE categoria = 'premium' AND tipo_produto = 'pizza';

UPDATE products SET 
    permite_meia = true,
    categoria_display = 'Pizzas Especiais',
    ordem_exibicao = 3
WHERE categoria = 'especial' AND tipo_produto = 'pizza';

-- 8. INSERIR ESFIHAS SE NÃO EXISTIREM
INSERT INTO products (nome, categoria, descricao, preco, estoque, tipo_produto, categoria_display, permite_meia, ordem_exibicao, imagem) 
SELECT * FROM (VALUES
    ('Esfiha Carne', 'tradicional', 'Carne temperada com cebola e especiarias', 2.50, 100, 'esfiha', 'Esfihas Tradicionais', false, 4, 'https://images.pexels.com/photos/4253320/pexels-photo-4253320.jpeg'),
    ('Esfiha Frango', 'tradicional', 'Frango desfiado temperado', 2.50, 100, 'esfiha', 'Esfihas Tradicionais', false, 4, 'https://images.pexels.com/photos/4253319/pexels-photo-4253319.jpeg'),
    ('Esfiha Queijo', 'tradicional', 'Queijo derretido cremoso', 2.50, 100, 'esfiha', 'Esfihas Tradicionais', false, 4, 'https://images.pexels.com/photos/4253318/pexels-photo-4253318.jpeg'),
    
    ('Esfiha Carne com Queijo', 'premium', 'Carne temperada coberta com queijo derretido', 3.00, 80, 'esfiha', 'Esfihas Premium', false, 5, 'https://images.pexels.com/photos/4253321/pexels-photo-4253321.jpeg'),
    ('Esfiha Frango com Catupiry', 'premium', 'Frango desfiado com catupiry cremoso', 3.00, 80, 'esfiha', 'Esfihas Premium', false, 5, 'https://images.pexels.com/photos/4253322/pexels-photo-4253322.jpeg'),
    ('Esfiha Calabresa', 'premium', 'Calabresa temperada com cebola', 3.00, 80, 'esfiha', 'Esfihas Premium', false, 5, 'https://images.pexels.com/photos/4253325/pexels-photo-4253325.jpeg'),
    
    ('Esfiha Camarão', 'especial', 'Camarão refogado com temperos especiais', 4.00, 60, 'esfiha', 'Esfihas Especiais', false, 6, 'https://images.pexels.com/photos/4253323/pexels-photo-4253323.jpeg'),
    ('Esfiha Salmão', 'especial', 'Salmão grelhado com cream cheese', 4.50, 50, 'esfiha', 'Esfihas Especiais', false, 6, 'https://images.pexels.com/photos/4253324/pexels-photo-4253324.jpeg'),
    ('Esfiha Camarão com Catupiry', 'especial', 'Camarão refogado com catupiry premium', 4.50, 50, 'esfiha', 'Esfihas Especiais', false, 6, 'https://images.pexels.com/photos/4253326/pexels-photo-4253326.jpeg')
) AS v(nome, categoria, descricao, preco, estoque, tipo_produto, categoria_display, permite_meia, ordem_exibicao, imagem)
WHERE NOT EXISTS (SELECT 1 FROM products WHERE nome = v.nome);

-- 9. ATUALIZAR BEBIDAS
UPDATE products SET 
    categoria_display = 'Bebidas',
    ordem_exibicao = 7
WHERE tipo_produto = 'bebida';

-- 10. CRIAR ÍNDICES PARA PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_products_categoria_tipo ON products(categoria, tipo_produto);
CREATE INDEX IF NOT EXISTS idx_products_ordem_exibicao ON products(ordem_exibicao);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);

-- 11. ATUALIZAR CONFIGURAÇÕES
UPDATE configuracoes SET valor = '08:00' WHERE chave = 'horario_relatorios';
UPDATE configuracoes SET valor = '5.00' WHERE chave = 'taxa_entrega';

INSERT INTO configuracoes (chave, valor) VALUES 
('permite_meia_pizza', 'true'),
('tempo_preparo_pizza', '30'),
('tempo_preparo_esfiha', '20')
ON CONFLICT (chave) DO UPDATE SET valor = EXCLUDED.valor;

-- 12. VERIFICAÇÃO FINAL
SELECT 
    COUNT(*) as total_produtos,
    COUNT(*) FILTER (WHERE tipo_produto = 'pizza') as pizzas,
    COUNT(*) FILTER (WHERE tipo_produto = 'esfiha') as esfihas,
    COUNT(*) FILTER (WHERE tipo_produto = 'bebida') as bebidas
FROM products;
