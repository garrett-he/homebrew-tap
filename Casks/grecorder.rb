cask "grecorder" do
  version "1.5.4"
  sha256 "fb8e6d557d96c58c3628e558b62c462e6d8d827d53ad1400c1c19a5bb01e415f"

  url "https://gstudios.ks3-cn-beijing.ksyuncs.com/%E3%80%90mac%E3%80%91%E5%91%B1%E5%91%B1%E6%9C%89%E5%A3%B0%E5%BD%95%E9%9F%B3%E5%AE%9DV#{version}.zip"
  name "GRecorder"
  name "呱呱有声录音宝"
  desc "Audio recording and editing app"
  homepage "https://gstudios.com.cn/recording"

  livecheck do
    url :homepage
    regex(/websiteVersion:"Version (\d+(?:\.\d+)+)/i)
    strategy :page_match
  end

  auto_updates true
  depends_on :macos
  container nested: "【mac】呱呱有声录音宝V#{version}/【mac安装包】呱呱有声录音宝_setup_#{version}_universal.dmg"

  app "呱呱有声录音宝.app"

  zap trash: [
    "~/Library/Application Support/呱呱有声录音宝",
    "~/Library/Caches/g-recorder-updater",
    "~/Library/Preferences/com.ling-ban.g-recorder.plist",
    "~/Library/Saved Application State/com.ling-ban.g-recorder.savedState",
  ]
end
