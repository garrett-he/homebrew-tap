cask "dumate" do
  version :latest
  sha256 :no_check

  url "https://dumate-app-public.cdn.bcebos.com/release-info/artifacts/Dumate-mac-arm64-latest.dmg"
  name "DuMate"
  name "百度搭子 DuMate"
  desc "AI agent that automates office tasks across apps and files"
  homepage "https://www.dumate.cn/"

  depends_on arch: :arm64
  depends_on macos: :monterey

  app "DuMate.app"

  zap trash: [
    "~/Library/Application Support/qianfan-desktop-app",
    "~/Library/Caches/com.baidu.qianfan.desktop",
    "~/Library/Caches/qianfan-desktop-app-updater",
    "~/Library/HTTPStorages/com.baidu.qianfan.desktop",
    "~/Library/Preferences/com.baidu.qianfan.desktop.plist",
    "~/Library/Saved Application State/com.baidu.qianfan.desktop.savedState",
  ]
end
