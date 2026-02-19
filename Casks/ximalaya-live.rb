cask "ximalaya-live" do
  version :latest
  sha256 :no_check

  url "https://www.ximalaya.com/down?from=live_mac"
  name "Ximalaya Live Assistant"
  name "喜马拉雅直播助手"
  desc "Live streaming assistant for Ximalaya hosts"
  homepage "https://www.ximalaya.com/download/"

  depends_on :macos

  app "喜马拉雅直播助手.app"

  zap trash: [
    "~/Library/Application Support/com.ximalaya.live",
    "~/Library/Application Support/喜马拉雅直播助手",
    "~/Library/Caches/com.ximalaya.live",
    "~/Library/Caches/xmly-live-updater",
    "~/Library/HTTPStorages/com.ximalaya.live",
    "~/Library/Preferences/com.ximalaya.live.plist",
    "~/Library/Saved Application State/com.ximalaya.live.savedState",
  ]
end
