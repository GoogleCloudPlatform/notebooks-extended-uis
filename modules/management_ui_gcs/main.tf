/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# ------------------------------
# Bucket
# ------------------------------

# Static bucket and files.
resource "google_storage_bucket" "console" {
  project       = var.project
  name          = var.gcs_url
  location      = var.gcs_location
  force_destroy = true
  uniform_bucket_level_access = true
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_storage_bucket_iam_member" "bucket_public" {
  bucket = google_storage_bucket.console.name
  role = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_storage_bucket_object" "files_third_party" {
  for_each     = fileset(var.folder_static, "third_party/**/*.{html,css,js,ttf}")
  name         = each.value
  source       = "${var.folder_static}/${each.value}"
  bucket       = google_storage_bucket.console.name
  content_type = lookup(
    tomap({
      html = "text/html; charset=utf-8"
      js = "text/javascript; charset=utf-8"
      css = "text/css; charset=utf-8"
      ttf = "font/ttf; charset=utf-8"
    }),
    element(split(".", each.value), length(split(".", each.value))-1),
    "text/plain; charset=utf-8")
}

resource "google_storage_bucket_object" "file_404" {
  name          = "404.html"
  content       = templatefile("${var.folder_static}/404.tpl", { relative_path = var.relative_path })
  bucket        = google_storage_bucket.console.name
  content_type  = "text/html; charset=utf-8"
  cache_control = var.cache_control
}

resource "google_storage_bucket_object" "file_index" {
  name          = "index.html"
  content       = templatefile("${var.folder_static}/index.tpl", { relative_path = var.relative_path })
  bucket        = google_storage_bucket.console.name
  content_type  = "text/html; charset=utf-8"
  cache_control = var.cache_control
}

resource "google_storage_bucket_object" "file_config" {
  name          = "javascript/config.js"
  content       = templatefile("${var.folder_static}/javascript/config.tpl", { client_id = var.client_id, is_activating_project_selector_proactive = var.is_activating_project_selector_proactive })
  bucket        = google_storage_bucket.console.name
  content_type  = "text/javascript; charset=utf-8"
  cache_control = var.cache_control
}

# ------------------------------
# DNS
# ------------------------------

# If asked by user, creates a Cloud DNS zone
resource "google_dns_managed_zone" "dns_zone" {
  count    = (var.cloud_dns_zone != "") && (var.deployment_target == "gcs_static") != "" ? 1 : 0
  project  = var.cloud_dns_project
  name     = var.cloud_dns_zone
  dns_name = "${var.gcs_url}."
}

# Reserves an external IP for the LB.
resource "google_compute_global_address" "console" {
  count   = var.deployment_target == "gcs_static" ? 1 : 0
  project = var.project
  name    = "console-lb-ip"
}

# If asked by user, creates a Cloud DNS record set with the reserved IP.
resource "google_dns_record_set" "console" {
  count        = (var.cloud_dns_record_zone != "") && (var.deployment_target == "gcs_static") ? 1 : 0
  project      = var.cloud_dns_project != "" ? var.cloud_dns_project : google_dns_managed_zone.dns_zone[0].name
  name         = "${var.gcs_url}."
  type         = "A"
  ttl          = 60
  managed_zone = var.cloud_dns_record_zone
  rrdatas      = [google_compute_global_address.console[0].address]
}

# ------------------------------
# Load Balancing
# ------------------------------

# Creates a GCS backend.
resource "google_compute_backend_bucket" "console" {
  count       = var.deployment_target == "gcs_static" ? 1 : 0
  project     = var.project
  name        = "console-backend-gcs"
  description = "Contains files needed by the website"
  bucket_name = google_storage_bucket.console.name
  enable_cdn  = false
}

# Creates HTTPS certificate. This might take a while.
resource "google_compute_managed_ssl_certificate" "console" {
  count    = var.deployment_target == "gcs_static" ? 1 : 0
  provider = google-beta
  project  = var.project
  name     = "console-certificate"
  managed {
    domains = ["${var.gcs_url}."]
  }
}

# Url map for the console (this is the name of the load balancer)
resource "google_compute_url_map" "console" {
  count           = var.deployment_target == "gcs_static" ? 1 : 0
  project         = var.project
  name            = "console-lb"
  default_service = google_compute_backend_bucket.console[0].self_link
}

# Target proxy for the console.
resource "google_compute_target_https_proxy" "console" {
  count            = var.deployment_target == "gcs_static" ? 1 : 0
  project          = var.project
  name             = "console-target-https-proxy"
  url_map          = google_compute_url_map.console[0].self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.console[0].self_link]
}

# Forwarding rule uses the reserved IP.
resource "google_compute_global_forwarding_rule" "console" {
  count                 = var.deployment_target == "gcs_static" ? 1 : 0
  project               = var.project
  name                  = "console-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.console[0].address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.console[0].self_link
}
