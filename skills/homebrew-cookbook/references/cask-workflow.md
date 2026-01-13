# Cask Workflow

This is the cask branch of the `homebrew-cookbook` skill. A cask is a declarative Ruby block that installs prebuilt software: `.app` bundles, `.pkg` installers, shell scripts, fonts, plugins, or standalone binaries. Unlike a formula, a cask does not compile from source and has no `test do` block. This workflow covers the path from a vendor's release artifact to a validated cask in a tap or a `homebrew/cask` pull request.

If you have not yet decided between a cask and a formula, follow the decision tree in the root `SKILL.md` first.

Read `references/cask-anatomy.md` for the stanza reference and token rules, `references/artifacts-and-uninstall.md` for install/uninstall/zap logic, `references/cask-validation.md` for debugging and audit fixes, and `references/taps-and-ci.md` for acceptance rules and CI.

## Destination (read first)

1. Is the target a personal/team tap (for example `garrett-he/tap`)? → Continue. Pass `--tap=<user>/<repo>` to `brew create --cask` and store the file at `<tap>/Casks/<token>.rb`.
2. Is the target `homebrew/cask`? → Read `references/taps-and-ci.md` first and confirm the software meets acceptance rules (public presence, notability, verifiable vendor distribution, Gatekeeper-safe, working `livecheck`, `zap` stanza).

## Workflow

### Step 1: Collect artifact facts

Gather these before writing Ruby:

- Vendor-provided download URL for a `.dmg`, `.zip`, `.pkg`, or other archive (not a third-party mirror or forum build).
- The stable version, or `version :latest` when no version can be derived.
- SHA-256 of the exact artifact, or `sha256 :no_check` when the URL never changes between releases.
- Full vendor name, one-line description, HTTPS homepage.
- The artifact layout: which `.app`, `.pkg`, or binary is inside, and whether there is a nested directory.
- The cask token (lowercase, hyphenated; see `references/cask-anatomy.md`).
- Whether the app self-updates (`auto_updates true`) and which bundle IDs / package IDs exist for uninstall.

Run `brew search <token>` and `brew info --cask <token>` to avoid duplicates.

### Step 2: Generate the cask

```sh
brew create --cask <artifact-url> --tap=<user>/<repo> --set-name=<token>
```

`brew create --cask` downloads the artifact, computes `sha256`, and guesses the version, description, homepage and artifacts. Use `--no-fetch` when offline and calculate the checksum with `scripts/sha256_of_url.sh`. Fix a wrong version with `--set-version=<version>`.

If the app is already installed in `/Applications`, `brew create --cask` also generates a `zap` stanza for you.

To find a hidden direct download URL, read the artifact's extended metadata:

```sh
mdls -name kMDItemWhereFroms '<downloaded-file>'
```

### Step 3: Complete the required stanzas

Read `references/cask-anatomy.md` and copy `assets/cask-template.rb` as the starting point. Every cask needs:

- Header matching the filename: `cask "<token>" do ... end`.
- Identity and download: `version`, `sha256`, `url`, `name`, `desc`, `homepage`.
- At least one artifact stanza: `app`, `pkg`, `installer`, `binary`, `suite`, etc.

Follow the canonical stanza order from the reference; Homebrew's style checks enforce it.

### Step 4: Add uninstall and zap logic

Read `references/artifacts-and-uninstall.md`.

- Any cask using `pkg` or `installer` must also declare `uninstall`; use `pkgutil:` first, then `quit:`, `launchctl:`, `script:`, and only as a last resort `delete:`.
- Casks in `homebrew/cask` require a `zap` stanza. Generate it with `brew generate-zap <token>` after installing and briefly launching the app. If nothing needs zapping, declare `zap :not_required`.
- Find bundle and package IDs with `pkgutil --pkgs`, `pkgutil --files <id>`, and `defaults read '/path/to/App.app/Contents/Info' CFBundleIdentifier`.

### Step 5: Add version tracking

Add a `livecheck` block unless automatic strategies find the correct version:

```ruby
livecheck do
  url :url
  strategy :header_match
end
```

Verify with `brew livecheck --cask --newer-only <token>`. Use `version :latest` only when no reliable version source exists; those casks are excluded from autobump.

### Step 6: Validate locally

```sh
brew style <token>
brew audit --new --cask <token>
brew fetch --cask <token>
```

`--new` implies `--strict` and `--online`. Run all checks with `scripts/validate_cask.sh <token>`; pass `--install` to also install the cask from local files. Consult `references/cask-validation.md` for fixes. Casks have no `brew test` block.

### Step 7: Commit and submit

Commit with `<token> <version> (new cask)` as the first line, one cask per commit. Push to the tap and let CI run; see `references/taps-and-ci.md` for tap layout and CI details.

## Non-negotiable rules

- Use a download published or publicly endorsed by the vendor; never a forum build, unendorsed mirror, or a URL needing account login.
- Include `version`, `sha256`, `url`, `name`, `desc`, `homepage`, and at least one artifact stanza.
- Use HTTPS, prefer a versioned URL, and checksum every artifact that changes between releases.
- Pair `version :latest` with `sha256 :no_check` only when a version or changing checksum cannot be obtained.
- Match the header token to the filename; follow the canonical stanza order.
- Always pair `pkg` or `installer` with `uninstall`; prefer `pkgutil:` over `delete:`.
- Declare `auto_updates true` when the app updates itself; do not claim it when "Check for Updates" only opens a webpage.
- Do not use `target:` to strip version numbers for aesthetics.
- Casks in `homebrew/cask` need `zap` and a working `livecheck`; third-party taps are more permissive.

## Resources

### scripts/

- `scripts/sha256_of_url.sh <url>` — download a `.dmg`/`.zip`/`.pkg` and print its SHA-256.
- `scripts/validate_cask.sh <token> [--install]` — run style, new-cask audit, and fetch; `--install` first installs the cask from local tap files.

### references/

- `references/cask-anatomy.md` — stanza order, required/optional stanzas, version and URL details, conditional blocks, token rules, caveats mini-DSL.
- `references/artifacts-and-uninstall.md` — artifact stanzas, `installer`/`pkg`/`uninstall`/`zap` syntax and discovery commands.
- `references/cask-validation.md` — local debug/audit commands and fixes for common failures.
- `references/taps-and-ci.md` — destination rules, tap layout, CI, and autobump.

### assets/

- `assets/cask-template.rb` — starter Ruby template with the canonical stanza order and placeholders.
