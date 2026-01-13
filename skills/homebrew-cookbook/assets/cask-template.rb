cask "example-app" do
  version "1.2.3"
  sha256 "REPLACE_WITH_SHA256"

  url "https://example.com/releases/ExampleApp-#{version}.dmg"
  name "Example App"
  desc "Short one-line description of the application"
  homepage "https://example.com/example-app"

  livecheck do
    url :url
    strategy :header_match
  end

  auto_updates false
  conflicts_with cask: "example-app-beta"
  # depends_on macos: :monterey
  # depends_on formula: "unar"

  app "Example App.app"

  # For a .pkg installer, always add an uninstall stanza too:
  # pkg "ExampleApp.pkg"
  # uninstall pkgutil: "com.example.exampleapp.*",
  #           quit:    "com.example.exampleapp"

  # Casks in homebrew/cask require zap:
  # zap trash: [
  #   "~/Library/Application Support/Example App",
  #   "~/Library/Preferences/com.example.exampleapp.plist",
  # ]
  # Use `zap :not_required` when there is nothing to zap.

  # caveats do
  #   requires_rosetta
  # end
end
