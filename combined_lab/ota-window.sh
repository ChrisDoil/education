#!/usr/bin/env bash
# ota-window.sh — Phase 0 window survey, as numbers instead of a screenshot.
#
# Sweeps the two reference stations with rtl_power and prints, per station:
#   noise  median level in an EMPTY neighbouring channel (the reference)
#   pilot  peak in a ±60 kHz window around the 8VSB pilot
#   data   median level across the flat 8VSB payload
# plus pilot-noise and data-noise in dB. The data-noise figure is the one
# that predicts decodability (8VSB wants ~15 dB); pilot-noise is easier to
# eyeball against SDR++.
#
# Reference (empty) channels come from the RabbitEars survey: RF 7
# (174-180) below KHON, RF 24 (530-536) above KGMB. RF 22 below KGMB is
# KHII (ATSC 3.0) and is NOT quiet, so the UHF noise reference sits above.
#
# Usage:  ./ota-window.sh                # stop SDR++ first: one owner per dongle
#         GAIN=28 INT=20 ./ota-window.sh
#         CSV_DIR=path ./ota-window.sh   # re-parse a previous run, no dongle
#
# Same GAIN at every window. The absolute numbers are uncalibrated; only
# the differences between windows mean anything.

set -uo pipefail

GAIN="${GAIN:-29.7}"
INT="${INT:-10}"                   # seconds of integration per band
CSV_DIR="${CSV_DIR:-}"

command -v rtl_power >/dev/null || { echo "rtl_power missing: sudo apt install rtl-sdr" >&2; exit 1; }

if [ -z "$CSV_DIR" ]; then
  CSV_DIR=$(mktemp -d); echo "csv dir: $CSV_DIR" >&2
  sweep() {  # sweep <band> <range> <csv>
    echo "sweeping $1 ... ${INT}s" >&2
    rtl_power -f "$2" -g "$GAIN" -i "$INT" -1 "$CSV_DIR/$3" 2>"$CSV_DIR/$3.log" || {
      echo "rtl_power failed on $1 (SDR++ still holding the dongle?). Its output:" >&2
      cat "$CSV_DIR/$3.log" >&2; exit 1; }
    [ -s "$CSV_DIR/$3" ] || { echo "rtl_power wrote no data for $1. Its output:" >&2
      cat "$CSV_DIR/$3.log" >&2; exit 1; }
  }
  sweep "VHF-Hi (KHON)" 174M:187M:10k vhf.csv
  sleep 1   # librtlsdr can refuse an immediate reopen after close
  sweep "UHF (KGMB)"    512M:537M:10k uhf.csv
fi

python3 - "$CSV_DIR" "$GAIN" <<'PY'
import csv, math, statistics, sys
d, gain = sys.argv[1], sys.argv[2]

def load(path):
    bins = {}
    try:
        rows = list(csv.reader(open(path)))
    except OSError as e:
        print(f"  !! cannot read {path}: {e}", file=sys.stderr); return bins
    for row in rows:
        if len(row) < 7: continue
        try: lo, hi, step = float(row[2]), float(row[3]), float(row[4])
        except ValueError: continue
        for i, v in enumerate(row[6:]):
            try:
                x = float(v)
                if math.isfinite(x): bins[lo + i*step] = x
            except ValueError: pass
    if not bins: print(f"  !! no usable bins in {path}", file=sys.stderr)
    return bins

def stat(bins, lo, hi, fn):
    vals = [v for f, v in bins.items() if lo <= f < hi]
    return fn(vals) if vals else float('nan')

stations = [
  # name,   csv,       noise ref (MHz),  pilot window,       data span
  ("KHON RF 8  (pilot 180.31)", "vhf.csv", (175.0, 179.8), (180.25, 180.37), (181.0, 185.0)),
  ("KGMB RF 23 (pilot 524.31)", "uhf.csv", (531.0, 535.5), (524.25, 524.37), (525.0, 529.0)),
]
M = 1e6
print(f"gain {gain} dB; levels are rtl_power dB, uncalibrated — compare windows, not absolutes\n")
print(f"{'station':28} {'noise':>7} {'pilot':>7} {'data':>7}   {'pilot-noise':>11} {'data-noise':>10}")
for name, f, n, p, dspan in stations:
    b = load(f"{d}/{f}")
    noise = stat(b, n[0]*M, n[1]*M, statistics.median)
    pilot = stat(b, p[0]*M, p[1]*M, max)
    data  = stat(b, dspan[0]*M, dspan[1]*M, statistics.median)
    print(f"{name:28} {noise:7.1f} {pilot:7.1f} {data:7.1f}   {pilot-noise:11.1f} {data-noise:10.1f}")
print(f"\ncsv kept in {d}")
PY
