cask "doubao-work" do
  version "2.37.7"
  sha256 "610b0baa001f69e383bc3da81f597c55663adbff1448bbd3396b4e8645cbf103"

  url "https://lf-flow-web-cdn.doubao.com/obj/flow-doubao/doubao_pc/#{version}/DoubaoWork_universal_#{version}.dmg"
  name "Doubao Work"
  desc "AI work assistant for documents, slides, research and automation"
  homepage "https://www.doubao.com/work"

  livecheck do
    url "https://www.doubao.com/service/settings/v3/?device_platform=web&brand=doubaowork&aid=1044603"
    strategy :json do |json|
      json.dig("data", "settings", "saman_update_address", "version")
    end
  end

  auto_updates true
  depends_on macos: :monterey

  app "DoubaoWork.app"

  zap trash: [
    "~/Library/Application Support/DoubaoWork",
    "~/Library/Caches/com.work.pc.doubao",
    "~/Library/Caches/DoubaoWork",
    "~/Library/HTTPStorages/com.work.pc.doubao",
    "~/Library/Preferences/com.work.pc.doubao.plist",
    "~/Library/Saved Application State/com.work.pc.doubao.savedState",
  ]
end
