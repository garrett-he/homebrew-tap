#!/usr/bin/env bash
# Validate a Homebrew formula: optional source build, functional test, audit, style.
# Usage: validate_formula.sh <tap/name> [--install]
set -euo pipefail

if ! command -v brew >/dev/null 2>&1; then
  echo "Error: brew not found in PATH" >&2
  exit 2
fi

formula=""
install_first=0
for arg in "$@"; do
  case "$arg" in
    --install) install_first=1 ;;
    *) formula="$arg" ;;
  esac
done

if [[ -z "$formula" ]]; then
  echo "Usage: $0 <tap/name> [--install]" >&2
  exit 2
fi

if [[ "$install_first" -eq 1 ]]; then
  echo "==> Building $formula from source"
  HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source --debug --verbose "$formula"
fi

echo "==> brew test $formula"
brew test "$formula"

echo "==> brew audit --new --formula $formula"
brew audit --new --formula "$formula"

echo "==> brew style $formula"
brew style "$formula"

echo "==> All checks passed for $formula"
