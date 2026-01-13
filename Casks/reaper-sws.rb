cask "reaper-sws" do
  arch arm: "arm64", intel: "x86_64"

  version "2.14.0.7"
  sha256 arm:   "03338b0608775840aa6c51cc4d9e0404634ba4095e5c5253d944b387ba439100",
         intel: "ef04a089a39c087a545c1b4e05d4d38b7f3933de22f059d6080a7870dd11c9cb"

  on_arm do
    artifact "reaper_sws-arm64.dylib",
             target: "~/Library/Application Support/REAPER/UserPlugins/reaper_sws-arm64.dylib"
  end
  on_intel do
    artifact "reaper_sws-x86_64.dylib",
             target: "~/Library/Application Support/REAPER/UserPlugins/reaper_sws-x86_64.dylib"
  end

  url "https://sws-extension.org/download/featured/sws-#{version}-Darwin-#{arch}.dmg"
  name "SWS Extension"
  desc "Extension for the REAPER digital audio workstation"
  homepage "https://sws-extension.org/"

  livecheck do
    url :homepage
    regex(/sws-(\d+(?:\.\d+)+)-Darwin-arm64\.dmg/i)
  end

  depends_on cask: "reaper"
  depends_on :macos

  artifact "sws_python.py",
           target: "~/Library/Application Support/REAPER/Scripts/sws_python.py"
  artifact "sws_python64.py",
           target: "~/Library/Application Support/REAPER/Scripts/sws_python64.py"
  artifact "Grooves",
           target: "~/Library/Application Support/REAPER/Grooves"

  zap trash: [
    "~/Library/Application Support/REAPER/Grooves",
    "~/Library/Application Support/REAPER/Scripts/sws_python.py",
    "~/Library/Application Support/REAPER/Scripts/sws_python64.py",
    "~/Library/Application Support/REAPER/UserPlugins/reaper_sws-arm64.dylib",
    "~/Library/Application Support/REAPER/UserPlugins/reaper_sws-x86_64.dylib",
  ]
end
