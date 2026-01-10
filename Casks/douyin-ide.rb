cask "douyin-ide" do
  version "4.5.7"
  sha256 arm:   "7ba0574f6e5e0d332ead0f0ef6ae60f7110281de4752ecf306f5ace631e8727f",
         intel: "660e14fc86c4fb56ac096001a55d1a56a4ab5937ac8b26cc5801074bb4c981a8"

  on_arm do
    url "https://sf1-cdn-tos.douyinstatic.com/obj/microapp/frontend/ide/package/obj/developer/ide/531320067/darwin-arm64-pkg/%E6%8A%96%E9%9F%B3%E5%BC%80%E5%8F%91%E8%80%85%E5%B7%A5%E5%85%B7-#{version}-arm64.pkg"
  end
  on_arm do
    pkg "抖音开发者工具-#{version}-arm64.pkg"

    uninstall quit:    "ide.micro.app.bytedance",
              pkgutil: "ide.micro.app.bytedance"
  end
  on_intel do
    url "https://sf1-cdn-tos.douyinstatic.com/obj/microapp/frontend/ide/package/obj/developer/ide/531320067/darwin/%E6%8A%96%E9%9F%B3%E5%BC%80%E5%8F%91%E8%80%85%E5%B7%A5%E5%85%B7-#{version}-x64.dmg"
  end
  on_intel do
    app "抖音开发者工具.app"
  end

  name "Douyin Developer Tools"
  name "抖音开发者工具"
  desc "IDE for developing Douyin mini apps and mini games"
  homepage "https://developer.open-douyin.com/docs/resource/zh-CN/mini-app/develop/dev-tools/developer-instrument/download/developer-instrument-update-and-download"

  livecheck do
    url :homepage
    regex(%r{class="heading-h1"[^>]*><span></span><span>(\d+(?:\.\d+)+)}i)
    strategy :page_match
  end

  auto_updates true
  depends_on :macos

  zap trash: [
    "~/Library/Application Support/@byted/vela",
    "~/Library/Application Support/ide.micro.app.bytedance",
    "~/Library/Application Support/miniprogram-ide",
    "~/Library/Caches/@bytedminiprogram-ide-updater",
    "~/Library/Preferences/ide.micro.app.bytedance.plist",
    "~/Library/Saved Application State/ide.micro.app.bytedance.savedState",
  ]
end
