import express from 'express';
import bcrypt from 'bcryptjs';
import { body, validationResult } from 'express-validator';
import { pool } from '../config/database.js';
import { authenticateToken, requireAdmin } from '../middleware/auth.js';

const router = express.Router();

// Validações
const validateCadastro = [
    body('nome').isLength({ min: 2 }).withMessage('Nome deve ter pelo menos 2 caracteres'),
    body('email').isEmail().withMessage('Email inválido'),
    body('senha').isLength({ min: 6 }).withMessage('Senha deve ter pelo menos 6 caracteres'),
    body('telefone').notEmpty().withMessage('Telefone obrigatório'),
    body('endereco').isLength({ min: 10 }).withMessage('Endereço deve ser mais detalhado')
];

// Cadastro público
router.post('/cliente', validateCadastro, async (req, res) => {
    try {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ 
                error: 'Dados inválidos', 
                details: errors.array() 
            });
        }

        const { nome, email, senha, telefone, endereco, cep, cidade, estado, data_nascimento } = req.body;

        // Verificar email
        const existing = await pool.query('SELECT id FROM users WHERE email = $1', [email]);
        if (existing.rows.length > 0) {
            return res.status(400).json({ error: 'Email já cadastrado' });
        }

        // Hash senha
        const hashedPassword = await bcrypt.hash(senha, 10);

        // Inserir cadastro pendente
        await pool.query(`
            INSERT INTO cliente_cadastros (nome, email, senha, telefone, endereco, cep, cidade, estado, data_nascimento)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        `, [nome, email, hashedPassword, telefone, endereco, cep, cidade, estado, data_nascimento]);

        res.status(201).json({
            message: 'Cadastro enviado! Aguarde aprovação do administrador.'
        });
    } catch (error) {
        console.error('Erro no cadastro:', error);
        res.status(500).json({ error: 'Erro interno' });
    }
});

// Listar cadastros pendentes (admin)
router.get('/pendentes', authenticateToken, requireAdmin, async (req, res) => {
    try {
        const result = await pool.query(
            'SELECT * FROM cliente_cadastros WHERE status = $1 ORDER BY created_at DESC',
            ['pendente']
        );
        res.json(result.rows);
    } catch (error) {
        res.status(500).json({ error: 'Erro ao buscar cadastros' });
    }
});

// Aprovar cadastro (admin)
router.post('/aprovar/:id', authenticateToken, requireAdmin, async (req, res) => {
    const client = await pool.connect();
    try {
        await client.query('BEGIN');
        
        const result = await client.query(
            'SELECT * FROM cliente_cadastros WHERE id = $1 AND status = $2',
            [req.params.id, 'pendente']
        );
        
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Cadastro não encontrado' });
        }
        
        const cadastro = result.rows[0];
        
        // Criar usuário
        await client.query(`
            INSERT INTO users (nome, email, senha, telefone, endereco, cep, cidade, estado, data_nascimento, tipo)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, 'cliente')
        `, [
            cadastro.nome, cadastro.email, cadastro.senha, cadastro.telefone,
            cadastro.endereco, cadastro.cep, cadastro.cidade, cadastro.estado,
            cadastro.data_nascimento
        ]);
        
        // Marcar como aprovado
        await client.query('UPDATE cliente_cadastros SET status = $1 WHERE id = $2', ['aprovado', req.params.id]);
        
        await client.query('COMMIT');
        res.json({ message: 'Cadastro aprovado!' });
    } catch (error) {
        await client.query('ROLLBACK');
        res.status(500).json({ error: 'Erro ao aprovar cadastro' });
    } finally {
        client.release();
    }
});

export default router;
