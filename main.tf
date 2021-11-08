# key pair
resource "aws_key_pair" "test-ec2" {
  key_name   = "test-ec2"
  public_key = file("./test-ec2.pub")
}

# security group
resource "aws_security_group" "demo-securitygroup" {
  name = "demo-securitygroup"
  description = "Allow SSH port from all"
  vpc_id = aws_vpc.terraform-vpc1.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-securitygroup"
  }
}

# ec2 bastion
resource "aws_instance" "bastion" {
  ami = "ami-0252a84eb1d66c2a0"
  instance_type = "t2.micro"
  key_name = aws_key_pair.test-ec2.key_name
  subnet_id = aws_subnet.terraform-ps1.id

  vpc_security_group_ids = [
    aws_security_group.demo-securitygroup.id
  ]

  tags = {
    Name = "bastion"
  }
}

# ec2 web
resource "aws_instance" "web"{
  ami = "ami-0252a84eb1d66c2a0"
  instance_type = "t2.micro"
  key_name = aws_key_pair.test-ec2.key_name
  subnet_id = aws_subnet.terraform-private-web1.id
  
  vpc_security_group_ids = [
    aws_security_group.demo-securitygroup.id
  ]
  tags = {
      Name = "web1"
  }
}

# ec2 web2
resource "aws_instance" "web2"{
  ami = "ami-0252a84eb1d66c2a0"
  instance_type = "t2.micro"
  key_name = aws_key_pair.test-ec2.key_name
  subnet_id = aws_subnet.terraform-private-web2.id
  
  vpc_security_group_ids = [
    aws_security_group.demo-securitygroup.id
  ]
  tags = {
      Name = "web2"
  }
}