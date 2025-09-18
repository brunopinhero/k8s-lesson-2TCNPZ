variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "fiap-k8s-cluster"
}

variable "node_group_instance_type" {
  description = "The EC2 instance type for the EKS node group"
  type        = string
  default     = "t3.medium" # Escolha um tipo de instância que a AWS Academy permita
}

variable "node_group_desired_size" {
  description = "The desired number of nodes in the EKS node group"
  type        = number
  default     = 2
}