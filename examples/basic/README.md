# Basic example

Create one DigitalOcean Kubernetes worker node without an ingress controller.

To run the checked-out example:

```bash
git clone --branch v1.3.0 https://github.com/deepai-cloud/terraform-digitalocean-kubernetes.git # x-release-please-version
cd terraform-digitalocean-kubernetes/examples/basic
export DIGITALOCEAN_TOKEN="your-digitalocean-api-token"
terraform init
terraform plan
terraform apply
```

This provisions billable resources. Override `cluster_name` and `region` with `-var` flags or a local `.tfvars` file. To use the module without cloning, copy the [root quick start](../../README.md#quick-start).

```bash
umask 077
terraform output -raw kubeconfig > kubeconfig
export KUBECONFIG="$PWD/kubeconfig"
kubectl get nodes
```

Replace `terraform` with `tofu` to use OpenTofu. Destroy the example when finished:

```bash
terraform destroy
```
