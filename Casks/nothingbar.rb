cask "nothingbar" do
  version "2.12.1"
  sha256 "7bace6632c5b314b72de8fdcd736b069e192b6d9cee77a8acafcea8f6236d748"

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
