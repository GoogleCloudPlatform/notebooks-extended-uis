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

variable "folder_static" {
  description = "Static folder that contains the web app frontend."
  type        = string
  default     = "./docker/static"
}

variable "project" {
  description = "Project Id where to deploy the console."
  type        = string
  default     = ""
}

variable "client_id" {
  description = "Google Cloud Client ID from the console."
  type        = string
}

variable "is_activating_project_selector_proactive" {
  description = "Whether activating the project selector must be passed as a URL parameter"
  type        = string
  default     = "true"
}

# TODO(mayran): Add a validation for gcs and gcs_static
variable "deployment_target" {
  description = "Where to deploy the custom cloud console. Must be supported by VPC-SC. `gcs` uses the default Cloud Storage Url. `gcs_static` sets up a static bucket with HTTPS Load Balancer."
  type        = string
  default     = "gcs"
}

# Although caching file is not a security hasard , some users might get confused if files
# gets cached outside the VPC-SC perimeter and are visible so default sets `no-cache`.
variable "cache_control" {
  description = "Caching behavior for the static files."
  type        = string
  default     = "no-store"
}

variable "deploy_consoles" {
  description = "Whether to deploy notebook consoles."
  type        = string
  default     = "False"
}

variable "cloud_dns_project" {
  description = "Project where Cloud DNS is set up."
  type        = string
  default     = ""
}

variable "cloud_dns_zone" {
  description = "Value is a Cloud DNS zone name. If empty, Terraform skips the Cloud DNS zone setup. If not empty, Terraform sets up a Cloud DNS zone with the name. You still need to configure your name servers with your domain registrar."
  type        = string
  default     = ""
}

variable "cloud_dns_record_zone" {
  description = "Value is a Cloud DNS zone name. If empty, Terraform skips the creation of record sets. If not empty, Terraform creates records using the specified value and `gcs_url`. You need to have a zone already setup."
  type        = string
  default     = ""
}

variable "console_url" {
  description = "URL for users to access the custom console."
  type        = string
}

variable "gcs_location" {
  description = "Where to deploy the GCS bucket."
  type        = string
  default     = "US"
}

variable "gcs_domain_prefix" {
  description = "GCS URL prefix that gives access to objects. Needed when using GCS but not a static bucket."
  type        = string
  default     = "https://storage.googleapis.com"
}
