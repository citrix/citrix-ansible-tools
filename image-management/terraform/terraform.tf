terraform {
  required_version = ">= 1.4.0"
    required_providers {
      ansible = {
        version = "~> 1.3.0"
        source  = "ansible/ansible"
       }
      citrix = {
        source  = "citrix/citrix"
        version = ">=1.0.7"
      }
    }
}


 provider "citrix" {
   cvad_config = {
     hostname                    = "<hostname>"
     client_id                   = "<machine-domain>\\<username>"
     client_secret               = "<password>"
     disable_ssl_verification    = "true"
   }
 }