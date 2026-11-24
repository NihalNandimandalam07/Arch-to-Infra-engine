# Terraform state bootstrap

Creates the S3 bucket and KMS key that store Terraform state for every other stack in this repo. Run it **once per account**, by hand.

## What it creates

| Resource | Settings |
|---|---|
| S3 bucket `<prefix>-tfstate-<account>-<region>` | Versioned, SSE-KMS with a bucket key, public access fully blocked, ACLs disabled, TLS-only policy, old versions expire after 90 days, `prevent_destroy` |
| KMS key + alias `alias/<prefix>-tfstate` | Yearly rotation, 30-day deletion window |

State locking uses Terraform's native S3 lock file (`use_lockfile = true`), so no DynamoDB table is needed.

## First-time setup

```bash
cd infra/bootstrap
cp terraform.tfvars.example terraform.tfvars   # set allowed_account_ids
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Move the bootstrap's own state into the bucket

The first apply uses local state, because the bucket didn't exist yet. Afterwards:

```bash
terraform output -raw backend_config > backend.hcl
echo 'key = "bootstrap/terraform.tfstate"' >> backend.hcl
cp backend.tf.example backend.tf
terraform init -migrate-state -backend-config=backend.hcl
rm -f terraform.tfstate terraform.tfstate.backup
```

`backend.hcl` and `terraform.tfvars` contain account-specific values and are gitignored.
