data "terraform_remote_state" "infra_remote_data" {
  backend = "local"

  config = {
    path = "../infra/terraform.tfstate"
  }
}