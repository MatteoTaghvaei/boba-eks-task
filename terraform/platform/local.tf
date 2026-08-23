locals {
  CLUSTER_NAME        = data.terraform_remote_state.infra_remote_data.outputs.eks_cluster_name
  CLUSTER_ENDPOINT    = data.terraform_remote_state.infra_remote_data.outputs.eks_cluster_endpoint
  CLUSTER_CERTIFICATE = data.terraform_remote_state.infra_remote_data.outputs.eks_cluster_ca


}