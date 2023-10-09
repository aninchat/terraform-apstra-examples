# retrieve ID for frontend leaf logical device

data "apstra_logical_device" "frontend_leafs" {
    name = "AOS-26x100+6x400-1"
}

# retrieve ID for frontend spines

data "apstra_logical_device" "frontend_spines" {
    name = "AOS-32x400-2"
}

# retrieve ID for storage spines

data "apstra_logical_device" "storage_spines" {
    name = "AOS-32x400-2"
}