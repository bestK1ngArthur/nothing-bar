cask "nothingbar" do
  version "2.11.0"
  sha256 "36c9edc97a326eb952a363889d6ecee40cbc1314c4a42361130bd351a87c2f88"

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
