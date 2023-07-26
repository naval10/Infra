variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["192.16.0.0/26", "192.16.0.64/26"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["192.16.0.128/26", "192.16.0.192/26"]
}

variable "sg_ports" {
  type        = list(number)
  description = "list of ingress ports"
  default     = [8080, 443, 80, 22, 9000]
}

variable "azs" {
  type        = list(string)
  description = "Availability zones"
  default     = ["us-east-1a", "us-east-1b"]
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "192.16.0.0/24"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
   
  tags = {
    Name = "MyVPC"
  }
}

output "vpc_id" {
   value = aws_vpc.my_vpc.id
}

resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone = element(var.azs, count.index)
  
  tags = {
    Name = "Public Subnet ${count.index +1}"
  }
}

output "public_id" {
  value = aws_subnet.public_subnets[*].id
}

resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.azs, count.index)
  
  tags = {
    Name = "Private Subnet ${count.index +1}"
  }
}

output "private_id" {
 value = aws_subnet.private_subnets[*].id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "My-IGW"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-rtb"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "Private-rtb"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_security_group" "app_sg" {
  name = "ebs_sg"
  description = "Allow traffic to elasticbeanstalk"
  vpc_id = aws_vpc.my_vpc.id
  dynamic "ingress" {
    for_each = var.sg_ports
    iterator = each
    content {
      from_port  = each.value
      to_port    = each.value
      protocol   = "Tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
}
  egress {
    protocol = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks =["0.0.0.0/0"]
  }

  tags = {
    Name = "my_sg"
  }
}

output "sg_id" {
  value = aws_security_group.app_sg.id
}

resource "aws_security_group" "database_sg" {
   name = "rds"
   vpc_id = aws_vpc.my_vpc.id
   description = "Allow traffic from ebs"
   ingress {
     protocol = "Tcp"
     from_port = 3306
     to_port = 3306
     security_groups = [aws_security_group.app_sg.id]
   }
   egress {
    protocol = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks =["0.0.0.0/0"]
  }

  tags = {
    Name = "database_sg"
  }
}

output "database_id" {
  value = aws_security_group.database_sg.id
}

resource "tls_private_key" "web_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "Demo" {
  key_name = "Web_key"
  public_key = tls_private_key.web_key.public_key_openssh
}
resource "local_file" "web_key" {
   content = tls_private_key.web_key.private_key_pem
   filename = "Web_key.pem"
}

