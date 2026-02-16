cask "mimo-desktop" do
  version :latest
  sha256 :no_check

  url "https://mimocode-cdn.xiaomimimo.com/mimocode/mimodesktop/XiaomiMiMo-latest-arm64.dmg"
  name "Xiaomi MiMo"
  desc "AI desktop assistant for documents, slides, research and automation"
  homepage "https://mimo.xiaomimimo.com/desktop/"

  depends_on arch: :arm64
  depends_on macos: :monterey

  app "Xiaomi MiMo.app"

  zap trash: [
    "~/Library/Application Support/com.xiaomi.mimo.desktop",
    "~/Library/Caches/com.xiaomi.mimo.desktop",
    "~/Library/Caches/xiaomi-mimo-desktop-updater",
    "~/Library/HTTPStorages/com.xiaomi.mimo.desktop",
    "~/Library/Preferences/com.xiaomi.mimo.desktop.plist",
    "~/Library/Saved Application State/com.xiaomi.mimo.desktop.savedState",
  ]
end
