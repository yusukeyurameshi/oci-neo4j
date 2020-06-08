resource "oci_core_instance" "read-priv" {
  display_name        = "read-priv-${count.index}"
  compartment_id      = var.compartment_ocid
  availability_domain = lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0],"name")
  shape               = var.Instance_shape
  fault_domain = "FAULT-DOMAIN-${count.index %3 +1}"

  source_details {
    source_id   = lookup(data.oci_core_images.OLImageOCID.images[0],"id")
    source_type = "image"
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.neo4j_subnet_private.id
    hostname_label   = "read-${count.index}"
	assign_public_ip = "false"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key

    user_data = base64encode(join("\n", list(
      "#!/usr/bin/env bash",
      file("../scripts/read.sh")
    )))
  }

  freeform_tags = {
    "Quickstart" = "{\"Deployment\":\"TF\", \"Publisher\":\"Neo4j\", \"Offer\":\"neo4j-enterprise\",\"Licence\":\"byol\"}"

    "otherTagKey" = "otherTagVal"
  }

  count = var.Instance_count
}

#output "Read Priv server public IPs" {
#  value = "${join(",", oci_core_instance.read-priv.*.public_ip)}"
#}

output "Read-Priv-server-private-IPs" {
  value = join(",", oci_core_instance.read-priv.*.private_ip)
}
