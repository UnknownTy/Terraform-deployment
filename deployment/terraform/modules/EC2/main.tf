data "cloudinit_config" "server_config" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/socialEnv.yml", {
      db_ip: var.DBip
      db_user: var.DBUsername
      db_password : var.DBPassword
      db_name: var.DBName
      s3_region: var.region
      s3_name: var.S3_name
    })
  }
}

data "aws_ami" "social_ami" {
    most_recent = true
    name_regex = "socialSomething-app-*"
    owners = ["self"]
}
resource "aws_launch_template" "application_template" {
    name_prefix = "Social_Something-"
    image_id = data.aws_ami.social_ami.id
    instance_type = "t2.micro"

    vpc_security_group_ids = [var.private_sg]
    user_data = data.cloudinit_config.server_config.rendered
    iam_instance_profile {
      arn = var.instance_profile_arn
    }
}
resource "aws_autoscaling_group" "application_scaling" {
    vpc_zone_identifier = var.private_subnets
    max_size = 5
    min_size = 3

    target_group_arns = [var.target_arn]

    launch_template {
        id = aws_launch_template.application_template.id
        version = "$Latest"
    }
}

// resource "aws_instance" "social_app_1" {
//     instance_type = "t2.micro"
//     ami = data.aws_ami.social_ami.id
//     subnet_id = var.private_subnets[0]

//     vpc_security_group_ids = [var.private_sg]

//     user_data = data.cloudinit_config.server_config.rendered
//     tags = {
//         Name = "Social App 1"
//     }
// }
// resource "aws_instance" "social_app_2" {
//     instance_type = "t2.micro"
//     ami = data.aws_ami.social_ami.id
//     subnet_id = var.private_subnets[1]

//     vpc_security_group_ids = [var.private_sg]

//     user_data = data.cloudinit_config.server_config.rendered
//     tags = {
//         Name = "Social App 2"
//     }
// }
// resource "aws_instance" "social_app_3" {
//     instance_type = "t2.micro"
//     ami = data.aws_ami.social_ami.id
//     subnet_id = var.private_subnets[2]

//     vpc_security_group_ids = [var.private_sg]

//     user_data = data.cloudinit_config.server_config.rendered
//     tags = {
//         Name = "Social App 3"
//     }
// }