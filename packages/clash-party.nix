{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  perl,
  wrapGAppsHook3,
  alsa-lib,
  atk,
  at-spi2-atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libglvnd,
  libdrm,
  libgbm,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxtst,
  libxcb,
  libxshmfence,
  nspr,
  nss,
  pango,
  systemd,
  zlib,
}:

let
  pname = "clash-party";
  version = "1.9.6";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://github.com/mihomo-party-org/clash-party/releases/download/v${version}/clash-party-linux-${version}-amd64.deb";
      hash = "sha256-n8FUF0Mur6UdrSEhf1V8XEsCkvgU52/9xqRTpFH1geo=";
    };
  };
in
stdenv.mkDerivation {
  inherit pname version;
  src =
    sources.${stdenv.hostPlatform.system}
      or (throw "Unsupported system for ${pname}: ${stdenv.hostPlatform.system}");

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    perl
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    atk
    at-spi2-atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libglvnd
    libdrm
    libgbm
    libxkbcommon
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    systemd
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxscrnsaver
    libxtst
    libxcb
    libxshmfence
    zlib
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    ${dpkg}/bin/dpkg-deb -x "$src" unpacked
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/lib/${pname}" "$out/share"

    cp -r unpacked/opt/clash-party/. "$out/lib/${pname}"
    cp -r unpacked/usr/share/. "$out/share"

    ASAR_PATH="$out/lib/${pname}/resources/app.asar"

    chmod -R u+w "$out/share/applications"
    for desktop in "$out"/share/applications/*.desktop; do
      sed -i \
        -e "s|/opt/clash-party/mihomo-party|$out/bin/clash-party|g" \
        -e "s|Exec=mihomo-party|Exec=clash-party|g" \
        "$desktop"
    done

    # Upstream 1.9.6 Linux .deb ships sysproxy-rs JS without the matching native
    # binding. Patch the bundled module to a Linux no-op so the Electron main
    # process can start; Clash Party still manages TUN/core independently.
    perl - "$ASAR_PATH" <<'PERL'
use strict;
use warnings;

my $path = shift @ARGV;
open my $fh, '+<:raw', $path or die "open $path: $!";

read($fh, my $prefix, 16) == 16 or die "short asar prefix";
my (undef, undef, undef, $header_size) = unpack('V4', $prefix);
read($fh, my $header, $header_size) == $header_size or die "short asar header";

$header =~ /"sysproxy-rs":\{"files":\{"index\.js":\{"size":(\d+),"offset":"(\d+)"/
  or die "sysproxy-rs index.js not found in asar header";

my ($size, $offset) = ($1, $2);
my $content_base = 16 + $header_size;
my $absolute_offset = $content_base + $offset;

my $stub = <<'STUB';
const noop = () => true;
const noopAsync = async () => true;
const emptyProxy = () => ({ enable: false, host: "", bypass: [], mode: "manual", pacScript: "" });

module.exports.triggerManualProxy = noopAsync;
module.exports.triggerAutoProxy = noopAsync;
module.exports.getSystemProxy = emptyProxy;
module.exports.getAutoProxy = emptyProxy;
module.exports.setSystemProxy = noopAsync;
module.exports.setAutoProxy = noopAsync;
module.exports.setProxy = noopAsync;
module.exports.enableProxy = noopAsync;
module.exports.openUWPTool = noop;
STUB

length($stub) <= $size or die "sysproxy-rs stub larger than original index.js";
$stub .= ' ' x ($size - length($stub));

seek($fh, $absolute_offset, 0) or die "seek failed";
print {$fh} $stub or die "write failed";
close $fh or die "close failed";
PERL

    mkdir -p "$out/lib/${pname}/resources/nix-sidecar-store"
    for sidecar in mihomo mihomo-alpha mihomo-smart; do
      mv "$out/lib/${pname}/resources/sidecar/$sidecar" \
        "$out/lib/${pname}/resources/nix-sidecar-store/$sidecar.bin.real"
    done
    rm -rf "$out/lib/${pname}/resources/sidecar"
    ln -s /var/lib/clash-party/sidecar "$out/lib/${pname}/resources/sidecar"

    makeWrapper "$out/lib/${pname}/mihomo-party" "$out/bin/clash-party" \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libglvnd ]}" \
      --add-flags "--disable-setuid-sandbox"
    ln -s "$out/bin/clash-party" "$out/bin/mihomo-party"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Electron-based Mihomo GUI";
    homepage = "https://github.com/mihomo-party-org/clash-party";
    license = licenses.gpl3Only;
    mainProgram = "clash-party";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
