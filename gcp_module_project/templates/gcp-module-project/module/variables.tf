variable "project_prefix" {
  type = string
}

variable "environment_dict" {
  type = map(map(any))
  description = "Environment dictionary. Env name as key and Env config as value "
}