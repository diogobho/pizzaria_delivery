-- Limpar produtos existentes (se houver)
DELETE FROM products;

-- PIZZAS TRADICIONAIS
INSERT INTO products (nome, categoria, descricao, preco, estoque, tipo_produto, imagem) VALUES
('Pizza Margherita', 'tradicional', 'Molho de tomate, mussarela, manjericão', 3.50, 50, 'pizza', 'https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg?auto=compress&cs=tinysrgb&w=400'),
('Pizza Calabresa', 'tradicional', 'Molho de tomate, mussarela, calabresa, cebola', 3.50, 45, 'pizza', 'https://images.pexels.com/photos/2619967/pexels-photo-2619967.jpeg?auto=compress&cs=tinysrgb&w=400'),
('Pizza Portuguesa', 'tradicional', 'Molho de tomate, mussarela, presunto, ovos, cebola', 3.50, 40, 'pizza', 'https://images.pexels.com/photos/1049626/pexels-photo-1049626.jpeg?auto=compress&cs=tinysrgb&w=400');

-- PIZZAS PREMIUM
INSERT INTO products (nome, categoria, descricao, preco, estoque, tipo_produto, imagem) VALUES
('Pizza Frango Catupiry', 'premium', 'Molho de tomate, mussarela, frango desfiado, catupiry', 4.00, 35, 'pizza', 'https://images.pexels.com/photos/4394612/pexels-photo-4394612.jpeg?auto=compress&cs=tinysrgb&w=400'),
('Pizza Bacon', 'premium', 'Molho de tomate, mussarela, bacon crocante', 4.00, 30, 'pizza', 'https://images.pexels.com/photos/1049620/pexels-photo-1049620.jpeg?auto=compress&cs=tinysrgb&w=400');

-- PIZZAS ESPECIAIS
INSERT INTO products (nome, categoria, descricao, preco, estoque, tipo_produto, imagem) VALUES
('Pizza Quatro Queijos', 'especial', 'Mussarela, parmesão, gorgonzola, catupiry', 4.50, 25, 'pizza', 'https://images.pexels.com/photos/4109111/pexels-photo-4109111.jpeg?auto=compress&cs=tinysrgb&w=400'),
('Pizza Camarão', 'especial', 'Molho branco, mussarela, camarão, catupiry', 4.50, 20, 'pizza', 'https://images.pexels.com/photos/3915906/pexels-photo-3915906.jpeg?auto=compress&cs=tinysrgb&w=400');

-- ESFIHAS TRADICIONAIS
INSERT INTO products (nome, categoria, descricao, preco, estoque, tipo_produto, imagem) VALUES
('Esfiha Carne', 'esfihas_tradicional', 'Carne temperada com cebola e especiarias', 2.50, 80, 'esfiha', 'https://images.pexels.com/photos/4253320/pexels-photo-4253320.jpeg?auto=compress&cs=tinysrgb&w=400'),
('Esfiha Frango', 'esfihas_tradicional', 'Frango desfiado temperado', 2.50, 75, 'esfiha', 'https://images.pexels.com/photos/4253319/pexels-photo-4253319.jpeg?auto=compress&cs=tinysrgb&w=400');

-- ESFIHAS PREMIUM
INSERT INTO products (nome, categoria, descricao, preco, estoque, tipo_produto, imagem) VALUES
('Esfiha Carne com Queijo', 'esfihas_premium', 'Carne temperada coberta com queijo derretido', 3.00, 60, 'esfiha', 'https://images.pexels.com/photos/4253321/pexels-photo-4253321.jpeg?auto=compress&cs=tinysrgb&w=400'),
('Esfiha Frango com Catupiry', 'esfihas_premium', 'Frango desfiado com catupiry cremoso', 3.00, 55, 'esfiha', 'https://images.pexels.com/photos/4253322/pexels-photo-4253322.jpeg?auto=compress&cs=tinysrgb&w=400');

-- ESFIHAS ESPECIAIS
INSERT INTO products (nome, categoria, descricao, preco, estoque, tipo_produto, imagem) VALUES
('Esfiha Camarão', 'esfihas_especial', 'Camarão refogado com temperos especiais', 4.00, 40, 'esfiha', 'https://images.pexels.com/photos/4253323/pexels-photo-4253323.jpeg?auto=compress&cs=tinysrgb&w=400'),
('Esfiha Salmão', 'esfihas_especial', 'Salmão grelhado com cream cheese', 4.50, 30, 'esfiha', 'https://images.pexels.com/photos/4253324/pexels-photo-4253324.jpeg?auto=compress&cs=tinysrgb&w=400');

-- REFRIGERANTES
INSERT INTO products (nome, categoria, descricao, preco, estoque, tipo_produto, imagem) VALUES
('Coca-Cola 350ml', 'refrigerantes', 'Refrigerante de cola gelado', 2.50, 100, 'bebida', 'https://images.pexels.com/photos/50593/coca-cola-cold-drink-soft-drink-coke-50593.jpeg?auto=compress&cs=tinysrgb&w=400'),
('Guaraná Antarctica 350ml', 'refrigerantes', 'Refrigerante de guaraná gelado', 2.50, 80, 'bebida', 'https://images.pexels.com/photos/1292294/pexels-photo-1292294.jpeg?auto=compress&cs=tinysrgb&w=400');
