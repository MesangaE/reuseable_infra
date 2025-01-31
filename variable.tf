
variable "enable_versioning"{
  description = "in case of accidental delete"
 type = bool
}
variable "bucket_name" {
  description = "globally unique name of bucket"
 type = string
}

variable "Environment" {
  type = string
}
  

  
