/**
 On GCP
 */

output "policy" {
  description = "Resource snapshot policy details."
  value       = google_compute_resource_policy.policy
}

output "attachments" {
  description = "Disk attachments to the resource policy."
  value       = google_compute_disk_resource_policy_attachment.attachment[*]
}