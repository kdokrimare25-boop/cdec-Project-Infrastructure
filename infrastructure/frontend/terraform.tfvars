# Copy to terraform.tfvars. Do not commit terraform.tfvars.

aws_region  = "eu-west-1"
environment = "dev"
application = "cdec-alpha-frontend"

# bucket_name = "cdec-alpha-dev-frontend"

# cloudfront_aliases  = ["www.example.com"]
# acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/..."

dns_zone_name   = "example.com"
dns_record_name = "www.example.com"
