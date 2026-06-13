# Copy to terraform.tfvars. Do not commit terraform.tfvars.

aws_region  = "eu-north-1"
environment = "dev-d"
application = "cdec-alpha-d"

acm_certificate_arn = "arn:aws:acm:us-east-1:329504364887:certificate/bf9084f6-550e-4b97-b7e5-45d966320b18"

# Use a domain you own — example.com is reserved by AWS and will fail
dns_zone_name   = "awsproject.shop"
dns_record_name = "www.awsproject.shop"
