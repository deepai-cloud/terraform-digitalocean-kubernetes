# Changelog

## 1.3.0

- Replace placeholder organization names with `deepai-cloud` and document pinned downloads, installation, Registry registration, and release maintenance.
- Add a minimal example and correct the complete example's version requirements and chart configuration.
- Support fixed-size node pools with `node_count`, optional pool settings, and validation of sizes and scaling bounds.
- Skip Kubernetes version discovery when an exact version is supplied.
- Create custom error-page ConfigMaps before Helm consumes them and give the ingress submodule usable defaults.
- Check Terraform and OpenTofu compatibility, provider-mocked regression tests, examples, and generated documentation before publishing releases.

## 1.2.0

- Add Prometheus metrics support for the ingress controller.

## 1.1.0

- Allow a custom name for the default node pool.

## 1.0.0

- Provide the DigitalOcean Kubernetes module and optional ingress-nginx integration.
