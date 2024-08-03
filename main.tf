provider "aws" {
    region = "us-west-1"
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "vpc-main"
    }
}

resource "aws_subnet" "subnet-1" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.0.0/24"
    tags = {
        Name = "subnet-1"
    }
}

resource "aws_security_group" "web-sg-1" {
    vpc_id = aws_vpc.main.id

    ingress {
        to_port     = 80
        from_port   = 80
        cidr_blocks = ["0.0.0.0/0"]
        protocol    = "tcp"
    }

    egress {
        to_port     = 0
        from_port   = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "web-sg-1"
    }
}

resource "aws_security_group" "db-sg-1" {
    vpc_id = aws_vpc.main.id

    ingress {
        to_port     = 3306
        from_port   = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }

    egress {
        to_port     = 0
        from_port   = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "db-sg-1"
    }
}

resource "aws_instance" "web" {
    ami             = "ami-0c55b159cbfafe1f0"
    instance_type   = "t2.micro"
    security_groups = [aws_security_group.web-sg-1.name]
    subnet_id       = aws_subnet.subnet-1.id

    tags = {
        Name = "WebServer"
    }
}

resource "aws_db_instance" "mydatabase" {
    db_name                   = "mydatabase"
    engine                    = "mysql"
    allocated_storage         = 20
    instance_class            = "db.t2.micro"
    username                  = "foo"
    password                  = "pass"
    vpc_security_group_ids    = [aws_security_group.db-sg-1.id]
    db_subnet_group_name      = aws_db_subnet_group.main.name

    tags = {
        Name = "mydatabase"
    }
}

resource "aws_db_subnet_group" "main" {
    name       = "main-subnet-group"
    subnet_ids = [aws_subnet.subnet-1.id]

    tags = {
        Name = "main-subnet-group"
    }
}
