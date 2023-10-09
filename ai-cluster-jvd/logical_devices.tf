# Logical Device for Juniper PTX10008 
# this includes 2xPTX10K-LC1201-36CD which is 36x400G per LC

locals {
  ptx_card_count = 2
  ptx_card_definition = {
    rows    = 2
    columns = 18
    port_groups = [
      {
        port_count = 36
        port_speed = "400G"
        port_roles = ["superspine", "spine", "leaf", "unused", "generic"]
      },
    ]
  }
}

resource "apstra_logical_device" "AI-Spine-PTX_72x400" {
  name   = "AI-Spine 72x400"
  panels = [for i in range(local.ptx_card_count) : local.ptx_card_definition]
}

# Logical Device for a QFX5220 Leaf used in the AI Backend/Compute network
# this includes 16x400G and the other 16 ports broken out into 32x200G
# 16x400G is for uplinks to spines, while 32x200G is for downlinks to A100 GPUs

resource "apstra_logical_device" "AI-Leaf-QFX5220_16x400_32x200" {
  name = "AI-Leaf 16x400 and 32x200"
  panels = [
    {
      rows    = 2
      columns = 24
      port_groups = [
        {
          port_count = 16
          port_speed = "400G"
          port_roles = ["superspine", "spine", "leaf", "peer", "access", "generic", "unused"]
        },
        {
          port_count = 32
          port_speed = "200G"
          port_roles = ["superspine", "spine", "leaf", "peer", "access", "generic", "unused"]
        },
      ]
    }
  ]
}

# Logical Device for QFX5230-64 Leaf in the AI Backend/Compute network
# this includes 32x400G and the other 32 ports are broken out into 64x200G
# this is with the assumption that the Device Profile is already pre-loaded into Apstra 4.2.0 since
# it does not natively exist on that version of Apstra

resource "apstra_logical_device" "AI-Leaf-QFX5230_32x400_64x200" {
  name = "AI-Leaf 32x400 and 64x200"
  panels = [
    {
      rows    = 2
      columns = 48
      port_groups = [
        {
          port_count = 32
          port_speed = "400G"
          port_roles = ["superspine", "spine", "leaf", "peer", "access", "generic", "unused"]
        },
        {
          port_count = 64
          port_speed = "200G"
          port_roles = ["superspine", "spine", "leaf", "peer", "access", "generic", "unused"]
        },
      ]
    }
  ]
}

# Logical Device for Nvidia A100 GPU connection for backend network
# this is 1x200G connection uplink to each leaf, which means 8x200G per stripe

resource "apstra_logical_device" "A100-GPU_8x200G" {
  name = "A100 Server GPU 8x200G"
  panels = [
    {
      rows    = 2
      columns = 4
      port_groups = [
        {
          port_count = 8
          port_speed = "200G"
          port_roles = ["leaf", "access"]
        },
      ]
    }
  ]
}

# Logical Device for Nvidia A100 GPU connection for Storage network

resource "apstra_logical_device" "A100-Storage_1x200G" {
  name = "A100 Server Storage 1x200G"
  panels = [
    {
      rows    = 1
      columns = 1
      port_groups = [
        {
          port_count = 1
          port_speed = "200G"
          port_roles = ["leaf", "access"]
        },
      ]
    }
  ]
}

# NVIDIA DGX H100
#
# Standard networking: 1x 100 Gb/s Ethernet
# Storage Networking: 2x QSPF112 400 Gb/s InfiniBand/Ethernet, 
# GPUDirect RDMA Networking: 4x OSFP ports serving 8x single-port NVIDIA ConnectX-7 VPI 400 Gb/s InfiniBand/Ethernet

# Logical Device for Nvidia H100 GPU connection for backend network
# this is 1x400G connection uplink to each leaf, which means 8x400G per stripe

resource "apstra_logical_device" "H100-GPU_8x400G" {
  name = "H100 Server GPU 8x200G"
  panels = [
    {
      rows    = 2
      columns = 4
      port_groups = [
        {
          port_count = 8
          port_speed = "400G"
          port_roles = ["leaf", "access"]
        },
      ]
    }
  ]
}

resource "apstra_logical_device" "H100-Storage_2x400G" {
  name = "H100 Server Storage 2x400G"
  panels = [
    {
      rows    = 1
      columns = 2
      port_groups = [
        {
          port_count = 2
          port_speed = "400G"
          port_roles = ["leaf", "access"]
        },
      ]
    }
  ]
}

# Logical Device for Weka storage nodes

resource "apstra_logical_device" "Weka-Mgmt_1x100G" {
  name = "Weka Server Mgmt 1x100G"
  panels = [
    {
      rows    = 1
      columns = 1
      port_groups = [
        {
          port_count = 1
          port_speed = "100G"
          port_roles = ["leaf", "access"]
        },
      ]
    }
  ]
}

resource "apstra_logical_device" "Weka-Storage_2x200G" {
  name = "Weka Server Storage 2x200G"
  panels = [
    {
      rows    = 1
      columns = 2
      port_groups = [
        {
          port_count = 2
          port_speed = "200G"
          port_roles = ["leaf", "access"]
        },
      ]
    }
  ]
}