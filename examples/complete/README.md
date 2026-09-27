# Complete example

This example configures multiple autoscaling pools, labels and taints, a maintenance window, and the legacy ingress-nginx controller with custom error pages, Prometheus metrics, and upload settings.

The ingress controller is retained for existing users; [upstream ingress-nginx retired in March 2026](https://kubernetes.io/blog/2025/11/11/ingress-nginx-retirement/). Start with the [basic example](../basic) for a new cluster.

From this directory in a repository checkout, run:

```bash
export TF_VAR_do_token="your-digitalocean-api-token"
terraform init
terraform plan
terraform apply
```

The example uses the local module and creates billable DigitalOcean resources, including worker nodes and a load balancer. It requires Terraform or OpenTofu 1.6+. Replace `terraform` with `tofu` for OpenTofu.

Connect without overwriting an existing kubeconfig:

```bash
umask 077
terraform output -raw kubeconfig > kubeconfig
export KUBECONFIG="$PWD/kubeconfig"
kubectl get nodes
kubectl get pods -n ingress-nginx
```

Outputs are `cluster_endpoint`, sensitive `kubeconfig`, and `ingress_ip`. To use a remote versioned module in your own project, follow the [root quick start](../../README.md#quick-start).

Remove the example infrastructure when finished:

```bash
terraform destroy
```
