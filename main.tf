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

# Test using a new job flow template
data "aap_job_template" "config_app" {
  name              = "say-hello-world"
  organization_name = "Default"
}

resource "aap_job" "run_config" {
  job_template_id = data.aap_job_template.config_app.id
  wait_for_completion = true
  
  # Ensure this is valid JSON
  extra_vars = jsonencode({
    provisioned_by = "HCP-Terraform-Agent"
    run_id         = "${timestamp()}"
  })
}

# Instead of .id, we reference .url (which we saw is in the schema)
# This will show you the direct link to the job in your AAP UI
output "ansible_job_url" {
  value = aap_job.run_config.url
}

# If you strictly need the numeric ID, we use this trick:
output "ansible_job_id" {
  # We reference 'job_template_id' (which is known) and wait for 'status'
  # to prove the job started.
  value = "Job started for template ${aap_job.run_config.job_template_id}. Check AAP UI for status: ${aap_job.run_config.status}"
}
