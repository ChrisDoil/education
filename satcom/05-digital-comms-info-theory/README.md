# Module 05 — Digital Communications & Information Theory

## Learning objectives

- Understand Shannon's channel capacity theorem well enough to reason about
  why a given SATCOM link uses the modulation/coding scheme it does.
- Know the common digital modulation schemes (BPSK, QPSK, higher-order QAM)
  at the level of being able to implement a modulator/demodulator, not just
  recognize a constellation diagram.
- Understand forward error correction (FEC) conceptually and implement at
  least one simple code.

## Prerequisites

Module 01 (DSP foundations) is required — this module builds directly on
Fourier/filtering intuition and complex baseband representation.

## Resources

- **"Elements of Information Theory" by Cover and Thomas** — the standard
  rigorous text on information theory (entropy, channel capacity, coding
  theorems); given a strong math background, this is a good primary source
  rather than a simplified alternative.
- **MIT OCW 6.450 / 6.441, Principles of Digital Communication** (free) —
  covers the engineering side (modulation, detection, coding) that pairs
  with Cover & Thomas's more theoretical treatment.
- **"Digital Communications" by John Proakis** — the standard graduate
  reference text; dense, but the right place to look up a specific topic in
  depth (matched filtering, specific modulation performance curves, etc.)
  rather than a cover-to-cover read.
- **pysdr.org** again — has approachable, code-first chapters specifically
  on digital modulation and pulse shaping that make good hands-on companions
  to the more theoretical texts above.

## Hands-on labs

1. Implement Shannon capacity calculations for a few example channels
   (given bandwidth and SNR) and sanity-check against known real-world
   SATCOM figures you'll compute properly in Module 06.
2. Implement a BPSK and a QPSK modulator/demodulator from scratch in Python
   (map bits → symbols → pulse-shaped waveform, and the reverse) — no GNU
   Radio yet, to force the math through your own hands.
3. Rebuild the same modulator/demodulator as a GNU Radio flowgraph, and
   compare — this is a useful bridge from "I understand the math" to
   "I can use the tool this curriculum relies on."
4. Add AWGN (additive white Gaussian noise) to your simulated signal at
   varying SNR and plot bit-error-rate vs. SNR for BPSK vs. QPSK — confirm
   it matches the theoretical curves from the textbook.
5. Implement a simple FEC code (e.g. a (7,4) Hamming code, or a basic
   convolutional code with Viterbi decoding) and show it recovers correctly
   from injected bit errors that an uncoded scheme wouldn't survive.

## Checkpoint

You can explain why a satellite link with limited power (a fixed EIRP) but
plenty of bandwidth might choose a lower-order, more robust modulation
(e.g. QPSK) over a higher-throughput one (e.g. 16-QAM), and you've
implemented at least one full modulate → channel → demodulate → FEC-decode
chain yourself. This directly sets up Module 07 (real modem waveforms like
DVB-S2 are exactly this, at production complexity).
