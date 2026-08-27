cask "nothingbar" do
  version "2.12.2"
  sha256 "89f8d18d61ee526a4904c522babe8d1edf59a33a2c0ce631395e9bb46285eba4"

  url "https://github.com/bestK1ngArthur/nothing-bar/releases/download/#{version}/nothing-bar-#{version}.zip"
  name "NothingBar"
  desc "Control Nothing headphones and earbuds from the menu bar"
  homepage "https://nothingbar.bestk1ng.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on macos: :ventura

  app "NothingBar.app"

  zap trash: "~/Library/Preferences/com.bestk1ng.NothingBar.plist"
end
