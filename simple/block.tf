# block volumes for data

# Volume Core Servers
resource "oci_core_volume" "Core-Priv-Volume1" {
  count               = "${var.instance_count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "Node Core-Priv ${format("%01d", count.index)} Volume 1"
  size_in_gbs         = 700

  freeform_tags = {
    "Quickstart" = "{\"Deployment\":\"TF\", \"Publisher\":\"Neo4j\", \"Offer\":\"neo4j-enterprise\",\"Licence\":\"byol\"}"

    "otherTagKey" = "otherTagVal"
  }
}

resource "oci_core_volume_attachment" "NodeCore-Priv-Attachment1" {
  count           = "${var.instance_count}"
  attachment_type = "iscsi"
  instance_id     = "${oci_core_instance.core-priv.*.id[count.index]}"
  volume_id       = "${oci_core_volume.Core-Priv-Volume1.*.id[count.index]}"
}

# Volume Read Replica Servers
resource "oci_core_volume" "Read-Priv-Volume1" {
  count               = "${var.instance_count}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0],"name")}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "Node Read-Priv ${format("%01d", count.index)} Volume 1"
  size_in_gbs         = 700

  freeform_tags = {
    "Quickstart" = "{\"Deployment\":\"TF\", \"Publisher\":\"Neo4j\", \"Offer\":\"neo4j-enterprise\",\"Licence\":\"byol\"}"

    "otherTagKey" = "otherTagVal"
  }
}

resource "oci_core_volume_attachment" "NodeRead-Priv-Attachment1" {
  count           = "${var.instance_count}"
  attachment_type = "iscsi"
  instance_id     = "${oci_core_instance.read-priv.*.id[count.index]}"
  volume_id       = "${oci_core_volume.Read-Priv-Volume1.*.id[count.index]}"
}
