# Arch-to-Infra-engine

PoC that transforms AWS architecture diagrams into validated and security-compliant Terraform configurations.

An engineer uploads a diagram. Amazon Bedrock extracts it into a reviewable **Architecture IR**, and an engineer confirms the IR. A multi-agent workflow on Amazon Bedrock AgentCore then generates Terraform using only approved, version-pinned modules. Generated code is validated with `terraform plan`, OPA, tflint and checkov, with automatic repair, and goes to a person for final approval.

See [docs/DESIGN.md](docs/DESIGN.md) for the full solution design.

## Repository layout

| Path | Contents |
|---|---|
| `docs/` | Solution design, and later the runbook and playbook |
| `src/ir/` | Architecture IR JSON Schema, examples, validation helpers |
| `tests/` | Unit and golden tests |
| `samples/` | Test diagrams (see [samples/README.md](samples/README.md)) |

More folders (`infra/`, `src/api/`, `src/agents/`, `modules/`, `policies/`, …) are added as each phase is built. See DESIGN.md §14.

## Development setup

Prerequisites: [uv](https://docs.astral.sh/uv/), Terraform ≥ 1.10, and the AWS CLI v2 with access to the sandbox account.

```bash
uv sync                  # creates/updates .venv (Python 3.12) with all dependencies
uv run pytest            # run tests
uv run ruff check .      # lint
uv run ruff format .     # format
```

The engine is deployed to **us-east-1**, and the region is set explicitly in code. For ad-hoc CLI commands, run `export AWS_REGION=us-east-1`.
