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

var scopes = 'https://www.googleapis.com/auth/cloud-platform https://www.googleapis.com/auth/admin.directory.user.readonly';

var discoveryDocs = [
  'https://notebooks.googleapis.com/$discovery/rest?version=v1',
  'https://cloudresourcemanager.googleapis.com/$discovery/rest?version=v1',
];

// [START config]
var config = {
  'clientId': '${client_id}',
  'discoveryDocs': discoveryDocs,
  'scope': scopes
}


var ux = {
  INTERVAL_CHECK: 5000,
  IS_ACTIVATING_PROJECT_SELECTOR_PROACTIVE: ${is_activating_project_selector_proactive}
}
// [END config]