"""Structural tests for the Architecture IR JSON Schema (src/ir/schema.json)."""

import copy
import json

import pytest
from jsonschema import Draft202012Validator, FormatChecker

from ir import EXAMPLES_DIR, load_schema


@pytest.fixture(scope="module")
def validator() -> Draft202012Validator:
    schema = load_schema()
    Draft202012Validator.check_schema(schema)
    return Draft202012Validator(schema, format_checker=FormatChecker())


@pytest.fixture
def example() -> dict:
    return json.loads((EXAMPLES_DIR / "three_tier_web.json").read_text(encoding="utf-8"))


def _resource(ir: dict, rid: str) -> dict:
    return next(r for r in ir["resources"] if r["id"] == rid)


def _errors(validator: Draft202012Validator, ir: dict) -> list[str]:
    return [e.message for e in validator.iter_errors(ir)]


@pytest.mark.parametrize("path", sorted(EXAMPLES_DIR.glob("*.json")), ids=lambda p: p.name)
def test_examples_are_valid(validator, path):
    ir = json.loads(path.read_text(encoding="utf-8"))
    assert _errors(validator, ir) == []


def test_reviewed_stage_with_review_block_is_valid(validator, example):
    ir = copy.deepcopy(example)
    ir["stage"] = "reviewed"
    ir["review"] = {"reviewed_by": "engineer@example.com", "reviewed_at": "2026-11-24T16:00:00Z"}
    assert _errors(validator, ir) == []


def test_inferred_resource_with_rationale_is_valid(validator, example):
    ir = copy.deepcopy(example)
    ir["resources"].append(
        {
            "id": "sg_app",
            "type": "security_group",
            "label": "App tier security group",
            "origin": "inferred",
            "confidence": 1.0,
            "parent": "vpc_main",
            "rationale": "Derived from link l_alb_app (ALB -> app on 8080).",
            "properties": {
                "attached_to": ["asg_app"],
                "ingress": [
                    {
                        "from_resource": "alb_web",
                        "port": 8080,
                        "protocol": "tcp",
                        "derived_from_link": "l_alb_app",
                    }
                ],
            },
        }
    )
    assert _errors(validator, ir) == []


# Each case mutates a copy of the valid example; the schema must reject it.
INVALID_CASES = {
    "bad_cidr": lambda ir: _resource(ir, "vpc_main")["properties"].update(cidr="10.0.0.0/33"),
    "unknown_type_specific_property": lambda ir: _resource(ir, "rds_main")["properties"].update(
        publicly_accessible=True
    ),
    "inferred_without_rationale": lambda ir: _resource(ir, "users").update(origin="inferred"),
    "reviewed_without_review_block": lambda ir: ir.update(stage="reviewed"),
    "out_of_scope_resource_type": lambda ir: _resource(ir, "alb_web").update(type="lambda"),
    "port_out_of_range": lambda ir: ir["links"][0].update(port=70000),
    "confidence_above_one": lambda ir: _resource(ir, "igw").update(confidence=1.5),
    "bad_id_format": lambda ir: _resource(ir, "igw").update(id="IGW-1"),
    "wrong_ir_version": lambda ir: ir.update(ir_version="2.0"),
    "invalid_environment": lambda ir: ir["deployment"].update(environment="staging"),
    "empty_resources": lambda ir: ir.update(resources=[]),
    "unexpected_top_level_field": lambda ir: ir.update(terraform="resource {}"),
    "sg_rule_with_both_sources": lambda ir: ir["resources"].append(
        {
            "id": "sg_bad",
            "type": "security_group",
            "label": "bad",
            "origin": "engineer",
            "confidence": 1.0,
            "properties": {
                "ingress": [
                    {
                        "from_resource": "alb_web",
                        "from_cidr": "0.0.0.0/0",
                        "port": 80,
                        "protocol": "tcp",
                    }
                ]
            },
        }
    ),
}


@pytest.mark.parametrize("mutate", INVALID_CASES.values(), ids=INVALID_CASES.keys())
def test_invalid_ir_is_rejected(validator, example, mutate):
    ir = copy.deepcopy(example)
    mutate(ir)
    assert _errors(validator, ir), "schema accepted an invalid IR"
