terraform {
    required_providers {
        apstra = {
            source = "Juniper/apstra"
        }
    }
}

# provider details

provider "apstra" {
    url = "https://username:password@ip-address:443"
    tls_validation_disabled = true
    blueprint_mutex_enabled = false
    experimental = true
}