# Module 01 — Math & DSP Foundations

## Learning objectives

- Be fluent in the language every later module is written in: signals as
  functions of time, sampling, the Fourier transform (continuous and
  discrete), convolution/filtering, and basic modulation math.
- Be able to look at an IQ capture and reason about what's in it before
  running any decoder.

Given a strong math/physics background, this module should move fast on
notation and slow down only where DSP-specific intuition (aliasing, the
DFT vs. the continuous Fourier transform, complex baseband/IQ
representation) diverges from typical physics/engineering math training.

## Prerequisites

Calculus, linear algebra, basic complex numbers (all assumed already solid).
No RF background needed yet — this module is the RF-agnostic math layer
underneath everything else.

## Resources

- **MIT OCW 6.003, Signals and Systems** (free, MIT OpenCourseWare) — the
  standard rigorous treatment of continuous/discrete signals, LTI systems,
  Fourier and Laplace/Z transforms. Use this as the backbone.
- **"Think DSP" by Allen Downey** (free, available from the author's site
  and O'Reilly) — much lighter than 6.003, but excellent for building
  hands-on Python intuition (spectrograms, filtering, noise) alongside the
  theory.
- **dspguide.com — "The Scientist and Engineer's Guide to Digital Signal
  Processing" by Steven W. Smith** (free online) — a practical, low-formalism
  reference that's especially good for filter design intuition and the DFT.
- **"Software-Defined Radio for Engineers" (Analog Devices Press, free PDF)**
  — bridges pure DSP into SDR-specific concepts (IQ sampling, complex
  baseband, quadrature) that the above resources don't cover; read this
  after the core DSP material to make the RF connection explicit.
- **pysdr.org** — a free online textbook specifically on DSP-for-SDR with
  runnable Python examples; good as a companion/cross-reference to the above.

### Local references

- `references/thinkdsp.pdf` — full text of Allen Downey's *Think DSP*
  (CC BY-NC-SA 4.0, freely redistributable), kept locally for exact
  page/notation lookups.
- `references/thinkdsp.txt` — plain-text extraction of the same book, tagged
  with `===== PAGE N =====` markers, so specific pages/sections can be
  grepped or read directly without any PDF tooling.

## Hands-on labs

1. Generate synthetic signals in Python (sine waves, sums of sines, noise)
   and compute their FFTs — confirm you can predict the spectrum before
   running the code.
2. Deliberately under-sample a signal and observe aliasing in the FFT —
   build real intuition for the Nyquist criterion, not just the theorem
   statement.
3. Implement a simple FIR low-pass filter from scratch (windowed-sinc
   method) and apply it to a noisy synthetic signal; compare against
   `scipy.signal`'s built-in filter design.
4. Take a real IQ capture from the RTL-SDR (Module 00) of an FM broadcast
   station, plot its spectrogram, and identify the carrier and modulation
   sidebands by eye.
5. Implement basic AM and FM demodulation from raw IQ samples in Python
   (no GNU Radio) to force yourself through the complex-baseband math by
   hand once.

## Checkpoint

You can explain, without looking it up: what aliasing is and why it happens;
why SDRs sample in complex IQ pairs instead of real-valued samples; and you
can read a spectrogram of an unfamiliar signal and describe its bandwidth
and rough modulation type. If yes, Modules 02, 04, and 05 will make sense
without backtracking into this one.
