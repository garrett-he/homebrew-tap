cask "wxformbuilder" do
  arch arm: "14.5-arm64", intel: "12.7-x86_64"

  version "4.2.1"
  sha256 arm:   "192750f2a108c4dbb97c59bc2f6840d39485ca241ea8efbfdb7a5c1e7e34c5ac",
         intel: "235a495ae357a24bb7e08c2167d1660598c3f881167d9a96bfeda5995a5ef0ac"

  on_arm do
    depends_on macos: :sonoma
  end
  on_intel do
    depends_on macos: :monterey
  end

  url "https://github.com/wxFormBuilder/wxFormBuilder/releases/download/v#{version}/wxFormBuilder-#{version}-macos-#{arch}-bundle.zip"
  name "wxFormBuilder"
  desc "Visual GUI designer for wxWidgets applications"
  homepage "https://github.com/wxFormBuilder/wxFormBuilder"

  livecheck do
    url :url
    strategy :github_latest
  end

  app "wxFormBuilder.app"

  uninstall quit: "org.wxformbuilder.wxFormBuilder"

  zap trash: [
    "~/Library/Preferences/wxFormBuilder",
    "~/Library/Saved Application State/org.wxformbuilder.wxFormBuilder.savedState",
  ]
end
