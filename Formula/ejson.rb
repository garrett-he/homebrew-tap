class Ejson < Formula
  desc "Manage encrypted secrets using public key encryption"
  homepage "https://github.com/Shopify/ejson"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Shopify/ejson/releases/download/v1.6.0/ejson_1.6.0_darwin_arm64.tar.gz"
      sha256 "cd43c9dbc729e8e46f4357c52bb1201976aade036f37bcc2274221db12401467"
    end
    on_intel do
      url "https://github.com/Shopify/ejson/releases/download/v1.6.0/ejson_1.6.0_darwin_amd64.tar.gz"
      sha256 "49b9cf0c69610a27fcf1663561af280d93976c64e40cf44eeac0e365353b4f14"
    end
  end

  def install
    bin.install "ejson"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ejson --version")

    keygen = shell_output("#{bin}/ejson keygen")
    public_key = keygen.lines[1].strip
    private_key = keygen.lines[3].strip
    assert_match(/\A[0-9a-f]{64}\z/, public_key)
    assert_match(/\A[0-9a-f]{64}\z/, private_key)

    keydir = testpath/"keys"
    keydir.mkpath
    (keydir/public_key).write private_key

    (testpath/"secrets.ejson").write <<~JSON
      {
        "_public_key": "#{public_key}",
        "password": "hunter2"
      }
    JSON

    system bin/"ejson", "encrypt", "secrets.ejson"
    refute_match "hunter2", (testpath/"secrets.ejson").read

    decrypted = shell_output("#{bin}/ejson --keydir #{keydir} decrypt secrets.ejson")
    assert_match "hunter2", decrypted
  end
end
