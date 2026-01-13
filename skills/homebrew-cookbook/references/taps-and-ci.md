# Taps and CI

## Where to publish: core, cask, or a personal tap

| Situation | Destination |
|---|---|
| Open-source CLI/library or source-built GUI software, compatible license, immutable versioned source, stable release, no cask dependency | `homebrew/core` as a formula |
| Vendor-published prebuilt app, `.pkg`, plugin, font, or binary-only software | `homebrew/cask` as a cask |
| Internal/team tools, unnotarized builds, trials, alternative versions, channels outside official policy | A personal or team tap |

A rejection from `homebrew/core` does not by itself make software eligible for `homebrew/cask`.

### `homebrew/core` acceptance highlights (formula)

- Open source under a DFSG-compatible licence.
- Immutable versioned source with SHA-256; upstream-labelled stable release.
- Must build on the supported macOS/Linux CI matrix.
- No cask or proprietary dependency; self-update behaviour disabled.
- No native app bundle as the primary output; avoid downstream-only patches.
- Taps are lighter: they can carry versioned formulae, internal tools and CLI binaries that core would reject. They should still use immutable sources and checksums so builds are reproducible.

### Official-tap acceptance rules (cask)

Shared rules for official taps:

- Public presence and an independently maintained homepage; actively maintained upstream with no known unpatched vulnerabilities.
- Notability: for a GitHub project normally at least 30 forks/watchers or 75 stars; 90/90/225 when self-submitted by the repository owner or a commit author at the homepage domain. Equivalent evidence for non-GitHub hosting. Repository younger than 30 days is normally ineligible.
- Discoverable and searchable; no editorial curation.
- Forks replacing an original need public designation as successor or adoption by two other major distributions. Otherwise use a vendor-prefixed token.
- Adult content only when homepage and URL root page are safe for workplace review.

`homebrew/cask` specific rules:

- **Verifiable distribution**: download published or publicly endorsed by the developer; no unendorsed mirror, forum-only binary, or download behind unrelated account registration. No installer requiring certificate verification to be disabled.
- **Platform and security**: support the latest major macOS version and every declared OS/architecture; Gatekeeper-checkable artifacts must pass Homebrew's checks without disabling SIP or Gatekeeper. New Rosetta-only casks are rejected on recent macOS.
- **Channels**: the default token tracks the vendor-recommended channel, not necessarily the newest; `@beta`/`@nightly`/`@latest` for concurrent channels. Version pins only while upstream maintains them.
- **Regional editions**: one cask with `language`, not separate casks.
- **Trials**: eligible when the same download can be activated as the full version; not when the full version is only on the Mac App Store.
- **Required stanzas**: `zap` and a working `livecheck` that does not use `skip`.

## Tap layout

A tap is a Git repository named `homebrew-<name>` (for example `garrett-he/homebrew-tap`), referenced as `<user>/<tap>`. Formulae live in `Formula/`; casks live in `Casks/`. Homebrew core and cask shard by the first character of the token/name; a personal tap may use flat `Formula/foo.rb` / `Casks/<token>.rb` or sharded directories — keep one convention per tap.

```sh
brew tap-new <user>/<tap>                         # create a tap from the template
brew create <url> --tap=<user>/<tap>              # scaffold a formula
brew create --cask <url> --tap=<user>/<tap>       # scaffold a cask
brew install <user>/<tap>/<name>                  # install a formula from the tap
brew install --cask <user>/<tap>/<token>          # install a cask from the tap
brew tap                                          # list tapped repos
```

The `garrett-he/tap` workspace in this environment is a fresh `brew tap-new` tap with `README.md`, an empty `Formula/`, and `.github/workflows/{pr-pull,autobump,test-bot}.yml` plus `dependabot.yml`. Add a `Casks/` directory when the first cask is created.

## CI checks

```sh
brew test-bot --only-cleanup-before
brew test-bot --only-setup
brew test-bot --only-tap-syntax
brew test-bot --only-formulae          # formulae only: build, test, linkage, audit
```

`--only-tap-syntax` validates the tap structure and style without building. There is no cask-specific `--only-casks` flag; cask semantics are covered by `brew audit --new --cask <token>` locally and by the macOS CI job. `--only-formulae` performs the full build/test/linkage/audit steps. The template `test-bot.yml` runs on pushes and pull requests across macOS and a Linux container.

## Bottles

A bottle is a precompiled tarball for one macOS/Linux platform. `brew test-bot` builds and uploads bottles as CI artifacts. Maintainers then merge the PR with:

```sh
brew pr-pull --debug --tap=<user>/<tap> <pull-request-number>
```

This applies the bottles to the formula file and commits the result; the template's `pr-pull.yml` workflow wraps that command. Verify a bottle locally with `brew install --force-bottle <tap>/<name>`. Do not hand-edit a `bottle do ... end` block; brew generates the checksums and tags.

## Autobump and version tracking

The template `autobump.yml` runs daily and calls:

```sh
brew bump --no-fork --open-pr --formulae --bump-synced --tap=<tap-name>
```

For formulae it opens a PR when a new upstream version is detected; keep `url`/`version` easy to parse (version in the archive filename). The command targets formulae only — cask version updates rely on `livecheck` and BrewTestBot autobump in official taps. Keep versioned URLs and a working `livecheck` so updates can be detected; `version :latest` casks are excluded from autobump.

## Commit and PR conventions

- First line: `<name> <version> (new formula)` or `<token> <version> (new cask)`; 50 characters or fewer, blank line, then a longer explanation.
- One formula/cask per commit; squash fixup commits before PR.
- Reference related/upstream issues with `Closes #123` where relevant.
- For formulae: keep the PR focused on source URL, checksum, build logic and test; update `README.md` only if the tap uses a custom install layout.
- For casks: include the vendor URL, checksum, correct artifact stanza, `uninstall` for pkg/installer casks, and `zap` for official taps.

## Useful references

- Formula Cookbook: https://docs.brew.sh/Formula-Cookbook
- Cask Cookbook: https://docs.brew.sh/Cask-Cookbook
- Acceptable Formulae: https://docs.brew.sh/Acceptable-Formulae
- Acceptable Casks: https://docs.brew.sh/Acceptable-Casks
- Package Acceptance Policy: https://docs.brew.sh/Package-Acceptance-Policy
- Adding Software to Homebrew: https://docs.brew.sh/Adding-Software-to-Homebrew
- Formula API: https://docs.brew.sh/rubydoc/Formula
- Cask API: https://docs.brew.sh/rubydoc/Cask
- Bottles: https://docs.brew.sh/Bottles
- Taps: https://docs.brew.sh/Taps
- Brew Livecheck: https://docs.brew.sh/Brew-Livecheck
