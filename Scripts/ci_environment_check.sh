#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

required_xcode_version="${REQUIRED_XCODE_VERSION:-26.6}"
required_xcode_build="${REQUIRED_XCODE_BUILD:-17F113}"
required_ios_sdk_version="${REQUIRED_IOS_SDK_VERSION:-26.5}"
required_swift_prefix="${REQUIRED_SWIFT_VERSION_PREFIX:-6.3}"
deployment_target="${IOS_SIMULATOR_DEPLOYMENT_TARGET:-18.0}"
artifact_dir="build/evidence"
mkdir -p "$artifact_dir"

for command_name in xcodebuild xcrun sw_vers; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "ERROR: $command_name is required; run this probe on the pinned macOS/Xcode image." >&2
    exit 1
  fi
done

xcode_output="$(xcodebuild -version)"
actual_xcode_version="$(printf '%s\n' "$xcode_output" | awk 'NR == 1 { print $2 }')"
actual_xcode_build="$(printf '%s\n' "$xcode_output" | awk 'NR == 2 { print $3 }')"

if [[ "$actual_xcode_version" != "$required_xcode_version" ]]; then
  echo "ERROR: expected Xcode $required_xcode_version, found $actual_xcode_version." >&2
  exit 1
fi

if [[ "$actual_xcode_build" != "$required_xcode_build" ]]; then
  echo "ERROR: expected Xcode build $required_xcode_build, found $actual_xcode_build." >&2
  exit 1
fi

macos_version="$(sw_vers -productVersion)"
macos_major="${macos_version%%.*}"
macos_remainder="${macos_version#*.}"
macos_minor="${macos_remainder%%.*}"
if [[ "$macos_major" -ne 26 || "$macos_minor" -lt 2 ]]; then
  echo "ERROR: Xcode 26.6 requires macOS Tahoe 26.2 or later; found $macos_version." >&2
  exit 1
fi

actual_ios_sdk_version="$(xcrun --sdk iphonesimulator --show-sdk-version)"
if [[ "$actual_ios_sdk_version" != "$required_ios_sdk_version" ]]; then
  echo "ERROR: expected iOS Simulator SDK $required_ios_sdk_version, found $actual_ios_sdk_version." >&2
  exit 1
fi

swift_output="$(xcrun swiftc --version)"
case "$swift_output" in
  *"Swift version $required_swift_prefix"*|*"Apple Swift version $required_swift_prefix"*) ;;
  *)
    echo "ERROR: expected Swift $required_swift_prefix.x, found: $swift_output" >&2
    exit 1
    ;;
esac

runtime_output="$(xcrun simctl list runtimes available)"
case "$runtime_output" in
  *"iOS $required_ios_sdk_version"*) ;;
  *)
    echo "ERROR: iOS $required_ios_sdk_version Simulator runtime is not available." >&2
    exit 1
    ;;
esac

xcrun simctl list devices available > "$artifact_dir/simulator-devices.txt"
xcodebuild -showsdks > "$artifact_dir/xcode-sdks.txt"
printf '%s\n' "$swift_output" > "$artifact_dir/swift-version.txt"

module_path="$artifact_dir/VacuumCoverageEnvironmentProbe.swiftmodule"
xcrun --sdk iphonesimulator swiftc \
  -target "arm64-apple-ios${deployment_target}-simulator" \
  -swift-version 6 \
  -strict-concurrency=complete \
  -warnings-as-errors \
  -parse-as-library \
  -emit-module \
  -module-name VacuumCoverageEnvironmentProbe \
  -emit-module-path "$module_path" \
  Scripts/Fixtures/EnvironmentProbe.swift

if [[ ! -s "$module_path" ]]; then
  echo "ERROR: unsigned iOS Simulator probe module was not produced." >&2
  exit 1
fi

commit_sha="$(git rev-parse HEAD 2>/dev/null || printf 'uncommitted')"
printf '{\n  "commit": "%s",\n  "xcode": "%s",\n  "xcode_build": "%s",\n  "macos": "%s",\n  "ios_simulator_sdk": "%s",\n  "swift": "%s",\n  "deployment_target": "%s",\n  "code_signing": "disabled"\n}\n' \
  "$commit_sha" \
  "$actual_xcode_version" \
  "$actual_xcode_build" \
  "$macos_version" \
  "$actual_ios_sdk_version" \
  "$required_swift_prefix" \
  "$deployment_target" \
  > "$artifact_dir/environment.json"

echo "Environment gate passed: Xcode $actual_xcode_version ($actual_xcode_build), Swift $required_swift_prefix, iOS Simulator SDK $actual_ios_sdk_version."
