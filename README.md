# Terraform starter project for Azure Pipelines

## About this project

This project can be used as a starter for Azure Pipelines deploying resources on Terraform.

It includes a multi-stage pipeline allowing to manually review and approve infrastructure
changes before they are deployed.

The Terraform definition only deploys a resource group and two empty SQL Server instances
(to illustrate two different approaches to managing secrets, in this case the SQL Server
password).
You can extend the definition with your custom infrastructure, such as Web Apps.

The project can be used in local development without a remote Terraform state backend.
This allows quickly iterating while developing the Terraform configuration, and 
good security practices.

When the project is run in Azure DevOps, however, the pipeline adds the
`infrastructure/terraform_backend/backend.tf` to the `infrastructure/terraform` 
directory to enable the Azure Storage shared backend for additional resiliency.
See the Terraform documentation to understand [why a state store is needed](https://www.terraform.io/docs/state/purpose.html).

## Variables and state management

Variables can be injected using `-var key=value` syntax in the `TerraformArguments` parameter.
The pipeline demonstrates this by adding a custom tag named `department` to the
created resource group, with distinct values in staging and QA.

Rather than passing a Terraform plan between stages (which would contain clear-text secrets),
the pipeline performs `terraform plan` again before applying changes and verifies that
a textual representation of the plan (not including secrets values) is unchanged.

The Terraform state is managed in a Azure Storage backend. Note that this backend contains
secrets in cleartext.

## Secrets management

### Generate secrets with Terraform

To demonstrate one approach to secrets management, the Terraform configuration
generates a random password (per stage) for the SQL Server 1 instance, stored in
Terraform state.
You can adapt this to suit your lifecycle.

### Manage secrets with Azure DevOps

You might want to read credentials from an externally managed Key Vault
or inject them via pipeline variables. This approach is demonstrated
by defining a password for the SQL Server 2 instance and passing
it to Terraform via an environment variable.

## Getting started

In `infrastructure/terraform/variables.tf`, change the `appname` default value from
`starterterraform` to a globally unique name.

## Azure DevOps pipeline

Install the [Terraform extension for Azure DevOps](https://marketplace.visualstudio.com/items?itemName=ms-devlabs.custom-terraform-tasks).

As of December 2019, there is no support for stage gates in Azure DevOps multi-stage pipelines, but
*deployment environments* provide a basic mechanism for stage approvals.

Create an environment with no resources. Name it `Staging`.

![create environment](/docs/images/create_environment.png)

Define environment approvals. If you want to allow anyone out of a group a people to be able to individually approve, add a group.

![create environment_approval1](/docs/images/create_environment_approval1.png)

![create environment approval2](/docs/images/create_environment_approval2.png)

![create environment approval3](/docs/images/create_environment_approval3.png)

![environment approval](/docs/images/environment_approval.png)

Repeat those steps for an environment named `QA`.

Create a Service Connection of type Azure Resource Manager at subscription scope. Name the Service Connection `Terraform`.
Allow all pipelines to use the connection.

Under Library, create a Variable Group named `terraform-secrets`. Create a secret
named `SQL_PASSWORD` and give it a unique value (e.g. `Strong_Passw0rd!`). Make
the variable secret using the padlock icon.

![environment approval](/docs/images/variable_group.png)

In `infrastructure/terraform-init-template.yml`, update the `TerraformBackendStorageAccount` name to a globally unique storage account name.
The pipeline will create the storage account.

Create a build pipeline referencing `infrastructure/azure-pipelines.yml`.

As you run the pipeline, after running `terraform plan`, the next stage will be waiting for your approval.

![pipeline stage waiting](/docs/images/pipeline_stage_waiting.png)

Review the detailed plan to ensure no critical resources or data will be lost.

![terraform plan output](/docs/images/terraform_plan_output.png)

You can also review the plan and terraform configuration files by navigating to Pipeline Artifacts (rightmost column in the table below).

![pipeline artifacts](/docs/images/pipeline_artifacts.png)

![pipeline artifacts detail](/docs/images/pipeline_artifacts_detail.png)

Approve or reject the deployment.

![stage approval waiting](/docs/images/stage_approval_waiting.png)

The pipeline will proceed to `terraform apply`.

At this stage you will have a new resource group deployed named `rg-starterterraform-stage-main`. 

The pipeline will then proceed in the same manner for the `QA` environment.

![pipeline completed](/docs/images/pipeline_completed.png)

If any changes have been performed on the infrastructure between the Plan and Apply stages, the pipeline will fail.
You can rerun the Plan stage directly in the pipeline view to produce an updated plan.

![plan changed](/docs/images/plan_changed.png)

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
$ terraform plan -out tfplan
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
```

Run `terraform apply tfplan`.

```
$ terraform apply tfplan
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

# Next steps

* It's not currently possible to skip approval and deployment if there are no
  changes in the Terraform plan, because of limitations in multi-stage
  pipelines (stages cannot be conditioned on the outputs of previous stages).
  You could cancel the pipeline (through the REST API) in that case, but that
  would prevent extending the pipeline to include activities beyond Terraform.
* You can of course adapt the pipeline to other environments, such as Prod.
