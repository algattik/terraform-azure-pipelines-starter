# Terraform starter project for Azure Pipelines

## About this project

This project can be used as a starter for Azure Pipelines deploying resources on Terraform.

It includes a multi-stage pipeline allowing to manually review and approve infrastructure
changes before they are deployed.

The Terraform definition only deploys an empty resource group. You can extend the definition
with your custom infrastructure such as Web Apps.

The project can be used in local development without a remote Terraform state backend.
This allows quickly iterating while developing the Terraform configuration, and 
good security practices.

When the project is run in Azure DevOps, however, the pipeline adds the
`infrastructure/terraform_backend/backend.tf` to the `infrastructure/terraform` 
directory to enable the Azure Storage shared backend for additional resiliency.

## Local development

In local development, no backend is configured so a local backend is used.

Install Azure CLI and login. Terraform will use your Azure CLI credentials.

```
$ az login -o table
You have logged in. Now let us find all the subscriptions to which you have access...
CloudName    IsDefault    Name                                                  State    TenantId
-----------  -----------  ----------------------------------------------------  -------  ------------------------------------
AzureCloud   True         My Azure subscription                                 Enabled  xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
AzureCloud   False        My other Azure subscription                           Enabled  xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

Run `terraform init`.

```
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "azurerm" (hashicorp/azurerm) 1.38.0...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

Run `terraform plan`.

```
$ terraform plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.azurerm_client_config.current: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "northeurope"
      + name     = "rg-starterterraform-dev-main"
      + tags     = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

Run `terraform deploy`.

```
$ terraform apply
data.azurerm_client_config.current: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # azurerm_resource_group.main will be created
  + resource "azurerm_resource_group" "main" {
      + id       = (known after apply)
      + location = "northeurope"
      + name     = "rg-starterterraform-dev-main"
      + tags     = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_resource_group.main: Creating...
azurerm_resource_group.main: Creation complete after 1s [id=/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-starterterraform-dev-main]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

subscription_id = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

At this stage you will have a new resource group deployed named `rg-starterterraform-dev-main`. 

## Azure DevOps pipeline

As of December 2019, there is no support for stage gates in Azure DevOps multi-stage pipelines, but
*deployment environments* provide a basic mechanism for stage approvals.

Create an environment with no resources. Name it `Staging`.

![create environment](/docs/images/create_environment.png)

Define environment approvals.

![create environment_approval1](/docs/images/create_environment_approval1.png)

![create environment approval2](/docs/images/create_environment_approval2.png)

![create environment approval3](/docs/images/create_environment_approval3.png)

![environment approval](/docs/images/environment_approval.png)

Create a Service Connection of type Azure Resource Manager at subscription scope. Name the Service Connection `Terraform`.
Allow all pipelines to use the connection.

In your subscription, create a storage account and a storage container named `terraformstate` within the storage account.

In `infrastructure/azure-pipelines.yml`, update the `TerraformBackendStorageAccount` name to your storage account name.

Create a build pipeline referencing `infrastructure/azure-pipelines.yml`.

As you run the pipeline, after running `terraform plan`, the next stage will be waiting for your approval.

![pipeline stage waiting](/docs/images/pipeline_stage_waiting.png)

Review the detailed plan to ensure no critical resources or data will be lost.

![terraform plan output](/docs/images/terraform_plan_output.png)

Approve or reject the deployment.

![stage approval waiting](/docs/images/stage_approval_waiting.png)

The pipeline will proceed to `terraform apply`.

![pipeline completed](/docs/images/pipeline_completed.png)

At this stage you will have a new resource group deployed named `rg-starterterraform-stage-main`. 

# Next steps

* The pipeline should be adapted to skip deployment if there are no changes.
  The output of `terraform plan -detailed-exitcode` might be used for this.
* You can extend the pipeline to additional environments, such as QA and Prod.
