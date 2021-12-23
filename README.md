# Deploy two-tier web app on Azure

## Description
This repo will deploy a two tier (front end & backend) application on Azure K8S, fronted by an Application Gateway. _For the sake of a workable example_, I'll clone two remote repos, each containing a Dockerfile that i'll build and deploy into Azure Container Registry, before deploying to AKS. In the real world, these applications should be deployed as part of their own pipeline.

Once deployed, the application is accessible from the public IP address of the application gateway on port 80.

## Prerequisites
To run this demo you'll need to install or have access to:
* An Azure subscription
* An Azure DevOps account
* Terraform

In the Azure subscription you'll need to deploy the following before you can run the pipeline:
* ACR
* KeyVault (plus App Config if you don't like storing non-secrets in KeyVault)
* A service Principal/App registration (client ID & client secret in KV)
* A storage account to manage remote Terraform state
** This will need owner opermissions in order to create & manage Managed Identities

In Azure DevOps you'll need:
* A project
* Replace Tokens extension from AzDO marketplace (Search for `qetza.replacetokens.replacetokens-task.replacetokens@3`)
* Terraform extension from AzDO marketplace (search for `TerraformCLI@0`)
* A service connection to your subscription
* A Docker service connection to your ACR

## Terraform
The infra for the stack is written in Terraform. Because of some interesting dependancies as a result of my use of `for_each` to create the subnets, i've split this into modules (something which i'd usually consider overkill for a project of this size.).

**Root module**
The child modules contain the code that will create the resources, but it is the root module which references these and passed them the required values:

```
module "foundation" {
  source = ".//modules/foundation"
  prefix = var.prefix
  location = var.location
}
```

**Foundation module**
The foundation module creates the basic resources on which the app infrasturcture is deployed:
* Resource group
* Virtual network
* Subnets
* App Gateway Public IP

**Compute module**
The compute module creates the infra that the applications will be deployed to:
* AKS cluster
* App gateway
* User-assigned Managed Identity
* Role assignments


## Deployment

**Running locally**
You can clone this repo and run the Terraform locally by configuring the backend to use either remote or local state and running `terraform init/plan/apply` from the root directory.

This will spin up the infrastructure and you can run the `kubectl` commands from the pipeline manually to create a deployment and the necessary ingress to leverage the Application Gateway

**Pipeline**
The pipeline is split into three stages: Build > infra deploy > app deploy. In the real world, the infra would be a consequence of the application and would be closely coupled (you build it, you run it and all that), but I had limited time and no desire to create three pipelines.

Build:
* Installs .NET SDK
* Runs a `dotnet build`
* Build and pushes container image to ACR

Infra deploy:
* Terraform plan > apply
* Published artifact to be used in next stage

App deploy:
* Deploys pod, service & ingress to AKS


## Terratest
A basic Terratest has been created that deploys the foundation module and validates the name of the vnet. To use:
1. You'll need to install golang on the host operating system
2. CD to the tests directory and run `go mod init <module name>`
2. From the tests directory and run `go test -v -timeout 30m`

## TODO
* Implement NSG to block traffic from internet through the AKS public IP
* Add internal ingress for backend service
* Hook up AKS to Log Analytics
* DNS & SSL
* Add PR trigger to run tests when a new PR is created
* Remove obsolete variables
