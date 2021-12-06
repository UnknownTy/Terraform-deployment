resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block

    tags = {
        Name = "Social Something Private Cloud"
    }
}


resource "aws_subnet" "ec2_priv_subnet_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.priv_ec2_subnet_1
    availability_zone = var.az1

    tags = {
        Name = "EC2 Subnet 1"
    }
}
resource "aws_subnet" "ec2_priv_subnet_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.priv_ec2_subnet_2
    availability_zone = var.az2

    tags = {
        Name = "EC2 Subnet 2"
    }
}
resource "aws_subnet" "ec2_priv_subnet_3" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.priv_ec2_subnet_3
    availability_zone = var.az3

    tags = {
        Name = "EC2 Subnet 3"
    }
}


resource "aws_subnet" "rds_priv_subnet_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.priv_rds_subnet_1
    availability_zone = var.az1

    tags = {
        Name = "RDS Subnet 1"
    }
}
resource "aws_subnet" "rds_priv_subnet_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.priv_rds_subnet_2
    availability_zone = var.az2

    tags = {
        Name = "RDS Subnet 2"
    }
}
resource "aws_subnet" "rds_priv_subnet_3" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.priv_rds_subnet_3
    availability_zone = var.az3

    tags = {
        Name = "RDS Subnet 3"
    }
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.pub_lb_subnet_1
    availability_zone = var.az1

    tags = {
        Name = "Public Subnet 1"
    }
}
resource "aws_subnet" "public_subnet_2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.pub_lb_subnet_2
    availability_zone = var.az2

    tags = {
        Name = "Public Subnet 2"
    }
}
resource "aws_subnet" "public_subnet_3" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.pub_lb_subnet_3
    availability_zone = var.az3

    tags = {
        Name = "Public Subnet 3"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "Social Something Internet Connection"
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    route {
        ipv6_cidr_block = "::/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    tags = {
        Name = "Public Route Table"
    }
}

resource "aws_route_table_association" "public_1_rt_a" {
    subnet_id = aws_subnet.public_subnet_1.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_2_rt_a" {
    subnet_id = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_3_rt_a" {
    subnet_id = aws_subnet.public_subnet_3.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "public_sg" {
    name = "HTTP"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "private_sg" {
  name   = "Private HTTP"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "database_sg" {
  name        = "allow_mysql"
  description = "Allow MySQL connections over private network"
  vpc_id      = aws_vpc.main.id
  tags = {
    Name = "allow_mysql"
  }

  ingress {
    description = "MySQL 3306 from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}