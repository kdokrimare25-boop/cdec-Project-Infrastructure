# Shared Terraform modules

Reusable AWS modules consumed by stacks such as [`../frontend/`](../frontend/).

## Stacks

**Frontend** (`../frontend/main.tf`)

```text
module "cloudfront"  →  ../modules/cloudfront
module "route53"    →  ../modules/route53
```

**Backend** (`../backend/main.tf`)

```text
module "vpc"  →  ../modules/vpc
module "eks"  →  ../modules/eks   (uses vpc outputs)
```

## Modules

| Module | Responsibility | Used by |
|--------|----------------|---------|
| [cloudfront](cloudfront/) | S3 bucket + CloudFront CDN for static SPA | frontend |
| [route53](route53/) | Hosted zone + DNS records | frontend |
| [vpc](vpc/) | VPC, subnets, NAT | backend |
| [eks](eks/) | EKS cluster and node group | backend |

## Adding a module

Create `modules/<name>/` and reference from a stack: `source = "../modules/<name>"`.
