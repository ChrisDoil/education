#!/usr/bin/env bash
# ota-survey.sh — sweep the RF channels predicted for this location and report
# the Flex Duo's own per-channel signal metrics.
#
# Channel list is from the RabbitEars survey of 2026-09-13 (West Oahu).
# Frequencies are ATSC channel CENTERS:
#   VHF-Hi (7-13): center = 174 + 6*(n-7) + 3   MHz
#   UHF   (14-36): center = 470 + 6*(n-14) + 3  MHz
#
# Usage:  HDHR=192.168.5.56 ./ota-survey.sh          # picks a free tuner
#         HDHR=10990608 TUNER=1 SETTLE=4 ./ota-survey.sh
#
# Reads only; releases the tuner on exit. Safe to re-run while repositioning
# the antenna — that is the point.

set -uo pipefail

HDHR="${HDHR:?set HDHR to the tuner IP address or 8-hex-digit device ID}"
TUNER="${TUNER:-}"      # default: first tuner not locked by a client
SETTLE="${SETTLE:-2}"   # seconds to let the demod lock before reading

CHANNELS=(
  "8:183000000:KHON  FOX/CW   VHF-Hi *"
  "11:201000000:KHET  PBS      VHF-Hi"
  "15:479000000:KUPU  IND"
  "18:497000000:KALO  REL"
  "19:503000000:KIKU  IND"
  "20:509000000:KITV  ABC      cluster B"
  "22:521000000:KHII  ATSC 3.0 expect NO lock"
  "23:527000000:KGMB  CBS"
  "26:545000000:KWBN  Daystar"
  "27:551000000:KAAH  TBN"
  "29:563000000:KKAI  IND"
  "31:575000000:KWHE  IND      cluster B"
  "32:581000000:KPXO  ION"
  "33:587000000:KBFD  Korean   cluster B"
  "35:599000000:KHNL  NBC"
  "36:605000000:KHHI-LD        LTE-adjacent"
)

release() { hdhomerun_config "$HDHR" set "/tuner$TUNER/channel" none >/dev/null 2>&1; }
trap release EXIT

command -v hdhomerun_config >/dev/null || {
  echo "hdhomerun_config not found. On Debian/Kali: sudo apt install hdhomerun-config" >&2
  echo "If discovery fails under WSL2, pass the tuner's IP directly in HDHR." >&2
  exit 1
}

# A tuner streaming to a client (the HDHomeRun app, the TV) refuses `set`,
# and `get status` then reports the client's channel — a survey run against
# it is the same reading 16 times. Pick a free tuner, and refuse to run
# blind if the caller forced a busy one.
if [ -z "$TUNER" ]; then
  for t in 0 1; do
    key=$(hdhomerun_config "$HDHR" get "/tuner$t/lockkey" 2>/dev/null)
    [ "$key" = none ] && { TUNER=$t; break; }
  done
  [ -n "$TUNER" ] || { echo "both tuners are locked by clients — stop the HDHomeRun app / TV and retry" >&2; exit 1; }
else
  key=$(hdhomerun_config "$HDHR" get "/tuner$TUNER/lockkey" 2>/dev/null)
  [ "$key" = none ] || { echo "tuner$TUNER is locked by $key — use another tuner or stop that client" >&2; exit 1; }
fi
echo "using tuner$TUNER" >&2

printf '%-4s %-30s %-6s %4s %4s %4s  %s\n' RF STATION LOCK ss snq seq VERDICT
printf '%-4s %-30s %-6s %4s %4s %4s  %s\n' ---- ------------------------------ ------ ---- ---- ---- -------

for entry in "${CHANNELS[@]}"; do
  IFS=: read -r rf freq name <<<"$entry"

  hdhomerun_config "$HDHR" set "/tuner$TUNER/channel" "8vsb:$freq" >/dev/null 2>&1 \
    || { echo "tuner$TUNER refused set on RF $rf (client grabbed it mid-run?) — aborting" >&2; exit 1; }
  sleep "$SETTLE"
  status=$(hdhomerun_config "$HDHR" get "/tuner$TUNER/status" 2>/dev/null)

  lock=$(grep -o 'lock=[^ ]*' <<<"$status" | cut -d= -f2)
  ss=$( grep -o 'ss=[0-9]*'   <<<"$status" | cut -d= -f2)
  snq=$(grep -o 'snq=[0-9]*'  <<<"$status" | cut -d= -f2)
  sq=$( grep -o 'seq=[0-9]*'  <<<"$status" | cut -d= -f2)

  lock="${lock:-none}"; ss="${ss:-0}"; snq="${snq:-0}"; sq="${sq:-0}"

  # seq (symbol quality) is the deciding number; ss pinned at 100 with seq<100
  # is the overload signature, not a weak-signal one.
  if   [ "$lock" = none ];                      then verdict="NO LOCK"
  elif [ "$sq" -eq 100 ] && [ "$ss" -ge 100 ];  then verdict="ok (ss pinned - watch)"
  elif [ "$sq" -eq 100 ];                       then verdict="PASS"
  elif [ "$ss" -ge 100 ];                       then verdict="OVERLOAD? try the pad"
  else                                               verdict="MARGINAL"
  fi

  printf '%-4s %-30s %-6s %4s %4s %4s  %s\n' "$rf" "$name" "$lock" "$ss" "$snq" "$sq" "$verdict"
done

echo
echo "* KHON RF 8 is the station with the least margin (+46.6 dB, VHF-Hi,"
echo "  far cluster). If exactly one channel disappoints, expect it to be this one."
