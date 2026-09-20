#!/usr/bin/env bash
# setup-sdr-wsl.sh — reproduce the WSL2 side of the SDR / OTA toolchain on
# another machine (built against Kali rolling 2026.2; any Debian-family
# distro with these packages in apt should work).
#
# Installs:  sdrpp            SDR++ receiver GUI (draws via WSLg). Kali/Debian
#                             testing only — NOT in Ubuntu 26.04 (arrives in
#                             26.10). On Ubuntu it is skipped; ota-window.sh
#                             needs only rtl-sdr, and `gqrx-sdr` is the apt
#                             GUI alternative there.
#            rtl-sdr          rtl_test / rtl_power, librtlsdr, udev rules
#            hdhomerun-config Flex Duo control, for ota-survey.sh (Phases 1-3)
# Then blacklists the kernel DVB driver so it can't claim the dongle, adds
# the user to plugdev (the udev rule's group), and verifies the dongle if
# it is attached.
#
# Run with:  ./setup-sdr-wsl.sh      (prompts for sudo)
# Pair with setup-sdr-windows.ps1 on the Windows side, which forwards the
# dongle into WSL — nothing here can see the dongle until that is done.

set -euo pipefail

[ -r /proc/version ] && grep -qi microsoft /proc/version \
  || echo "note: this does not look like WSL; the usbipd steps won't apply, the rest still does" >&2

echo "==> apt packages"
sudo apt update
for pkg in sdrpp rtl-sdr hdhomerun-config; do
  if apt-cache policy "$pkg" 2>/dev/null | grep -q 'Candidate: [^(]'; then
    sudo apt install -y "$pkg"
  else
    echo "!! $pkg is not in this distro's apt; install it another way" >&2
    [ "$pkg" = sdrpp ] && echo "   (expected on Ubuntu 26.04 — not needed for ota-window.sh; 'apt install gqrx-sdr' if you want a GUI)" >&2
  fi
done

echo "==> blacklist the kernel DVB-T driver (it grabs the dongle before librtlsdr can)"
echo 'blacklist dvb_usb_rtl28xxu' | sudo tee /etc/modprobe.d/blacklist-rtlsdr.conf >/dev/null
sudo rmmod dvb_usb_rtl28xxu 2>/dev/null || true

echo "==> plugdev group (udev rule 60-librtlsdr0.rules gives the dongle to plugdev)"
if id -nG "$USER" | grep -qw plugdev; then
  echo "    already a member"
else
  sudo usermod -aG plugdev "$USER"
  echo "    added — log out and back in (or 'wsl --shutdown' from Windows) for it to take effect"
fi
sudo udevadm control --reload && sudo udevadm trigger || true

echo "==> verify"
if lsusb 2>/dev/null | grep -qi '0bda:2838'; then
  echo "    dongle visible on USB:"; lsusb | grep -i 0bda:2838
  echo "    rtl_test (the 'No E4000 tuner found' line at the end is expected — that test is for a different tuner):"
  rtl_test -t 2>&1 | head -6 || true
else
  echo "    dongle not attached to WSL yet. On Windows (admin PowerShell):"
  echo "      usbipd attach --wsl --hardware-id 0bda:2838"
  echo "    then here:  lsusb && rtl_test -t"
fi

echo
echo "done. Phase 0 survey:  ./ota-window.sh   (stop SDR++ first — one owner per dongle)"
