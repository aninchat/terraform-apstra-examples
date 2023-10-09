# create template which takes rack ID as an input
# static overlay is used to create just a routed IP fabric

# create template for frontend network

resource "apstra_template_rack_based" "frontend_template" {
  name                     = "AI_Frontend_Template"
  asn_allocation_scheme    = "unique"
  overlay_control_protocol = "static"
  spine = {
    logical_device_id = data.apstra_logical_device.frontend_spines.id
    count             = 2
  }
  rack_infos = {
     (apstra_rack_type.frontend_rack.id) = { count = 1 }
  }
}

# create template for backend network

resource "apstra_template_rack_based" "backend_template" {
  name                     = "AI_Backend_Template"
  asn_allocation_scheme    = "unique"
  overlay_control_protocol = "static"
  spine = {
    logical_device_id = apstra_logical_device.AI-Spine-PTX_72x400.id
    count             = 2
  }
  rack_infos = {
     (apstra_rack_type.backend_rack_qfx5220.id) = { count = 1 }
     (apstra_rack_type.backend_rack_qfx5230.id) = { count = 1 }
  }
}

# create template for Storage network (which includes both GPU Storage and Weka Storage)

resource "apstra_template_rack_based" "storage_template" {
  name                     = "AI_Storage_Template"
  asn_allocation_scheme    = "unique"
  overlay_control_protocol = "static"
  spine = {
    logical_device_id = data.apstra_logical_device.storage_spines.id
    count             = 2
  }
  rack_infos = {
     (apstra_rack_type.gpu_storage_rack_qfx5220.id) = { count = 1 }
     (apstra_rack_type.weka_storage_rack_qfx5220.id) = { count = 1 }
  }
}