terraform {
	required_version = ">= 0.12.0"
}

# ---------------------------------------------------------------------------------------------------------------------
# Environmental variables
# You probably want to define these as environmental variables.
# Instructions on that are here: https://github.com/cloud-partners/oci-prerequisites
# ---------------------------------------------------------------------------------------------------------------------

# Required by the OCI Provider
variable compartment_ocid {}
variable region {}

# Key used to SSH to OCI VMs
variable ssh_public_key {}

# ---------------------------------------------------------------------------------------------------------------------
# IPSec Network Variables
# You must modify to your reality
# ---------------------------------------------------------------------------------------------------------------------
variable CPE_IPAddress { default = "1.1.1.1" }
variable IPSec_StaticRoute { default = "172.30.0.0/24" }


# ---------------------------------------------------------------------------------------------------------------------
# Optional variables
# The defaults here will give you a cluster.  You can also modify these.
# ---------------------------------------------------------------------------------------------------------------------


variable Instance_count { default = 3} #minimum 3 instances
variable Instance_shape { default = "VM.Standard2.4"}
variable InstanceOS { default = "Oracle Linux"}
variable InstanceOSVersion { default = "7.8"}