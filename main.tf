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

module "management_ui_gcs" {
  count                   = contains(["gcs", "gcs_static"], var.deployment_target) ? 1 : 0
  source                  = "./modules/management_ui_gcs"
  deployment_target       = var.deployment_target
  cache_control           = var.cache_control
  folder_static           = var.folder_static
  project                 = var.project
  client_id               = var.client_id
  cloud_dns_project       = var.cloud_dns_project
  cloud_dns_zone          = var.cloud_dns_zone
  cloud_dns_record_zone   = var.cloud_dns_record_zone
  gcs_url                 = var.console_url
  gcs_location            = var.gcs_location
  relative_path           = var.deployment_target == "gcs" ? "${var.gcs_domain_prefix}/${var.console_url}" : "."
  is_activating_project_selector_proactive = var.is_activating_project_selector_proactive

}

// [START example_notebook]
resource "google_notebooks_instance" "instance" {
  count         = contains(["true", "yes", "1"], lower(var.deploy_consoles)) ? 1 : 0
  project       = var.project
  name          = "example-notebook-console"
  machine_type  = "n2-standard-2"
  location      = "us-west1-b"
  metadata = {
    enable-extended-ui = "True"
  }
  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "common-cpu"
  }
}
// [END example_notebook]