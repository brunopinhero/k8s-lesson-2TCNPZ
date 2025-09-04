#!/bin/bash

# =============================================================================
# Script de Instalação Linux - AWS EC2
# Para uso em aula - Ubuntu 22.04 LTS
# =============================================================================

set -e  # Para o script se houver erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log com cores
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Verificar se é Ubuntu
if [[ ! -f /etc/lsb-release ]]; then
    error "Este script foi feito para Ubuntu!"
    exit 1
fi

header "INICIANDO CONFIGURAÇÃO DO SERVIDOR LINUX"

# 1. ATUALIZAÇÃO DO SISTEMA
header "1. ATUALIZANDO O SISTEMA"
log "Atualizando lista de pacotes..."
sudo apt update

log "Fazendo upgrade dos pacotes instalados..."
sudo apt upgrade -y

# 2. INSTALAÇÃO DE PACOTES BÁSICOS
header "2. INSTALANDO PACOTES BÁSICOS"
log "Instalando ferramentas essenciais..."
sudo apt install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    tree \
    unzip \
    zip \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# 3. CONFIGURAÇÃO DO GIT
header "3. CONFIGURAÇÃO BÁSICA DO GIT"
read -p "Digite seu nome para o Git: " git_name
read -p "Digite seu email para o Git: " git_email

git config --global user.name "$git_name"
git config --global user.email "$git_email"
git config --global init.defaultBranch main

log "Git configurado para $git_name ($git_email)"

# 4. INSTALAÇÃO DO NODE.JS
header "4. INSTALANDO NODE.JS (LTS)"
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

log "Node.js $(node --version) instalado"
log "NPM $(npm --version) instalado"

# 5. INSTALAÇÃO DO DOCKER
header "5. INSTALANDO DOCKER"
# Adicionar chave GPG do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Adicionar repositório do Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

log "Docker instalado! (Faça logout/login para usar sem sudo)"

# 6. INSTALAÇÃO DO DOCKER COMPOSE
header "6. INSTALANDO DOCKER COMPOSE"
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

log "Docker Compose ${DOCKER_COMPOSE_VERSION} instalado"

# 7. CONFIGURAÇÃO DO FIREWALL
header "7. CONFIGURANDO FIREWALL BÁSICO"
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

log "Firewall configurado (SSH, HTTP, HTTPS permitidos)"

# 8. MELHORIAS NO BASH
header "8. CONFIGURANDO BASH"
cat >> ~/.bashrc << 'EOF'

# ============= CONFIGURAÇÕES CUSTOMIZADAS =============
# Aliases úteis
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias ports='netstat -tulanp'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline'

# Docker aliases
alias dps='docker ps'
alias dimg='docker images'
alias dlog='docker logs'

# Função para mostrar informações do sistema
sysinfo() {
    echo "=== INFORMAÇÕES DO SISTEMA ==="
    echo "Hostname: $(hostname)"
    echo "OS: $(lsb_release -d | cut -f2)"
    echo "Kernel: $(uname -r)"
    echo "Uptime: $(uptime -p)"
    echo "CPU: $(nproc) cores"
    echo "RAM: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo "Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
    echo "=============================="
}
EOF

# 9. CONFIGURAÇÃO BÁSICA DO VIM
header "9. CONFIGURANDO VIM"
cat > ~/.vimrc << 'EOF'
" Configuração básica do Vim
set number
set autoindent
set tabstop=4
set shiftwidth=4
set expandtab
set hlsearch
set incsearch
syntax on
colorscheme default

" Mapear teclas úteis
nnoremap <C-s> :w<CR>
inoremap <C-s> <Esc>:w<CR>a
EOF

# 10. VERIFICAÇÃO FINAL
header "10. VERIFICAÇÃO DAS INSTALAÇÕES"
echo "Sistema Operacional:"
lsb_release -a | head -4

echo -e "\nVersões instaladas:"
echo "Git: $(git --version)"
echo "Node.js: $(node --version)"
echo "NPM: $(npm --version)"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose --version)"

echo -e "\nServiços ativos:"
systemctl is-active docker && echo "✅ Docker está rodando" || echo "❌ Docker não está rodando"
sudo ufw status | head -1

header "INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
warn "IMPORTANTE: Faça logout e login novamente para usar o Docker sem sudo"
warn "Execute 'source ~/.bashrc' para carregar as novas configurações do bash"

log "Comandos úteis instalados:"
echo "  - sysinfo (mostra informações do sistema)"
echo "  - htop (monitor de processos)"
echo "  - tree (visualiza estrutura de pastas)"

log "Para testar o Docker:"
echo "  docker run hello-world"

log "Script criado para fins educacionais - Use responsavelmente!"
echo -e "\n${GREEN}Pressione ENTER para continuar...${NC}"
read
