class Hale < Formula
  desc "Instant network connection quality monitor"
  homepage "https://github.com/adamatan/hale"
  version "0.1.28"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/adamatan/hale/releases/download/v0.1.28/hale-aarch64-apple-darwin.tar.xz"
      sha256 "44f9ee91d19d38d5ac521293ddf6c76f0701bf676561df4fb2d429e8229bd5ca"
    end
    if Hardware::CPU.intel?
      url "https://github.com/adamatan/hale/releases/download/v0.1.28/hale-x86_64-apple-darwin.tar.xz"
      sha256 "5a25008af3ba7c750bad8a7d19dded186d422fb113e7401c05d8e545e23164d5"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/adamatan/hale/releases/download/v0.1.28/hale-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "93823277842f2e9c0c95a9f1c33d4364c7c47326a67e4329617e71bffa673698"
    end
    if Hardware::CPU.intel?
      url "https://github.com/adamatan/hale/releases/download/v0.1.28/hale-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "91e08ba2f6f69a763b251c3acc695fcba0c75fa4772d91078713e1dd4805c53f"
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
