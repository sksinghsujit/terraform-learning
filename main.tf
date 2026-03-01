terraform {
  required_providers {
    aap = {
      source  = "ansible/aap"
      version = "~> 1.4.0" # Current stable version in 2026
    }
  }
}

# The provider uses the variables you set in the HCP UI
provider "aap" {
  host                = var.AAP_HOST
  token               = var.AAP_TOKEN
  insecure_skip_verify = true # Set to false if you have valid SSL
}

# 1. Look up your existing Job Template by name
data "aap_job_template" "config_app" {
  name              = "test-jt"
  organization_name = "Default"
}

# 2. Launch the Job
# In AAP Provider v1.4+, we use the 'aap_job' action
# This needs to be validated
resource "aap_job" "run_config" {
  job_template_id = data.aap_job_template.config_app.id
  # inventory_id = 123
  
  # Pass dynamic data from Terraform to Ansible!
  extra_vars = jsonencode({
    target_env  = "development"
    provisioned_by = "HCP-Terraform-Agent"
    # Example: pass an IP from a VM you just created
    # server_ip = aws_instance.web.private_ip 
  })
}

# Output the Job ID so you can track it in the HCP UI logs
output "ansible_job_id" {
  value = aap_job.run_config.job_id
}
