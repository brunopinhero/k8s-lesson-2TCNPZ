output "kubeconfig" {
  description = "A configuration file to connect with your EKS cluster"
  value       = module.eks.kubeconfig
  sensitive   = true # Evita que a string seja exibida no console por segurança
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}