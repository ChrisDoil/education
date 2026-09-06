# Module 00 — Hardware & Tools

## Learning objectives

- Know what to buy, in what order, and why — matched to which labs each
  purchase unlocks.
- Have a working software toolchain before touching hardware, so the first
  hardware session isn't also a first software-install session.

## Prerequisites

None — this is the starting point.

## Buy list, by tier

Buy incrementally, in order. Don't buy Tier 2/3 gear before you've exhausted
what Tier 0/1 can teach you — you'll make better purchasing decisions once you
know what you actually want to do.

### Tier 0 — $0, software only

Install this first, before any hardware arrives:

- **GNU Radio** — the core SDR signal-processing framework used throughout
  this curriculum (GNU Radio Companion for flowgraph-building, plus the
  Python API).
- **gpredict** — satellite pass prediction and tracking, used from Module 04
  onward.
- **Skyfield** or **PyEphem** (Python packages) — orbit propagation for
  Module 04 labs.
- **gr-satellite** — GNU Radio out-of-tree module with ready-made decoders
  for many amateur/weather satellites, used heavily in Module 08.
- **SDR++** or **SDR#** — general-purpose SDR receiver GUI, good for casual
  listening/spectrum-browsing before you're writing your own flowgraphs.

### Tier 1 — ~$40, first hardware

- **RTL-SDR Blog V3 dongle** (or equivalent RTL2832U-based SDR) — the
  standard entry-level wideband SDR receiver. Covers roughly 500 kHz–1.7 GHz,
  which is enough for FM broadcast, ADS-B, AIS, NOAA APT, and most of
  Module 08's early labs.
- **A decent antenna for the bands you'll actually use** — the stock
  telescopic whip is fine to start; a dipole or discone tuned for
  137 MHz (NOAA weather sats) and 1090 MHz (ADS-B) will noticeably improve
  early labs.

This tier alone carries you through Modules 01, 02, 04 (software-only labs),
05 (software-only labs), and most of 08.

### Tier 2 — ~$150–300, once licensed (Module 03) or ready to experiment with TX

- **HackRF One** (or LimeSDR) — TX-capable SDR, half-duplex, ~1 MHz–6 GHz.
  Needed for any transmit experiments and some GEO satellite work that
  benefits from a wider/more flexible front end than the RTL-SDR.
- **Baofeng UV-5R** (or similar cheap HT) — inexpensive VHF/UHF handheld,
  useful once licensed for basic ham-band TX practice and satellite QSOs.

### Tier 3 — as your interests narrow

- **tinySA** (or tinySA Ultra) — budget handheld spectrum analyzer;
  useful for Module 02/07 hands-on work once you want to *see* spectra
  independent of a full SDR+PC setup.
- **Satellite dish + LNB** (a repurposed Ku-band DirecTV/Dish dish + LNB
  works and is often free/cheap secondhand) — needed for GEO satellite
  reception labs in Module 07/08 (e.g., DVB-S2 signals, Inmarsat STD-C).
- **Better antennas** — a turnstile/QFH antenna for reliable 137 MHz weather
  satellite reception, or a directional Yagi for higher-frequency work.

## Hands-on labs

1. Install the full Tier 0 software stack and confirm each tool launches
   (GNU Radio Companion opens, `gpredict` shows a satellite database,
   `python -c "import skyfield"` succeeds).
2. Once the RTL-SDR arrives: verify it's recognized (`rtl_test` on
   Linux, or the equivalent device check in SDR++), and receive a local FM
   broadcast station as a first "it works" test.

## Checkpoint

You have GNU Radio, gpredict, and an orbit-propagation library installed and
working, and (once hardware arrives) can pull in a live FM broadcast signal
on the RTL-SDR. If all of that works, you're unblocked for Modules 01, 02,
04, and the early part of 08.
