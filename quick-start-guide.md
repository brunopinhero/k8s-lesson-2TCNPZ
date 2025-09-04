# 🚀 Guia Rápido - Linux na AWS EC2

## Para os Alunos: Como Usar

### ⚡ Instalação Rápida (Recomendado)

**1. Conecte na sua instância EC2:**
```bash
ssh -i "sua-chave.pem" ubuntu@seu-ip-ec2
```

**2. Execute o script de instalação:**
```bash
curl -fsSL https://raw.githubusercontent.com/[SEU-USUARIO]/linux-aws-setup/main/install.sh | bash
```

**3. Aplicar configurações:**
```bash
source ~/.bashrc
newgrp docker
```

### 📥 Download Manual

**Opção 1 - Git Clone:**
```bash
git clone https://github.com/[SEU-USUARIO]/linux-aws-setup.git
cd linux-aws-setup
chmod +x *.sh
./install.sh
```

**Opção 2 - Download ZIP:**
```bash
wget https://github.com/[SEU-USUARIO]/linux-aws-setup/archive/main.zip
unzip main.zip
cd linux-aws-setup-main
chmod +x *.sh
./install.sh
```

## ✅ Verificar Instalação

**Comando de status:**
```bash
~/bin/status.sh
```

**Testar serviços:**
```bash
# Docker
docker run hello-world

# Nginx
curl http://localhost

# Informações do sistema
sysinfo
```

## 🌐 Acesso Web

Após a instalação, acesse no navegador:
```
http://SEU-IP-PUBLICO-EC2
```

## 📁 Estrutura Criada

```
~/
├── projetos/
│   ├── web/
│   ├── api/
│   ├── scripts/
│   └── docker/
├── backups/
└── bin/
    └── status.sh
```

## 🔧 Comandos Úteis Adicionados

```bash
sysinfo          # Informações do sistema
ll               # Lista detalhada
gs               # git status
dps              # docker ps
status.sh        # Status dos serviços
```

## ❗ Importantes

- **Fazer logout/login** após instalação para usar Docker
- **Configurar MariaDB:** `sudo mysql_secure_installation`
- **IP Público muda** ao reiniciar a instância
- **Free Tier:** 750 horas/mês grátis

## 🆘 Problemas Comuns

**Docker sem sudo não funciona:**
```bash
newgrp docker
# ou fazer logout/login
```

**Página web não carrega:**
```bash
sudo systemctl start nginx
sudo ufw allow 80
```

**Script não executa:**
```bash
chmod +x nome-do-script.sh
```

## 📞 Suporte

- Documentação: pasta `docs/`
- Issues: GitHub do projeto
- Professor: [seus contatos]

---

## 🎯 Para a Aula

### Demonstração (50 min):

1. **AWS Console** (10 min)
   - Criar EC2
   - Configurar Security Group
   - Baixar chave SSH

2. **SSH Connection** (5 min)
   - Configurar chave
   - Conectar na instância

3. **Script Execution** (20 min)
   - Executar instalação
   - Mostrar progress
   - Explicar cada etapa

4. **Verification** (10 min)
   - Testar serviços
   - Acessar página web
   - Usar comandos

5. **Q&A** (5 min)

### Material para Levar:

- [ ] Chaves SSH exemplo
- [ ] Links dos scripts
- [ ] Troubleshooting impresso
- [ ] Comandos principais numa cola

### Homework:

1. Criar própria instância EC2
2. Executar scripts
3. Customizar página web
4. Fazer screenshot funcionando
5. Destruir instância (evitar cobrança)

---

*Criado para fins educacionais - AWS Free Tier*
