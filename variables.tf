variable "ENV" {
  default = "bertrand"
}

variable "REGION" {
  default = "ap-south-1"
}

variable "VPC" {
  type = object({
    CIDR = string
    SUBNET_PUBLIC = list(string)
  })

  default = {
    "CIDR" = "10.0.0.0/16",
    "SUBNET_PUBLIC" = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  }
}