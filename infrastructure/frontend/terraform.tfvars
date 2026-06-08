# Copy to terraform.tfvars. Do not commit terraform.tfvars.

aws_region  = "eu-west-1"
environment = "dev"
application = "cdec-alpha-frontend"

acm_certificate_arn = "arn:aws:acm:eu-west-1:439055361064:certificate/63eddd95-dbfd-4e57-bff5-cc35eb17e2ce"

# Use a domain you own — example.com is reserved by AWS and will fail
dns_zone_name   = "thecloudnine.in"
dns_record_name = "www.thecloudnine.in"
