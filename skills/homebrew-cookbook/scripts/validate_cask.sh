#!/usr/bin/env bash
# Validate a Homebrew cask: optional install, style, new-cask audit, and artifact fetch.
# Usage: validate_cask.sh <token> [--install]
set -euo pipefail

if ! command -v brew >/dev/null 2>&1
then
  echo "Error: brew not found in PATH" >&2
  exit 2
fi

cask=""
install_first=0
for arg in "$@"
do
  case "${arg}" in
    --install) install_first=1 ;;
    *) cask="${arg}" ;;
  esac
done

if [[ -z "${cask}" ]]
then
  echo "Usage: $0 <token> [--install]" >&2
  exit 2
fi

if [[ "${install_first}" -eq 1 ]]
then
  echo "==> Installing ${cask} from local tap files"
  HOMEBREW_NO_INSTALL_FROM_API=1 brew install --cask "${cask}"
fi

echo "==> brew style ${cask}"
brew style "${cask}"

echo "==> brew audit --new --cask ${cask}"
brew audit --new --cask "${cask}"

echo "==> brew fetch --cask ${cask}"
brew fetch --cask "${cask}"

echo "==> All checks passed for ${cask}"
