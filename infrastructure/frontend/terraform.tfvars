# Copy to terraform.tfvars. Do not commit terraform.tfvars.

aws_region  = "eu-north-1"
environment = "dev"
application = "cdec-alpha-d"

acm_certificate_arn = "arn:aws:acm:us-east-1:072929087802:certificate/6d0b49e3-641c-40d1-a290-e65ec5f82982"

# Use a domain you own — example.com is reserved by AWS and will fail
dns_zone_name   = "ashaorganicsprocessunit.shop"
dns_record_name = "www.ashaorganicsprocessunit.shop"
