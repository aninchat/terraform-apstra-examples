# create local grouping of leafs and spines and their IMs

locals {
    frontend_leafs = {
        frontend_001_leaf1 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5220_26x100_6x400_IM.id 
        }
        frontend_001_leaf2 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5220_26x100_6x400_IM.id 
        }
    }
    frontend_spines = {
        spine1 = {
            initial_interface_map_id = "Juniper_QFX5220-32CD__AOS-32x400-2" # spines are just 32x400G LDs
        }
        spine2 = {
            initial_interface_map_id = "Juniper_QFX5220-32CD__AOS-32x400-2" # spines are just 32x400G LDs
        }
    }
    backend_leafs = {
        backend_qfx5220_001_leaf1 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5220_16x400_32x200_IM.id 
        }
        backend_qfx5220_001_leaf2 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5220_16x400_32x200_IM.id 
        }
        backend_qfx5220_001_leaf3 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5220_16x400_32x200_IM.id 
        }
        backend_qfx5220_001_leaf4 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5220_16x400_32x200_IM.id 
        }
        backend_qfx5220_001_leaf5 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5220_16x400_32x200_IM.id 
        }
        backend_qfx5220_001_leaf6 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5220_16x400_32x200_IM.id 
        }
        backend_qfx5220_001_leaf7 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5220_16x400_32x200_IM.id 
        }
        backend_qfx5220_001_leaf8 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5220_16x400_32x200_IM.id 
        }
        backend_qfx5230_001_leaf1 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5230_32x400_64x200_IM.id 
        }
        backend_qfx5230_001_leaf2 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5230_32x400_64x200_IM.id 
        }
        backend_qfx5230_001_leaf3 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5230_32x400_64x200_IM.id 
        }
        backend_qfx5230_001_leaf4 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5230_32x400_64x200_IM.id 
        }
        backend_qfx5230_001_leaf5 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5230_32x400_64x200_IM.id 
        }
        backend_qfx5230_001_leaf6 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5230_32x400_64x200_IM.id 
        }
        backend_qfx5230_001_leaf7 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5230_32x400_64x200_IM.id 
        }
        backend_qfx5230_001_leaf8 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5230_32x400_64x200_IM.id 
        }
    }
    backend_spines = {
        spine1 = {
            initial_interface_map_id = apstra_interface_map.AI-Spine-PTX10008_72x400_IM.id
        }
        spine2 = {
            initial_interface_map_id = apstra_interface_map.AI-Spine-PTX10008_72x400_IM.id
        }
    }
    storage_leafs = {
        gpu_storage_001_leaf1 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5220_16x400_32x200_IM.id
        }
        gpu_storage_001_leaf2 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5220_16x400_32x200_IM.id
        }
        weka_storage_001_leaf1 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5220_16x400_32x200_IM.id
        }
        weka_storage_001_leaf2 = {
            initial_interface_map_id = apstra_interface_map.AI-Leaf-QFX5220_16x400_32x200_IM.id
        }
    }
    storage_spines = {
        spine1 = {
            initial_interface_map_id = "Juniper_QFX5220-32CD__AOS-32x400-2" # spines are just 32x400G LDs
        }
        spine2 = {
            initial_interface_map_id = "Juniper_QFX5220-32CD__AOS-32x400-2" # spines are just 32x400G LDs
        }
    }
}

# create frontend blueprint

resource "apstra_datacenter_blueprint" "frontend_blueprint" {
    name        = "AI_Frontend"
    template_id = apstra_template_rack_based.frontend_template.id
}

# create backend blueprint

resource "apstra_datacenter_blueprint" "backend_blueprint" {
    name        = "AI_Backend"
    template_id = apstra_template_rack_based.backend_template.id
}

# create storage blueprint

resource "apstra_datacenter_blueprint" "storage_blueprint" {
    name        = "AI_Storage"
    template_id = apstra_template_rack_based.storage_template.id
}

# assign interface maps to devices in blueprints

resource "apstra_datacenter_device_allocation" "assigned_frontend_leafs" {
  for_each                 = local.frontend_leafs
  blueprint_id             = apstra_datacenter_blueprint.frontend_blueprint.id
  initial_interface_map_id = each.value["initial_interface_map_id"]
  node_name                = each.key
}

resource "apstra_datacenter_device_allocation" "assigned_frontend_spines" {
  for_each                 = local.frontend_spines
  blueprint_id             = apstra_datacenter_blueprint.frontend_blueprint.id
  initial_interface_map_id = each.value["initial_interface_map_id"]
  node_name                = each.key
}

resource "apstra_datacenter_device_allocation" "assigned_backend_leafs" {
  for_each                 = local.backend_leafs
  blueprint_id             = apstra_datacenter_blueprint.backend_blueprint.id
  initial_interface_map_id = each.value["initial_interface_map_id"]
  node_name                = each.key
}

resource "apstra_datacenter_device_allocation" "assigned_backend_spines" {
  for_each                 = local.backend_spines
  blueprint_id             = apstra_datacenter_blueprint.backend_blueprint.id
  initial_interface_map_id = each.value["initial_interface_map_id"]
  node_name                = each.key
}

resource "apstra_datacenter_device_allocation" "assigned_storage_leafs" {
  for_each                 = local.storage_leafs
  blueprint_id             = apstra_datacenter_blueprint.storage_blueprint.id
  initial_interface_map_id = each.value["initial_interface_map_id"]
  node_name                = each.key
}

resource "apstra_datacenter_device_allocation" "assigned_storage_spines" {
  for_each                 = local.storage_spines
  blueprint_id             = apstra_datacenter_blueprint.storage_blueprint.id
  initial_interface_map_id = each.value["initial_interface_map_id"]
  node_name                = each.key
}

# assign resources to blueprint

resource "apstra_datacenter_resource_pool_allocation" "frontend_spine_asns" {
    blueprint_id = apstra_datacenter_blueprint.frontend_blueprint.id
    role         = "spine_asns"
    pool_ids     = [apstra_asn_pool.asn_pool.id]
}

resource "apstra_datacenter_resource_pool_allocation" "frontend_leaf_asns" {
    blueprint_id = apstra_datacenter_blueprint.frontend_blueprint.id
    role         = "leaf_asns"
    pool_ids     = [apstra_asn_pool.asn_pool.id]
}

resource "apstra_datacenter_resource_pool_allocation" "frontend_p2p_interfaces" {
    blueprint_id = apstra_datacenter_blueprint.frontend_blueprint.id
    role         = "spine_leaf_link_ips"
    pool_ids     = [apstra_ipv4_pool.p2p.id]
}

resource "apstra_datacenter_resource_pool_allocation" "frontend_leaf_loopbacks" {
    blueprint_id = apstra_datacenter_blueprint.frontend_blueprint.id
    role         = "leaf_loopback_ips"
    pool_ids     = [apstra_ipv4_pool.loopback.id]
}

resource "apstra_datacenter_resource_pool_allocation" "frontend_spine_loopbacks" {
    blueprint_id = apstra_datacenter_blueprint.frontend_blueprint.id
    role         = "spine_loopback_ips"
    pool_ids     = [apstra_ipv4_pool.loopback.id]
}

resource "apstra_datacenter_resource_pool_allocation" "backend_spine_asns" {
    blueprint_id = apstra_datacenter_blueprint.backend_blueprint.id
    role         = "spine_asns"
    pool_ids     = [apstra_asn_pool.asn_pool.id]
}

resource "apstra_datacenter_resource_pool_allocation" "backend_leaf_asns" {
    blueprint_id = apstra_datacenter_blueprint.backend_blueprint.id
    role         = "leaf_asns"
    pool_ids     = [apstra_asn_pool.asn_pool.id]
}

resource "apstra_datacenter_resource_pool_allocation" "backend_p2p_interfaces" {
    blueprint_id = apstra_datacenter_blueprint.backend_blueprint.id
    role         = "spine_leaf_link_ips"
    pool_ids     = [apstra_ipv4_pool.p2p.id]
}

resource "apstra_datacenter_resource_pool_allocation" "backend_leaf_loopbacks" {
    blueprint_id = apstra_datacenter_blueprint.backend_blueprint.id
    role         = "leaf_loopback_ips"
    pool_ids     = [apstra_ipv4_pool.loopback.id]
}

resource "apstra_datacenter_resource_pool_allocation" "backend_spine_loopbacks" {
    blueprint_id = apstra_datacenter_blueprint.backend_blueprint.id
    role         = "spine_loopback_ips"
    pool_ids     = [apstra_ipv4_pool.loopback.id]
}

resource "apstra_datacenter_resource_pool_allocation" "backend_l3_to_gpu" {
    blueprint_id = apstra_datacenter_blueprint.backend_blueprint.id
    role         = "to_generic_link_ips"
    pool_ids     = [apstra_ipv4_pool.l3_to_gpu.id]
}

resource "apstra_datacenter_resource_pool_allocation" "storage_spine_asns" {
    blueprint_id = apstra_datacenter_blueprint.storage_blueprint.id
    role         = "spine_asns"
    pool_ids     = [apstra_asn_pool.asn_pool.id]
}

resource "apstra_datacenter_resource_pool_allocation" "storage_leaf_asns" {
    blueprint_id = apstra_datacenter_blueprint.storage_blueprint.id
    role         = "leaf_asns"
    pool_ids     = [apstra_asn_pool.asn_pool.id]
}

resource "apstra_datacenter_resource_pool_allocation" "storage_p2p_interfaces" {
    blueprint_id = apstra_datacenter_blueprint.storage_blueprint.id
    role         = "spine_leaf_link_ips"
    pool_ids     = [apstra_ipv4_pool.p2p.id]
}

resource "apstra_datacenter_resource_pool_allocation" "storage_leaf_loopbacks" {
    blueprint_id = apstra_datacenter_blueprint.storage_blueprint.id
    role         = "leaf_loopback_ips"
    pool_ids     = [apstra_ipv4_pool.loopback.id]
}

resource "apstra_datacenter_resource_pool_allocation" "storage_spine_loopbacks" {
    blueprint_id = apstra_datacenter_blueprint.storage_blueprint.id
    role         = "spine_loopback_ips"
    pool_ids     = [apstra_ipv4_pool.loopback.id]
}

resource "apstra_datacenter_resource_pool_allocation" "l3_to_storage" {
    blueprint_id = apstra_datacenter_blueprint.storage_blueprint.id
    role         = "to_generic_link_ips"
    pool_ids     = [apstra_ipv4_pool.l3_to_storage.id]
}

# deploy and commit changes to frontend blueprint

# ensure all dependencies are added here so that blueprint does not commit without
# these being met

resource "apstra_blueprint_deployment" "frontend_deploy" {
  blueprint_id = apstra_datacenter_blueprint.frontend_blueprint.id
  depends_on = [
    apstra_tag.host_tags,
    apstra_datacenter_device_allocation.assigned_frontend_leafs,
    apstra_datacenter_device_allocation.assigned_frontend_spines,
    apstra_datacenter_resource_pool_allocation.frontend_spine_asns,
    apstra_datacenter_resource_pool_allocation.frontend_leaf_asns,
    apstra_datacenter_resource_pool_allocation.frontend_p2p_interfaces,
    apstra_datacenter_resource_pool_allocation.frontend_leaf_loopbacks,
    apstra_datacenter_resource_pool_allocation.frontend_spine_loopbacks,
    apstra_datacenter_virtual_network.frontend_a100_vn,
    apstra_datacenter_virtual_network.frontend_h100_vn,
    apstra_datacenter_virtual_network.frontend_headend_vn,
    apstra_datacenter_virtual_network.frontend_storage_vn,
    apstra_datacenter_connectivity_template_assignment.frontend_assign_ct_a100,
    apstra_datacenter_connectivity_template_assignment.frontend_assign_ct_h100,
    apstra_datacenter_connectivity_template_assignment.frontend_assign_ct_headend,
    apstra_datacenter_connectivity_template_assignment.frontend_assign_ct_storage
  ]

  # Version is replaced using `text/template` method. Only predefined values
  # may be replaced with this syntax. USER is replaced using values from the
  # environment. Any environment variable may be specified this way.
  comment      = "Deployment by Terraform {{.TerraformVersion}}, Apstra provider {{.ProviderVersion}}, User $USER."
}

# deploy and commit backend bluprint 

resource "apstra_blueprint_deployment" "backend_deploy" {
  blueprint_id = apstra_datacenter_blueprint.backend_blueprint.id
  depends_on = [
    apstra_tag.host_tags,
    apstra_datacenter_device_allocation.assigned_backend_leafs,
    apstra_datacenter_device_allocation.assigned_backend_spines,
    apstra_datacenter_resource_pool_allocation.backend_spine_asns,
    apstra_datacenter_resource_pool_allocation.backend_leaf_asns,
    apstra_datacenter_resource_pool_allocation.backend_p2p_interfaces,
    apstra_datacenter_resource_pool_allocation.backend_leaf_loopbacks,
    apstra_datacenter_resource_pool_allocation.backend_spine_loopbacks,
    apstra_datacenter_connectivity_template_assignment.backend_5220_assign_ct_a100,
    apstra_datacenter_connectivity_template_assignment.backend_5230_assign_ct_a100
  ]

  # Version is replaced using `text/template` method. Only predefined values
  # may be replaced with this syntax. USER is replaced using values from the
  # environment. Any environment variable may be specified this way.
  comment      = "Deployment by Terraform {{.TerraformVersion}}, Apstra provider {{.ProviderVersion}}, User $USER."
}

# deploy and commit storage bluprint 

resource "apstra_blueprint_deployment" "storage_deploy" {
  blueprint_id = apstra_datacenter_blueprint.storage_blueprint.id
  depends_on = [
    apstra_tag.host_tags,
    apstra_datacenter_device_allocation.assigned_storage_leafs,
    apstra_datacenter_device_allocation.assigned_storage_spines,
    apstra_datacenter_resource_pool_allocation.storage_spine_asns,
    apstra_datacenter_resource_pool_allocation.storage_leaf_asns,
    apstra_datacenter_resource_pool_allocation.storage_p2p_interfaces,
    apstra_datacenter_resource_pool_allocation.storage_leaf_loopbacks,
    apstra_datacenter_resource_pool_allocation.storage_spine_loopbacks
  ]

  # Version is replaced using `text/template` method. Only predefined values
  # may be replaced with this syntax. USER is replaced using values from the
  # environment. Any environment variable may be specified this way.
  comment      = "Deployment by Terraform {{.TerraformVersion}}, Apstra provider {{.ProviderVersion}}, User $USER."
}