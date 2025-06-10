<!-- # Local Module

- A networking module that should:

1. Create a vpc with a given CIDR block.
2. Allows the users to provide configurations for multiple subnets.
    1. The user should be able to mark a subnet as public or private.
        1. If atleast one subnet is public then we need to create a IGW.
        2. We need to associate the public subnet to a public RTB.
    2. The user should be able to provide CIDR blocks.
    3. The user should be able to provide AWS AZ. Also we have to write a validation block for this seperately by using precondition in a lifecycle block. Added a Multiline error message for full details.
Note: Lets put object variables instead of primitives. -->

# Local Module for Networking with Terraform

## Overview

This project demonstrates the creation and usage of a local Terraform module for networking. The module is designed to create a VPC with configurable subnets, route tables, and an internet gateway (if required). It allows users to provide custom configurations for subnets, including CIDR blocks, availability zones, and public/private subnet designation. The module also includes validation for user inputs using lifecycle preconditions.

## Features

### 1. VPC Creation

- Dynamically creates a VPC with a user-defined CIDR block.

### 2. Configurable Subnets

- Allows users to define multiple subnets with custom configurations.
- Subnet configurations include:
  -CIDR blocks.
  -Availability zones.
  -Public or private designation.

### 3. Public Subnet Support

- Automatically creates an Internet Gateway (IGW) if at least one subnet is marked as public.
- Associates public subnets with a public route table.

### 4. Validation with Lifecycle Preconditions

- Ensures that the provided availability zones are valid for the selected AWS region.
- Includes a detailed, multi-line error message for invalid configurations.

### 5. Object Variables

- Uses object variables for subnet configurations instead of primitive variables for better flexibility and scalability.

## Usage

### 1. Module Input Variables

The module accepts the following input variables:

- vpc_config:

  - Defines the VPC configuration.
  - Example:

```hcl
vpc_config = {
  name = "my-vpc"
  cidr = "10.0.0.0/16"
}
```

- subnet_config:

  - Defines the configuration for subnets.
  - Example:

```hcl
subnet_config = {
  public-subnet-1 = {
    cidr_block = "10.0.1.0/24"
    az         = "us-east-1a"
    public     = true
  }
  private-subnet-1 = {
    cidr_block = "10.0.2.0/24"
    az         = "us-east-1b"
    public     = false
  }
}
```

### 2. Module Outputs

The module provides the following outputs:

- vpc_id: The ID of the created VPC.
- public_subnets: A list of IDs for public subnets.
- private_subnets: A list of IDs for private subnets.
- igw_id: The ID of the Internet Gateway (if created).

### 3. Example Usage

Here’s an example of how to use the module in your Terraform configuration:

```hcl
module "networking" {
  source = "./modules/networking"

  vpc_config = {
    name = "my-vpc"
    cidr = "10.0.0.0/16"
  }

  subnet_config = {
    public-subnet-1 = {
      cidr_block = "10.0.1.0/24"
      az         = "us-east-1a"
      public     = true
    }
    private-subnet-1 = {
      cidr_block = "10.0.2.0/24"
      az         = "us-east-1b"
      public     = false
    }
  }
}
```

## Project Structure

- modules/networking/vpc.tf:

  - Contains the Terraform code for creating the VPC, subnets, route tables, and internet gateway.
  - Includes lifecycle preconditions for validating availability zones.

- variables.tf:

  - Defines the input variables for the module.

- outputs.tf:

  - Specifies the outputs for the module.

- providers.tf:

  - Contains the providers for the module.

## Validation

The module includes a validation block using lifecycle preconditions to ensure that:

1. The provided availability zones are valid for the selected AWS region.
2. A detailed error message is displayed if invalid availability zones are provided.

Example error message:

```text
Subnet Key: public-subnet-1
Availability Zones: us-east-1a, us-east-1b, us-east-1c
AWS Current Region: us-east-1
Invalid AZ: us-east-1z
```

## Notes

- Ensure that the availability zones provided in subnet_config are valid for the selected AWS region.
- Use the terraform plan command to validate the configuration before applying changes.
- The module is designed to be reusable and can be extended for additional networking components.
