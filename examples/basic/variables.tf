variable "cluster_name" {
  description = "Name of the example cluster"
  type        = string
  default     = "deepai-example"
}

variable "region" {
  description = "DigitalOcean region for the example cluster"
  type        = string
  default     = "fra1"
}
