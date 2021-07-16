# Extended Notebooks UIs

The goal of this solution is to deploy a simple HTML page that can act as a console to list and manage Google Cloud's Notebooks.

The solution provides:

1. A way to deploy semi-managed Notebooks with an extended UI that provides graphical interaction to some Google Cloud services
1. A way for data practitioneers to exerce some controls over those Notebooks environments.

Both components are compliant with VPC Services Controls and support data residency.

Use this solution in the following context:

1. You are an administrator who creates Notebooks environments on behalf of end-users.
1. Your company uses VPC-SC to mitigate exfiltration risks.
1. Your end-users can interact with Google APIs through AI Platform Notebooks.
1. Your IAM policies enforce what end-users can and can not do.

**This is not an official product**

> Note: The detault deployment of the Notebooks management UI is static only and does not use any server side code. It authenticates the user to Google and uses their crendentials to call Google APIs directly. The client does not enforce any server-side logic other than what Google APIs provide. You must set the proper authorization rules using Cloud IAM to prevent users from performing unauthorized actions.

## What you deploy

What you deploy is:

1. A UI to manage Notebooks that is VPC-SC compliant and hosted on Cloud Storage.
1. A secure way for users to list, manage and access their Notebooks.
1. An OAuth2.0 flow so the Notebooks management UI can interact with Google API using the user's credentials provided through Google Sign-In.
1. (Optionnal) Notebooks with an extended UI. This can also be part as part of another workflow in your organization.

## Preparation

You can run this example on your admninistrative machine or by using Cloud Shell. When possible, we recommend to use Cloud Shell.

This solution uses the following tools:

- Google Cloud SDK aka gcloud CLI (already installed in Cloud Shell).
- Terraform (See installation instructions).

Make sure that you have them installed.

## Security

This section refers to some variables that you need to set in your Terraform setup: `console_url`, `client_id`. For details about those variables, see the [Inputs](#inputs) section.

Before you can deploy the custom console, you need an **OAuth2.0 Web client ID**: To create one, refer to this [documentation](https://support.google.com/cloud/answer/6158849#zippy=%2Cweb-applications):

- If you user `gcs` as a `deployment_target`, make sure to add `https://storage.googleapis.com` as a Javascript origin.
- If you user `gcs_static` as a `deployment_target`, make sure to add the `console_url` value as a Javascript origin.

Once you have created the web client ID, go to the console and copy the values to populate `client_id` in your `terraform.tfvars` file.

## Deployment with Terraform

### Setup

From your command line, make sure that you are in the the root folder of this repository then run through the following steps:

1. Create a `terraform.tfvars` file with the required inputs. For more details, see the Inputs section below and the example.tfvars file.

1. Run `terraform init` to get the plugins

1. Run `terraform plan"` to see the infrastructure plan.

1. Run `terraform apply"` to apply the infrastructure build.

### Inputs

| Name | Type | Default | Required |  Description |
|------|-------------|:----:|:-----:|:-----|
|client_id|`string`||yes|An Google Cloud oauth2.0 Client ID for web applications. Ex: `987654321-ghijklm.apps.googleusercontent.com`
|project|`string`||yes|Google Cloud project where to deploy the console. Ex: `example-project-id`|
|console_url|`string`||yes|Url for users to access the console. Ex: `console.example.com`|
|deployment_target|`string`|`gcs`|no|Where to deploy the UI. Currently supports Cloud Storage `gcs` and Cloud Storage static buckets `gcs_static`.|
|cache_control|`string`|`no-cache`|no| Caching behavior for index.html, 404.html and config.js.|
|deploy_consoles|`string`|`False`|no| Whether to create an example Notebook Console.|
|cloud_dns_project|`string`||no|Project where your Cloud DNS is set up. Ex: `example-project-dns-id`|
|cloud_dns_zone|`string`||no|Name of the Cloud DNS zone to create for your console. Ex: `example-com-zone`|
|cloud_dns_record_zone|`string`||no|Name of the Cloud DNS zone where you want to add the DNS record for the console. Ex: `example-com-zone`|
|gcs_location|`string`||no|Location where to create the bucket that host the console. Ex: `US`|
|gcs_html_prefix|`string`|`https://storage.googleapis.com`|no|GCS URL prefix that gives access to objects|
|is_activating_project_selector_proactive|`string`|`true`|no|Whether users must enabled the project selector through the `hasProjectSelector` URL parameter. When set to `true`, users must always set `projectId` in the URL to display instances for that project.|

