# Notebooks Management Console

The goal of this solution is to mitigate data exfiltration risks through the Cloud Console due to VPC Services Controls (VPC-SC) currently not supporting the Cloud Console.

To work around this limitation, the solution must provide:

1. An interface to Google Cloud APIs that is flexible and supported by VPC-SC.
1. A way for data practitioneers to exerce some controls over their sandbox environments.

This repository addresses the latter point and deploys a web app for end users and assumes that the former points is addressed by using AI Platform Notebooks.

Use this solution in the following context:

1. You are an administrator who creates environments on behalf of end-users.
1. Your end-users interacts with Google APIs through AI Platform Notebooks.
1. Your company uses VPC-SC to mitigate exfiltration risks.
1. Your IAM policies enforce what end-users can and can not do.

**This is not an official product**

> Note: The current version of this solution is static only and does not use any server. It authenticates the user to Google and uses their crendentials to call Google APIs directly. The client does not enforce any server-side logic other than what Google APIs provide. You must set the proper authorization rules using Cloud IAM to prevent users from performing unauthorized actions.

## What you deploy

What you deploy is:

1. A user interface that is VPC-SC compliant and hosted on Cloud Storage as a static website fronted by a global HTTPs Load Balancer.
1. A secure way for users to list, manage and access their AI Platform Notebooks.
1. API calls leverage user credentials provided by a Google SignIn flow.

## Preparation

You can run this example on your admninistrative machine or by using Cloud Shell. When possible, we recommend to use Cloud Shell.

This blueprint uses the following tools:

- Google Cloud SDK aka gcloud CLI (already installed in Cloud Shell).
- Terraform (See installation instructions).

Make sure that you have them installed.

## Security

This section refers to some variables that you need to set in your Terraform setup: `console_url`, `client_id`. For details about those variables, see the [Inputs](#inputs) section.

Before you can deploy the custom console, you need an **OAuth2.0 Web client ID**: To create one, refer to this [documentation](https://support.google.com/cloud/answer/6158849#zippy=%2Cweb-applications):

- If you user `gcs` as a `deployment_target`, make sure to add `https://storage.googleapis.com` as a Javascript origin.
- If you user `gcs_static` as a `deployment_target`, make sure to add the `console_url` value as a Javascript origin.

Once you have created the web client ID, go to the console and copy the values to populate `client_id` in your `.tfvars` file.

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
|deployment_context|`string`|`prod`|no|Deployment context. `dev` prevents static page caching.|
|cloud_dns_project|`string`||no|Project where your Cloud DNS is set up. Ex: `example-project-dns-id`|
|cloud_dns_zone|`string`||no|Name of the Cloud DNS zone to create for your console. Ex: `example-com-zone`|
|cloud_dns_record_zone|`string`||no|Name of the Cloud DNS zone where you want to add the DNS record for the console. Ex: `example-com-zone`|
|gcs_location|`string`||no|Location where to create the bucket that host the console. Ex: `US`|
|gcs_html_prefix|`string`|`https://storage.googleapis.com`|no|GCS URL prefix that gives access to objects|

## Behavior

This solution aims at . You should have a VPC-SC setup for your project and that includes at a minimum the Notebooks API, BigQuery API, Cloud Storage API. With such a setup:

- Access to the console from outside the perimeter should return

    ```xml
    <Error>
      <Code>SecurityPolicyViolated</Code>
      <Message>Request violates VPC Service Controls.</Message>
    </Error>
    ```

- If for some reason, you managed to access the UI, the API call for listing notebooks should return a `401` or `403` error and the UI would not show any notebook.

## Notes

- You can access apis.google.com. You can not add the API to VPC-SC but it does not create exfiltration risk. The API is only used to authenticate the user.
- The Terrafrom script currently only supports deplpoyment on Cloud Storage. The files are packages in a Docker folder though, so you can deploy the application to services that are supported by VPC-SC and can run containers (Cloud Run, AI Platform Notebooks, Compute Engine, Kubernetes Engine)
- `cloudresourcemanager.googleapis.com` is user-scoped when fetching projects which means that users might still be able to list their own projects which is not a security liability.
- The solution disable the CDN for the load balancer to prevent the static content to cache. Although it would only show the web page and API calls would still be blocked, seeing the UI could be confusing for users.
