
terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }

    random = {
      source = "hashicorp/random"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  required_version = "~> 1.8.5"
}

provider "oci" {
  # Authentication is handled through environment variables or config file:
  # - OCI_TENANCY_OCID
  # - OCI_USER_OCID
  # - OCI_FINGERPRINT
  # - OCI_PRIVATE_KEY_PATH
  # - OCI_REGION
  # Or use ~/.oci/config file
}

provider "random" {}

provider "tls" {}
