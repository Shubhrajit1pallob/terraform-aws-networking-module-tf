# 1. VPC IDs.
# 2. Objects of public subnets. subnet_key => {subnet_id, avilability_zone}
# 3. Objects of private subnets. subnet_key => {subnet_id, avilability_zone}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_info" {
  value = {
    for key in keys(local.public_subnets) : key => {
      subnet_id          = aws_subnet.this[key].id
      availability_zones = aws_subnet.this[key].availability_zone
    }
  }
}

output "private_subnet_info" {
  value = {
    for key in keys(local.private_subnets) : key => {
      subnet_id          = aws_subnet.this[key].id
      availability_zones = aws_subnet.this[key].availability_zone
    }
  }
}

output "public_subnets" {
  value = local.public_subnets
}