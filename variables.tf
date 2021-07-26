variable "vcn_id" {}
variable "cidr" {}
variable "name" {}
variable "public" {}

variable "acl" {
  default = {
    ingress = {}
    egress = {}
  }
}
