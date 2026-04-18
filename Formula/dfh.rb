class Dfh < Formula
  desc "Human-readable disk usage with colorized bars, physical disk grouping, and system volume annotations"
  homepage "https://github.com/adamatan/dfh"
  version "0.1.3"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/adamatan/dfh/releases/download/v0.1.3/dfh-aarch64-apple-darwin.tar.xz"
      sha256 "9f32e7b18a0d5ce0fb949cbb6c09ae6d3011f8971ccb298987a3b44d8523ed07"
    end
    if Hardware::CPU.intel?
      url "https://github.com/adamatan/dfh/releases/download/v0.1.3/dfh-x86_64-apple-darwin.tar.xz"
      sha256 "68357b661019c3603afe9624929586dee38d648320201eb07831811af6dd7e06"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/adamatan/dfh/releases/download/v0.1.3/dfh-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "239ee28c4c77b06b9c35897a1979bea9fc160e7a89bc1e045356d36524de52f0"
    end
    if Hardware::CPU.intel?
      url "https://github.com/adamatan/dfh/releases/download/v0.1.3/dfh-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "39784a50487327c6b17111534882f5ee0dc3b8932a3a3e3078dd614482d81056"
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
    bin.install "dfh" if OS.mac? && Hardware::CPU.arm?
    bin.install "dfh" if OS.mac? && Hardware::CPU.intel?
    bin.install "dfh" if OS.linux? && Hardware::CPU.arm?
    bin.install "dfh" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
