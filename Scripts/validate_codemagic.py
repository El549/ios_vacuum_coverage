#!/usr/bin/env python3
"""Dependency-free invariant checks for the deliberately small Codemagic YAML."""

from pathlib import Path
import re


yaml_text = Path("codemagic.yaml").read_text(encoding="utf-8")

required_patterns = {
    "workflows root": r"(?m)^workflows:\s*$",
    "environment workflow": r"(?m)^  ios-environment-gate:\s*$",
    "M2 runner": r"(?m)^    instance_type: mac_mini_m2\s*$",
    "pinned Xcode": r"(?m)^      xcode: 26\.6\s*$",
    "repository validation": r"bash Scripts/validate_bootstrap\.sh",
    "simulator probe": r"bash Scripts/ci_environment_check\.sh",
}

for description, pattern in required_patterns.items():
    if re.search(pattern, yaml_text) is None:
        raise SystemExit(f"ERROR: codemagic.yaml is missing invariant: {description}")

forbidden_patterns = {
    "automatic triggering": r"(?m)^    triggering:\s*$",
    "publishing": r"(?m)^    publishing:\s*$",
    "signing configuration": r"(?m)^    (?:ios_signing|integrations):\s*$",
    "secret groups": r"(?m)^      groups:\s*$",
    "floating Xcode alias": r"(?m)^      xcode: (?:latest|edge)\s*$",
}

for description, pattern in forbidden_patterns.items():
    if re.search(pattern, yaml_text) is not None:
        raise SystemExit(f"ERROR: environment workflow must not contain {description}")

print("Codemagic invariants passed.")
