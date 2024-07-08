class Uv < Formula
  desc "Extremely fast Python package installer and resolver, written in Rust"
  homepage "https://github.com/astral-sh/uv"
  url "https://github.com/astral-sh/uv/archive/refs/tags/0.2.23.tar.gz"
  sha256 "66180758496773d35c10c79f13e73155b6898a7afe7504333b7a9f10c4f19c6a"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/astral-sh/uv.git", branch: "main"

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "a84920842a5a6048107d4317d5fe17bc16409a975db4caa9df525fc1b2cac35f"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "39b3199c43622c86f1caf87909a58997b48be7334b4cf6c8c8653891d753b760"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "c5a7a5405984b8b2dcf51fa704f5885644d292ab5d7b7bec4001f10cf4a7aeba"
    sha256 cellar: :any_skip_relocation, sonoma:         "7ff7a8ef16964e503dcf5d6270d724d45123f3c6a4efcfb863d4d70c2f8d3561"
    sha256 cellar: :any_skip_relocation, ventura:        "872a07fb1c13916141796bc494666bfd7b991c896c6bfafc8f5d149f569aad63"
    sha256 cellar: :any_skip_relocation, monterey:       "6fcf3ac01a3b4f469433a25b3e249a130369141a30c15233edd811b7065e4fbd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "c0069cffe395b3fe51528cef48b201ad9a098f6d7a11b56c6e0a7080567c7aa7"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build

  uses_from_macos "python" => :test

  on_linux do
    # On macOS, bzip2-sys will use the bundled lib as it cannot find the system or brew lib.
    # We only ship bzip2.pc on Linux which bzip2-sys needs to find library.
    depends_on "bzip2"
  end

  def install
    ENV["UV_COMMIT_HASH"] = ENV["UV_COMMIT_SHORT_HASH"] = tap.user
    ENV["UV_COMMIT_DATE"] = time.strftime("%F")
    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "crates/uv")
    generate_completions_from_executable(bin/"uv", "generate-shell-completion")
  end

  test do
    (testpath/"requirements.in").write <<~EOS
      requests
    EOS

    compiled = shell_output("#{bin}/uv pip compile -q requirements.in")
    assert_match "This file was autogenerated by uv", compiled
    assert_match "# via requests", compiled

    assert_match "ruff 0.5.1", shell_output("#{bin}/uvx -q ruff@0.5.1 --version")
  end
end
