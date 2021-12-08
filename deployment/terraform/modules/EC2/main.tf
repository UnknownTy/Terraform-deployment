// Cloud init that sets the app.env
data "cloudinit_config" "server_config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/socialEnv.yml", {
      db_ip : var.DBip
      db_user : var.DBUsername
      db_password : var.DBPassword
      db_name : var.DBName
      s3_region : var.region
      s3_name : var.S3_name
    })
  }
}
// Source most recent application AMI
data "aws_ami" "social_ami" {
  most_recent = true
  name_regex  = "socialSomething-app-*"
  owners      = ["self"]
}

// Launch tempplate for the application.
// Builds on a free EC2 Instance & connects up to cloudwatch
resource "aws_launch_template" "application_template" {
  name_prefix   = "Social_Something-"
  image_id      = data.aws_ami.social_ami.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [var.private_sg]
  user_data              = data.cloudinit_config.server_config.rendered
  iam_instance_profile {
    arn = var.instance_profile_arn
  }
}

// Autoscaling group
resource "aws_autoscaling_group" "application_scaling" {
  vpc_zone_identifier = var.private_subnets
  max_size            = 5
  min_size            = 3

  target_group_arns = [var.target_arn]

  launch_template {
    id      = aws_launch_template.application_template.id
    version = "$Latest"
  }
}

#TEST APPLICATION - Only enable to create a secondary machine you can SSH into.
# Use this to add the database schema to the RDS.
# First install MySQL to it, then use the mysql_dump_command output to automatically dump the schema to the DB.
# Afterwards this section can be commented out again to be removed.

// resource "aws_instance" "test_application" {
//   instance_type = "t2.micro"
//   ami           = data.aws_ami.social_ami.id
//   subnet_id     = var.public_subnet

//   key_name                    = var.ssh_key
//   associate_public_ip_address = true

//   vpc_security_group_ids = [var.test_sg_id]

//   user_data = data.cloudinit_config.server_config.rendered
//   tags = {
//     Name = "Test Application"
//   }
// }