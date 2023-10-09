# use VN ID to create data source for CT for frontend network

data "apstra_datacenter_ct_virtual_network_single" "frontend_a100_vn" {
    vn_id = apstra_datacenter_virtual_network.frontend_a100_vn.id
    tagged = false
}

data "apstra_datacenter_ct_virtual_network_single" "frontend_h100_vn" {
    vn_id = apstra_datacenter_virtual_network.frontend_h100_vn.id
    tagged = false
}

data "apstra_datacenter_ct_virtual_network_single" "frontend_headend_vn" {
    vn_id = apstra_datacenter_virtual_network.frontend_headend_vn.id
    tagged = false
}

data "apstra_datacenter_ct_virtual_network_single" "frontend_storage_vn" {
    vn_id = apstra_datacenter_virtual_network.frontend_storage_vn.id
    tagged = false
}

# create IP Link data source for CT for backend L3 connections down to GPUs
# find ID of default routing zone for this

data "apstra_datacenter_routing_zone" "backend_default_rz" {
  blueprint_id = apstra_datacenter_blueprint.backend_blueprint.id
  name           = "default"
}

data "apstra_datacenter_ct_ip_link" "backend_to_gpu" {
  routing_zone_id      = data.apstra_datacenter_routing_zone.backend_default_rz.id
  ipv4_addressing_type = "numbered"
  ipv6_addressing_type = "none"
}

# create IP Link data source for CT for storage L3 connections down to GPU Storage links and Weka Storage
# find ID of default routing zone for this

data "apstra_datacenter_routing_zone" "storage_default_rz" {
  blueprint_id = apstra_datacenter_blueprint.storage_blueprint.id
  name           = "default"
}

data "apstra_datacenter_ct_ip_link" "l3_to_storage" {
  routing_zone_id      = data.apstra_datacenter_routing_zone.storage_default_rz.id
  ipv4_addressing_type = "numbered"
  ipv6_addressing_type = "none"
}

# create actual frontend CT for VNs now by attaching the primitive from the data source

resource "apstra_datacenter_connectivity_template" "frontend_a100_ct" {
  blueprint_id = apstra_datacenter_blueprint.frontend_blueprint.id
  name         = "A100_VLAN"
  description  = "A100 untagged VLAN"
  primitives   = [
    data.apstra_datacenter_ct_virtual_network_single.frontend_a100_vn.primitive
  ]
}

resource "apstra_datacenter_connectivity_template" "frontend_h100_ct" {
  blueprint_id = apstra_datacenter_blueprint.frontend_blueprint.id
  name         = "H100_VLAN"
  description  = "H100 untagged VLAN"
  primitives   = [
    data.apstra_datacenter_ct_virtual_network_single.frontend_h100_vn.primitive
  ]
}

resource "apstra_datacenter_connectivity_template" "frontend_headend_ct" {
  blueprint_id = apstra_datacenter_blueprint.frontend_blueprint.id
  name         = "Headend_VLAN"
  description  = "Headend untagged VLAN"
  primitives   = [
    data.apstra_datacenter_ct_virtual_network_single.frontend_headend_vn.primitive
  ]
}

resource "apstra_datacenter_connectivity_template" "frontend_storage_ct" {
  blueprint_id = apstra_datacenter_blueprint.frontend_blueprint.id
  name         = "Storage_VLAN"
  description  = "Storage untagged VLAN"
  primitives   = [
    data.apstra_datacenter_ct_virtual_network_single.frontend_storage_vn.primitive
  ]
}

# create the L3 IP Link CT by attaching primitive from data source

resource "apstra_datacenter_connectivity_template" "backend_to_gpu_l3_ct" {
  blueprint_id = apstra_datacenter_blueprint.backend_blueprint.id
  name         = "L3_to_GPUs"
  description  = "L3 link to GPUs for IP connectivity in IP Fabric"
  primitives   = [
    data.apstra_datacenter_ct_ip_link.backend_to_gpu.primitive
  ]
}

resource "apstra_datacenter_connectivity_template" "storage_l3_ct" {
  blueprint_id = apstra_datacenter_blueprint.storage_blueprint.id
  name         = "L3_to_Storage"
  description  = "L3 link to Storage nodes for IP connectivity in IP Fabric"
  primitives   = [
    data.apstra_datacenter_ct_ip_link.l3_to_storage.primitive
  ]
}

# gather graph IDs for all interfaces based on their tags assignments
# which point to the hosts

data "apstra_datacenter_interfaces_by_link_tag" "a100" {
    blueprint_id = apstra_datacenter_blueprint.frontend_blueprint.id
    tags         = ["frontend_a100"]
}

data "apstra_datacenter_interfaces_by_link_tag" "h100" {
    blueprint_id = apstra_datacenter_blueprint.frontend_blueprint.id
    tags         = ["frontend_h100"]
}

data "apstra_datacenter_interfaces_by_link_tag" "headend" {
    blueprint_id = apstra_datacenter_blueprint.frontend_blueprint.id
    tags         = ["frontend_headend"]
}

data "apstra_datacenter_interfaces_by_link_tag" "storage" {
    blueprint_id = apstra_datacenter_blueprint.frontend_blueprint.id
    tags         = ["frontend_storage"]
}

data "apstra_datacenter_interfaces_by_link_tag" "qfx5220_a100_gpu" {
    blueprint_id = apstra_datacenter_blueprint.backend_blueprint.id
    tags         = ["qfx5220_a100_gpu"]
}

data "apstra_datacenter_interfaces_by_link_tag" "qfx5230_a100_gpu" {
    blueprint_id = apstra_datacenter_blueprint.backend_blueprint.id
    tags         = ["qfx5230_a100_gpu"]
}

data "apstra_datacenter_interfaces_by_link_tag" "qfx5220_h100_gpu" {
    blueprint_id = apstra_datacenter_blueprint.backend_blueprint.id
    tags         = ["qfx5220_h100_gpu"]
}

data "apstra_datacenter_interfaces_by_link_tag" "qfx5230_h100_gpu" {
    blueprint_id = apstra_datacenter_blueprint.backend_blueprint.id
    tags         = ["qfx5230_h100_gpu"]
}

# assign CT to application points

# create count loop using the actual count of each generic system type
# and then loop through list using count.index when assigning application point

# count * 8 because each stripe has 8 leafs and there are two stripes, and each GPU connects to all 8 leafs

resource "apstra_datacenter_connectivity_template_assignment" "backend_5220_assign_ct_a100" {
  count = apstra_rack_type.backend_rack_qfx5220.generic_systems.A100_GPUs.count * 8
  blueprint_id              = apstra_datacenter_blueprint.backend_blueprint.id
  application_point_id      = tolist(data.apstra_datacenter_interfaces_by_link_tag.qfx5220_a100_gpu.ids)[count.index]
  connectivity_template_ids = [
    apstra_datacenter_connectivity_template.backend_to_gpu_l3_ct.id
    ]
}

resource "apstra_datacenter_connectivity_template_assignment" "backend_5230_assign_ct_a100" {
  count = apstra_rack_type.backend_rack_qfx5230.generic_systems.A100_GPUs.count * 8
  blueprint_id              = apstra_datacenter_blueprint.backend_blueprint.id
  application_point_id      = tolist(data.apstra_datacenter_interfaces_by_link_tag.qfx5230_a100_gpu.ids)[count.index]
  connectivity_template_ids = [
    apstra_datacenter_connectivity_template.backend_to_gpu_l3_ct.id
    ]
}

resource "apstra_datacenter_connectivity_template_assignment" "frontend_assign_ct_a100" {
  count = apstra_rack_type.frontend_rack.generic_systems.A100_Frontend.count
  blueprint_id              = apstra_datacenter_blueprint.frontend_blueprint.id
  application_point_id      = tolist(data.apstra_datacenter_interfaces_by_link_tag.a100.ids)[count.index]
  connectivity_template_ids = [
    apstra_datacenter_connectivity_template.frontend_a100_ct.id
    ]
}

resource "apstra_datacenter_connectivity_template_assignment" "frontend_assign_ct_h100" {
  count = apstra_rack_type.frontend_rack.generic_systems.H100_Frontend.count
  blueprint_id              = apstra_datacenter_blueprint.frontend_blueprint.id
  application_point_id      = tolist(data.apstra_datacenter_interfaces_by_link_tag.h100.ids)[count.index]
  connectivity_template_ids = [
    apstra_datacenter_connectivity_template.frontend_h100_ct.id
    ]
}

resource "apstra_datacenter_connectivity_template_assignment" "frontend_assign_ct_headend" {
  count = apstra_rack_type.frontend_rack.generic_systems.Headend_Servers_Frontend.count
  blueprint_id              = apstra_datacenter_blueprint.frontend_blueprint.id
  application_point_id      = tolist(data.apstra_datacenter_interfaces_by_link_tag.headend.ids)[count.index]
  connectivity_template_ids = [
    apstra_datacenter_connectivity_template.frontend_headend_ct.id
    ]
}

resource "apstra_datacenter_connectivity_template_assignment" "frontend_assign_ct_storage" {
  count = apstra_rack_type.frontend_rack.generic_systems.Weka_Storage_Frontend.count
  blueprint_id              = apstra_datacenter_blueprint.frontend_blueprint.id
  application_point_id      = tolist(data.apstra_datacenter_interfaces_by_link_tag.storage.ids)[count.index]
  connectivity_template_ids = [
    apstra_datacenter_connectivity_template.frontend_storage_ct.id
    ]
}