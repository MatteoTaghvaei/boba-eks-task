# TODO

Things I would improve if this was going to production:

- Move Terraform state to a remote backend with locking
- Use a NAT Gateway per availability zone
- Replace the Classic Load Balancer with an NLB using AWS Load Balancer Controller
- Tighten IAM permissions and avoid broad managed policies
- Move Kubernetes secrets to an external secret manager
- Add log aggregation, for example CloudWatch
- Add alerting rules for application availability and latency
- Add database connectivity checks from the application
- Add automated Terraform plan checks in CI
- Pin GitHub Actions and Helm chart versions more strictly