# Publishing and maintaining releases

Repository: `deepai-cloud/terraform-digitalocean-kubernetes`  
Public Registry address: `deepai-cloud/kubernetes/digitalocean`

## One-time Terraform Registry registration

A GitHub release or tag makes the module downloadable through its Git source immediately. Public Registry discovery also requires a one-time registration; a release workflow alone cannot register the module.

1. Keep the repository public, keep its `terraform-digitalocean-kubernetes` name, and set a short description such as “Terraform and OpenTofu module for DigitalOcean Kubernetes clusters with configurable worker pools and optional ingress.”
2. Ensure at least one semantic version tag exists (for example, `v1.3.0`).
3. Open the [Terraform Registry](https://registry.terraform.io/) publishing/sign-in flow and sign in to HCP Terraform with an account that can manage the GitHub repository.
4. Follow the current public namespace flow to manage `deepai-cloud`, connect the GitHub repository, and publish `kubernetes` for the `digitalocean` provider. Authorize the repository webhook when requested.
5. Verify that the [module page](https://registry.terraform.io/modules/deepai-cloud/kubernetes/digitalocean/latest) lists the release and that a clean configuration using the Registry source succeeds with `terraform init -backend=false`.
6. Promote the Registry snippet in the root README once registration is confirmed.

See HashiCorp's [public module publishing requirements](https://developer.hashicorp.com/terraform/registry/modules/publish) and [public namespace documentation](https://developer.hashicorp.com/terraform/cloud-docs/public-namespace). HCP organization access alone does not imply access to the GitHub organization.

## Routine releases

The release workflow validates both modules and examples with Terraform and OpenTofu and checks generated documentation before running Release Please. Use conventional commits (`fix:`, `feat:`, or breaking-change notation) so the release PR chooses the appropriate version.

Merge the release PR after its checks pass. Release Please updates `version.txt`, `CHANGELOG.md`, the manifest, and marked installation snippets; then it creates a `vX.Y.Z` tag and GitHub release. Registry webhooks ingest tags after the one-time registration.

In GitHub Actions settings, enable “Allow GitHub Actions to create and approve pull requests” for Release Please. PRs created with the default `GITHUB_TOKEN` do not trigger other workflows automatically; close and reopen the release PR as a maintainer to trigger CI, or use an approved GitHub App token for Release Please. A failed validation prevents the release job from running.

## Manual release / initial bootstrap

For an intentional manual release, update the changelog, `version.txt`, `.release-please-manifest.json`, and marked documentation versions together. Validate the committed revision before pushing a new tag:

```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
```

The tag-triggered workflow validates that revision and creates a GitHub release. Once registered, the Registry may index a pushed tag immediately, before GitHub Actions finishes, so run checks before tagging. Never move an existing published version tag.

Verify download availability independently of Registry indexing:

```hcl
module "kubernetes" {
  source = "git::https://github.com/deepai-cloud/terraform-digitalocean-kubernetes.git?ref=vX.Y.Z"

  cluster_name          = "download-check"
  install_nginx_ingress = false
}
```

Run `terraform init -backend=false` and `terraform validate` in that scratch configuration. Neither command creates DigitalOcean resources.
