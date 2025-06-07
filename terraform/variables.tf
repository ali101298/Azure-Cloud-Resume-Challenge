# declaring all our tf variables with default values here 

variable "project_name" {
  description = "Name of the project"
  type = string
  default = ""
}

variable "environment" {
    description = "Environment name"
    type = string
    default = ""
}

variable "location" {
    description = "Azure region"
    type = string
    default = ""
}

variable "tags" {
    description = "Tags to apply to all resources"
    type = map(string)
    default = {
        Project = ""
        Environment = ""
        ManagedBy = ""
        Owner = ""
    }
}