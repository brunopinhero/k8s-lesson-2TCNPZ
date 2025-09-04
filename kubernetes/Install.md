# Sumário para Instalação de Kubernetes em Instância EC2 na AWS

1. [Criar Instância EC2 na AWS](#1-criar-instância-ec2-na-aws) ✅

- curso-k8s

2. [Criar Chave SSH para Conexão](#2-criar-chave-ssh-para-conexão) ✅
3. [Conectar na Instância via SSH](#3-conectar-na-instância-via-ssh) ✅

```
ssh -i "nova-chave-professor.pem" ubuntu@<IP_DA_INSTÂNCIA>
```


4. [Instalar Editor de Texto Vim](#4-instalar-editor-de-texto-vim) ✅

```
sudo usermod -aG sudo $USER
sudo apt-get install vim
```

5. [Trocar Nome da Máquina](#5-trocar-nome-da-máquina) ✅

```
sudo vim /etc/hostname
```

6. [Reiniciar a Máquina](#6-reiniciar-a-máquina) ✅

```
 sudo reboot
```

7. [Verificar e Desabilitar o Swap](#7-verificar-e-desabilitar-o-swap) ✅

```
  sudo swapoff -a
  sudo cat /etc/fstab

```


8. [Instalar Containerd](#8-instalar-containerd) ✅

https://github.com/containerd/containerd/blob/main/docs/getting-started.md#option-2-from-apt-get-or-dnf

```
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
```
```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

```
sudo apt-get install containerd.io
sudo systemctl status containerd

```

9. [Configurar CNI Plugins](#9-configurar-cni-plugins) ✅
https://github.com/containerd/containerd/blob/main/docs/getting-started.md
https://github.com/containernetworking/plugins/releases

```
sudo mkdir -p /opt/cni/bin
```

```
wget https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-amd64-v1.5.1.tgz
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.5.1.tgz
```


10. [Configurar Containerd com Systemd Cgroup Driver](#10-configurar-containerd-com-systemd-cgroup-driver)


```
sudo vim /etc/containerd/config.toml
```

```
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  SystemdCgroup = true
```

```
sudo systemctl restart containerd
sudo systemctl status containerd

```

11. [Verificar Socket do Containerd](#11-verificar-socket-do-containerd)

```
ls /var/run/containerd/containerd.sock
```

12. [Adicionar Repositórios Kubernetes](#12-adicionar-repositórios-kubernetes)

```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

13. [Instalar Pacotes Kubernetes](#13-instalar-pacotes-kubernetes)

```
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

kubeadm version
apt list -a kubeadm

```

14. [Habilitar Serviços Necessários](#14-habilitar-serviços-necessários)

```
sudo systemctl enable --now kubelet

```


15. [Configurar Módulos e Sysctl](#15-configurar-módulos-e-sysctl)
https://kubernetes.io/docs/setup/production-environment/container-runtimes/

```
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

```

```
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

```
sudo sysctl --system
```

16. [Inicializar o Cluster Kubernetes](#16-inicializar-o-cluster-kubernetes)

```
sudo kubeadm init --kubernetes-version=1.31.1
```

17. [Configurar o Kubectl para o Usuário](#17-configurar-o-kubectl-para-o-usuário)

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

18. [Instalar o Plugin de Rede (WeaveNet)](#18-instalar-o-plugin-de-rede-weavenet)

-- configurar porta inbound - 6443

```
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

19. [Verificar Nós do Cluster](#19-verificar-nós-do-cluster)

```
kubectl get nodes
kubectl get namespaces
kubectl get pods -n kube-system
```

20. [Reset](#Reset)

```
sudo kubeadm reset
sudo kubeadm reset -f
rm -rf $HOME/.kube
sudo iptables -F
```

## Contato

- Professor: [Robson Roberto Camanducci]
