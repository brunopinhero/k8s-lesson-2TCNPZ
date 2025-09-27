variable "aws_region" {
  description = "The AWS region to create the cluster in."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "meu-cluster-terraform"
}

# No longer needed, as subnets are now created by Terraform:
# variable "subnet_ids" {
#   description = "The IDs of the subnets where the nodes will be created."
#   type        = list(string)
# }