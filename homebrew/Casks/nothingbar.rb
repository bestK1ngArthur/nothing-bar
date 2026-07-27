cask "nothingbar" do
  version "2.10.0"
  sha256 "979e3668ba95f7a4b6fc7fc756efb2f962af7a48b3f5897d0023bf582aecc2af"

  url "https://github.com/bestK1ngArthur/nothing-bar/releases/download/#{version}/nothing-bar-#{version}.zip"
  name "NothingBar"
  desc "Native macOS menu bar app to control Nothing and CMF headphones"
  homepage "https://github.com/bestK1ngArthur/nothing-bar"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  depends_on macos: ">= :ventura"

  app "NothingBar.app"

  zap trash: [
    "~/Library/Preferences/com.bestk1ng.NothingBar.plist",
    "~/Library/HTTPStorages/com.bestk1ng.NothingBar",
    "~/Library/Caches/com.bestk1ng.NothingBar",
  ]
end