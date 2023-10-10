# 5220-32C is a 32x400G device which allows for multiple ports speeds
# and breakouts. In this use case, we want 6x400G for uplinks (to spines)
# and the remaining to be 100G ports for downlinks (to servers)
# Thus, the interface map builds a 26x100G + 6x400G device below.

locals {
  # local.if_map spells out two ranges of mappings for our
  # second interface map: 48x10G ports and 6x40G ports.

  qfx5220_frontend_if_map = [
    { # map logical 1/1 - 1/26 to physical et-0/0/0 - et-0/0/25
      # this is for 26x100G on 5220-32C
      ld_panel       = 1
      ld_first_port  = 1
      phy_prefix     = "et-0/0/"
      phy_first_port = 0
      count          = 26
    },
    { # map logical 2/1 - 2/6 to physical et-0/0/26 - et-0/0/32
      # this is for 6x400G on 5220-32C
      ld_panel       = 2
      ld_first_port  = 1
      phy_prefix     = "et-0/0/"
      phy_first_port = 26
      count          = 6
    },
  ]
  qfx5220_backend_if_map = [
    { # map logical 1/1 - 1/16 to physical et-0/0/0 - et-0/0/15
      # this is for 16x400G on 5220-32C
      ld_panel       = 1
      ld_first_port  = 1
      phy_prefix     = "et-0/0/"
      phy_first_port = 0
      count          = 16
      breakout_count = null
    },
    { # map logical 1/16 - 1/32 to physical et-0/0/16:0 - et-0/0/32:1
      # this is for 32x200G on 5220-32C with two breakout 200Gs per port written as et-0/0/x:0 and et-0/0/x:1
      ld_panel       = 1
      ld_first_port  = 17
      phy_prefix     = "et-0/0/"
      phy_first_port = 16
      count          = 32
      breakout_count = 2
    },
  ]
    qfx5230_backend_if_map = [
    { # map logical 1/1 - 1/32 to physical et-0/0/0 - et-0/0/31
      # this is for 32x400G on 5230-64C
      ld_panel       = 1
      ld_first_port  = 1
      phy_prefix     = "et-0/0/"
      phy_first_port = 0
      count          = 32
      breakout_count = null
    },
    { # map logical 1/33 - 1/96 to physical et-0/0/32:0 - et-0/0/64:1
      # this is for 32x200G on 5220-32C with two breakout 200Gs per port written as et-0/0/x:0 and et-0/0/x:1
      ld_panel       = 1
      ld_first_port  = 33
      phy_prefix     = "et-0/0/"
      phy_first_port = 32
      count          = 64
      breakout_count = 2
    },
  ]
  ptx10008_backend_if_map = [
    { # map logical 1/1 - 1/32 to physical et-0/0/0 - et-0/0/31
      # this is for 32x400G on slot 0 of PTX10008
      ld_panel       = 1
      ld_first_port  = 1
      phy_prefix     = "et-0/0/"
      phy_first_port = 0
      count          = 36
    },
    { # map logical 2/1 - 2/32 to physical et-1/0/0 - et-1/0/31
      # this is for 32x400G on slot 1 of PTX 10008
      ld_panel       = 2
      ld_first_port  = 1
      phy_prefix     = "et-1/0/"
      phy_first_port = 0
      count          = 36
    },
  ]
  # local.interfaces loops over the elements of if_map
  # (panel 1 and panel 2).
  # within each iteration, it loops 'count' times
  # (every interface in the panel)
  # to build up the detailed mapping between logical and physical ports.

  qfx5220_frontend_interfaces = [
    for map in local.qfx5220_frontend_if_map : [
      for i in range(map.count) : {
        logical_device_port     = format("%d/%d", map.ld_panel, map.ld_first_port + i)
        physical_interface_name = format("%s%d", map.phy_prefix, map.phy_first_port + i)
      }
    ]
  ]
  # breakout_count can be 2 (example 2x200G) or 4 (example 4x100G)
  # the conditional for phy intf name checks if breakcount_count is null or not
  # if null, it executes first option, if not, it executes second. This covers both cases (breakout and no breakout)
  # floor is used because for 2 breakouts, we need same port twice - example et-0/0/16:0 and et-0/0/16:1
  # so, we just add phy port + floor of i/breakout_count. Say i starts with 0, so this logic gives us:
  # during first run - phy_first_port + floor(0/2) -> 16 + floor(0) -> 16, which is et-0/0/16:0%2 = et-0/0/16:0
  # during second run -  phy_first_port + floor(1/2) -> 16 + floor(0.5) -> 16, which is et-0/0/16:1%2 = et-0/0/16:1

  qfx5220_backend_interfaces = [
    for map in local.qfx5220_backend_if_map : [
      for i in range(map.count) : {
        logical_device_port     = format("%d/%d", map.ld_panel, map.ld_first_port + i)
        physical_interface_name = map.breakout_count != null ? format("%s%d:%d", map.phy_prefix, map.phy_first_port + floor(i / map.breakout_count), i%map.breakout_count) : format("%s%d", map.phy_prefix, map.phy_first_port + i)
      }
    ]
  ]
  qfx5230_backend_interfaces = [
    for map in local.qfx5230_backend_if_map : [
      for i in range(map.count) : {
        logical_device_port     = format("%d/%d", map.ld_panel, map.ld_first_port + i)
        physical_interface_name = map.breakout_count != null ? format("%s%d:%d", map.phy_prefix, map.phy_first_port + floor(i / map.breakout_count), i%map.breakout_count) : format("%s%d", map.phy_prefix, map.phy_first_port + i)
      }
    ]
  ]
  ptx10008_backend_interfaces = [
    for map in local.ptx10008_backend_if_map : [
      for i in range(map.count) : {
        logical_device_port     = format("%d/%d", map.ld_panel, map.ld_first_port + i)
        physical_interface_name = format("%s%d", map.phy_prefix, map.phy_first_port + i)
      }
    ]
  ]
}

# Interface Map for a QFX5220-32C used in the AI Frontend network as a leaf

resource "apstra_interface_map" "AI-Leaf-QFX5220_26x100_6x400_IM" {
  name              = "Juniper_QFX5220-32CD____AOS-26x100+6x400-1"
  logical_device_id = data.apstra_logical_device.frontend_leafs.id
  device_profile_id = "Juniper_QFX5220-32CD_Junos"
  interfaces        = flatten([local.qfx5220_frontend_interfaces])
}

# create PTX device profile from base PTX10008 chassis profile

resource "apstra_modular_device_profile" "PTX10008_72x400_DP" {
  name               = "PTX10008_72x400"
  chassis_profile_id = "Juniper_PTX10008"
  line_card_profile_ids = {
    0 = "Juniper_PTX10K_LC1201_36CD"
    1 = "Juniper_PTX10K_LC1201_36CD"
  }
}

# Interface Map for a PTX10008 with 2xPTX10K-LC1201-36CD used in the AI Backend network as spines

resource "apstra_interface_map" "AI-Spine-PTX10008_72x400_IM" {
  name              = "PTX10008_72x400G____AI-Spine 72x400"
  logical_device_id = apstra_logical_device.AI-Spine-PTX_72x400.id
  device_profile_id = apstra_modular_device_profile.PTX10008_72x400_DP.id 
  interfaces        = flatten([local.ptx10008_backend_interfaces])
}

# Interface Map for a QFX5220-32C used in the AI Backend network as leafs

resource "apstra_interface_map" "AI-Leaf-QFX5220_16x400_32x200_IM" {
  name              = "Juniper_QFX5220-32CD____AI-Leaf 16x400 and 32x200"
  logical_device_id = apstra_logical_device.AI-Leaf-QFX5220_16x400_32x200.id
  device_profile_id = "Juniper_QFX5220-32CD_Junos"
  interfaces        = flatten([local.qfx5220_backend_interfaces])
}

# Interface Map for a QFX5230-64C used in the AI Backend network as a leaf

resource "apstra_interface_map" "AI-Leaf-QFX5230_32x400_64x200_IM" {
  name              = "Juniper_QFX5230-64CD____AI-Leaf 32x400 and 64x200"
  logical_device_id = apstra_logical_device.AI-Leaf-QFX5230_32x400_64x200.id
  device_profile_id = "Juniper_QFX5230-64CD_Junos"
  interfaces        = flatten([local.qfx5230_backend_interfaces])
}