# Portal de Notícias – NodePort Service no Kubernetes

Este diretório contém exemplos de como configurar um NodePort Service no Kubernetes para a aplicação app-noticias.

## 📋 Recursos Kubernetes Incluídos

O arquivo `app-noticias-pod.yaml` contém três tipos de recursos para demonstração:

### 1. Pod Individual
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-noticias
  namespace: portal-noticias
```
- Um pod único executando a aplicação
- Útil para testes e demonstrações
- **Limitação**: Se o pod falhar, ele não será recriado automaticamente

### 2. Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-noticias-deployment
spec:
  replicas: 3
```
- Gerencia múltiplas réplicas da aplicação (3 pods)
- **Vantagens**:
  - Auto-recuperação: recria pods que falharem
  - Escalabilidade: pode ajustar o número de réplicas
  - Rolling updates: atualizações sem downtime
  - Load balancing automático entre os pods

### 3. NodePort Service
```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-noticias-nodeport
spec:
  type: NodePort
  ports:
  - port: 3500          # porta interna do cluster
    targetPort: 3500    # porta do container
    nodePort: 30080     # porta exposta nos nós (30000-32767)
```

## 🚀 Como aplicar no cluster

1. **Criar namespace** (se não existir):
```bash
kubectl create namespace portal-noticias
```

2. **Aplicar os recursos**:
```bash
kubectl apply -f app-noticias-pod.yaml
```

3. **Verificar os recursos criados**:
```bash
# Ver pods
kubectl get pods -n portal-noticias

# Ver deployment
kubectl get deployment -n portal-noticias

# Ver service
kubectl get service -n portal-noticias
```

## 🌐 Acessando a aplicação

### Com NodePort
- **Localmente**: `http://localhost:30080`
- **Cluster remoto**: `http://<IP-DO-NODE>:30080`

Para descobrir o IP dos nós:
```bash
kubectl get nodes -o wide
```

## 📊 Diferenças entre Pod e Deployment

| Aspecto | Pod | Deployment |
|---------|-----|------------|
| **Resiliência** | Se falhar, não recria | Recria automaticamente |
| **Escalabilidade** | Apenas 1 instância | Múltiplas réplicas |
| **Atualizações** | Manual | Rolling updates |
| **Uso recomendado** | Testes/Debug | Produção |

## 🔧 Comandos úteis

```bash
# Escalar deployment
kubectl scale deployment app-noticias-deployment --replicas=5 -n portal-noticias

# Ver logs dos pods
kubectl logs -l app=app-noticias -n portal-noticias

# Fazer port-forward (alternativa ao NodePort)
kubectl port-forward service/app-noticias-nodeport 3500:3500 -n portal-noticias

# Deletar recursos
kubectl delete -f app-noticias-pod.yaml
```

---

## Setup Local com Docker (Alternativo)

Este passo a passo ensina como subir a aplicação app-noticias junto com MySQL usando Docker, com persistência de dados e rede dedicada.

1️⃣ Pré-requisitos

Docker instalado (https://www.docker.com/get-started
)

Docker Compose (opcional, caso queira usar docker-compose)

Navegador ou cliente REST (Postman/cURL)

(Opcional) DBeaver para conectar ao MySQL

2️⃣ Criar rede Docker

Crie uma rede dedicada para que os containers se comuniquem pelo nome:

docker network create noticias-net

3️⃣ Criar volume para persistência do MySQL
docker volume create mysql-data


Isso garante que os dados do MySQL não sejam perdidos ao reiniciar o container.

4️⃣ Subir o MySQL
docker run -d \
  --name mysql \
  --network noticias-net \
  -v mysql-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=noticiasdb \
  -p 3306:3306 \
  mysql:8


-v mysql-data:/var/lib/mysql → persistência de dados

--network noticias-net → rede compartilhada com a aplicação

-p 3306:3306 → acesso externo para DBeaver ou localhost

Aguarde alguns segundos para o MySQL iniciar.

5️⃣ Subir a aplicação app-noticias:1.0
docker run -d \
  --name app-noticias \
  --network noticias-net \
  -p 3000:3000 \
  -e DB_HOST=mysql \
  -e DB_USER=root \
  -e DB_PASS=root \
  -e DB_NAME=noticiasdb \
  camanducci/app-noticias:1.0


-p 3000:3000 → acessível em http://localhost:3000

DB_HOST=mysql → conecta ao container MySQL na mesma rede

6️⃣ Testar a aplicação

Abra o navegador: http://localhost:3000

Login:

Usuário: admin
Senha:   admin


Cadastre notícias e visualize a lista.

7️⃣ Acessar o MySQL externamente (opcional)

Host: localhost

Porta: 3306

Usuário: root

Senha: root

Banco de dados: noticiasdb

Você pode usar DBeaver ou qualquer cliente SQL.

8️⃣ Parar e remover containers
docker stop app-noticias mysql
docker rm app-noticias mysql


Os dados do MySQL permanecem no volume mysql-data.

9️⃣ Reiniciar containers mantendo dados
docker run -d \
  --name mysql \
  --network noticias-net \
  -v mysql-data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=root \
  -e MYSQL_DATABASE=noticiasdb \
  -p 3306:3306 \
  mysql:8

docker run -d \
  --name app-noticias \
  --network noticias-net \
  -p 3000:3000 \
  -e DB_HOST=mysql \
  -e DB_USER=root \
  -e DB_PASS=root \
  -e DB_NAME=noticiasdb \
  camanducci/app-noticias:1.0


