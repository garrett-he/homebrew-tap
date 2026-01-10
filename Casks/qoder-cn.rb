cask "qoder-cn" do
  arch arm: "arm64", intel: "x64"

  version "0.5.14"
  sha256 arm:   "71a7e393e566be4d9f582dd0366e8b10eafe2c97c58761b87663ba5531caa7b5",
         intel: "a93892ff2cbf7cf8dc06b89e4d5babf05985ded7545d555e181ead35d6ceda40"

  url "https://static.qoder.com.cn/qoder-app/releases/#{version}/Qoder-CN-mac-#{arch}.zip"
  name "Qoder CN"
  desc "Agentic coding platform (China edition)"
  homepage "https://qoder.cn/"

  livecheck do
    url "https://static.qoder.com.cn/qoder-app/releases/latest-mac.yml"
    strategy :electron_builder
  end

  auto_updates true
  depends_on macos: :monterey

  app "Qoder CN.app"

  uninstall quit: "com.qodercn.app"

  zap trash: [
    "~/.qoder-cn",
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.qodercn.app.sfl*",
    "~/Library/Application Support/com.qodercn.app",
    "~/Library/Preferences/com.qodercn.app.plist",
  ]
end
