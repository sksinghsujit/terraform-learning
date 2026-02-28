variable "AAP_TOKEN" {
  type        = string
  description = "The API token for Ansible Automation Platform"
  sensitive   = true # This ensures the value isn't printed in logs
}

variable "AAP_HOST" {
  type        = string
  description = "The internal URL/IP of your AAP instance"
}
