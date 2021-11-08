# vpc
resource "aws_vpc" "terraform-vpc1" {
  cidr_block = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "tf-vpc1"
  }
}

# internet gateway
resource "aws_internet_gateway" "terraform-gw1" {
  vpc_id = aws_vpc.terraform-vpc1.id

  tags = {
    Name = "tf-igw1"
  }
}

# public subnet
# az: ap-northeast-2a
resource "aws_subnet" "terraform-ps1" {
  vpc_id     = aws_vpc.terraform-vpc1.id
  cidr_block = "10.1.0.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "tf-ps1"
  }
}

# public routing table
resource "aws_route_table" "terraform-pr1" {
  vpc_id = aws_vpc.terraform-vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-gw1.id
  }

  tags = {
    Name = "tf-pr1"
  }
}

# apply public route table
resource "aws_route_table_association" "terraform-asspr1" {
  subnet_id      = aws_subnet.terraform-ps1.id
  route_table_id = aws_route_table.terraform-pr1.id
}

# private subnet
# web
# az: ap-northeast-2a
resource "aws_subnet" "terraform-private-web1"{
    vpc_id = aws_vpc.terraform-vpc1.id
    cidr_block = "10.1.10.0/24"
    availability_zone = "ap-northeast-2a"

    tags = {
        Name = "terraform-private-web1"
    }
}

# private subnet
# web
# az: ap-northeast-2c
resource "aws_subnet" "terraform-private-web2"{
    vpc_id = aws_vpc.terraform-vpc1.id
    cidr_block = "10.1.11.0/24"
    availability_zone = "ap-northeast-2c"

    tags = {
        Name = "terraform-private-web2"
    }
}

# private subnet
# was
# az: ap-northeast-2a
resource "aws_subnet" "terraform-private-was1"{
    vpc_id = aws_vpc.terraform-vpc1.id
    cidr_block = "10.1.20.0/24"
    availability_zone = "ap-northeast-2a"

    tags = {
        Name = "terraform-private-was1"
    }
}

# private subnet
# db1
# az: ap-northeast-2a
resource "aws_subnet" "terraform-private-db1"{
    vpc_id = aws_vpc.terraform-vpc1.id
    cidr_block = "10.1.30.0/24"
    availability_zone = "ap-northeast-2a"

    tags = {
        Name = "terraform-private-db1"
    }
}

# nat gateway
resource "aws_eip" "eip"{
    vpc = true
    tags = {
        Name = "eip"
    }
}
resource "aws_nat_gateway" "storage-ngw"{
    allocation_id = aws_eip.eip.id
    subnet_id = aws_subnet.terraform-ps1.id
    tags = {
        Name = "storage-ngw"
    }
}

# private routing table
resource "aws_route_table" "terraform-private-routetable1"{
    vpc_id = aws_vpc.terraform-vpc1.id

    tags = {
        Name = "tf-private-route1"
    }
}

# apply routing table
resource "aws_route" "private-web"{
    route_table_id = aws_route_table.terraform-private-routetable1.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.storage-ngw.id
}

resource "aws_route_table_association" "private-assRT-web1"{
    subnet_id = aws_subnet.terraform-private-web1.id
    route_table_id = aws_route_table.terraform-private-routetable1.id
}

resource "aws_route_table_association" "private-assRT-web2"{
    subnet_id = aws_subnet.terraform-private-web2.id
    route_table_id = aws_route_table.terraform-private-routetable1.id
}

resource "aws_route_table_association" "private-assRT-was1"{
    subnet_id = aws_subnet.terraform-private-was1.id
    route_table_id = aws_route_table.terraform-private-routetable1.id
}

resource "aws_route_table_association" "private-assRT-db1"{
    subnet_id = aws_subnet.terraform-private-db1.id
    route_table_id = aws_route_table.terraform-private-routetable1.id
}

