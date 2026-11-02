cask "nothingbar" do
  version "2.13.0"
  sha256 "403b5c0bdc38649ad658696c0aa5f04b93d0f0297e6d39c0a533fb2242490db3"

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
