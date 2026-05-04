# Gabrielle's Scrapbook

Your personal website — a place to share writing, art, and architecture projects.

---

## How to add a new piece of writing

1. Open your terminal and run:
   ```
   npm run dev
   ```
2. Open your browser and go to **http://localhost:4321/keystatic**
3. Click **Writing** in the left sidebar.
4. Click **New Entry** (top right).
5. Fill in the fields:
   - **Title** — the title of your piece
   - **Date** — when you wrote it
   - **Category** — choose from Poem, Essay, Journal, or Other
   - **Excerpt** — a short teaser (shown on the writing index page); max 200 characters
   - **Content** — the full text of your piece
   - **Draft** — tick this if you're not ready to publish yet
6. Click **Save**.
7. Ask your developer friend to **commit and push** the new file to publish it (see "How publishing works" below).

---

## How to add new artwork

1. Run `npm run dev` and open **http://localhost:4321/keystatic**
2. Click **Art** in the left sidebar.
3. Click **New Entry**.
4. Fill in the fields:
   - **Title** — name of the piece
   - **Date** — when it was created
   - **Medium** — Photography, Drawing, Mixed Media, or Other
   - **Image** — upload your image file (it will be saved into `public/art/`)
   - **Short Note** — an optional sentence or two about the piece
   - **Draft** — tick if not ready to publish
5. Click **Save**.
6. Ask your developer friend to commit and push to publish.

---

## How to add an architecture project

1. Run `npm run dev` and open **http://localhost:4321/keystatic**
2. Click **Architecture** in the left sidebar.
3. Click **New Entry**.
4. Fill in the fields:
   - **Title** — project name
   - **Date** — project date
   - **Typology** — Residential, Public, Commercial, Concept, or Other
   - **Year** — the year of the project
   - **Hero Image** — the main image shown on the project card and detail page
   - **Project Images** — optional additional images shown in the gallery on the project page
   - **Short Description** — a one-paragraph summary (shown in the project card)
   - **Project Description** — full write-up (shown on the project detail page)
   - **Draft** — tick if not ready to publish
5. Click **Save**.
6. Ask your developer friend to commit and push to publish.

---

## How publishing works

When you save something in Keystatic, it writes a file to your computer (in the `src/content/` folder). That file exists locally but hasn't been published to the website yet.

To publish:
1. Your developer friend commits the new files to Git.
2. They push the commit to the `main` branch on GitHub.
3. GitHub automatically triggers a build-and-deploy pipeline (GitHub Actions).
4. The site is built and deployed to AWS — usually within a minute or two.

You don't need to understand all of this — just know that **saving in Keystatic ≠ publishing**. You need someone to push the changes to GitHub before they go live.

> **Tip for your developer friend:** The site runs `npm run build` (outputs to `dist/`), then syncs `dist/` to the S3 bucket and invalidates the CloudFront cache. Secrets are configured in the GitHub repository settings under *Settings → Secrets and variables → Actions*.

---

## First-time setup for developers

### Prerequisites
- Node.js 22 (use `nvm` or install directly)
- AWS CLI configured with credentials that have S3 + CloudFront permissions
- Terraform 1.5+

### Steps

1. **Clone the repository and install dependencies**
   ```bash
   git clone <repo-url>
   cd gabymey.co.za
   npm install
   ```

2. **Run in development mode**
   ```bash
   npm run dev
   ```
   The site will be available at `http://localhost:4321`.
   The Keystatic CMS will be at `http://localhost:4321/keystatic`.

3. **Set up AWS credentials**
   Configure your AWS CLI with credentials that have the necessary permissions:
   ```bash
   aws configure
   ```
   Or use environment variables: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`.

4. **Provision infrastructure with Terraform**
   ```bash
   cd infra
   # Replace ACCOUNT_ID in s3.tf and iam.tf with your actual AWS account ID first
   terraform init
   terraform plan
   terraform apply
   ```
   After `apply`, Terraform will output:
   - `cloudfront_domain_name` — your site's URL
   - `cloudfront_distribution_id` — needed for the `CF_DIST_ID` secret
   - `s3_bucket_name` — needed for the `BUCKET_NAME` secret

5. **Set GitHub Actions secrets**
   Go to your GitHub repository → *Settings → Secrets and variables → Actions → New repository secret* and add:
   
   | Secret name | Value |
   |-------------|-------|
   | `AWS_ACCESS_KEY_ID` | Access key ID for the `Github-Actions` IAM user |
   | `AWS_SECRET_ACCESS_KEY` | Secret access key for the `Github-Actions` IAM user |
   | `AWS_REGION` | `us-east-1` (or your chosen region) |
   | `BUCKET_NAME` | Output from Terraform: `s3_bucket_name` |
   | `CF_DIST_ID` | Output from Terraform: `cloudfront_distribution_id` |

6. **Push to main to trigger the first deploy**
   ```bash
   git add .
   git commit -m "Initial deploy"
   git push origin main
   ```
   Watch the pipeline run in GitHub → *Actions* tab. When it completes, the site will be live at the CloudFront URL.

### Build without deploying
```bash
npm run build      # builds to dist/
npm run preview    # serves dist/ locally for testing
npm run check      # TypeScript type-checking
```

### Terraform notes
- Remote state is stored in S3 bucket `gabrielle-account-state`, key `gabrielle-site/terraform.tfstate` (region `us-east-1`). This bucket must exist before running `terraform init`.
- **No custom domain yet** — the site is served from the default `*.cloudfront.net` address. To add a custom domain later: add `aliases` to `cloudfront.tf`, issue an ACM certificate in `us-east-1`, and add a `viewer_certificate` block referencing it.
