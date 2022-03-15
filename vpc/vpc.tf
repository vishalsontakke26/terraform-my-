provider "aws" {
  region  = "us-east-2"
  profile = "aws-key"
}

resource "aws_vpc" "my-vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "172.16.11.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "private-subnet"
  }
}


resource "aws_security_group" "my-dg" {
  name   = "my-dg"
  vpc_id = aws_vpc.my-vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "my-igw"
  }
}




resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "public-rt"
  }
}
resource "aws_route_table_association" "public-as" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_key_pair" "id_rsa" {
  key_name   = "id_rsa"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDF0fAbYbfZURCsP7cQnlWID3Z+39/IHRSKu8rgJNNslIpXXEwjvfZsehcV6TTqzXnpVXoZrBmSlEYL8ObDAxRsKnVu4os9M2jvjaM06XT0TzVfyWUk8b4JQBRSj4cUit5dzTI0jG+ZHml6vcydcTwkkN6ajO9UIiwbGBITIemQGRlFJXCX32i1Luus3rIE33z023fFnNU0FCmg47Ttd0DIm7LPuPXWnOIVmKrZ0sfKufnfj4sGuvjR67bZ+lOYNQcd2MXe7glFCwHJ7difsFfHsPqoqQ2r/GEuQo5rbnxNxf6Jxy1RIShHmg2No4e/2AGirxezKlAYN8uzdSHae1N7 root@DESKTOP-B0QLM1J"
}



resource "aws_eip" "my-aws-eip" {
  instance = aws_instance.web-instance.id
  vpc      = true
}


resource "aws_instance" "web-instance" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public-subnet.id
  vpc_security_group_ids = [aws_security_group.my-dg.id]
    key_name = "id_rsa"
    tags = {
    Name = "web-instance"
  }
}

resource "aws_instance" "db-instance" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.private-subnet.id
  vpc_security_group_ids = [aws_security_group.my-dg.id]
    key_name = "id_rsa"
    tags = {
    Name = "db-instance"
  }
}

resource "aws_eip" "my-eip" {
  vpc      = true
}

resource "aws_nat_gateway" "my-nat" {
  allocation_id = aws_eip.my-eip.id
  subnet_id     = aws_subnet.public-subnet.id
 }


resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my-nat.id
  }

  tags = {
    Name = "private-rt"
  }
}
resource "aws_route_table_association" "private-as" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-rt.id
}






  

 
 