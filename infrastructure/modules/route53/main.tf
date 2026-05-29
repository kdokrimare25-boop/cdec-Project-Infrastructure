# Route 53 — hosted zone + DNS records (CloudFront aliases, etc.)

locals {
  name_prefix = var.name_prefix != null ? var.name_prefix : "${var.application}-${var.environment}"
  zone_name   = trimsuffix(var.zone_name, ".")
  base_tags = merge(
    {
      Environment = var.environment
      Application = var.application
      ManagedBy   = "terraform"
      Module      = "route53"
    },
    var.tags
  )
  # Create a new zone unless an existing zone_id is supplied
  create_zone = var.zone_id == null
  zone_id     = local.create_zone ? aws_route53_zone.this[0].zone_id : var.zone_id
}

resource "aws_route53_zone" "this" {
  count = local.create_zone ? 1 : 0

  name          = local.zone_name
  comment       = coalesce(var.comment, "Hosted zone for ${local.name_prefix}")
  force_destroy = var.force_destroy

  tags = merge(local.base_tags, {
    Name = local.zone_name
  })
}

resource "aws_route53_record" "this" {
  for_each = {
    for record in var.records : "${record.name}-${record.type}" => record
  }

  zone_id = local.zone_id
  name    = each.value.name
  type    = each.value.type

  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []
    content {
      name                   = alias.value.name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  ttl     = each.value.alias != null ? null : each.value.ttl
  records = each.value.alias != null ? null : each.value.records
}
