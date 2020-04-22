# ---------------------------------------------------------------------------------------------------------------------
# Environmental variables
# You probably want to define these as environmental variables.
# Instructions on that are here: https://github.com/cloud-partners/oci-prerequisites
# ---------------------------------------------------------------------------------------------------------------------

# Required by the OCI Provider
variable "tenancy_ocid" {
}

variable "compartment_ocid" {
}

variable "region" {
}

# Key used to SSH to OCI VMs
variable "ssh_public_key" {
}

# ---------------------------------------------------------------------------------------------------------------------
# Optional variables
# The defaults here will give you a cluster.  You can also modify these.
# ---------------------------------------------------------------------------------------------------------------------

variable "node_shape" {
  default     = "VM.Standard2.4"
  description = "Instance shape to deploy for each node."
}

variable "node_count" {
  default     = "3"
  description = "Number of nodes to deploy."
}

# Ignored if ad_name non-empty
variable "ad_number" {
  default     = 1
  description = "Which availability domain to deploy to depending on quota, zero based."
}

# Not used for normal terraform apply, added for ORM deployments.
variable "ad_name" {
  default = ""
}

variable "disk_size" {
  default     = 500
  description = "Size of block volume in GB for data, min 50. If set to 0 volume will not be created/mounted."
}

variable "disk_count" {
  default     = 0
  description = "Number of disks to create for each node. Multiple disks will create a RAID0 array."
}

# ---------------------------------------------------------------------------------------------------------------------
# Network variables
# ---------------------------------------------------------------------------------------------------------------------

variable "vcn_display_name" {
  default = "testVCN"
}

variable "vcn_cidr" {
  default = "10.0.0.0/16"
}

# ---------------------------------------------------------------------------------------------------------------------
# Marketplace variables
# ---------------------------------------------------------------------------------------------------------------------


variable "mp_listing_id" {
  default = "ocid1.appcataloglisting.oc1..aaaaaaaadiac3nglcrwfadxgnnqk3kedu73sigacpeibvmsyy2tr3it5x2gq"
}

variable "mp_listing_resource_id" {
  default = "ocid1.image.oc1..aaaaaaaagxifvo6c2yvximfkyjippelig5jptmuo5wybo6odyp7m3fajx7oa"
}

variable "mp_listing_resource_version" {
  default = "1.0"
}

variable "use_marketplace_image" {
  default = true
}
