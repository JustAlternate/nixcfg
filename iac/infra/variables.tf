variable "hetzner_token" {
  description = "hetzner API key"
  type        = string
	sensitive   = true
}

variable "root_pass" {
  description = "A root pass for each machine deployment"
  type        = string
	sensitive   = true
}
