cask "earmaster" do
  version :latest
  sha256 :no_check

  url "https://www.earmaster.com/download/EarMaster7.pkg"
  name "EarMaster"
  desc "Ear training, sight-singing and rhythm training"
  homepage "https://www.earmaster.com/"

  depends_on :macos

  pkg "EarMaster7.pkg"

  uninstall quit:    "com.earmaster.ear70p",
            pkgutil: "com.earmaster.ear70p"

  zap trash: [
    "~/Library/Application Support/com.earmaster.ear70p",
    "~/Library/Application Support/EarMaster 7",
    "~/Library/Caches/com.earmaster.ear70p",
    "~/Library/Preferences/com.earmaster.ear70p.plist",
    "~/Library/Saved Application State/com.earmaster.ear70p.savedState",
  ]
end
