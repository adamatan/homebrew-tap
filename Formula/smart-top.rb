class SmartTop < Formula
  desc "Smart top: a TUI that diagnoses why your computer is slow and names the process responsible."
  homepage "https://github.com/adamatan/smart-top"
  version "0.1.1"
  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/adamatan/smart-top/releases/download/v0.1.1/smart-top-aarch64-apple-darwin.tar.xz"
      sha256 "78f3c5a05136c91e818cd4beed8e30182238e73afcdbb7272e04e684f172f9b2"
    end
    if Hardware::CPU.intel?
      url "https://github.com/adamatan/smart-top/releases/download/v0.1.1/smart-top-x86_64-apple-darwin.tar.xz"
      sha256 "257acf0fc33a3c23d2faad553e1cb8d2a6fd645675f8aa5b660264a38d25bea0"
    end
  end
  if OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/adamatan/smart-top/releases/download/v0.1.1/smart-top-aarch64-unknown-linux-gnu.tar.xz"
      sha256 "86b518c687ef825dc7f5952be45eb4dd0d72cafe893e992f8ad7575ef6e0fbef"
    end
    if Hardware::CPU.intel?
      url "https://github.com/adamatan/smart-top/releases/download/v0.1.1/smart-top-x86_64-unknown-linux-gnu.tar.xz"
      sha256 "02de03271c89110cc01049c084a29955762405394ba6930e13aa4562489cb466"
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
