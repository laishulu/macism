# Documentation: https://docs.brew.sh/Formula-Cookbook
#                https://rubydoc.brew.sh/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
class Macism < Formula
  version '1.0.0'
  desc "MacOS Input Source Manager"
  homepage "https://github.com/laishulu/macism"
  url "https://github.com/laishulu/macism/releases/download/#{version}/macism-#{version}-x86_64-apple-darwin.tar.gz"
  sha256 "7f5a47e64906ee3f5be06f9c98572f1e2481d922657e49455cb4f2842d059ef3"

  # depends_on "cmake" => :build
  def install
    bin.install "macsim"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fa'i il and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test macism`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "true"
  end
end
