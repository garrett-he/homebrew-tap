cask "douyin-webcast-mate" do
  version :latest
  sha256 :no_check

  url "https://streamingtool.douyin.com/api/invoke/download-mac?arch=universal&isAutoUpdate=1"
  name "Douyin Webcast Mate"
  name "抖音直播伴侣Mac版"
  desc "Live streaming companion app for Douyin"
  homepage "https://streamingtool.douyin.com/"

  depends_on macos: :ventura

  app "Douyin Webcast Mate.app"

  zap trash: [
    "~/Library/Application Support/Douyin Webcast Mate",
    "~/Library/Caches/com.bytedance.webcastmate.mac",
    "~/Library/Caches/webcast_mate_mac-updater",
    "~/Library/Preferences/com.bytedance.webcastmate.mac.plist",
    "~/Library/Saved Application State/com.bytedance.webcastmate.mac.savedState",
  ]
end
