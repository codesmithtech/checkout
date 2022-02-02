output "app_url" {
  value = "https://${var.app_domain}${var.app_path}"
}

output "app_version" {
  value = var.app_version
}