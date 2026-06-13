# Copy to terraform.tfvars. Do not commit terraform.tfvars.

aws_region  = "eu-north-1"
environment = "dev-d"
application = "cdec-alpha-d"

acm_certificate_arn = "arn:aws:acm:eu-north-1:329504364887:certificate/278f0c77-f159-4561-be8a-2b7f800f17ff"

# Use a domain you own — example.com is reserved by AWS and will fail
dns_zone_name   = "awsproject.shop"
dns_record_name = "www.awsproject.shop"
