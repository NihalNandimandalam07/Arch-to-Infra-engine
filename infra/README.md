# Engine infrastructure

The main Terraform stack for the engine's own AWS resources. State lives in the bucket created by [bootstrap/](bootstrap/), which must be applied first.

## Current contents

| File | Resources |
|---|---|
| `kms.tf` | Engine KMS key `alias/<prefix>-engine` (yearly rotation) |
| `storage.tf` | Artifacts bucket (per-job working files, expire after 90 days) and evidence bucket (Object Lock, default 90-day GOVERNANCE retention) |
| `modules/secure_bucket/` | Internal module: versioned, SSE-KMS, public access blocked, ACLs off, TLS only, wrong-key uploads denied, optional Object Lock |

Later phases add `api.tf`, `workflow.tf`, `agentcore.tf` and others here.

## Usage

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars          # set allowed_account_ids
terraform -chdir=bootstrap output -raw backend_config > backend.hcl
echo 'key = "engine/terraform.tfstate"' >> backend.hcl
terraform init -backend-config=backend.hcl
terraform plan -out=tfplan
terraform apply tfplan
```

## Notes

- **The evidence bucket's Object Lock can't be turned off.** In GOVERNANCE mode, an admin with `s3:BypassGovernanceRetention` can still delete locked objects, which is useful for cleanup in a sandbox. Use COMPLIANCE for production: then nobody, including root, can delete objects before their retention expires.
- **Destroying the evidence bucket requires emptying it first,** which Object Lock blocks until retention has passed (or until a governance bypass is used).
