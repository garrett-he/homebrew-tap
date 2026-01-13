class Foo < Formula
  desc "One-line description (do not repeat the formula name)"
  homepage "https://example.com/foo"
  url "https://example.com/foo-1.2.3.tar.gz"
  sha256 "REPLACE_WITH_SHA256"
  license "MIT" # SPDX identifier, e.g. MIT, BSD-2-Clause, Apache-2.0

  # Add dependencies required at build or test time.
  # depends_on "pkgconf" => :build
  # uses_from_macos "bzip2"

  def install
    # Match the upstream build system. Use std_*_args helpers.
    system "./configure", *std_configure_args
    system "make", "install"

    # For prebuilt binaries instead:
    # bin.install "foo"
    # prefix.install "LICENSE", "README.md"
  end

  test do
    # Exercise real functionality, not only --version / --help.
    assert_match "expected output", shell_output("#{bin}/foo some-command")
    # assert_path_exists testpath/"output.txt"
  end
end
