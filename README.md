# Terraform-deployment

A complete deployment of a terraform application.

---

This application was created by Sam Meech Ward of BCIT. The deployment method utilizing Terraform was completely created by Tiras Gimpel [@UnknownTy](https://github.com/UnknownTy).
This repository was created for Sam's Cloud Computing class as a final, and is intended for education purposes. The deployment code can be looked at and used to learn how
completely deploy something through Terraform.

## Deployment

### Packer

First, you must create an AMI that Terraform will use for all web application instances.
This can easily be accomplished by following these steps:

1. [Install packer](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli)
2. Navigate to the Packer subdirectory (./deployment/packer/)
3. Run `packer init .` in console to intialize and download all required packer plugins
4. In the `social_something.pkr.hcl` file, set the `region` to your desired AWS region
    1. By default this is set to `us-west-2`, but it can be any valid AWS region.
5. In the `awscli.conf` file, set the `region` to the same AWS region as before
6. Run `packer build .` in console to build the AMI

All done! After a short time, you will have an AMI ready to be used by Terraform to create your web instances!

### Terraform

#### Variables

This application requires quite a few variables to be set to be properly deployed. They are as follows:

- region
  - The AWS Region to be used by Terraform to deploy the application
  - This region MUST be the same as the one used by Packer
- bucket_name
  - The S3 Bucket's name used by the application
  - Will not be used by the end user, so can be any unique bucket name.
- database_admin_password
  - The master password to be used by the AWS RDS instance
  - A good secure password is always recommended!
- domain_name
  - The domain name to be used by the application
  - This domain name MUST already have a hosted zone ready under AWS
- ssh_key
  - An SSH Key used to SSH into a test instance to configure the RDS
  - This SSH key MUST already exist in the required region! You can create keypairs manually through AWS' EC2 section
  - Yes the whole instance is private, but this was the easiest way to configure the RDS when it's newly created.
  
#### Deployment

Once all terraform variables are properly configured and set, you can build and deploy the entire application! \
This can be done through the following steps:

1. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform)
2. Navigate to the Terraform subdirectory (./deployment/terraform)
3. Run `terraform init` in console to initialize and download all required modules
4. Run `terraform apply` in console
5. Enter any terraform variables not declared in a `.tfvars`
6. Enter `yes` to begin the deployment process

And now you wait! After a few minutes, the application should be deployed, however it is not entirely complete!
In order to use the application we must add our SQL to the RDS manually. To do this, we have a test instance ready to go.

1. Navigate to the EC2 subdirectory (/terraform/modules/EC2/)
2. In the main.tf, scroll to the bottom of the file
3. Uncomment the `test_application` code
4. Navigate to the root terraform directory
5. Run `terraform apply` in console
6. SSH into the machine using your preferred method
7. Run `sudo yum install mysql -y` in the instance's console
8. Use the `mysql_dump_command` provided Terraform's output
    1. You can find this command in the console of after running `terraform apply`
    2. If you don't see it, you can also run `terraform output` to see the command again
9. Enter the RDS' password

And you are now done! The database is now properly configured, so the application is entirely ready to be used.
If you want, you can also delete the test EC2 instance as it has now completed its purpose. \
You can do this by re-commenting its code and running `terraform apply` one last time.

#### Tearing Down

Taking down an application deployed with Terraform is really easy.
To do this, just run:
`terraform destroy` in the root terraform directory.

This is irreversible without completely re-deploying the application. Always be sure you really want to do this!
If you're making a minor change, just run `terraform apply` again instead, it knows what you change and can make the modification for you!


---

I hope these instructions prove useful to anyone wanting to use this project to learn about Terraform. 
I tried to add lots of comments to exlain what each section tries to accomplish.
Take care!
#### Tiras Gimpel
