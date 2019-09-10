# ---------------------------------------------------------------------------------------------------------------------
# Marketplace variables
# ---------------------------------------------------------------------------------------------------------------------

variable "mp_listing_id" {
  default = ""
}
variable "mp_listing_resource_id" {
  default = ""
}
variable "mp_listing_resource_version" {
 default = ""
}

variable "use_marketplace_image" {
  default = true
}

variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}

# ---------------------------------------------------------------------------------------------------------------------
# Optional variables
# The defaults here will give you a cluster.  You can also modify these.
# ---------------------------------------------------------------------------------------------------------------------

variable "ssh_public_key" {}

variable "node_shape" {
  default     = "VM.Standard2.4"
  description = "Instance shape to deploy for each node."
}

variable "node_count" {
  default     = "3"
  description = "Number of nodes to deploy."
}

# Must be negative to be ignored to allow for schema.yaml/GUI selection of ad_name
variable "ad_number" {
  default = -1
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
# Constants
# You probably don't need to change these.
# ---------------------------------------------------------------------------------------------------------------------

# Unused in a mkpl deployment
variable "platform-images" {
  type = "map"

  default = {
    ap-seoul-1     = "ocid1.image.oc1.ap-seoul-1.aaaaaaaalhbuvdg453ddyhvnbk4jsrw546zslcfyl7vl4oxfgplss3ovlm4q"
    ap-tokyo-1     = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaamc2244t7h3gwrrci5z4ni2jsulwcg76gugupkb6epzrypawcz4hq"
    ca-toronto-1   = "ocid1.image.oc1.ca-toronto-1.aaaaaaaakjkxzw33dcocgu2oylpllue34tjtyngwru7pcpqn4qh2nwon7n7a"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaandqh4s7a3oe3on6osdbwysgddwqwyghbx4t4ryvtcwk5xikkpvhq"
    uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaa2xe7cufdwkksdazshtmqaddgd72kdhiyoqurtoukjklktf4nxkbq"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaa4bfsnhv2cd766tiw5oraw2as7g27upxzvu7ynqwipnqfcfwqskla"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaavtjpvg4njutkeu7rf7c5lay6wdbjhd4cxis774h7isqd6gktqzoa"
  }
}
