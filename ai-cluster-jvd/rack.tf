# local variables used to build racks

locals {
  backend_rack_qfx5220_leaf_count = 8
  backend_rack_qfx5230_leaf_count = 8
  frontend_rack_qfx5220_leaf_count = 2
  gpu_storage_rack_qfx5220_leaf_count = 2
  weka_storage_rack_qfx5220_leaf_count = 2
  backend_rack_qfx5220_leaf_definition = {
    logical_device_id = apstra_logical_device.AI-Leaf-QFX5220_16x400_32x200.id
    spine_link_count  = 1
    spine_link_speed  = "400G"
  }
  backend_rack_qfx5230_leaf_definition = {
    logical_device_id = apstra_logical_device.AI-Leaf-QFX5230_32x400_64x200.id
    spine_link_count  = 1
    spine_link_speed  = "400G"
  }
  frontend_rack_qfx5220_leaf_definition = {
    logical_device_id = data.apstra_logical_device.frontend_leafs.id
    spine_link_count  = 1
    spine_link_speed  = "400G"
  }
  gpu_storage_rack_qfx5220_leaf_definition = {
    logical_device_id = apstra_logical_device.AI-Leaf-QFX5220_16x400_32x200.id
    spine_link_count  = 2
    spine_link_speed  = "400G"
  }
  weka_storage_rack_qfx5220_leaf_definition = {
    logical_device_id = apstra_logical_device.AI-Leaf-QFX5220_16x400_32x200.id
    spine_link_count  = 1
    spine_link_speed  = "400G"
  }
}

# create rack for frontend network

# an example rack type looks like:
# resource "apstra_rack_type" "frontend_rack" {
#   name                       = "Frontend"
#   description                = "Created by Terraform"
#   fabric_connectivity_design = "l3clos"
#   leaf_switches = {
#     leaf1 = { // "leaf switch" on this line is the name used by links targeting this switch.
#       logical_device_id   = data.apstra_logical_device.frontend_leafs.id
#       spine_link_count    = 2
#       spine_link_speed    = "400G"
#     },
#     leaf2 = { // "leaf switch" on this line is the name used by links targeting this switch.
#       logical_device_id   = data.apstra_logical_device.frontend_leafs.id
#       spine_link_count    = 2
#       spine_link_speed    = "400G"
#     }
#   }
#   generic_systems = {
#     A100 = {
#       count             = 8
#       logical_device_id = "AOS-1x100-1"
#       links = {
#         link = {
#           speed              = "100G"
#           target_switch_name = "leaf1"
#           tag_ids = [apstra_tag.host_tags["frontend_a100"].id]
#         }
#       }
#     },
#     Storage = {
#       count             = 8
#       logical_device_id = "AOS-1x100-1"
#       links = {
#         link = {
#           speed              = "100G"
#           target_switch_name = "leaf2"
#           tag_ids = [apstra_tag.host_tags["frontend_storage"].id]
#         }
#       }
#     },
#     H100 = {
#       count             = 4
#       logical_device_id = "AOS-1x100-1"
#       links = {
#         link = {
#           speed              = "100G"
#           target_switch_name = "leaf1"
#           tag_ids = [apstra_tag.host_tags["frontend_h100"].id]
#         }
#       }
#     },
#     Headend_Servers = {
#       count             = 3
#       logical_device_id = "AOS-1x100-1"
#       links = {
#         link = {
#           speed              = "100G"
#           target_switch_name = "leaf1"
#           tag_ids = [apstra_tag.host_tags["frontend_headend"].id]
#         }
#       }
#     }
#   }
# }

resource "apstra_rack_type" "frontend_rack" {
  name                       = "Frontend"
  description                = "Created by Terraform"
  fabric_connectivity_design = "l3clos"
  leaf_switches = {
    for i in range(local.frontend_rack_qfx5220_leaf_count) : "Leaf${i + 1}" => local.frontend_rack_qfx5220_leaf_definition
  }
  generic_systems = {
    A100_Frontend = {
      count             = 8
      logical_device_id = "AOS-1x100-1"
      links = {
        link = {
          speed              = "100G"
          target_switch_name = "Leaf1"
          tag_ids = [apstra_tag.host_tags["frontend_a100"].id]
        }
      }
    },
    Weka_Storage_Frontend = {
      count             = 8
      logical_device_id = apstra_logical_device.Weka-Mgmt_1x100G.id
      links = {
        link = {
          speed              = "100G"
          target_switch_name = "Leaf2"
          tag_ids = [apstra_tag.host_tags["frontend_storage"].id]
        }
      }
    },
    H100_Frontend = {
      count             = 4
      logical_device_id = "AOS-1x100-1"
      links = {
        link = {
          speed              = "100G"
          target_switch_name = "Leaf1"
          tag_ids = [apstra_tag.host_tags["frontend_h100"].id]
        }
      }
    },
    Headend_Servers_Frontend = {
      count             = 3
      logical_device_id = "AOS-1x100-1"
      links = {
        link = {
          speed              = "100G"
          target_switch_name = "Leaf1"
          tag_ids = [apstra_tag.host_tags["frontend_headend"].id]
        }
      }
    }
  }
}

# create QFX5220 based rack for backend/compute network

resource "apstra_rack_type" "backend_rack_qfx5220" {
  name                       = "Backend_QFX5220"
  description                = "Created by Terraform"
  fabric_connectivity_design = "l3clos"
  leaf_switches = {
    for i in range(local.backend_rack_qfx5220_leaf_count) : "Leaf${i + 1}" => local.backend_rack_qfx5220_leaf_definition
  }
  generic_systems = {
    A100_GPUs = {
      count             = 4
      logical_device_id = apstra_logical_device.A100-GPU_8x200G.id
      links = {
        for i in range(local.backend_rack_qfx5220_leaf_count) : "link${i + 1}" => {
          speed              = "200G"
          target_switch_name = "Leaf${i + 1}"
          tag_ids = [apstra_tag.host_tags["qfx5220_a100_gpu"].id]
        }
      }
    }
    # either A100s or H100s are used so for now, H100 is commented out
    # uncomment H100s and comment A100s if you want to use H100s instead
  #   H100_GPUs = {
  #     count             = 2
  #     logical_device_id = apstra_logical_device.H100-GPU_8x400G.id
  #     links = {
  #       for i in range(local.backend_rack_qfx5220_leaf_count) : "link${i + 1}" => {
  #         speed              = "400G"
  #         target_switch_name = "leaf${i+1}"
  #         tag_ids = [apstra_tag.host_tags["qfx5220_h100_gpu"].id]
  #     }
  #   }
  # }
  }
}

# create QFX5230 based rack for backend/compute network

resource "apstra_rack_type" "backend_rack_qfx5230" {
  name                       = "Backend_QFX5230"
  description                = "Created by Terraform"
  fabric_connectivity_design = "l3clos"
  leaf_switches = {
    for i in range(local.backend_rack_qfx5230_leaf_count) : "Leaf${i + 1}" => local.backend_rack_qfx5230_leaf_definition
  }
  generic_systems = {
    A100_GPUs = {
      count             = 4
      logical_device_id = apstra_logical_device.A100-GPU_8x200G.id
      links = {
        for i in range(local.backend_rack_qfx5230_leaf_count) : "link${i + 1}" => {
          speed              = "200G"
          target_switch_name = "Leaf${i + 1}"
          tag_ids = [apstra_tag.host_tags["qfx5230_a100_gpu"].id]
        }
      }
    }
    # either A100s or H100s are used so for now, H100 is commented out
    # uncomment H100s and comment A100s if you want to use H100s instead
  #   H100_GPUs = {
  #     count             = 2
  #     logical_device_id = apstra_logical_device.H100-GPU_8x400G.id
  #     links = {
  #       for i in range(local.backend_rack_qfx5230_leaf_count) : "link${i + 1}" => {
  #         speed              = "400G"
  #         target_switch_name = "leaf${i+1}"
  #         tag_ids = [apstra_tag.host_tags["qfx5230_h100_gpu"].id]
  #     }
  #   }
  # }
  }
}

# rack for GPU Storage network

resource "apstra_rack_type" "gpu_storage_rack_qfx5220" {
  name                       = "gpu_storage"
  description                = "Created by Terraform"
  fabric_connectivity_design = "l3clos"
  leaf_switches = {
    for i in range(local.gpu_storage_rack_qfx5220_leaf_count) : "Leaf${i + 1}" => local.gpu_storage_rack_qfx5220_leaf_definition
  }
  generic_systems = {
    A100_Storage_1 = {
      count             = 4
      logical_device_id = apstra_logical_device.A100-Storage_1x200G.id
      links = {
        link1 = {
          speed              = "200G"
          target_switch_name = "Leaf1"
          tag_ids = [apstra_tag.host_tags["a100_storage"].id]
        }
      }
    }
    A100_Storage_2 = {
      count             = 4
      logical_device_id = apstra_logical_device.A100-Storage_1x200G.id
      links = {
        link1 = {
          speed              = "200G"
          target_switch_name = "Leaf2"
          tag_ids = [apstra_tag.host_tags["a100_storage"].id]
        }
      }
    }
    # uncomment H100_Storage if these need to be used and comment out A100_Storage
    # H100_Storage_1 = {
    #   count             = 2
    #   logical_device_id = apstra_logical_device.H100-Storage_2x400G.id
    #   links = {
    #     link1 = {
    #       speed              = "400G"
    #       target_switch_name = "Leaf1"
    #       tag_ids = [apstra_tag.host_tags["h100_storage"].id]
    #     }
    #     link2 = {
    #       speed              = "400G"
    #       target_switch_name = "Leaf1"
    #       tag_ids = [apstra_tag.host_tags["h100_storage"].id]
    #     }
    #   }
    # }
    # H100_Storage_2 = {
    #   count             = 2
    #   logical_device_id = apstra_logical_device.H100-Storage_2x400G.id
    #   links = {
    #     link1 = {
    #       speed              = "400G"
    #       target_switch_name = "Leaf2"
    #       tag_ids = [apstra_tag.host_tags["h100_storage"].id]
    #     }
    #     link2 = {
    #       speed              = "400G"
    #       target_switch_name = "Leaf2"
    #       tag_ids = [apstra_tag.host_tags["h100_storage"].id]
    #     }
    #   }
    # }
  }
}

# rack for Weka storage network

resource "apstra_rack_type" "weka_storage_rack_qfx5220" {
  name                       = "weka_storage"
  description                = "Created by Terraform"
  fabric_connectivity_design = "l3clos"
  leaf_switches = {
    for i in range(local.weka_storage_rack_qfx5220_leaf_count) : "Leaf${i + 1}" => local.weka_storage_rack_qfx5220_leaf_definition
  }
  generic_systems = {
    Weka_Storage_1 = {
      count             = 4
      logical_device_id = apstra_logical_device.Weka-Storage_2x200G.id
      links = {
        link1 = {
          speed              = "200G"
          target_switch_name = "Leaf1"
          tag_ids = [apstra_tag.host_tags["weka_storage"].id]
        }
        link2 = {
          speed              = "200G"
          target_switch_name = "Leaf1"
          tag_ids = [apstra_tag.host_tags["weka_storage"].id]
        }
      }
    }
    Weka_Storage_2 = {
      count             = 4
      logical_device_id = apstra_logical_device.Weka-Storage_2x200G.id
      links = {
        link1 = {
          speed              = "200G"
          target_switch_name = "Leaf2"
          tag_ids = [apstra_tag.host_tags["weka_storage"].id]
        }
        link2 = {
          speed              = "200G"
          target_switch_name = "Leaf2"
          tag_ids = [apstra_tag.host_tags["weka_storage"].id]
        }
      }
    }
  }
}