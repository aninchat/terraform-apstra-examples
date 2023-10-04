# 5220-32C is a 32x400G device which allows for multiple ports speeds
# and breakouts. In this use case, we want 6x400G for uplinks (to spines)
# and the remaining to be 100G ports for downlinks (to servers)
# Thus, the interface map builds a 26x100G + 6x400G device below.

locals {
  # local.if_map spells out two ranges of mappings for our
  # second interface map: 48x10G ports and 6x40G ports.
  if_map = [
    { # map logical 1/1 - 1/26 to physical et-0/0/0 - et-0/0/25
      # this is for 26x100G on 5220-32C
      ld_panel       = 1
      ld_first_port  = 1
      phy_prefix     = "et-0/0/"
      phy_first_port = 0
      count          = 26
    },
    { # map logical 2/1 - 2/6 to physical et-0/0/26 - et-0/0/32
      # this is for 6x400G ports on 5220-32C
      ld_panel       = 2
      ld_first_port  = 1
      phy_prefix     = "et-0/0/"
      phy_first_port = 26
      count          = 6
    },
  ]
  # local.interfaces loops over the elements of if_map
  # (panel 1 and panel 2).
  # within each iteration, it loops 'count' times
  # (every interface in the panel)
  # to build up the detailed mapping between logical and physical ports.
  interfaces = [
    for map in local.if_map : [
      for i in range(map.count) : {
        logical_device_port     = format("%d/%d", map.ld_panel, map.ld_first_port + i)
        physical_interface_name = format("%s%d", map.phy_prefix, map.phy_first_port + i)
      }
    ]
  ]
}

resource "apstra_interface_map" "qfx5220_im" {
  name              = "Juniper_QFX5220-32CD____AOS-26x100+6x400-1"
  logical_device_id = data.apstra_logical_device.frontend_leafs.id
  device_profile_id = "Juniper_QFX5220-32CD_Junos"
  interfaces        = flatten([local.interfaces])
}