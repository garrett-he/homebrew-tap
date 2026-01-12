cask "dubbing-rtvc" do
  version "1.5.12"
  sha256 "3b3bf86b3b63b9babf15008794f55046a20772bbbcb5f542e8ae1ae92a27e8f0"

  url "https://dvi.dubbing.tech/version_assets/2026/11/17/DubbingRtvcMacOSPro_v#{version}_2026.11.17.20.24_Release.pkg"
  name "大饼AI变声"
  desc "AI voice changer for gaming and live streaming"
  homepage "https://dubbing.tech/"

  livecheck do
    url "https://dubbing.tech/p/console/api/officialSite/download?productId=5&platformId=4&channel=official&versionId=0&fromUserId=0&redirect=1"
    strategy :header_match do |headers|
      headers["location"][/DubbingRtvcMacOSPro_v(\d+(?:\.\d+)+)_/i, 1]
    end
  end

  auto_updates true
  depends_on :macos

  pkg "DubbingRtvcMacOSPro_v#{version}_2026.11.17.20.24_Release.pkg"

  uninstall quit:    "halo.dubbingai.com",
            pkgutil: "halo.dubbingai.com",
            delete:  "/Library/Audio/Plug-Ins/HAL/DubbingVirtualAudio.driver"

  zap trash: [
    "~/Library/Caches/halo.dubbingai.com",
    "~/Library/Preferences/halo.dubbingai.com.plist",
  ]
end
