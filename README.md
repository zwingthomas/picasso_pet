# picasso_pet
A web service built with Flask & FastAPI that lets users upload a pet photo, composites it into “The Scream” by Edvard Munch, and produces merch (hoodies, shirts, hats) via Stripe and Printful, hosted on Google Cloud Platform.

graph LR
  Browser[Browser]\n  CDN[CloudFront CDN]\n  LB[ALB / Load Balancer]\n  FL[Flask App<br/>(SSR + Uploads)]\n  FA[FastAPI App<br/>(APIs & Webhooks)]\n  MQ[Redis Queue]\n  WK[Celery Workers<br/>(Pillow)]\n  PG[(PostgreSQL<br/>RDS)]\n  S3[(S3 Bucket)]\n  ST[Stripe]\n  PF[Printful API]\n  SG[SendGrid]

  Browser -->|HTTPS| CDN
  CDN --> LB
  LB --> FL
  LB --> FA
  FL -->|POST /api/upload| MQ
  FA -->|POST /api/upload| MQ
  MQ --> WK
  WK --> S3
  FL --> S3
  FA --> PG
  FA --> S3
  FA --> ST
  ST -->|Webhook| FA
  FA --> PF
  PF -->|Tracking| FA
  FA --> SG


# Components & Technology Stack

**Frontend**: React for upload/crop UI (react-easy-crop), Flask (Cloud Run) for SSR landing & catalog pages

**API Layer**: FastAPI (Cloud Run) behind Google Cloud Load Balancer

**Image Processing**: Celery workers in GKE cluster using Memorystore Redis (broker) and Pillow for fixed-coordinate compositing

**Storage**: Cloud Storage buckets for original & processed images, served via Cloud CDN

**Database**: Cloud SQL for PostgreSQL (Multi‑Zone) with SQLAlchemy ORM

**Payments**: Stripe Checkout & Webhooks

**Fulfillment**: Printful API (orders + UPS/FedEx labels)

**Email**: SendGrid for order & shipping confirmations

**Admin Dashboard**: React-based UI (Cloud Run) behind IAP or Cloud IAM for order management

**Analytics & Monitoring**: Google Analytics (funnel events), Cloud Logging & Cloud Monitoring (Redis queue metrics, HTTP latencies), Error Reporting (Sentry)

**Infra & CI/CD**: Terraform for GCP IaC (VPC, subnets, GKE, Cloud SQL, Memorystore, IAM, Load Balancer), Cloud Build for build/test & deployment

**Security**: HTTPS via Managed SSL certificates, Cloud Armor (WAF), Secret Manager for credentials, signed URL access to Cloud Storage, rate limiting on upload endpoint, ClamAV scan in worker


# Data Model (Core Tables)

```
-- Users (optional)
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Uploaded Pet Images
CREATE TABLE pet_images (
  id SERIAL PRIMARY KEY,
  user_email TEXT NOT NULL,
  orig_key TEXT NOT NULL,
  processed_key TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Products
CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  sku TEXT UNIQUE NOT NULL,
  price_cents INT NOT NULL,
  variants JSONB
);

-- Orders
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  user_email TEXT NOT NULL,
  stripe_session_id TEXT UNIQUE NOT NULL,
  status TEXT NOT NULL DEFAULT 'created',
  total_cents INT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  shipped_at TIMESTAMPTZ,
  tracking_number TEXT
);

-- Order Items
CREATE TABLE order_items (
  id SERIAL PRIMARY KEY,
  order_id INT REFERENCES orders(id),
  product_id INT REFERENCES products(id),
  pet_image_id INT REFERENCES pet_images(id),
  quantity INT NOT NULL
);
```


# Operational Flows

## 1. Upload & Crop
React upload/crop UI → POST /api/upload → save original to Cloud Storage + record in Cloud SQL → enqueue Redis job

## 2. Image Processing
Celery worker on GKE composites pet into “The Scream” → upload processed PNG to Cloud Storage → update pet_images.status to complete

## 3. Checkout
User selects product/variant → POST /api/create-checkout → create Stripe Checkout session → redirect to Stripe

## 4. Payment Webhook
Stripe calls /api/webhook/stripe → verify signature → mark order paid in Cloud SQL → send order confirmation via SendGrid → call Printful API

## 5. Fulfillment & Shipping
Printful returns tracking number → update order with tracking_number & shipped_at → send shipping email

## 6. Admin Dashboard
React UI lists & filters orders, retries failed jobs/webhooks, views logs & errors


# Scaling & Availability
**Compute**: Cloud Run services auto-scale on request volume; GKE node pools autoscale based on Redis queue depth

**Database**: Cloud SQL with high availability (regional) and read replicas for analytics

**Storage**: Cloud Storage + Cloud CDN for cached assets

**Resilience**: Cloud Armor protects edge; retry logic and circuit-breakers on Printful calls; defining alerts on Monitoring for queue backlog, HTTP error spikes, and latency thresholds


# Considerations
- Evaluate Printful vs. Printify + EasyPost integration

- Define Monitoring Alerts: e.g. Redis queue > 100 jobs or > 2 min processing time

- Plan Admin Features: refund processing, promotional codes

- Consider GPU-backed image service (AI segmentation) if composite time approaches 1 min