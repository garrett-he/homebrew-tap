# Formula Workflow

This is the formula branch of the `homebrew-cookbook` skill. A Homebrew formula is a Ruby file that declares where a versioned source archive lives, what it depends on, how to build and install it, and how to prove it works. This workflow covers the path from an upstream release to a validated formula in a tap or a homebrew-core pull request.

If you have not yet decided between a formula and a cask, follow the decision tree in the root `SKILL.md` first.

Read `references/formula-anatomy.md` for the full stanza reference, `references/install-patterns.md` for build-system recipes, `references/formula-validation.md` for debugging and audit fixes, and `references/taps-and-ci.md` for tap layout, bottles, and CI.

## Destination (read first)

1. Is the target a personal/team tap (for example `garrett-he/tap`)? → Continue. Pass `--tap=<user>/<repo>` to `brew create` and store the file at `<tap>/Formula/<name>.rb`.
2. Is the target `homebrew/core`? → Read `references/taps-and-ci.md` first and confirm the software meets core acceptance rules (open source, DFSG-compatible licence, immutable versioned source, stable release, no cask dependency).

## Workflow

### Step 1: Collect upstream facts

Gather these before writing Ruby:

- Stable version and an immutable release archive URL (tag-derived tarball or zip, never a moving default branch).
- The exact SHA-256 of that archive.
- An SPDX licence identifier, an HTTPS homepage, and a one-line description.
- The build system (Autotools, CMake, Meson, Go, Cargo, npm, prebuilt binary, etc.).
- Build/runtime dependencies and a real command to exercise in `test do`.

Run `brew search <name>` to avoid duplicating an existing formula.

### Step 2: Scaffold with `brew create`

```sh
brew create <archive-url> --tap=<user>/<repo> --set-name=<name> --set-version=<version> --cmake
```

Pick the matching template flag: `--autotools`, `--cabal`, `--cmake`, `--crystal`, `--go`, `--meson`, `--node`, `--perl`, `--python`, `--ruby`, `--rust`, `--zig`. Omit the flag for a plain prebuilt binary tarball.

`brew create` downloads the archive to fill in `sha256` and, for GitHub projects, `desc` and `homepage`. When offline, pass `--no-fetch`, then compute the checksum with `scripts/sha256_of_url.sh` or `shasum -a 256 <archive>`. Fix a wrong guessed version with `--set-version`; fix a wrong guessed name with `--set-name`.

For `homebrew/core`, run `brew create <archive-url>` without `--tap` after tapping `homebrew/core`.

### Step 3: Complete the formula

Read `references/formula-anatomy.md` and copy `assets/formula-template.rb` as the starting point. Every formula needs:

- `desc`, `homepage`, `url`, `sha256`, `license`
- `depends_on` / `uses_from_macos` for anything required at build or test time
- `def install` that builds and installs explicit files into Homebrew's prefixes
- `test do` that checks real functionality, not just `--version` or `--help`

Match the install logic to the upstream build system using `references/install-patterns.md`.

### Step 4: Install and inspect locally

```sh
HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source --debug --verbose <tap>/<name>
```

`HOMEBREW_NO_INSTALL_FROM_API=1` forces brew to read local tap files instead of the API JSON. Add `--interactive` to drop into the extracted source tree and inspect the build system.

### Step 5: Test and audit

```sh
brew test <tap>/<name>
brew audit --new --formula <tap>/<name>
brew style <tap>/<name>
```

`--new` implies `--strict` and `--online`. Run all three at once with `scripts/validate_formula.sh <tap>/<name>`. Consult `references/formula-validation.md` for common failures and their fixes.

### Step 6: Commit, CI, and bottles

Commit with a message in the form `<name> <version> (new formula)`, one formula per commit. Push to the tap and let CI run `brew test-bot`; see `references/taps-and-ci.md` for tap layout, syntax checks, bottles, `brew pr-pull`, and autobump.

## Non-negotiable rules

- Use an immutable, versioned source URL and its SHA-256. Never fetch a moving branch or an unchecksummed archive during install.
- Include `homepage`, `desc`, `license`, and a functional `test do` in every formula.
- Declare build dependencies with `depends_on`; Homebrew's `bin` is not on `PATH` during installation.
- Prefer `std_configure_args`, `std_cmake_args`, `std_meson_args`, `std_go_args`, `std_cargo_args`, `std_npm_args`, and `std_pip_args` over hand-written flag lists.
- Install specific files/directories; use `install_symlink` for relocatable symlinks instead of `ln_s`.
- Use `post_install_steps do ... end`; new `post_install` methods are rejected.

## Resources

### scripts/

- `scripts/sha256_of_url.sh <url>` — download an archive and print its SHA-256; use when `brew create --no-fetch` was used or to verify an upstream checksum.
- `scripts/validate_formula.sh <tap/name> [--install]` — run style, new-formula audit, and functional test in sequence; `--install` first rebuilds from source.

### references/

- `references/formula-anatomy.md` — stanza-by-stanza DSL reference and dependency syntax.
- `references/install-patterns.md` — per-build-system `def install` recipes and file-installation helpers.
- `references/formula-validation.md` — local debug/test/audit commands and fixes for common failures.
- `references/taps-and-ci.md` — destination rules, tap structure, bottles, and CI workflows.

### assets/

- `assets/formula-template.rb` — starter Ruby template with placeholders for every required stanza.
