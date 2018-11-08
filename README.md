# Basic Terraform Webapp

This project creates very basic and minimum infrastructure with Terraform to deploy a web application.

### Prerequisites

Before being able to execute this project, you should have the next prerequisites:

- Have Terraform installed
- Have an AWS account

### Before executing

Please copy file _credentials.auto.tfvars.sample_ and rename to _credentials.auto.tfvars_, adding your specific AWS access and secret keys to the new file. Those variables are going to be injected to the execution when Terraform plan is executed.

### Executing

For initializing your Terraform plan, please execute the next command:

    terraform init

For applying your configuration, please execute the following command, where _ENV_ should be replaced by _dev_ or _qa_ values:

    terraform apply -var-file=environment/ENV.tfvars -state=terraform-ENV.tfstate

You will be asked before applying those changes, in case you want to proceed please type _yes_.

For destroying the created infrastructure, please execute the following command, where _ENV_ should be replaced by _dev_ or _qa_ values:

    terraform destroy -var-file=environment/ENV.tfvars -state=terraform-ENV.tfstate

Remember that not destroying created infrastructure could end in some money charges.
