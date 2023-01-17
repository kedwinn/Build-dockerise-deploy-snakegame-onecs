resource "aws_vpc" "demovpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "demovpc"
  }
}

resource "aws_subnet" "pubsub1" {
  count = 2
  vpc_id            = aws_vpc.demovpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2"
  map_public_ip_on_launch = true
  tags = {
    Name = "pubsub1"
  }
}

resource "aws_route_table" "RTA" {
  vpc_id = aws_vpc.demovpc.id
}

reaource "aws_route_table_association" "RTA"{
  vpc_id = aws_vpc.demovpc.id
  subnet_id = aws_subnet.punsub1.vpc_id
  }


resource "aws_security_group" "snake_game" {
  name        = "snake_game"
  description = "snake_game security group"
  vpc_id      = aws_vpc.demovpc.id

  ingress {
    from_port   = 80
    to_port     = 80
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


