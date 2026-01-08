{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, dpkg
, wrapGAppsHook3
, makeWrapper
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, libGL
, libX11
, libXScrnSaver
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXfixes
, libXi
, libXrandr
, libXrender
, libXtst
, libdrm
, libnotify
, libpulseaudio
, libuuid
, libxcb
, libxkbcommon
, mesa
, nspr
, nss
, pango
, systemd
, udev
, xdg-utils
, wayland
, libva
, libvdpau
}:

stdenv.mkDerivation rec {
  pname = "thorium-browser";
  version = "138.0.7204.300";

  src = fetchurl {
    url = "https://github.com/Alex313031/thorium/releases/download/M${version}/thorium-browser_${version}_AVX2.deb";
    sha256 = "16bzij7j74qcdzbc8agcv963b0swg3qi661yikyxrb96lwcx02k9";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    wrapGAppsHook3
    makeWrapper
    stdenv.cc.bintools
  ];

  autoPatchelfIgnoreMissingDeps = [
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libGL
    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libdrm
    libnotify
    libpulseaudio
    libuuid
    libxcb
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    udev
    xdg-utils
    wayland
    libva
    libvdpau
  ];

  unpackPhase = ''
    ar x $src
    tar xf data.tar.*
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/thorium
    cp -r opt/chromium.org/thorium/* $out/lib/thorium/

    # Fix the desktop file
    mkdir -p $out/share/applications
    cp usr/share/applications/thorium-browser.desktop $out/share/applications/thorium-browser.desktop || \
    cp $out/lib/thorium/thorium-browser.desktop $out/share/applications/thorium-browser.desktop

    # The original desktop file might have hardcoded paths or incorrect icon names
    # We use sed to ensure the Exec and Icon lines are correctly pointed to our store paths
    sed -i "s|/opt/chromium.org/thorium/thorium-browser|thorium-browser|g" $out/share/applications/thorium-browser.desktop
    # In case the icon path was absolute in the original file
    sed -i "s|Icon=/opt/chromium.org/thorium/.*|Icon=thorium-browser|g" $out/share/applications/thorium-browser.desktop

    # Icons
    for size in 16 24 32 48 64 128 256 512; do
      mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
      cp $out/lib/thorium/product_logo_''${size}.png $out/share/icons/hicolor/''${size}x''${size}/apps/thorium-browser.png || true
    done

    # Create bin wrapper
    mkdir -p $out/bin
    makeWrapper $out/lib/thorium/thorium-browser $out/bin/thorium-browser \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --add-flags "--ozone-platform-hint=auto" \
      --add-flags "--enable-features=WaylandWindowDecorations"

    runHook postInstall
  '';

  meta = with lib; {
    description = "The fastest browser on Earth. Chromium fork named after radioactive element number 90";
    homepage = "https://thorium.rocks/";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ ];
  };
}
