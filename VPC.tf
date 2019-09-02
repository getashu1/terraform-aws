provider "aws" {
region     = "us-east-1"
}


resource "aws_vpc" "dc1" {
  cidr_block       = "10.10.0.0/16"

  tags = {
    Name = "dc1"
  }
}

resource "aws_vpc" "dc2" {
  cidr_block       = "172.16.0.0/16"

  tags = {
    Name = "dc2"
  }
}


data "aws_availability_zones" "azs" {
  state = "available"
}



resource "aws_subnet" "subnet_dc1_az1" {
  availability_zone = "${data.aws_availability_zones.azs.names[0]}"
  cidr_block        = "10.10.20.0/24"
  vpc_id            = "${aws_vpc.dc1.id}"
  map_public_ip_on_launch = "true"
  tags = {
   Name = "dc1-public-subnet"
   }
}

resource "aws_subnet" "subnet_dc1_az2" {
  availability_zone = "${data.aws_availability_zones.azs.names[1]}"
  cidr_block        = "10.10.21.0/24"
  vpc_id            = "${aws_vpc.dc1.id}"
  tags = {
   Name = "dc1-private-subnet"
   }
}




resource "aws_subnet" "subnet_dc2_az1" {
  availability_zone = "${data.aws_availability_zones.azs.names[0]}"
  cidr_block        = "172.16.20.0/24"
  vpc_id            = "${aws_vpc.dc2.id}"
  map_public_ip_on_launch = "true"
  tags = {
   Name = "dc2-public-subnet"
   }
}

resource "aws_subnet" "subnet_dc2_az2" {
  availability_zone = "${data.aws_availability_zones.azs.names[1]}"
  cidr_block        = "172.16.21.0/24"
  vpc_id            = "${aws_vpc.dc2.id}"
  tags = {
   Name = "dc2-private-subnet"
   }
}







output "dc_out" {
value = "${aws_vpc.dc1}"
}

output "azs_out" {
value = "${data.aws_availability_zones.azs}"
}