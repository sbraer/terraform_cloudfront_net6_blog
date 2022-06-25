variable "lambda_function_name" {
  default = "lambda_function_name"
}

variable "s3bucketname" {
    description = "Bucket name"
    type = string
    default = "az-site-domain"  
}

variable "domain" {
    description = "Domain name"
    type = string
    default = "example.com"
}

variable "apisubdomain" {
    description = "Api sub Domain name"
    type = string
    default = "api"
}

variable "region" {
    description = "AWS region"
    type = string
    default = "eu-south-1"
}
