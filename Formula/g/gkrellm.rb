class Gkrellm < Formula
  desc "Extensible GTK system monitoring application"
  homepage "https://billw2.github.io/gkrellm/gkrellm.html"
  url "https://gkrellm.srcbox.net/releases/gkrellm-2.4.0.tar.bz2"
  sha256 "6f83665760b936ad4b55f9182b1ec7601faf38a0f25ea1e4bddc9965088f032d"
  license "GPL-3.0-or-later"

  livecheck do
    url "https://gkrellm.srcbox.net/releases/"
    regex(/href=.*?gkrellm[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_sonoma:   "993ebbc08b5ec357975352c9a128735a459e5e844d45502fc47179f2ffbb70e7"
    sha256 arm64_ventura:  "b76e8a47e234dcaddce425c0c01250bd5055de84de83428e1035e7545fa59eeb"
    sha256 arm64_monterey: "cffde5aecac4ab95199a6a127eefa70248eea91eab2e3eb48f67b808e8094bd1"
    sha256 sonoma:         "2fd34cbbdb66f96ab134190c082ad04c14bd82a93a972f0cf5ad01636d71cda3"
    sha256 ventura:        "39828a1b0aa6586591195d1b7175a9a127abf4ed13e6a22094410f88ed05da7c"
    sha256 monterey:       "ac1bdf3dcd6745101eb07b106acd4ae64d7e68ea27307dfc7033d1915f8af74d"
    sha256 x86_64_linux:   "8d8b012ba597fb48d4a205aecfff14230f67053b25a504e64945378fa3331fd4"
  end

  depends_on "pkgconf" => :build
  depends_on "at-spi2-core"
  depends_on "cairo"
  depends_on "fontconfig"
  depends_on "freetype"
  depends_on "gdk-pixbuf"
  depends_on "gettext"
  depends_on "glib"
  depends_on "gtk+" # GTK3 issue: https://git.srcbox.net/gkrellm/gkrellm/issues/1
  depends_on "openssl@3"
  depends_on "pango"

  on_macos do
    depends_on "harfbuzz"
  end

  on_linux do
    depends_on "libice"
    depends_on "libsm"
    depends_on "libx11"
  end

  # disable systemd service handling on macos, upstream pr ref: https://git.srcbox.net/gkrellm/gkrellm/pulls/44
  patch do
    url "https://git.srcbox.net/gkrellm/gkrellm/commit/bb444190052b3d4096bbaaeaef15a57df4212b3c.patch?full_index=1"
    sha256 "20e7d9ed74977450c4417b558a2bd3bbb2cbaf6c0e8cd4df12ea07cf574fb703"
  end

  def install
    args = ["INSTALLROOT=#{prefix}"]
    args << "macosx" if OS.mac?
    system "make", *args
    system "make", "INSTALLROOT=#{prefix}", "install"
  end

  test do
    pid = spawn "#{bin}/gkrellmd --pidfile #{testpath}/test.pid"
    sleep 2

    begin
      assert_path_exists testpath/"test.pid"
    ensure
      Process.kill "SIGINT", pid
      Process.wait pid
    end
  end
end
