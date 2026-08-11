cask "nothingbar" do
  version "2.12.0"
  sha256 "56d1a1729657dd495120fefaf102a98744ac8b23410d2c6dbbd2de793e3d991f"

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
