# Validation and Debugging

## Local command sequence

```sh
# 1. See what brew knows about the formula (version, dependencies, caveats)
brew info --formula <tap>/<name>

# 2. Build from source against local tap files, with full diagnostics
HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source --debug --verbose <tap>/<name>

# 3. Inspect the extracted source tree (optional but useful for new formulae)
HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source --interactive <tap>/<name>

# 4. Run the formula's functional test
brew test <tap>/<name>

# 5. Audit eligibility + style, then check style again explicitly
brew audit --new --formula <tap>/<name>
brew style <tap>/<name>

# 6. Verify every linked library is declared
brew linkage --test <name>

# 7. Re-run everything in one shot
scripts/validate_formula.sh <tap>/<name> --install
```

`brew audit --new` implies `--strict` and `--online`. Use `--only=<method>` / `--except=<method>` to narrow a noisy audit, and `--fix` to auto-correct RuboCop violations.

`brew install --debug` drops into an interactive shell on failure. Inspect `Homebrew::Formula#buildpath` output, the failing log, and any `config.log`.

## Common failures and fixes

| Symptom | Likely cause / fix |
|---|---|
| `SHA256 mismatch` | Re-download from the official immutable URL and recompute `shasum -a 256`. Confirm the URL is not a redirect to a newer release. |
| `Version cannot be determined from URL` | Add `version "..."` or re-create with `--set-version=<version>`. |
| Audit: missing `homepage`, `desc`, or `license` | Add all three; use an SPDX licence identifier. |
| Build fails: command not found | Declare the tool with `depends_on "tool" => :build`; `$(brew --prefix)/bin` is not on `PATH` during install. |
| Installed files collide with another formula | Install into `libexec` and expose only entry points via `bin.install_symlink` / `write_env_script`. |
| `brew test` fails with "command not found" | Check the exact installed name from `bin.install`; rename with `bin.install "src/foo" => "foo"` if needed. |
| Formula tries to download during install | Move downloads into `def fetch` or checksummed `resource` blocks; install steps must work offline. |
| `post_install` rejected by audit | Replace the method with a `post_install_steps do ... end` block. |
| Undefined symbols / runtime linkage errors | Run `brew linkage --test <name>`; add missing `depends_on` entries. |
| Formula name rejected | Use `--set-name` with a valid lowercase, hyphenated name, or `--force` only if the name is genuinely safe. |
| Homebrew core rejects the formula | Read `references/taps-and-ci.md`; GUI apps, proprietary binaries, self-updaters and unversioned sources belong in a cask or a tap. |

## Definition of done

- `brew install --build-from-source <tap>/<name>` succeeds from a clean state.
- `brew test <tap>/<name>` passes with a functional assertion.
- `brew audit --new --formula <tap>/<name>` reports no errors.
- `brew style <tap>/<name>` reports no offences.
- Every source archive has an immutable URL and a matching SHA-256.
- No network access happens during `def install`.
- CI (`brew test-bot`) passes on the tap's supported macOS versions.
