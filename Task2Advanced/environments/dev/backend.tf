terraform {
  backend "s3" {
    bucket                      = "tfstate"
    key                         = "environments/dev/terraform.tfstate"
    region                      = "us-east-1"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true

    endpoints = {
      s3 = "http://localhost:9000"
    }
  }
}
