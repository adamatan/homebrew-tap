class Hale < Formula
  desc "Instant network connection quality monitor"
  homepage "https://github.com/adamatan/hale"
  version "0.1.30"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/adamatan/hale/releases/download/v0.1.30/hale-aarch64-apple-darwin.tar.xz"
      sha256 "0f770713e679c65f6b7fd84de2df113a3eefa3233e1f334f358e7af3ca026b10"
    end
    if Hardware::CPU.intel?
      url "https://github.com/adamatan/hale/releases/download/v0.1.30/hale-x86_64-apple-darwin.tar.xz"
      sha256 "2ccda8ecad586be64fa471c8ef51ebd10008b882850409348e39b43f73c5fadc"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/adamatan/hale/releases/download/v0.1.30/hale-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "95579c8fbd407810799e084e8239e5db5d62e9d15cd3b3ffbf396750ba855525"
    end
    if Hardware::CPU.intel?
      url "https://github.com/adamatan/hale/releases/download/v0.1.30/hale-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "31dbb28f077d577c005e178d523eae8f8cae9c486cd0f0ebe772437ac4369295"
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
