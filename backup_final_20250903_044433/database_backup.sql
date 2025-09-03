--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: order_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.order_status AS ENUM (
    'nao_iniciado',
    'em_andamento',
    'finalizado'
);


ALTER TYPE public.order_status OWNER TO postgres;

--
-- Name: product_category; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.product_category AS ENUM (
    'tradicional',
    'premium',
    'especial',
    'refrigerantes',
    'esfihas_tradicional',
    'esfihas_premium',
    'esfihas_especial'
);


ALTER TYPE public.product_category OWNER TO postgres;

--
-- Name: user_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_type AS ENUM (
    'cliente',
    'proprietario'
);


ALTER TYPE public.user_type OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: adicionais; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adicionais (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nome character varying(100) NOT NULL,
    preco_pizza numeric(10,2) NOT NULL,
    preco_esfiha numeric(10,2) NOT NULL,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.adicionais OWNER TO postgres;

--
-- Name: bordas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bordas (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nome character varying(100) NOT NULL,
    preco_adicional numeric(10,2) DEFAULT 0,
    created_at timestamp without time zone DEFAULT now(),
    categoria_gratuita text[] DEFAULT '{}'::text[]
);


ALTER TABLE public.bordas OWNER TO postgres;

--
-- Name: configuracoes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.configuracoes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    chave character varying(100) NOT NULL,
    valor text NOT NULL,
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.configuracoes OWNER TO postgres;

--
-- Name: entregadores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.entregadores (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nome character varying(255) NOT NULL,
    telefone character varying(20),
    ativo boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.entregadores OWNER TO postgres;

--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    order_id uuid,
    product_id uuid,
    product_name character varying(255) NOT NULL,
    quantidade integer NOT NULL,
    preco_unit numeric(10,2) NOT NULL,
    observacao text,
    formato character varying(20) DEFAULT 'inteira'::character varying,
    sabor_1 text,
    sabor_2 text,
    borda_id uuid,
    borda_nome character varying(100),
    borda_preco numeric(10,2) DEFAULT 0,
    adicionais jsonb DEFAULT '[]'::jsonb,
    created_at timestamp without time zone DEFAULT now(),
    adicionais_info jsonb DEFAULT '[]'::jsonb
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    numero_pedido integer NOT NULL,
    user_id uuid,
    status public.order_status DEFAULT 'nao_iniciado'::public.order_status,
    total numeric(10,2) NOT NULL,
    valor_frete numeric(10,2) DEFAULT 0,
    observacao text,
    observacao_admin text,
    entregador character varying(255),
    endereco_entrega text,
    telefone_contato character varying(20),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: orders_numero_pedido_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.orders ALTER COLUMN numero_pedido ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.orders_numero_pedido_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nome character varying(255) NOT NULL,
    categoria public.product_category NOT NULL,
    descricao text,
    preco numeric(10,2) NOT NULL,
    estoque integer DEFAULT 0,
    imagem text,
    tipo_produto character varying(20) DEFAULT 'pizza'::character varying,
    ativo boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    permite_meia boolean DEFAULT false,
    categoria_display character varying(50),
    ordem_exibicao integer DEFAULT 0
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    nome character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    senha character varying(255) NOT NULL,
    tipo public.user_type DEFAULT 'cliente'::public.user_type,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: adicionais; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adicionais (id, nome, preco_pizza, preco_esfiha, created_at) FROM stdin;
cd055e25-0d95-492c-acaf-e52e7fb96ff9	Bacon	3.00	2.00	2025-09-02 21:30:20.948617
ae62566d-90a5-42e8-82da-fabb07e02a46	Cream Cheese	2.50	2.00	2025-09-02 21:30:20.948617
3568d0be-004c-4bea-87bc-d22ff21b6ec3	Requeijão Extra	2.00	1.50	2025-09-02 21:30:20.948617
be1d9c32-e7ad-4c2e-84e6-30f864a9b5d9	Cheddar Extra	2.50	2.00	2025-09-02 21:30:20.948617
c675d82c-fa50-4497-9c1e-03bec5c183ce	Azeitona	1.50	1.00	2025-09-02 21:30:20.948617
9bf710be-3ddf-465e-9181-3434444508d3	Champignon	2.00	1.50	2025-09-02 21:30:20.948617
\.


--
-- Data for Name: bordas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bordas (id, nome, preco_adicional, created_at, categoria_gratuita) FROM stdin;
b1a8d111-4f20-479b-b89d-a4dbe9b17c90	Sem borda	0.00	2025-09-01 14:41:05.66039	{}
da083f8a-df0f-49a3-ba78-96e3b00c41cc	Requeijão	2.00	2025-09-01 14:41:05.66039	{}
fa3536d9-1149-4e7b-85b0-061343b8e240	Catupiry	3.00	2025-09-01 14:41:05.66039	{}
dd817f2f-e0a0-4ef5-b3ab-869faf85b22d	Cheddar	3.00	2025-09-01 14:41:05.66039	{}
0a865fe0-ad55-4fd1-9e46-a1b79bc74f3a	Chocolate	4.00	2025-09-01 14:41:05.66039	{}
c706b1a5-57aa-412b-9b56-5eb30f8f7fb8	Sem borda	0.00	2025-09-02 21:30:20.932823	{}
7c68f2b3-f97d-4229-acfb-359a78f3cea1	Requeijão	2.00	2025-09-02 21:30:20.932823	{tradicional}
f7e8b19c-21a9-4d2b-93c6-689e3c29daf0	Catupiry	3.00	2025-09-02 21:30:20.932823	{premium}
4c3095b7-3ca1-4737-9f3a-ff7c879ac65a	Cheddar	3.00	2025-09-02 21:30:20.932823	{premium}
89c29cef-4446-472b-8165-7701bb3e863a	Chocolate	4.00	2025-09-02 21:30:20.932823	{}
\.


--
-- Data for Name: configuracoes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.configuracoes (id, chave, valor, updated_at) FROM stdin;
beedf5db-71de-409e-8095-482ed8da6329	telefone_pizzaria	(11) 99999-9999	2025-09-01 14:41:05.66826
92ea5d0a-6b02-4f2e-827b-86a0e3445b16	endereco_pizzaria	Rua da Pizza, 123 - Centro	2025-09-01 14:41:05.66826
8083ee85-7cac-4004-87ee-ca67a9f6228d	horario_relatorios	08:00	2025-09-01 14:41:05.66826
e725e82c-8236-4d02-87fa-7d700f5a9ebb	taxa_entrega	5.00	2025-09-01 14:41:05.66826
a1f32e50-039b-474d-824f-6fc500d84c87	permite_meia_pizza	true	2025-09-02 21:30:20.999344
c3d7a865-aa08-4423-8099-e50fa92dd9c6	tempo_preparo_pizza	30	2025-09-01 14:41:05.66826
b54e7690-208b-4f48-a550-83a697e1b27b	tempo_preparo_esfiha	20	2025-09-01 14:41:05.66826
\.


--
-- Data for Name: entregadores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.entregadores (id, nome, telefone, ativo, created_at) FROM stdin;
98b3b542-6a84-4a15-a5fd-0ef396bc0dca	João Silva	(11) 99999-1111	t	2025-09-01 14:41:05.669591
ee1f2709-ea49-43d9-9878-a2fc89a386a3	Maria Santos	(11) 99999-2222	t	2025-09-01 14:41:05.669591
ece17aea-63fa-41e6-ad1f-dd52b07a1874	Pedro Costa	(11) 99999-3333	t	2025-09-01 14:41:05.669591
246a2fea-bc3e-4aeb-bf34-cca4d5a56d22	Ana Oliveira	(11) 99999-4444	t	2025-09-01 14:41:05.669591
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (id, order_id, product_id, product_name, quantidade, preco_unit, observacao, formato, sabor_1, sabor_2, borda_id, borda_nome, borda_preco, adicionais, created_at, adicionais_info) FROM stdin;
09cbd174-a9e2-4e74-922c-d7a5b27fd8bf	c4062c79-73a8-4ba8-b0d7-3d22321cee7a	78ceab02-56d9-4b90-9e31-d0c2fe7f114c	Margherita	2	35.00	\N	inteira	Margherita	\N	da083f8a-df0f-49a3-ba78-96e3b00c41cc	Requeijão	0.00	[{"nome": "Bacon", "tipo": "inteira", "preco": 3.00}]	2025-09-01 14:41:05.670886	[]
a91d3c5c-a8c5-44a1-a939-64fd18a65462	c4062c79-73a8-4ba8-b0d7-3d22321cee7a	723e0185-5989-4a12-9116-ddd38d237f18	Carne	4	2.50	\N	inteira	Carne	\N	\N	\N	0.00	[]	2025-09-01 14:41:05.670886	[]
6adab9ab-fca8-40a2-9ebc-af88d6a3e7c6	0b45bd3d-016e-424d-9947-f371e584d812	78ceab02-56d9-4b90-9e31-d0c2fe7f114c	Meia a Meia	1	40.00	\N	meia	Margherita	Calabresa	\N	\N	0.00	[]	2025-09-01 14:41:05.670886	[]
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, numero_pedido, user_id, status, total, valor_frete, observacao, observacao_admin, entregador, endereco_entrega, telefone_contato, created_at, updated_at) FROM stdin;
c4062c79-73a8-4ba8-b0d7-3d22321cee7a	1	45a947d2-df27-40b9-895c-10a80206510d	em_andamento	87.50	5.00	Entregar no portão da frente	\N	João Silva	Rua das Flores, 456 - Apto 203	(11) 98888-7777	2025-09-01 14:41:05.670886	2025-09-01 14:41:05.670886
0b45bd3d-016e-424d-9947-f371e584d812	2	45a947d2-df27-40b9-895c-10a80206510d	finalizado	45.00	0.00	Retirada no balcão	\N	\N		(11) 98888-7777	2025-09-01 14:41:05.670886	2025-09-01 14:41:05.670886
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, nome, categoria, descricao, preco, estoque, imagem, tipo_produto, ativo, created_at, updated_at, permite_meia, categoria_display, ordem_exibicao) FROM stdin;
723e0185-5989-4a12-9116-ddd38d237f18	Carne	tradicional	Carne temperada com cebola e especiarias	2.50	100	https://images.pexels.com/photos/4253320/pexels-photo-4253320.jpeg?auto=compress&cs=tinysrgb&w=400	esfiha	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	f	\N	0
b1a97da8-97b5-403e-aab2-84772cc708b1	Frango	tradicional	Frango desfiado temperado	2.50	100	https://images.pexels.com/photos/4253319/pexels-photo-4253319.jpeg?auto=compress&cs=tinysrgb&w=400	esfiha	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	f	\N	0
987ff1a7-c9f3-43f1-846a-6349fc577626	Queijo	tradicional	Queijo mussarela derretido	2.50	100	https://images.pexels.com/photos/4253318/pexels-photo-4253318.jpeg?auto=compress&cs=tinysrgb&w=400	esfiha	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	f	\N	0
cf4ff9c6-adaf-46a6-ab65-73795cda744b	Carne com Queijo	premium	Carne temperada coberta com queijo derretido	3.00	80	https://images.pexels.com/photos/4253321/pexels-photo-4253321.jpeg?auto=compress&cs=tinysrgb&w=400	esfiha	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	f	\N	0
34d4156c-bdbe-4b04-97da-7357e8d1b22c	Frango com Catupiry	premium	Frango desfiado com catupiry cremoso	3.00	80	https://images.pexels.com/photos/4253322/pexels-photo-4253322.jpeg?auto=compress&cs=tinysrgb&w=400	esfiha	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	f	\N	0
08cab6e2-7276-4bf3-9955-0e53ca2c10d7	Bacon com Queijo	premium	Bacon crocante com queijo derretido	3.50	60	https://images.pexels.com/photos/4253323/pexels-photo-4253323.jpeg?auto=compress&cs=tinysrgb&w=400	esfiha	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	f	\N	0
8f89e3a3-e41f-44b1-b86c-af3e9e83573e	Camarão	especial	Camarão refogado com temperos especiais	4.00	40	https://images.pexels.com/photos/4253324/pexels-photo-4253324.jpeg?auto=compress&cs=tinysrgb&w=400	esfiha	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	f	\N	0
d3d35311-e867-4445-b2fa-9d52b6558060	Salmão	especial	Salmão grelhado com cream cheese	4.50	30	https://images.pexels.com/photos/4253325/pexels-photo-4253325.jpeg?auto=compress&cs=tinysrgb&w=400	esfiha	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	f	\N	0
e08f8a6e-18d0-4329-8cb8-0c05d76db001	Camarão com Catupiry	especial	Camarão com catupiry e temperos especiais	4.50	25	https://images.pexels.com/photos/4253326/pexels-photo-4253326.jpeg?auto=compress&cs=tinysrgb&w=400	esfiha	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	f	\N	0
78ceab02-56d9-4b90-9e31-d0c2fe7f114c	Margherita	tradicional	Molho de tomate, mussarela, manjericão	35.00	50	https://images.pexels.com/photos/315755/pexels-photo-315755.jpeg?auto=compress&cs=tinysrgb&w=400	pizza	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	t	Pizzas Tradicionais	1
b7037005-5446-4b6e-aa1b-38e5413a1635	Calabresa	tradicional	Molho de tomate, mussarela, calabresa, cebola	35.00	50	https://images.pexels.com/photos/2619967/pexels-photo-2619967.jpeg?auto=compress&cs=tinysrgb&w=400	pizza	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	t	Pizzas Tradicionais	1
b28bdd8a-ef8e-4657-a345-ae68677bffb9	Portuguesa	tradicional	Molho de tomate, mussarela, presunto, ovos, cebola	35.00	50	https://images.pexels.com/photos/1049626/pexels-photo-1049626.jpeg?auto=compress&cs=tinysrgb&w=400	pizza	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	t	Pizzas Tradicionais	1
57057974-1252-48e3-a731-dd743b91037d	Frango Catupiry	premium	Molho de tomate, mussarela, frango desfiado, catupiry	40.00	30	https://images.pexels.com/photos/4394612/pexels-photo-4394612.jpeg?auto=compress&cs=tinysrgb&w=400	pizza	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	t	Pizzas Premium	2
7a15f7f4-1bb9-46de-98d2-cfe203893044	Bacon	premium	Molho de tomate, mussarela, bacon crocante	40.00	30	https://images.pexels.com/photos/1049620/pexels-photo-1049620.jpeg?auto=compress&cs=tinysrgb&w=400	pizza	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	t	Pizzas Premium	2
a12a9857-c083-4120-beca-666a556b9a9c	Pepperoni	premium	Molho de tomate, mussarela, pepperoni	42.00	25	https://images.pexels.com/photos/708587/pexels-photo-708587.jpeg?auto=compress&cs=tinysrgb&w=400	pizza	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	t	Pizzas Premium	2
7f9fd7d8-08dc-45ed-ac03-b5dfde3cdf80	Quatro Queijos	especial	Mussarela, parmesão, gorgonzola, catupiry	45.00	20	https://images.pexels.com/photos/4109111/pexels-photo-4109111.jpeg?auto=compress&cs=tinysrgb&w=400	pizza	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	t	Pizzas Especiais	3
cd9e859a-2d81-4589-ad9e-218809c7a4f3	Camarão	especial	Molho branco, mussarela, camarão, catupiry	50.00	15	https://images.pexels.com/photos/3915906/pexels-photo-3915906.jpeg?auto=compress&cs=tinysrgb&w=400	pizza	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	t	Pizzas Especiais	3
47cf16a0-78be-4af9-9c5c-6ab352aac95d	Salmão	especial	Molho branco, mussarela, salmão, cream cheese	52.00	10	https://images.pexels.com/photos/1049620/pexels-photo-1049620.jpeg?auto=compress&cs=tinysrgb&w=400	pizza	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	t	Pizzas Especiais	3
9ecec169-c044-4cba-997f-96203b288b72	Coca-Cola 350ml	refrigerantes	Refrigerante de cola gelado	2.50	100	https://images.pexels.com/photos/50593/coca-cola-cold-drink-soft-drink-coke-50593.jpeg?auto=compress&cs=tinysrgb&w=400	bebida	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	f	Bebidas	7
a0b73581-9702-479a-85cd-7d21bc597696	Guaraná Antarctica 350ml	refrigerantes	Refrigerante de guaraná gelado	2.50	80	https://images.pexels.com/photos/1292294/pexels-photo-1292294.jpeg?auto=compress&cs=tinysrgb&w=400	bebida	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	f	Bebidas	7
8ad0d1e8-005e-4030-b641-80e04e9bf28e	Sprite 350ml	refrigerantes	Refrigerante de limão gelado	2.50	60	https://images.pexels.com/photos/1292295/pexels-photo-1292295.jpeg?auto=compress&cs=tinysrgb&w=400	bebida	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	f	Bebidas	7
22f7be78-1349-46ad-b791-03f189014503	Água Mineral 500ml	refrigerantes	Água mineral sem gás	2.00	120	https://images.pexels.com/photos/1292296/pexels-photo-1292296.jpeg?auto=compress&cs=tinysrgb&w=400	bebida	t	2025-09-01 14:41:05.66575	2025-09-01 14:41:05.66575	f	Bebidas	7
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, nome, email, senha, tipo, created_at, updated_at) FROM stdin;
45a947d2-df27-40b9-895c-10a80206510d	Cliente Teste	cliente@teste.com	$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi	cliente	2025-09-01 14:41:05.640873	2025-09-01 14:41:05.640873
0f07f560-1a38-4620-83eb-5e15ce49c1a5	Rodrigo	rodrigo@pizzaria.com	$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi	proprietario	2025-09-01 14:41:05.640873	2025-09-01 14:41:05.640873
\.


--
-- Name: orders_numero_pedido_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.orders_numero_pedido_seq', 2, true);


--
-- Name: adicionais adicionais_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adicionais
    ADD CONSTRAINT adicionais_pkey PRIMARY KEY (id);


--
-- Name: bordas bordas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bordas
    ADD CONSTRAINT bordas_pkey PRIMARY KEY (id);


--
-- Name: configuracoes configuracoes_chave_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.configuracoes
    ADD CONSTRAINT configuracoes_chave_key UNIQUE (chave);


--
-- Name: configuracoes configuracoes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.configuracoes
    ADD CONSTRAINT configuracoes_pkey PRIMARY KEY (id);


--
-- Name: entregadores entregadores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.entregadores
    ADD CONSTRAINT entregadores_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_order_items_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_items_order_id ON public.order_items USING btree (order_id);


--
-- Name: idx_products_categoria_tipo; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_categoria_tipo ON public.products USING btree (categoria, tipo_produto);


--
-- Name: idx_products_ordem_exibicao; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_ordem_exibicao ON public.products USING btree (ordem_exibicao);


--
-- Name: order_items order_items_borda_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_borda_id_fkey FOREIGN KEY (borda_id) REFERENCES public.bordas(id);


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: order_items order_items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: orders orders_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO app_user;


--
-- Name: TABLE adicionais; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.adicionais TO app_user;


--
-- Name: TABLE bordas; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.bordas TO app_user;


--
-- Name: TABLE configuracoes; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.configuracoes TO app_user;


--
-- Name: TABLE entregadores; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.entregadores TO app_user;


--
-- Name: TABLE order_items; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.order_items TO app_user;


--
-- Name: TABLE orders; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.orders TO app_user;


--
-- Name: SEQUENCE orders_numero_pedido_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.orders_numero_pedido_seq TO app_user;


--
-- Name: TABLE products; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.products TO app_user;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.users TO app_user;


--
-- PostgreSQL database dump complete
--

