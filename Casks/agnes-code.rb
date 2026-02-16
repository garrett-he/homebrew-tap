cask "agnes-code" do
  arch arm: "AgnesCode", intel: "AgnesCode-intel"

  version :latest
  sha256 :no_check

  url "https://cos-agnes-code.agnes-ai.cn/release/latest/#{arch}.dmg"
  name "Agnes Code"
  desc "Free AI coding desktop workbench with built-in models and MCP support"
  homepage "https://agnes-ai.com/agnescode"

  depends_on macos: :monterey

  app "AgnesCode.app"

  zap trash: [
    "~/Library/Application Support/AgnesCode",
    "~/Library/Caches/com.agnes.code",
    "~/Library/Preferences/com.agnes.code.plist",
    "~/Library/Saved Application State/com.agnes.code.savedState",
  ]
end
