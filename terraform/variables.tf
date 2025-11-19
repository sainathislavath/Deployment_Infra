variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "instance_type_web" {
  default = "t3.micro"
}

variable "instance_type_db" {
  default = "t3.micro"
}

variable "ami" {
  description = "AMI ID to use"
  type        = string
  default     = "ami-00f46ccd1cbfb363e"
}

variable "key_name" {
  type    = string
  default = "sainath-sai"
}
