# Data
data "aws_availability_zones" "available" {}

# VPC
resource "aws_vpc" "main" {
    cidr_block           = var.vpc_cidr_block
    instance_tenancy     = "default"
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
        Name                = "main",
        Owner               = var.owner
    }
}

# Public subnets
resource "aws_subnet" "public" {
    count               = "${length(var.public_subnets_cidr_block)}"
    vpc_id              = aws_vpc.main.id
    cidr_block          = "${var.public_subnets_cidr_block[count.index]}"
    availability_zone   = "${data.aws_availability_zones.available.names[count.index]}"

    tags = {
        Name            = "public-${data.aws_availability_zones.available.names[count.index]}",
        Owner           = var.owner
    }
}

# Private subnets
resource "aws_subnet" "private" {
    count               = "${length(var.private_subnets_cidr_block)}"
    vpc_id              = aws_vpc.main.id
    cidr_block          = "${var.private_subnets_cidr_block[count.index]}"
    availability_zone   = "${data.aws_availability_zones.available.names[count.index]}"

    tags = {
        Name            = "private-${data.aws_availability_zones.available.names[count.index]}",
        Owner           = var.owner
    }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id    = aws_vpc.main.id

    tags = {
        Name    = "Internet Gateway Main",
        Owner   = var.owner
    }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
    vpc        = true
    depends_on = [aws_internet_gateway.igw]
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = "${element(aws_subnet.public.*.id, 0)}"
    depends_on    = [aws_internet_gateway.igw]

    tags = {
        Name        = "NAT Gateway Main",
        Owner       = var.owner
    }
}

# Route tables
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block  = "0.0.0.0/0"
        gateway_id  = aws_internet_gateway.igw.id
    }
    tags = {
        Name        = "public",
        Owner       = var.owner
    }
}

resource "aws_route_table" "private" {
    vpc_id          = aws_vpc.main.id
    route {
        cidr_block  = "0.0.0.0/0"
        gateway_id  = aws_nat_gateway.nat_gw.id
    } 
    tags = {
        Name        = "private",
        Owner       = var.owner
    }
}

resource "aws_route_table_association" "public" {
    count          = "${length(var.public_subnets_cidr_block)}"
    subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
    count          = "${length(var.private_subnets_cidr_block)}"
    subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
    route_table_id = "${aws_route_table.private.id}"
}

# Security Groups
resource "aws_security_group" "load_balancer" {
    name            = "load-balancer"
    description     = "Security Group asociado al balanceador de carga"
    vpc_id          = aws_vpc.main.id

    tags = {
        Name        = "sg-balanceador",
        Owner       = var.owner
    }
}

resource "aws_security_group" "instances" {
    name            = "instances"
    description     = "Security Group asociado a las instancias"
    vpc_id          = aws_vpc.main.id

    tags = {
        Name        = "sg-instancias",
        Owner       = var.owner
    }
}

resource "aws_security_group" "database" {
    name            = "database"
    description     = "Security Group asociado a la capa de base de datos"
    vpc_id          = aws_vpc.main.id

    tags = {
        Name        = "sg-database",
        Owner       = var.owner
    }
}

resource "aws_security_group_rule" "load_balancer_http" {
    type                = "ingress"
    from_port           = 80
    to_port             = 80
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]
    ipv6_cidr_blocks    = ["::/0"]
    security_group_id   = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "instances_load_balancer" {
    type                        = "ingress"
    from_port                   = 5000
    to_port                     = 5000
    protocol                    = "tcp"
    source_security_group_id    = aws_security_group.load_balancer.id
    security_group_id           = aws_security_group.instances.id
}

resource "aws_security_group_rule" "instances_ssh" {
    type                        = "ingress"
    from_port                   = 22
    to_port                     = 22
    protocol                    = "tcp"
    cidr_blocks                 = [var.vpc_cidr_block]
    security_group_id           = aws_security_group.instances.id
}

resource "aws_security_group_rule" "database_instances" {
    type                        = "ingress"
    from_port                   = 3306
    to_port                     = 3306
    protocol                    = "tcp"
    source_security_group_id    = aws_security_group.instances.id
    security_group_id           = aws_security_group.database.id
}

resource "aws_security_group_rule" "load_balancer_outbound" {
    type                        = "egress"
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    cidr_blocks                 = ["0.0.0.0/0"]
    security_group_id           = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "instances_outbound" {
    type                        = "egress"
    from_port                   = 0
    to_port                     = 0
    protocol                    = "-1"
    cidr_blocks                 = ["0.0.0.0/0"]
    security_group_id           = aws_security_group.instances.id
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
    name       = "main"
    subnet_ids = aws_subnet.private.*.id

    tags = {
        Name    = "Main DB subnet group"
        Owner   = var.owner
    }
}