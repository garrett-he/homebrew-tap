cask "replay" do
  arch arm: "mac", intel: "mac_x64"

  version :latest
  sha256 :no_check

  url "https://tryreplay.io/api/replay/download-url?platform=#{arch}"
  name "Replay"
  desc "Offline AI audio production and voice conversion tool"
  homepage "https://www.weights.com/replay"

  depends_on macos: :monterey

  app "Replay.app"

  zap trash: [
    "~/Library/Application Support/Replay",
    "~/Library/Caches/com.replay.Replay",
    "~/Library/Logs/Replay",
    "~/Library/Preferences/com.replay.Replay.plist",
  ]
end
