# Module 08 — SDR & GNU Radio Hands-on Labs

## Learning objectives

This module is different from the others: it's not a single conceptual
topic, but an accumulating set of practical receive (and eventually
transmit) exercises that run *alongside* the rest of the curriculum,
roughly ordered from easiest to hardest. Its purpose is to keep hands-on
skill with GNU Radio and real signals developing continuously rather than
saving all practice for the end.

## Prerequisites

Module 00 (RTL-SDR hardware + software toolchain). Individual labs below
note which other module's concepts they draw on.

## Resources

- **GNU Radio's own tutorials** (in the GNU Radio wiki/docs) — start here
  for learning GNU Radio Companion itself: blocks, flowgraphs, sample
  rates, throttle blocks.
- **rtl-sdr.com** — a large, continuously updated library of practical
  guides for exactly this hardware, including several of the specific labs
  below (NOAA APT, ADS-B, AIS reception guides).
- **gr-satellite** (installed in Module 00) — pre-built GNU Radio decoders
  for many amateur/weather/cubesat satellites; use this once you've tried
  building a decoder yourself at least once, so you understand what it's
  doing for you.
- **SatNOGS** (satnogs.org) — open-source global network of satellite
  ground stations; browsing their observation database is a good way to
  see what real decoded satellite data looks like before you produce your
  own.
- **SigMF (Signal Metadata Format)** — an open standard for recording IQ
  captures alongside their metadata (sample rate, frequency, annotations);
  a good habit to adopt once you start producing your own characterization
  write-ups in the lab below, so captures stay self-describing.
- **gr-inspector** (GNU Radio out-of-tree module, KIT) — an existing
  cyclostationary signal analysis tool; worth studying *after* you've built
  your own symbol-rate estimator by hand (lab 7 below), same philosophy as
  `gr-satellite` elsewhere in this module.
- **pysdr.org's chapter on RF machine learning / modulation classification**
  — covers both classical feature-based automatic modulation classification
  (AMC) and modern deep-learning approaches (e.g. the RadioML dataset); read
  the classical section before lab 7c.

## Labs, roughly in order

1. **FM broadcast reception** (needs: nothing but Module 00 hardware) —
   first "it works" test, tune to a local FM station in SDR++ or GNU Radio
   Companion.
2. **ADS-B aircraft tracking** (1090 MHz) — a great early digital-decode
   lab: strong signals, simple framing, immediate visual payoff (plot
   aircraft positions on a map). Good stepping stone before tackling
   satellite signals, which tend to be weaker and harder to acquire.
3. **AIS ship tracking** (161.975/162.025 MHz) — similar in spirit to
   ADS-B, another accessible real-world digital decode.
4. **NOAA APT weather satellite reception** (137 MHz, analog FM) — your
   first actual satellite decode. Use the pass prediction from your
   Module 04 lab; requires decent antenna and timing but no complex
   digital sync — a good bridge from terrestrial to satellite work.
5. **Meteor-M2 LRPT reception** (137 MHz, digital) — same general setup as
   APT but digital, more like a "real" satellite digital decode in
   miniature; harder than APT, easier than DVB-S2.
6. **ISS reception** (145.8 MHz downlink, sometimes SSTV image
   transmissions during special events) — combine with your Module 04 ISS
   pass prediction lab.
7. **Blind signal characterization** (needs: Module 05 concepts —
   symbol rate, C/N, Eb/No, modulation) — given an IQ capture, extract its
   statistics without prior knowledge of what generated it. This is the
   SIGINT-style "collection site" skill set, and it's a natural checkpoint
   on everything digital-comms-theoretic from Module 05:
   1. **Symbol rate estimation.** First read it off the spectrum (occupied
      bandwidth ≈ Rs·(1+α), from the PSD shoulders). Then implement the
      more robust blind estimator: square (or delay-and-multiply) the
      signal and take its FFT — symbol timing produces a spectral line at
      Rs even when the signal is too noisy to demodulate. Validate both
      methods against a GNU Radio-generated QPSK signal of known Rs before
      trusting them on a real capture.
   2. **C/N and Eb/No estimation.** Measure C/N from the PSD (in-band power
      vs. adjacent noise floor). Chain that into Es/No using your Rs
      estimate and the noise bandwidth, then into Eb/No once you have a
      modulation-order estimate from step 3. Do this first on a synthetic
      signal where *you* added the noise (so you know true Eb/No) and
      quantify how much error compounds through the chain before trying it
      blind.
   3. **Blind modulation classification.** Build a simple classifier from
      instantaneous amplitude/phase statistics: constant-envelope signals
      (PSK family) separate cleanly from varying-envelope ones (QAM/APSK)
      on amplitude histogram alone; higher-order moments/kurtosis push the
      separation further (BPSK vs. QPSK vs. 8PSK, etc.). Test it against
      synthetic BPSK/QPSK/8PSK/16QAM at a range of SNRs to find where your
      classifier breaks down.
   4. **Put it together blind.** Take a capture from an earlier lab (e.g.
      ADS-B or Meteor-M2) you haven't looked at in a while, and write up a
      full characterization — Rs, C/N, Eb/No, modulation type — using only
      steps 1–3. Then check it against the known ground truth for that
      signal.
8. **DVB-S2 reception** (needs: Tier 3 dish/LNB hardware, Module 07
   concepts) — the capstone receive lab; see Module 07 for details.
9. **TX-based labs** (needs: Module 03 license + Tier 2 TX-capable SDR) —
   once licensed, experiment with transmitting a simple signal (e.g. a
   basic APRS beacon) on amateur bands, and/or attempt an AMSAT satellite
   contact through a FM "easy sat" repeater — a well-documented rite of
   passage in the amateur satellite community.

## Checkpoint

For each lab: can you build the receive chain yourself (even if starting
from a reference flowgraph) and explain what each block is doing, rather
than just running someone else's script and getting output? Keep your own
flowgraphs and captured data in this module's folder as you go — they're
useful references later, and useful evidence of what you actually built
when it's time to look at Module 10's security research with informed
eyes.

For lab 7 specifically: given an IQ capture you haven't seen before, can
you produce a full characterization (symbol rate, C/N, Eb/No estimate,
modulation classification) without being told what generated it — and can
you explain which of those estimates compounds error from the others (Eb/No
is downstream of both the symbol-rate and modulation-order estimates, so
its error bars are the widest of the four)?
