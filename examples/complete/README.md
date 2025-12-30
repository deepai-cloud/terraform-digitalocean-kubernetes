# Complete Example

This example demonstrates a full-featured DigitalOcean Kubernetes cluster with:

- Auto-scaling default node pool
- Additional high-memory node pool with taints
- NGINX Ingress Controller with large file upload support
- Custom error pages
- Extended timeouts for long-running uploads

## Usage

1. Set your DigitalOcean API token:

```bash
export TF_VAR_do_token="your-digitalocean-api-token"
```

2. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

3. Get the kubeconfig:

```bash
terraform output -raw kubeconfig > ~/.kube/config
```

4. Verify the cluster:

```bash
kubectl get nodes
kubectl get pods -n ingress-nginx
```

## Outputs

- `cluster_endpoint` - The Kubernetes API server endpoint
- `kubeconfig` - Raw kubeconfig for kubectl access
- `ingress_ip` - External IP of the NGINX Ingress Controller

## Clean Up

```bash
terraform destroy
```
