#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

required_files=(
  README.md
  CONTRIBUTING.md
  codemagic.yaml
  Config/Signing.local.xcconfig.example
  Docs/ENVIRONMENT.md
  Docs/ACCESS_AND_SIGNING.md
  Docs/DEVICE_LAB.md
  Docs/OWNERSHIP_AND_GATES.md
  Docs/TROUBLESHOOTING.md
  Docs/EVIDENCE/PLAY-41_ENVIRONMENT_GATE.md
  Scripts/Fixtures/EnvironmentProbe.swift
  Scripts/ci_environment_check.sh
  Scripts/validate_codemagic.py
)

for required_file in "${required_files[@]}"; do
  if [[ ! -s "$required_file" ]]; then
    echo "ERROR: required bootstrap file is missing or empty: $required_file" >&2
    exit 1
  fi
done

bash -n Scripts/validate_bootstrap.sh
bash -n Scripts/ci_environment_check.sh

python3 Scripts/validate_codemagic.py

git diff --check
git diff --cached --check

while IFS= read -r tracked_file; do
  case "$tracked_file" in
    *.cer|*.p8|*.p12|*.pem|*.key|*.mobileprovision|.env|.env.*|*/.env|*/.env.*|Config/Signing.local.xcconfig)
      echo "ERROR: forbidden credential material is tracked: $tracked_file" >&2
      exit 1
      ;;
  esac
done < <(git ls-files)

if git grep -n -E -- \
  '-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----|ghp_[A-Za-z0-9]{30,}|sk_live_[A-Za-z0-9]{16,}' \
  -- . ':(exclude)Scripts/validate_bootstrap.sh'; then
  echo "ERROR: probable secret material found in tracked content" >&2
  exit 1
fi

echo "Bootstrap validation passed."
