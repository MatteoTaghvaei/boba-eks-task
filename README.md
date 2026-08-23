# Boba EKS Task

This project creates a small AWS EKS environment and deploys a simple Python web application on top of it.

The goal was to keep the setup simple while still covering infrastructure, CI/CD, GitOps, HTTPS and basic monitoring.

## Architecture

The environment includes:

- EKS with managed worker nodes
- Public and private subnets across two availability zones
- RDS MySQL Multi-AZ
- ECR for application images
- Traefik as the ingress controller
- Argo CD for GitOps
- cert-manager with Let's Encrypt
- Prometheus and Grafana for monitoring
- GitHub Actions for building and pushing application images

The worker nodes and database run in private subnets.

Traefik provides the public entry point to the application.

## Application

The application is a small FastAPI service with three endpoints:

- `/` returns a Hello World response
- `/health` is used for health checks
- `/metrics` exposes Prometheus metrics

The application runs with two replicas in Kubernetes.

## CI/CD and GitOps

When application code is pushed to `master`, GitHub Actions:

1. Builds the Docker image
2. Pushes the image to ECR
3. Updates the image tag in the Kubernetes deployment manifest
4. Commits the manifest change back to the repository

Argo CD watches the Kubernetes manifests in the repository and deploys changes to the cluster.

## HTTPS

Traefik handles ingress traffic and cert-manager requests the TLS certificate from Let's Encrypt.

The application was exposed through:

`https://boba.monocloud.tech`

## Monitoring

The cluster uses kube-prometheus-stack.

The application exposes custom Prometheus metrics for:

- HTTP request count
- HTTP request duration

A ServiceMonitor is used so Prometheus can discover and scrape the application.

## Security

A few security choices were included in the setup:

- GitHub Actions uses OIDC instead of AWS access keys
- Worker nodes run in private subnets
- RDS is private and encrypted
- MySQL access is allowed only from the EKS worker security group
- RDS credentials are managed by AWS Secrets Manager
- ECR image scanning is enabled
- Argo CD uses a read-only GitHub deploy key
- HTTPS is enabled with Let's Encrypt

## Terraform

Terraform is split into two parts:

```text
terraform/
  infra/
  platform/
```

`infra` creates the AWS resources such as networking, EKS, RDS and ECR.

`platform` installs the Kubernetes components such as Traefik, Argo CD, cert-manager and monitoring.

## Deploy

```bash
cd terraform/infra
terraform init
terraform apply

cd ../platform
terraform init
terraform apply
```

## Cleanup

Destroy the platform components first:

```bash
cd terraform/platform
terraform destroy
```

Then destroy the AWS infrastructure:

```bash
cd ../infra
terraform destroy
```

## Production Improvements

For a production environment I would consider:

- Remote Terraform state with locking
- A NAT Gateway per availability zone
- NLB with AWS Load Balancer Controller
- More restrictive IAM policies
- External secret management for Kubernetes secrets