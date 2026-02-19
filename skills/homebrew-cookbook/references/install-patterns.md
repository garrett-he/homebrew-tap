# Install Patterns

## General rules

- `def install` starts in the extracted source directory. Use `cd "subdir" do ... end` when the source lives deeper.
- Use the `std_*_args` helpers instead of hard-coding flags; their defaults track Homebrew policy.
- Install into `libexec` for software that carries its own runtime/dependency tree, then expose only the intended commands via `bin.install_symlink` or `write_env_script`. This prevents prefix collisions.
- Be explicit about what gets installed: `bin.install "foo"` is preferred over copying the whole build output.
- Use `ENV.deparallelize` for makefiles that fail under parallel builds.
- Pass makefile variables on the command line: `system "make", "CC=#{ENV.cc}", "PREFIX=#{prefix}"`.
- `inreplace "path", before, after` patches files in place; block form requires modifying the block variable `s` directly.
- Separate network downloads into `def fetch` when the install step runs offline:

```ruby
def fetch
  system "cargo", "fetch", *std_cargo_fetch_args
end
```

## Autotools / configure

```ruby
depends_on "pkgconf" => :build

def install
  system "./configure", *std_configure_args(prefix: libexec)
  system "make"
  system "make", "install"
end
```

When the project installs a non-Homebrew runtime tree, expose commands manually:

```ruby
def install
  system "./configure", *std_configure_args(prefix: libexec)
  system "make", "install"
  bin.install_symlink libexec/"bin/foo"
end
```

## CMake

```ruby
def install
  system "cmake", "-S", ".", "-B", "build", *std_cmake_args(install_prefix: libexec)
  system "cmake", "--build", "build"
  system "cmake", "--install", "build"
end
```

Always pass explicit `-S` and `-B` directories.

## Meson

```ruby
depends_on "meson" => :build
depends_on "ninja" => :build

def install
  system "meson", "setup", "build", *std_meson_args
  system "meson", "compile", "-C", "build", "--verbose"
  system "meson", "install", "-C", "build"
end
```

## Go

```ruby
depends_on "go" => :build

def install
  system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/foo"
end
```

Use `std_go_args(ldflags: ...)`, not a hand-built `-ldflags` string. Add `DEFINE` values via `ldflags: "-X main.version=#{version} -s -w"` when upstream needs them.

## Rust / Cargo

```ruby
depends_on "rust" => :build

def fetch
  system "cargo", "fetch", *std_cargo_fetch_args
end

def install
  system "cargo", "install", *std_cargo_args
  bin.install Dir[libexec/"bin/*"]
end
```

## Node

```ruby
depends_on "node"

def install
  system "npm", "install", *std_npm_args
  bin.install_symlink libexec/"bin/foo"
end
```

## Python

Prefer `virtualenv_install_with_resources` when dependencies are declared as `resource` blocks. Otherwise use `std_pip_args` inside a virtualenv, never the user's global pip.

```ruby
depends_on "python@3.13"

def install
  virtualenv_install_with_resources
end
```

## Prebuilt binary archives

```ruby
def install
  bin.install "foo"
  prefix.install "LICENSE", "README.md"
  man1.install "man/foo.1"
  bash_completion.install "completions/foo.bash" => "foo"
  zsh_completion.install "completions/_foo"
  fish_completion.install "completions/foo.fish"
end
```

Rename during install with `bin.install "foo.py" => "foo"`. Install directory trees with `prefix.install Dir["share/*"]`.

## Wrappers and symlinks

```ruby
bin.install_symlink libexec/"foo"                 # relocatable symlink
bin.write_exec_script Dir[libexec/"bin/*"]        # wrapper scripts for a bin dir
(bin/"foo").write_env_script libexec/"bin/foo", FOO_ROOT: libexec
bin.env_script_all_files libexec/"bin", PERL5LIB: ENV.fetch("PERL5LIB", nil)
```

Avoid `ln_s`; `install_symlink` generates relative, relocatable links.

## Patches

```ruby
patch do
  url "https://example.com/foo-1.2.3-fix.patch"
  sha256 "0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
end

def install
  inreplace "Makefile" do |s|
    s.gsub! "-Werror", ""
    s.gsub! "/usr/local", prefix
  end
  # ...
end
```

Modifications in an `inreplace` block must be applied to `s`; the block's return value is ignored. Prefer passing variables to `make` over patching makefiles when possible.

## Patching around build failures

- Missing tool at build time → add `depends_on "tool" => :build`.
- Compiler flag incompatibility → pass `CC=#{ENV.cc}` / `CXX=#{ENV.cxx}` to `make`, or use `std_configure_args`.
- Makefile ignores `CXXFLAGS` → `inreplace` the flag or pass it as a make variable.
- Parallel build race → `ENV.deparallelize`.
- Undefined symbols / linkage problems → inspect `brew linkage --test <formula>` and verify every linked library has a `depends_on`.
