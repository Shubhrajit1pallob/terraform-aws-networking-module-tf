# variable "vpc_cidr" {
#   type = string

#   validation {
#     condition     = can(cidrnetmask(var.vpc_cidr))
#     error_message = "The variable 'vpc_cidr' must be a valid CIDR block."
#   }
# }

# variable "vpc_name" {
#   type = string
# }

data "aws_availability_zones" "available" {
  state = "available"
}

variable "vpc_config" {
  type = object({
    cidr_block = string
    name       = string
  })

  validation {
    condition     = can(cidrnetmask(var.vpc_config.cidr_block))
    error_message = "The variable 'vpc_cidr' must be a valid CIDR block."
  }
}

# This is the subnet configuration variables.
variable "subnet_config" {
  # This is a map of objects that can store multiple subnet configurations.
  type = map(object({
    cidr_block = string
    az         = string
    public     = optional(bool, false) # Optional field to indicate if the subnet is public
  }))

  validation {
    condition = alltrue([
      for config in values(var.subnet_config) : can(cidrnetmask(config.cidr_block))
    ])
    error_message = "The variable 'subnet_config' must be a valid CIDR block."
  }
}