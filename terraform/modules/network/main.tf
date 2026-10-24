locals {
  az_map = {
    for index, az in var.availability_zones :
    az => index
  }

  common_tags = merge(var.tags, {
    ManagedBy = "Terraform"
    Module    = "network"
  })
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = "${var.name}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = local.az_map

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = var.public_subnet_cidrs[each.value]
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.name}-public-${each.key}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each = local.az_map

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = var.private_subnet_cidrs[each.value]

  tags = merge(local.common_tags, {
    Name = "${var.name}-private-${each.key}"
    Tier = "private"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}


resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  for_each = local.az_map

  domain = "vpc"

  tags = merge(local.common_tags, {
    Name = "${var.name}-nat-eip-${each.key}"
  })
}

resource "aws_nat_gateway" "this" {
  for_each = local.az_map

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  depends_on = [aws_internet_gateway.this]

  tags = merge(local.common_tags, {
    Name = "${var.name}-nat-${each.key}"
  })
}


resource "aws_route_table" "private" {
  for_each = local.az_map

  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags, {
    Name = "${var.name}-private-rt-${each.key}"
  })
}

resource "aws_route" "private_nat" {
  for_each = local.az_map

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}