class SmartTop < Formula
  desc "Smart top: a TUI that diagnoses why your computer is slow and names the process responsible."
  homepage "https://github.com/adamatan/smart-top"
  version "0.1.0"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/adamatan/smart-top/releases/download/v0.1.0/smart-top-aarch64-apple-darwin.tar.xz"
      sha256 "1eafe1b7b72e599ae77da4b5d59c213bb3198cb9bdd36d663a1234c4d1bc77fd"
    end
    if Hardware::CPU.intel?
      url "https://github.com/adamatan/smart-top/releases/download/v0.1.0/smart-top-x86_64-apple-darwin.tar.xz"
      sha256 "56edb2ce75db4ca0a872c6e9cfbd80bb0ec1805b4630b6d5bece67712a1844e2"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/adamatan/smart-top/releases/download/v0.1.0/smart-top-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "487dfd63a2dbb911bb3d8570deefd92e67c290d81b620390cc0b56433f8afb9c"
    end
    if Hardware::CPU.intel?
      url "https://github.com/adamatan/smart-top/releases/download/v0.1.0/smart-top-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "fa261dcfb2c1416e32e2f9d4a0c561de9eee576aaa9ac0e0633ba01252b61fce"
    end
  end
  license any_of: ["MIT", "Apache-2.0"]

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
    bin.install "stop" if OS.mac? && Hardware::CPU.arm?
    bin.install "stop" if OS.mac? && Hardware::CPU.intel?
    bin.install "stop" if OS.linux? && Hardware::CPU.arm?
    bin.install "stop" if OS.linux? && Hardware::CPU.intel?

    install_binary_aliases!

    # Homebrew will automatically install these, so we don't need to do that
    doc_files = Dir["README.*", "readme.*", "LICENSE", "LICENSE.*", "CHANGELOG.*"]
    leftover_contents = Dir["*"] - doc_files

    # Install any leftover files in pkgshare; these are probably config or
    # sample files.
    pkgshare.install(*leftover_contents) unless leftover_contents.empty?
  end
end
