#!/bin/bash

# =============================================================================
# Script para Configuração de Ambiente de Desenvolvimento
# Complementar ao script principal
# =============================================================================

set -e

# Cores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

header "CONFIGURAÇÃO DE AMBIENTE DE DESENVOLVIMENTO"

# 1. PYTHON E PIP
header "1. INSTALANDO PYTHON E FERRAMENTAS"
sudo apt install -y python3 python3-pip python3-venv python3-dev
pip3 install --upgrade pip

# Instalar algumas bibliotecas Python úteis
pip3 install requests beautifulsoup4 pandas numpy matplotlib

log "Python $(python3 --version) instalado"

# 2. JAVA
header "2. INSTALANDO JAVA (OpenJDK 11)"
sudo apt install -y openjdk-11-jdk
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.bashrc

log "Java instalado: $(java -version 2>&1 | head -1)"

# 3. NGINX
header "3. INSTALANDO NGINX"
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx

log "Nginx instalado e iniciado"

# 4. MYSQL/MariaDB
header "4. INSTALANDO MARIADB"
sudo apt install -y mariadb-server mariadb-client
sudo systemctl enable mariadb
sudo systemctl start mariadb

warn "Execute 'sudo mysql_secure_installation' depois para configurar segurança"

# 5. REDIS
header "5. INSTALANDO REDIS"
sudo apt install -y redis-server
sudo systemctl enable redis-server
sudo systemctl start redis-server

log "Redis instalado e iniciado"

# 6. FERRAMENTAS DE MONITORAMENTO
header "6. INSTALANDO FERRAMENTAS DE MONITORAMENTO"
sudo apt install -y nethogs iotop iftop ncdu

# 7. CONFIGURAÇÃO DE SWAP (se necessário)
header "7. VERIFICANDO SWAP"
if [ $(free | grep Swap | awk '{print $2}') -eq 0 ]; then
    log "Criando arquivo de swap de 1GB..."
    sudo fallocate -l 1G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    log "Swap de 1GB criado e ativado"
else
    log "Swap já configurado"
fi

# 8. LIMPEZA DO SISTEMA
header "8. LIMPEZA DO SISTEMA"
sudo apt autoremove -y
sudo apt autoclean

# 9. CRIAÇÃO DE ESTRUTURA DE PROJETOS
header "9. CRIANDO ESTRUTURA DE PROJETOS"
mkdir -p ~/projetos/{web,api,scripts,docker}
mkdir -p ~/backups

# Criar um projeto exemplo
cat > ~/projetos/web/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Servidor Linux AWS - Funcionando!</title>
    <style>
        body { font-family: Arial; text-align: center; margin-top: 100px; }
        .container { max-width: 600px; margin: 0 auto; }
        .success { color: #28a745; }
        .info { background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="success">🎉 Servidor Linux AWS Configurado!</h1>
        <div class="info">
            <h3>Serviços Instalados:</h3>
            <p>✅ Nginx<br>✅ Docker<br>✅ Node.js<br>✅ Python<br>✅ Java<br>✅ MariaDB<br>✅ Redis</p>
        </div>
        <p><strong>Hostname:</strong> <span id="hostname"></span></p>
        <p><strong>Data:</strong> <span id="datetime"></span></p>
    </div>
    
    <script>
        document.getElementById('hostname').textContent = window.location.hostname;
        document.getElementById('datetime').textContent = new Date().toLocaleString('pt-BR');
    </script>
</body>
</html>
EOF

# Copiar para nginx
sudo cp ~/projetos/web/index.html /var/www/html/

# 10. SCRIPT DE STATUS DO SISTEMA
header "10. CRIANDO SCRIPT DE STATUS"
cat > ~/bin/status.sh << 'EOF'
#!/bin/bash

echo "=== STATUS DO SERVIDOR ==="
echo "Data: $(date)"
echo "Uptime: $(uptime -p)"
echo ""

echo "=== RECURSOS ==="
echo "CPU Load: $(uptime | awk -F'load average:' '{print $2}')"
echo "Memory: $(free -h | awk '/^Mem:/ {print $3 "/" $2 " (" int($3/$2*100) "%)"}')"
echo "Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')"
echo ""

echo "=== SERVIÇOS ==="
services=("nginx" "mariadb" "redis-server" "docker")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        echo "✅ $service está rodando"
    else
        echo "❌ $service está parado"
    fi
done

echo ""
echo "=== PORTAS EM USO ==="
ss -tulpn | grep LISTEN | awk '{print $1, $5}' | sort -u
EOF

mkdir -p ~/bin
chmod +x ~/bin/status.sh

# Adicionar ~/bin ao PATH
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc

# 11. CONFIGURAÇÃO DE LOG PERSONALIZADO
header "11. CONFIGURANDO LOGS PERSONALIZADOS"
sudo mkdir -p /var/log/meusscripts
sudo chown $USER:$USER /var/log/meusscripts

# Função para log em arquivo
cat >> ~/.bashrc << 'EOF'

# Função para log personalizado
logit() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $USER - $*" >> /var/log/meusscripts/atividades.log
}
EOF

header "AMBIENTE DE DESENVOLVIMENTO CONFIGURADO!"

log "Estrutura criada em ~/projetos/"
log "Script de status disponível: ~/bin/status.sh"
log "Página teste disponível em: http://$(curl -s ifconfig.me)"

warn "Execute 'source ~/.bashrc' para carregar as novas configurações"
warn "Execute 'sudo mysql_secure_installation' para configurar o MariaDB"

echo -e "\n${GREEN}Configuração completa! Pressione ENTER...${NC}"
read
