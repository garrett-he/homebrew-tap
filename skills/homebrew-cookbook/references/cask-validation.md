# Validation and Debugging

## Local command sequence

```sh
# Inspect what brew knows about the cask
brew info --cask <token>

# Download the artifact and verify the checksum
brew fetch --cask <token>

# Check version detection
brew livecheck --cask --newer-only <token>

# Style and eligibility audit (--new implies --strict and --online)
brew style <token>
brew audit --new --cask <token>

# Install from local tap files to test the real install path
HOMEBREW_NO_INSTALL_FROM_API=1 brew install --cask <token>

# Generate or verify the zap stanza after installing and launching the app
brew generate-zap <token>

# Exercise zap removal, then reinstall
brew uninstall --zap <token>

# Run all static checks at once
scripts/validate_cask.sh <token> --install
```

Casks have no `brew test` block; installation and `--zap` uninstall are the functional checks.

Useful audit modifiers: `--strict`, `--online`, `--fix` (auto-correct, including `depends_on macos:`), `--only=<method>`, `--except=<method>`, `--display-filename`.

## Common failures and fixes

| Symptom | Likely cause / fix |
|---|---|
| `SHA256 mismatch` | Re-download from the official vendor URL and recompute `shasum --algorithm 256`. Confirm the URL is not a rotating or per-visit link. |
| Header/token error | The `cask "<token>"` header must equal the filename without `.rb`. |
| Audit: stanza out of order | Reorder to the canonical sequence in `cask-anatomy.md`. |
| Audit: `name`, `desc` or `homepage` missing/invalid | Add all three; use HTTPS and an SPDX-free plain description. |
| Audit: "requires zap" | Add `zap` from `brew generate-zap`, or `zap :not_required`. |
| Audit: "version cannot be determined" | Add a `livecheck` block or use a versioned `url`. |
| Audit: minimum macOS mismatch | Let `brew audit --cask --online --fix` write `depends_on macos:` from the artifact metadata. |
| `pkg`/`installer` uninstall missing | Add `uninstall` with `pkgutil:`; discover IDs with `pkgutil --pkgs`. |
| Install finds no `.app` | Include the archive's nested directory in the artifact path, e.g. `app "Foo/Foo.app"`. |
| `auto_updates` audit failure | Only set true when the in-app updater downloads and installs; otherwise remove it. |
| Gatekeeper rejection | Use a notarized/signed vendor build; official casks cannot require SIP or Gatekeeper to be disabled. |
| Download blocked for CLI | Provider blocks command-line clients or rotates URLs; use another vendor-hosted URL or skip the cask. |

## Definition of done

- `brew fetch --cask <token>` downloads and the checksum matches.
- `brew style <token>` and `brew audit --new --cask <token>` report no offences.
- `brew install --cask <token>` installs the expected artifacts from local files.
- `brew uninstall --zap <token>` removes the app and declared user files.
- `livecheck` reports the current version (or `version :latest` is justified).
- Every `pkg` or `installer` has a working `uninstall`.
- `homebrew/cask` submissions also have `zap` and a working `livecheck`.
- CI passes on the tap's supported macOS versions.
