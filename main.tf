# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

# Create a VPC
resource "aws_vpc" "terraform_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Terraform_vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Terraform_pubsubnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {  
    Name = "Terraform_prisubnet"
  }
}


# Create an Internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "Terraform_igw"
  }
}  

#Create Route table
resource "aws_route_table" "terraform_RT" {
  vpc_id = aws_vpc.terraform_vpc.id  
  route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
  }
  
  tags = {
    Name = "terraform_RT"
  }
}

# Create security_group
resource "aws_security_group" "terraform_sg" {
  name        = "terraform_sg"
  description = "Allow http and ssh inbound traffic"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

  
  ingress {
    
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }
    
   
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "Terraform_sg"
  }
}


# Create route table association
resource "aws_route_table_association" "terraform_RT" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.terraform_RT.id
} 

  
# Create an ec2_instance
resource "aws_instance" "terraform_ec2" {
  #ami = data.aws_ami.web.id
  ami = "ami-0ba62214afa52bec7" 
  instance_type = var.instancetype
  key_name    = var.key_name
  monitoring  = false
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  subnet_id        = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  depends_on      = [aws_internet_gateway.gw]

  tags = {
    Name = "Terraform_Ec2"
 }
}

#data "aws_ami" "web" {
#    most_recent = true
#    owners      = ["812818276534"] # Canonical

#    filter {
#      name   = "name"
#      values = ["rhel7_ima*"]
#    }
#}

output "instance_ips" {
  value = aws_instance.terraform_ec2.public_ip
}


resource "aws_cloudwatch_metric_alarm" "foobar" {
  alarm_name                = "terraform-test-foobar5"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "Terraform_Ec2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "70"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
}


resource "aws_cloudwatch_metric_alarm" "foobar1" {
  alarm_name                = "terraform-test-foobar6"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "Harddisk"
  namespace                 = "Terraform_Ec2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "70"
  alarm_description         = "This metric monitors ec2 Hard disk"
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "foobar2" {
  alarm_name                = "terraform-test-foobar7"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "Memory I/O Ops"
  namespace                 = "Terraform_Ec2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "70"
  alarm_description         = "This metric monitors ec2 Memory I/O Ops"
  insufficient_data_actions = []
}





 
