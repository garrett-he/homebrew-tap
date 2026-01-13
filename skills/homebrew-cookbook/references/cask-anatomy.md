# Cask Anatomy

A cask is a declarative Ruby block, not a class. Its header line is `cask "<token>" do`, and the token must match the filename without `.rb`.

## Canonical stanza order

Homebrew style checks expect this order. Blank lines between groups matter; extra parameters (symbols after a comma) go one per line, except `target:`.

```text
arch
on_arch_conditional
os
on_system_conditional

version
sha256

on_<system>       # arm, intel, macOS releases (oldest first), macos, then linux

language

url
name
desc
homepage

livecheck

no_autobump!
deprecate!
disable!

auto_updates
conflicts_with
depends_on
container

rename

suite
app
app_image
pkg
generated_script
installer
binary
command_wrapper
manpage
bash_completion
zsh_completion
fish_completion
pwsh_completion
generate_completions_from_executable
colorpicker
dictionary
font
input_method
internet_plugin
keyboard_layout
prefpane
mdimporter
screen_saver
service
audio_unit_plugin
vst_plugin
vst3_plugin
artifact, target:
stage_only

preflight_steps
postflight_steps
uninstall_preflight_steps
uninstall_postflight_steps

uninstall

zap

caveats
```

Order multiple `depends_on` stanzas alphabetically by dependency type, then value.

## Required stanzas

| Stanza | Rule |
|---|---|
| `version` | Application version or `:latest`. Interpolate into `url` so updates need only version and checksum changes. |
| `sha256` | SHA-256 of the downloaded artifact, or `:no_check` when checksumming is impractical. |
| `url` | HTTPS URL to the vendor's `.dmg`/`.zip`/`.pkg`/archive. |
| `name` | Full vendor name; repeatable for alternate names. |
| `desc` | One-line description shown in `brew info`. |
| `homepage` | HTTPS application homepage. Use `homepage "https://...", browsed: "YYYY-MM-DD"` when bots are blocked but a browser works; use a real past date. |
| one artifact | At least one of `app`, `pkg`, `installer`, `binary`, `suite`, etc. See `artifacts-and-uninstall.md`. |

Casks in `homebrew/cask` additionally require `zap` and a working `livecheck`.

## `version`

Interpolate and reshape the version to keep the URL stable:

```ruby
version "1.2.3"
url "https://example.com/file-version-#{version.delete(".")}.dmg"

version "1.2.3build4"
url "https://example.com/#{version.sub(/build\d+/, "")}/file-version-#{version}.dmg"
```

Helpers: `major`, `minor`, `patch`, `major_minor`, `major_minor_patch`, `minor_patch`, `csv.first`, `csv.second`, `dots_to_hyphens`, `no_dots`, plus permutations of `{dots,hyphens,underscores}_to_{...}` and `no_{dots,hyphens,underscores,dividers}`.

`version :latest` is for artifacts with no version information and no usable `livecheck`, or where version detection is impractical. It requires `sha256 :no_check` and excludes the cask from autobump.

## `sha256`

Compute with `shasum --algorithm 256 <file>`. Use `sha256 :no_check` only when the URL does not change between releases (and always with `version :latest`). A checksum is preferred whenever possible.

## `url`

Prefer HTTPS. Extra downloader parameters:

```ruby
url "https://example.com/app.dmg",
    using:       :post,
    cookies:     { "key" => "value" },
    referer:     "https://example.com/download",
    header:      "Authorization: Bearer ...",
    user_agent:  :fake,
    data:        { "key" => "value" }
```

`using:` accepts `:post`, `:homebrew_curl`, `:svn`, `:git`. Git URLs ending in `.git` also accept `tag:`, `revision:`, `branch:`, `only_path:`. Subversion URLs accept `revision:` and `trust_cert: true`. Find a browser-hidden URL with `mdls -name kMDItemWhereFroms '<file>'`. URLs that rotate on every visit or block command-line clients are not usable.

For SourceForge prefer `https://downloads.sourceforge.net/<project>/<file>.<ext>`.

## `depends_on`

```ruby
depends_on cask: "macfuse"                 # required cask token(s)
depends_on formula: "unar"                 # required formula name(s), e.g. for 7z archives
depends_on macos: :monterey                # minimum macOS release
depends_on maximum_macos: :ventura         # maximum macOS release
depends_on arch: :arm64                    # :arm64, :intel, :x86_64 or array
depends_on :macos                          # macOS-only
depends_on :linux                          # Linux-only
```

Top-level `depends_on :macos` or `macos:` marks a cask macOS-only. For a cross-platform cask, put OS-specific requirements inside `on_macos` / `on_linux` blocks. `brew audit --online` reads the real minimum from the artifact's `LSMinimumSystemVersion`, a pkg `Distribution` file, or the executable's load commands; `brew audit --cask --online --fix` can write it when there are no conditional stanzas.

## `conflicts_with`

```ruby
conflicts_with cask: "macfuse@dev"
```

## `auto_updates`

`auto_updates true` asserts the artifacts update themselves. Use it when an in-app "Check for Updates…" downloads and installs; not when it only opens a webpage.

## `livecheck`

Every cask needs a version source that `livecheck` can check by default, or an explicit block with a `url`. Omit the block when automatic detection already works.

```ruby
livecheck do
  url :url          # or :homepage, or a literal URL
  strategy :sparkle
end
```

Never use `skip` for a new cask in an official tap. Check with `brew livecheck --cask --newer-only <token>`.

## Conditional blocks

Use `on_<system>` instead of `MacOS.version` / `Hardware::CPU` checks. Per-architecture downloads with a shared version use `arch:` substitutions and a multi-value `sha256`:

```ruby
cask "libreoffice" do
  arch arm: "aarch64", intel: "x86-64"
  folder = on_arch_conditional arm: "aarch64", intel: "x86_64"

  version "7.6.0"
  sha256 arm:   "81eab945a33622fc156951e804024d23aa9a745c06743b4947215ed9303ad1c4",
         intel: "ede541af151487f60eb518e310d20dad1a973f3dbe9ff78d782dd29b14ba2946"

  url "https://download.documentfoundation.org/libreoffice/stable/#{version}/mac/#{folder}/LibreOffice_#{version}_MacOS_#{arch}.dmg"
end
```

`sha256` accepts `arm:`, `intel:`, `arm64_linux:` and `x86_64_linux:` keys. When versions differ per architecture, place `version` and `sha256` inside `on_arm`/`on_intel` blocks. For macOS-release-specific versions use sequences such as `on_sonoma :or_older`, `on_sequoia`, `on_tahoe :or_newer`. Use `language` for regional editions rather than separate casks.

## `caveats`

Use sparingly and only for installation matters. String form is evaluated at compile time and may interpolate `token`, `version`, `homepage`, `caskroom_path`, `staged_path`:

```ruby
caveats "Using #{token} may be hazardous to your health."
```

Block form is evaluated at install time and may use `@cask`. Mini-DSL helpers include `path_environment_variable`, `zsh_path_helper`, `depends_on_java`, `requires_rosetta`, `logout`, `reboot`, `files_in_usr_local`, `kext`, `unsigned_accessibility`, `license`, `free_license`.

## Token rules

- Lowercase the vendor's simplified distribution name, replace spaces with hyphens, strip punctuation.
- Use a vendor prefix when the app name is generic or conflicts with an existing app; use suffixes `@beta`, `@nightly`, `@latest` for upstream channels and `@...` version pins where upstream maintains them.
- The cask filename must equal the token plus `.rb`; `homebrew/cask` shards files by the first character of the token.
