# Module 02 — RF & Electronics Fundamentals

## Learning objectives

- Reason quantitatively about a radio link: propagation loss, antenna gain,
  noise floor, and the decibel arithmetic that ties them together.
- Understand antennas well enough to pick/build the right one for a given
  frequency and application, not just plug in whatever came in the box.
- Read a basic RF block diagram (LNA, mixer, filter, ADC) and know what each
  stage is for.

## Prerequisites

Module 01 (DSP foundations) — you need complex-baseband/IQ intuition before
RF front-end concepts (mixing, downconversion) make sense. Basic circuits
(Ohm's law, impedance) is assumed background.

## Resources

- **The ARRL Handbook for Radio Communications** — the standard reference for
  practical RF engineering at the amateur/professional-adjacent level;
  covers propagation, antennas, transmission lines, and receiver/transmitter
  architecture. Dense — use as a reference, not a cover-to-cover read.
- **The ARRL Antenna Book** — deep dive on antenna theory and practical
  designs; you don't need to read it all, but the early chapters on gain,
  polarization, and impedance matching are foundational.
- **rtl-sdr.com blog and its "Getting Started" guides** — practical,
  amateur-friendly explanations of noise figure, gain, and antenna choice
  specifically in the context of cheap SDR receivers, which is exactly the
  hardware you're using.
- **pysdr.org** (carried over from Module 01) has a strong chapter on RF
  front-ends and receiver architecture that connects the DSP math to the
  physical hardware.

## Hands-on labs

1. Compute link budgets by hand for a few toy scenarios (a WiFi AP at 20 m,
   an FM broadcast tower at 10 km) using free-space path loss — get
   comfortable with the dB arithmetic before Module 06 makes it load-bearing.
2. Compare received signal strength on the RTL-SDR using the stock whip
   antenna vs. a simple homemade dipole cut for a known frequency (e.g.
   FM broadcast band) — confirm the antenna theory predicts what you
   measure.
3. Look at the noise floor on a wideband SDR waterfall display with nothing
   connected, then with an antenna connected — identify where thermal noise
   ends and real signals begin.
4. If you have a tinySA or similar (Tier 3 hardware): sweep a known signal
   source (e.g. a cheap RF signal generator or even a nearby WiFi AP) and
   compare the spectrum analyzer's reading against what the SDR waterfall
   shows for the same signal.

## Checkpoint

You can compute a rough free-space path loss and link margin for a simple
scenario without looking up the formula, explain why antenna polarization
mismatch costs you signal, and you understand why an LNA needs to be as
close to the antenna as possible (noise figure cascading). If yes, Module 06
(link budgets) will be mostly about applying this, not learning it fresh.
