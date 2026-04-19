class Dfh < Formula
  desc "Human-readable disk usage with colorized bars, physical disk grouping, and system volume annotations"
  homepage "https://github.com/adamatan/dfh"
  version "0.1.4"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/adamatan/dfh/releases/download/v0.1.4/dfh-aarch64-apple-darwin.tar.xz"
      sha256 "86fd931666698820765e3f73941f5d0a4f2c101ac178a100c87aa0fcf61ea9f3"
    end
    if Hardware::CPU.intel?
      url "https://github.com/adamatan/dfh/releases/download/v0.1.4/dfh-x86_64-apple-darwin.tar.xz"
      sha256 "c665489ea3a15dcabf7519c5cffbf2049f9451aa08097e2ce2705a4e80230575"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/adamatan/dfh/releases/download/v0.1.4/dfh-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "e1de7b0f42d732c268f1c37866223ad37dfb2717bce2b8e570ca90f087b262d7"
    end
    if Hardware::CPU.intel?
      url "https://github.com/adamatan/dfh/releases/download/v0.1.4/dfh-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "934bf62a202857bc9b50a3a443576a1fcde4ba40db9ec3a28c44110fe8180a5d"
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
