variable "app_name" {
  description = "app name"
  default = "mathenger"
}

variable "aws_profile" {
  description = "AWS profile"
  default = "mathenger"
}

variable "db_name" {
  description = "name of the db"
  default = "mathenger"
}

variable "aws_region" {
  description = "AWS region"
  default = "eu-west-3"
}

variable "mysql_username" {
  description = "MySQL username"
  default = "admin"
}

variable "mysql_password" {
  description = "MySQL password"
}

variable "path_to_jar" {
  description = "Path to the Jar file of Mathenger API"
}

variable "frontend_path" {
  description = "Path to the frontend build folder"
}

variable "spring_mail_username" {
  default = "email"
  description = "Email used by Java Mail Sender"
}

variable "spring_mail_password" {
  default = "password"
  description = "Password for Java Mail Sender"
}

variable "public_key" {
  description = "Public key to access the EC2 instances"
}

