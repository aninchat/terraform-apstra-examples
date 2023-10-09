# create local set to loop over and create tags

locals {
  hosts = toset([
    "frontend_a100",
    "frontend_storage",
    "frontend_h100",
    "frontend_headend",
    "qfx5220_a100_gpu",
    "qfx5220_h100_gpu",
    "qfx5230_a100_gpu",
    "qfx5230_h100_gpu",
    "a100_storage",
    "h100_storage",
    "weka_storage"
  ])
}

# description is important otherwise TF thinks tags must be updated
# in place every time with an empty string

resource "apstra_tag" "host_tags" {
    for_each    = local.hosts
    name        = each.key
    description = each.key
}