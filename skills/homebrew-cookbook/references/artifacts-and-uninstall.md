# Artifacts, Uninstall, and Zap

## Artifact stanzas

At least one artifact is required. Supported operating systems are inferred from `depends_on` declarations, not from artifact types: `app_image` is Linux-only, `app` and `pkg` are macOS-only, `binary` works on both.

| Stanza | Effect |
|---|---|
| `app "Foo.app"` | Move the bundle into `/Applications`. Include nested paths: `app "Foo/Foo.app"`. |
| `app "Foo.app", target: "Bar.app"` | Rename the installed bundle. Use only for functional reasons, not to strip version numbers. |
| `suite "Foo"` | Move a containing directory into `/Applications`. |
| `binary "foo"` | Symlink a binary into `$(brew --prefix)/bin`. |
| `pkg "Foo.pkg"` | Run the macOS installer. Requires `uninstall`. |
| `installer manual: "Foo Installer.app"` | An interactive installer the user must run. Requires `uninstall`. |
| `installer script: { ... }` | Automated vendor install script. Requires `uninstall`. Never for interactive installs. |
| `font`, `prefpane`, `screen_saver`, `service`, `dictionary`, `colorpicker`, `input_method`, `internet_plugin`, `keyboard_layout`, `mdimporter`, `vst_plugin`, `vst3_plugin`, `audio_unit_plugin` | Move the artifact into the corresponding `~/Library` or `/Library` location. |
| `manpage`, `bash_completion`, `zsh_completion`, `fish_completion`, `pwsh_completion` | Link into the respective Homebrew share directories. |
| `generate_completions_from_executable` | Generate shell completions from the installed binary at install time; runs in a sandbox. |
| `command_wrapper`, `generated_script` | Generate a wrapper or helper script. |
| `artifact "src", target: "/absolute/path"` | Arbitrary move to an absolute target; last resort, prefer `app`. |
| `stage_only true` | Declares no activatable artifact. |

`target:` works on most artifact types. A leading slash means an absolute path and parent directories are created.

## `installer`

Always pair with `uninstall`. The first key must be `manual:` or `script:`.

```ruby
installer manual: "RubyMotion Installer.app"

installer script: {
  executable: "Miniforge3-#{version}-MacOSX-x86_64.sh",
  args:       ["-b", "-p", "#{caskroom_path}/base"],
}
```

`script:` keys: `executable:`, `args:`, `input:`, `must_succeed: false`, `print_stderr: false`, `print_stdout: false`, `sudo: true`. A script with no extra keys can be given as a bare path: `installer script: "#{staged_path}/install.sh"`. Installer scripts run outside the cask sandbox; prefer a more specific artifact when one fits.

## `pkg`

Always pair with `uninstall`. Only `choices:` is supported as an extra key; it overrides defaults via `installer -applyChoiceChangesXML`.

```ruby
pkg "Unity.pkg"

pkg "LandoInstaller.pkg",
    choices: [
      {
        "choiceIdentifier" => "choiceDocker",
        "choiceAttribute"  => "selected",
        "attributeSetting" => 0,
      },
    ]
```

Get choice values with `installer -showChoicesXML -pkg '/path/to/my.pkg'`.

## `uninstall`

Required in practice for every `pkg` or `installer` cask; usually unnecessary for plain `app` casks. Keys are applied in a fixed order regardless of how they appear in the file:

1. `early_script:`
2. `launchctl:`
3. `quit:`
4. `signal:`
5. `login_item:`
6. `kext:`
7. `script:`
8. `pkgutil:`
9. `delete:`
10. `trash:`
11. `rmdir:`

```ruby
uninstall launchctl: "com.example.helper",
          quit:      "com.example.app",
          pkgutil:   "com.example.pkg.*",
          trash:     "~/Library/Application Support/Example",
          rmdir:     "~/Library/Example"
```

- `pkgutil:` is the most useful key; accepts strings, regexps, or arrays of both. Strongly preferred over `delete:`.
- `quit:` sends Cmd+Q to running apps; supports a `*` wildcard that must match the whole bundle ID and needs at least three dot-separated parts.
- `signal:` is an array of `[signal, bundle_id]` pairs for processes that ignore `quit:`; skipped on upgrade/reinstall unless `on_upgrade: :signal`.
- `script:` keys match `installer script:` and may set `sudo: true`; complements rather than replaces `pkgutil:`.
- `delete:` and `trash:` need double-quoted absolute paths with basic `~` expansion and glob support. Use `zap` for user-specific files.
- `rmdir:` removes empty directories recursively.

Discovery commands:

```sh
pkgutil --pkgs
pkgutil --pkgs=<regexp>
pkgutil --files <package.id>
pkgutil --payload-files '/path/to/my.pkg'
launchctl list
osascript -e 'tell application "System Events" to get the bundle identifier of every application process'
defaults read '/path/to/App.app/Contents/Info' CFBundleIdentifier
```

For distribution packages, expand and inspect each component:

```sh
pkgutil --expand '/path/to/my.pkg' /tmp/expanded.unpkg
lsbom -s /tmp/expanded.unpkg/*.pkg/Bom
find /tmp/expanded.unpkg -name PackageInfo
```

## `zap`

`zap` removes preferences, caches, and shared resources. It only runs with `brew uninstall --zap <token>` (add `--force` if the cask is no longer installed). Never remove files the user created directly. Use the same directives as `uninstall`, preferring `trash:` over `delete:`.

Generate it by installing and briefly launching the app, then:

```sh
brew generate-zap <token>
```

If there is nothing to remove, declare `zap :not_required`. A cask supporting Linux needs a `zap` stanza (or `zap :not_required`) inside both `on_macos` and `on_linux`, since `brew generate-zap` only scans macOS.

Manual discovery:

```sh
sudo find / -iname "*item*"
```

Inspect `/Library/{'Application Support',LaunchAgents,LaunchDaemons,Frameworks,Logs,Preferences,PrivilegedHelperTools}` and `~/Library/{'Application Support',Caches,Containers,LaunchAgents,Logs,Preferences,'Saved Application State'}`.

## Common artifact pitfalls

- Archive expands into a folder → include it in the artifact path: `app "Folder/Foo.app"`.
- App requires Rosetta → add `caveats do requires_rosetta end`; note new Rosetta-only casks are no longer accepted in `homebrew/cask` on recent macOS.
- Vendor installer is `.pkg` but no `uninstall` → `brew audit --new` fails; use `pkgutil --pkgs` after a test install.
- A cask with no activatable artifact (license or helper only) → use `stage_only true`.
