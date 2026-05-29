# Frontend stack — S3 + CloudFront for the Vite/React SPA

module "cloudfront" {
  source = "../modules/cloudfront"

  application = var.application
  environment = var.environment

  bucket_name       = var.bucket_name
  force_destroy     = var.force_destroy
  enable_versioning = var.enable_versioning

  aliases             = var.cloudfront_aliases
  acm_certificate_arn = var.acm_certificate_arn
  enable_spa_routing  = var.enable_spa_routing

  tags = {
    Component = "cloudfront"
  }
}

module "route53" {
  source = "../modules/route53"

  application = var.application
  environment = var.environment

  zone_name   = var.dns_zone_name
  zone_id     = var.route53_zone_id
  force_destroy = var.dns_zone_force_destroy

  records = var.dns_record_name != "" ? [
    {
      name = var.dns_record_name
      type = "A"
      alias = {
        name    = module.cloudfront.domain_name
        zone_id = module.cloudfront.hosted_zone_id
      }
    },
    {
      name = var.dns_record_name
      type = "AAAA"
      alias = {
        name    = module.cloudfront.domain_name
        zone_id = module.cloudfront.hosted_zone_id
      }
    },
  ] : []

  tags = {
    Component = "route53"
  }
}
