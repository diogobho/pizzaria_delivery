const API_BASE = window.location.origin;

document.addEventListener('DOMContentLoaded', function() {
    const token = localStorage.getItem('token');
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    
    if (!token) {
        window.location.href = '/login';
        return;
    }
    
    if (user.nome) {
        document.getElementById('userName').textContent = user.nome;
    }
    
    verificarToken();
});

async function verificarToken() {
    try {
        const response = await fetch(`${API_BASE}/api/auth/me`, {
            headers: {
                'Authorization': `Bearer ${localStorage.getItem('token')}`
            }
        });
        
        if (!response.ok) {
            throw new Error('Token inválido');
        }
        
        const data = await response.json();
        localStorage.setItem('user', JSON.stringify(data.user));
        document.getElementById('userName').textContent = data.user.nome;
        
    } catch (error) {
        console.error('Erro ao verificar token:', error);
        logout();
    }
}

function acessarCardapio() {
    window.location.href = '/cardapio';
}

function acessarCarrinho() {
    window.location.href = '/carrinho';
}

function acessarPedidos() {
    window.location.href = '/pedidos';
}

function logout() {
    if (confirm('Tem certeza que deseja sair?')) {
        localStorage.removeItem('user');
        localStorage.removeItem('token');
        localStorage.removeItem('cart');
        window.location.href = '/';
    }
}

async function testarConexao() {
    try {
        const response = await fetch(`${API_BASE}/health`);
        const data = await response.json();
        console.log('✅ API Status:', data);
    } catch (error) {
        console.error('❌ Erro na conexão:', error);
    }
}

testarConexao();
