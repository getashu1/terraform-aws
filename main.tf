provider "aws" {
region     = "us-east-1"
}


resource "aws_vpc" "dc1" {
  cidr_block       = "10.10.0.0/16"
  tags = {
    Name = "dc1"
  }
}


#--  Create Internet Gateway
resource "aws_internet_gateway" "dc1_igw" {
 vpc_id = "${aws_vpc.dc1.id}"
 tags = {
    Name = "dc1-igw"
 }
}


# -- Create Elastic IP


resource "aws_eip" "eip" {
  vpc=true
}


# -- -------- Subnet Creation 

data "aws_availability_zones" "azs" {
  state = "available"
}



resource "aws_subnet" "public-subnet-1a" {
  availability_zone = "${data.aws_availability_zones.azs.names[0]}"
  cidr_block        = "10.10.20.0/24"
  vpc_id            = "${aws_vpc.dc1.id}"
  map_public_ip_on_launch = "true"
  tags = {
   Name = "public-subnet-1"
   }
}


resource "aws_subnet" "public-subnet-1b" {
  availability_zone = "${data.aws_availability_zones.azs.names[1]}"
  cidr_block        = "10.10.21.0/24"
  vpc_id            = "${aws_vpc.dc1.id}"
  map_public_ip_on_launch = "true"
  tags = {
   Name = "public-subnet-1b"
   }
}



resource "aws_subnet" "private-subnet-1a" {
  availability_zone = "${data.aws_availability_zones.azs.names[0]}"
  cidr_block        = "10.10.30.0/24"
  vpc_id            = "${aws_vpc.dc1.id}"
  tags = {
   Name = "private-subnet-1a"
   }
}


resource "aws_subnet" "private-subnet-1b" {
  availability_zone = "${data.aws_availability_zones.azs.names[1]}"
  cidr_block        = "10.10.31.0/24"
  vpc_id            = "${aws_vpc.dc1.id}"
  tags = {
   Name = "private-subnet-1b"
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





# --------------  NAT Gateway 

resource "aws_nat_gateway" "dc1-ngw" {
  allocation_id = "${aws_eip.eip.id}"
  subnet_id = "${aws_subnet.public-subnet-1b.id}"
  tags = {
      Name = "DC1 Nat Gateway"
  }
}


# ------------------- Routing ----------


resource "aws_route_table" "dc1-public-route" {
  vpc_id =  "${aws_vpc.dc2.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.dc1_igw.id}"
  }

   tags = {
       Name = "dc1-public-route"
   }
}


resource "aws_default_route_table" "dc1-default-route" {
  default_route_table_id = "${aws_vpc.dc1.default_route_table_id}"
  tags = {
      Name = "dc1-default-route"
  }
}



#--- Subnet Association -----

resource "aws_route_table_association" "arts1a" {
  subnet_id = "${aws_subnet.public-subnet-1a.id}"
  route_table_id = "${aws_route_table.dc1-public-route.id}"
}


resource "aws_route_table_association" "arts1b" {
  subnet_id = "${aws_subnet.public-subnet-1b.id}"
  route_table_id = "${aws_route_table.dc1-public-route.id}"
}


resource "aws_route_table_association" "arts-p-1a" {
  subnet_id = "${aws_subnet.private-subnet-1a.id}"
  route_table_id = "${aws_vpc.dc1.default_route_table_id}"
}

resource "aws_route_table_association" "arts-p-1b" {
  subnet_id = "${aws_subnet.private-subnet-1b.id}"
  route_table_id = "${aws_vpc.dc1.default_route_table_id}"
}






output "dc_out" {
value = "${aws_vpc.dc1}"
}

output "azs_out" {
value = "${data.aws_availability_zones.azs}"
}