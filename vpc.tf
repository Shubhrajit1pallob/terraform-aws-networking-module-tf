locals {
  public_subnets = {
    # This will filter the subnets to only include those that are marked as public.
    for key, config in var.subnet_config : key => config if config.public
  }
  private_subnets = {
    # This will filter the subnets to only include those that are marked as private.
    for key, config in var.subnet_config : key => config if config.public == false
  }
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_config.cidr_block

  tags = {
    Name = var.vpc_config.name
  }
}

resource "aws_subnet" "this" {
  for_each          = var.subnet_config
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.az

  tags = {
    Name = each.key
    Access = each.value.public ? "Public" : "Private"
  }

  lifecycle {
    # This is the type of validation block that will ensure the subnet availability zones is valid.
    precondition {
      condition     = contains(data.aws_availability_zones.available.names, each.value.az)
      error_message = <<-EOT
      The provided avilability zone "${each.value.az}" for the subnet "${each.key}" is not valid.

      Please choose from the available availability zones in the current region.
      Available zones are: "[${join(", ", data.aws_availability_zones.available.names)}]"
      EOT
    }
  }
}

resource "aws_internet_gateway" "this" {
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "public_rtb" {
  count  = length(local.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }
}

resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.public_rtb[0].id
}