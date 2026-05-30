# CDEC Frontend

React + TypeScript + Vite single-page application for the CDEC course enrollment UI. Static assets are built locally and deployed to **S3**, served through **CloudFront** (see [`infrastructure/frontend/`](../../infrastructure/frontend/README.md)).

## Prerequisites

| Tool | Version | Notes |
|------|---------|-------|
| Node.js | 20.x | Matches the Docker build image |
| npm | 10.x+ | Bundled with Node |
| AWS CLI | v2 | Required only for S3 deploy |
| Terraform | 1.x | Required only to read bucket/distribution outputs |

Configure AWS credentials before deploying (profile or environment variables):

```bash
export AWS_DEFAULT_REGION=eu-west-1
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
```

## Environment variables

Vite reads API URLs at **build time**. Copy the example file and adjust values for your environment:

```bash
cd application/frontend
cp env.example .env
```

| Variable | Description |
|----------|-------------|
| `VITE_AUTH_API` | Authentication API base URL |
| `VITE_COURSE_API` | Courses API base URL |
| `VITE_ENROLL_API` | Enrollments API base URL |

Example values (from `env.example`):

```bash
VITE_AUTH_API=https://api.thecloudnine.in/api/auth
VITE_COURSE_API=https://api.thecloudnine.in/api/courses
VITE_ENROLL_API=https://api.thecloudnine.in/api/enroll
```

## Run locally (development)

From the repository root:

```bash
cd application/frontend
npm ci
npm run dev
```

Open the URL printed by Vite (typically `http://localhost:5173`). The dev server supports hot module replacement.

Other useful commands:

```bash
npm run lint      # ESLint
npm run preview   # Serve the production build locally
```

## Build for production

```bash
cd application/frontend
npm ci
npm run build
```

This runs TypeScript compilation and Vite bundling. Output is written to `dist/`.

To verify the build locally before uploading:

```bash
npm run preview
```

## Deploy to S3

Infrastructure (S3 bucket + CloudFront + DNS) is managed by Terraform in `infrastructure/frontend/`. Apply that stack first if it is not already provisioned:

```bash
cd infrastructure/frontend
cp backend.hcl.example backend.hcl    # if not already configured
cp terraform.tfvars.example terraform.tfvars
terraform init -backend-config=backend.hcl
terraform apply -var-file=terraform.tfvars
```

Then build and upload from a Linux shell:

```bash
# 1. Build the SPA (uses .env for API URLs)
cd application/frontend
npm ci
npm run build

# 2. Resolve bucket and CloudFront distribution from Terraform
BUCKET=$(terraform -chdir=../../infrastructure/frontend output -raw s3_bucket_name)
DIST_ID=$(terraform -chdir=../../infrastructure/frontend output -raw cloudfront_distribution_id)

# 3. Sync static assets to S3 (--delete removes stale files)
aws s3 sync dist/ "s3://${BUCKET}/" --delete

# 4. Invalidate CloudFront cache so users get the new build
aws cloudfront create-invalidation \
  --distribution-id "$DIST_ID" \
  --paths "/*"
```

One-liner (after `npm run build`):

```bash
BUCKET=$(terraform -chdir=../../infrastructure/frontend output -raw s3_bucket_name) && \
DIST_ID=$(terraform -chdir=../../infrastructure/frontend output -raw cloudfront_distribution_id) && \
aws s3 sync dist/ "s3://${BUCKET}/" --delete && \
aws cloudfront create-invalidation --distribution-id "$DIST_ID" --paths "/*"
```

After deploy, the site is available at the CloudFront domain or your configured DNS name:

```bash
terraform -chdir=../../infrastructure/frontend output cloudfront_domain_name
terraform -chdir=../../infrastructure/frontend output dns_record_fqdns
```

## Run with Docker (optional)

Build and run the production nginx image locally:

```bash
cd application/frontend

docker build \
  --build-arg VITE_AUTH_API=https://api.thecloudnine.in/api/auth \
  --build-arg VITE_COURSE_API=https://api.thecloudnine.in/api/courses \
  --build-arg VITE_ENROLL_API=https://api.thecloudnine.in/api/enroll \
  -t cdec-frontend .

docker run --rm -p 5173:5173 cdec-frontend
```

Open `http://localhost:5173`.

## Project layout

```text
application/frontend/
├── src/              # React components, contexts, API client
├── public/           # Static assets copied as-is to dist/
├── dist/             # Production build output (gitignored)
├── env.example       # Template for .env
├── vite.config.ts
├── Dockerfile        # nginx-based production image
└── package.json
```

## Related documentation

- Frontend infrastructure (Terraform, Jenkins): [`infrastructure/frontend/README.md`](../../infrastructure/frontend/README.md)
- Remote Terraform state: [`infrastructure/REMOTE_STATE.md`](../../infrastructure/REMOTE_STATE.md)
