# create fabric resources

resource "apstra_ipv4_pool" "loopback" {
  name = "loopback"
  subnets = [
    { network = "192.0.2.0/24" }
  ]
}

resource "apstra_ipv4_pool" "p2p" {
  name = "p2p"
  subnets = [
    { network = "198.51.100.0/24" }
  ]
}

resource "apstra_asn_pool" "asn_pool" {
  name = "asn_pool"
  ranges = [
    {
      first = 64512
      last  = 64999
    }
  ]
}

# IP pools for L3 links to GPUs for Backend Network

resource "apstra_ipv4_pool" "l3_to_gpu" {
  name = "l3_to_gpu"
  subnets = [
    { network = "172.16.10.0/24" },
    { network = "172.16.11.0/24" },
    { network = "172.16.12.0/24" }
  ]
}

# IP pools for L3 links to Storage for Storage Network

resource "apstra_ipv4_pool" "l3_to_storage" {
  name = "l3_to_storage"
  subnets = [
    { network = "172.16.20.0/24" },
    { network = "172.16.21.0/24" },
    { network = "172.16.22.0/24" }
  ]
}