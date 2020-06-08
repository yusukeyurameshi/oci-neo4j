resource "oci_core_instance" "core-priv" {
  display_name        = "core-priv-${count.index}"
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
    hostname_label   = "core-${count.index}"
	assign_public_ip = "false"
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key

    user_data = base64encode(join("\n", list(
      "#!/usr/bin/env bash",
      file("../scripts/core.sh")
    )))
  }

  freeform_tags = {
    "Quickstart" = "{\"Deployment\":\"TF\", \"Publisher\":\"Neo4j\", \"Offer\":\"neo4j-enterprise\",\"Licence\":\"byol\"}"

    "otherTagKey" = "otherTagVal"
  }

  count = var.Instance_count
}

output "Core-Priv-server-private-IPs" {
  value = join(",", oci_core_instance.core-priv.*.private_ip)
}