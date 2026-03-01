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

# 1. Look up your existing Job Template
data "aap_job_template" "config_app" {
  name              = "Post-Provisioning Config" # Ensure this exactly matches AAP
  organization_name = "Default"
}

# 2. Launch the Job using the 'aap_job' resource
resource "aap_job" "run_config" {
  job_template_id = data.aap_job_template.config_app.id
  
  # Optional: If your template requires an inventory to be "prompted on launch"
  # inventory_id = 123 

  # Pass data from Terraform to Ansible
  extra_vars = jsonencode({
    target_env     = "development"
    provisioned_by = "HCP-Terraform-Agent"
  })
}

# Output the Job ID for tracking
output "ansible_job_id" {
  value = aap_job.run_config.id
}
