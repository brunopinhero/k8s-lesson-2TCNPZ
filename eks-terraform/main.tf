# Criação do VPC para o cluster EKS
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "fiap-eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Criação do cluster EKS
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "20.1.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29" # Versão do Kubernetes
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets

  # Configuração do Grupo de Nós
  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_group_instance_type]

      min_size     = 1
      max_size     = 3
      desired_size = var.node_group_desired_size
    }
  }

  # Configuração para acesso via kubectl
  # Certifique-se de que a role de professor da AWS Academy tem permissões
  # para criar e gerenciar o cluster.
  # Esta seção adiciona a sua role do IAM (a que você assume na AWS Academy)
  # ao cluster para que você possa usar o kubectl.
  enable_cluster_creator_admin_permissions = true
}