cask "qwenwork-cn" do
  arch arm: "arm64", intel: "x64"

  version :latest
  sha256 :no_check

  url "https://assets.qwenwork.cn/release/latest/qwenworkcn-darwin-#{arch}.dmg"
  name "QwenWork"
  desc "AI work assistant for documents, slides, research and automation"
  homepage "https://qwenwork.cn/"

  depends_on macos: :sonoma

  app "QwenWorkCN.app"

  zap trash: [
    "~/Library/Application Support/cn.qwenwork.desktop.mac",
    "~/Library/Caches/cn.qwenwork.desktop.mac",
    "~/Library/HTTPStorages/cn.qwenwork.desktop.mac",
    "~/Library/Preferences/cn.qwenwork.desktop.mac.plist",
    "~/Library/Saved Application State/cn.qwenwork.desktop.mac.savedState",
  ]
end
