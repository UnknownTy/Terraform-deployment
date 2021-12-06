packer{
    required_plugins {
        amazon = {
            version = ">= 1.0.0"
            source = "github.com/hashicorp/amazon"
        }
    }

}

locals {
    region    = "ca-central-1"
    timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}


source "amazon-ebs" "socialSomething" {
    ami_name = "socialSomething-app-${local.timestamp}"
    source_ami_filter {
        filters = {
            name                = "amzn2-ami-hvm-2.*"
            root-device-type    = "ebs"
            virtualization-type = "hvm"
        }
        most_recent = true
        owners      = ["amazon"]
    }
    instance_type = "t2.micro"
    region = local.region
    ssh_username = "ec2-user"
}

build{
    sources = [
        "source.amazon-ebs.socialSomething"
    ]
    // Compress the application to a tgz for transfer
    provisioner "shell-local" {
    command = "tar -C ../../ --exclude ./deployment --exclude ./.git --exclude ./node_modules -cvzf social_something.tgz ."
  }
    // Transfer over the service file
    provisioner "file" {
        source = "./socialSomething.service"
        destination = "/tmp/socialSomething.service"
    }
    // Transfer over the generated .tgz
    provisioner "file" {
        source = "./social_something.tgz"
        destination = "/home/ec2-user/social_something.tgz"
        generated = true
    }
    // Begin bootup script
    provisioner "shell" {
        script = "./bootup.sh"
    }
}

