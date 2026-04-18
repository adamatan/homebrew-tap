class Hale < Formula
  desc "Instant network connection quality monitor"
  homepage "https://github.com/adamatan/hale"
  version "0.1.31"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/adamatan/hale/releases/download/v0.1.31/hale-aarch64-apple-darwin.tar.xz"
      sha256 "e2e61d4a9e0c2cceb04b9f07f2d1481b24cc81eb9e6cc29d919da099d1bb3d82"
    end
    if Hardware::CPU.intel?
      url "https://github.com/adamatan/hale/releases/download/v0.1.31/hale-x86_64-apple-darwin.tar.xz"
      sha256 "8648335c55a5ba39066bbff61144a1662d0f998c5cc43e683dd29b56f18fbd45"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/adamatan/hale/releases/download/v0.1.31/hale-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "6f36a6bd627137510c6d0728f87243e990c4d206a85d532651c937d329c12e2c"
    end
    if Hardware::CPU.intel?
      url "https://github.com/adamatan/hale/releases/download/v0.1.31/hale-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "e05c0974ee323785fef519f7907956dc232a4534868919e5bad8b17c7bdf5647"
    end
  end
  license "MIT"

  BINARY_ALIASES = {
    "aarch64-apple-darwin":      {},
    "aarch64-unknown-linux-gnu": {},
    "x86_64-apple-darwin":       {},
    "x86_64-unknown-linux-gnu":  {},
  }.freeze

  def target_triple
    cpu = Hardware::CPU.arm? ? "aarch64" : "x86_64"
    os = OS.mac? ? "apple-darwin" : "unknown-linux-gnu"

    "#{cpu}-#{os}"
  end

  def install_binary_aliases!
    BINARY_ALIASES[target_triple.to_sym].each do |source, dests|
      dests.each do |dest|
        bin.install_symlink bin/source.to_s => dest
      end
    end
  end

  def install
    bin.install "hale" if OS.mac? && Hardware::CPU.arm?
    bin.install "hale" if OS.mac? && Hardware::CPU.intel?
    bin.install "hale" if OS.linux? && Hardware::CPU.arm?
    bin.install "hale" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
