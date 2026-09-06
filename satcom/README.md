# SATCOM Security Learning Curriculum

A self-paced, hands-on path from "strong software/security background, weak
RF" to being able to reason critically about satellite communications systems
and their security — orbital mechanics, digital communications theory,
satellite modems/waveforms, and COMSEC/encryption — using amateur-affordable
gear (SDR dongles, a shortwave/ham radio, a budget spectrum analyzer) instead
of lab-grade equipment.

## Legal/ethics note (read first)

Radio spectrum is regulated. Two rules to keep this curriculum entirely legal
throughout:

1. **Receive-only requires no license anywhere in most jurisdictions**
   (including the US). Every lab in this repo before Module 3 is receive-only.
2. **Transmitting requires a license** (amateur radio license for ham bands;
   other services have their own licensing). Do not transmit until you're
   licensed for the band/service in question. Module 3 covers getting a
   Technician-class amateur license, which is the gate for any TX labs later
   in the curriculum.

Module 10 has a dedicated section on the legal boundary between passive
signal analysis (generally fine) and things that cross into wiretap-law
territory (decoding the *content* of communications not intended for you) —
read it before doing any real-world signal-hunting beyond the labs in this
repo.

## How this repo is organized

Each numbered module is self-contained: `README.md` with **Learning
objectives → Prerequisites → Resources → Hands-on labs → Checkpoint**. Modules
are numbered in a suggested order, but several can run in parallel — see the
sequencing notes below. Add your own notes, code, and captures inside each
module folder as you go; the repo is meant to grow with you.

```
00-hardware-and-tools/       what to buy (and when), software toolchain setup
01-math-dsp-foundations/     signals & systems, Fourier, filtering, sampling
02-rf-electronics-fundamentals/   propagation, antennas, noise, dB math
03-ham-radio-license/        Technician license — unlocks legal TX + AMSAT
04-orbital-mechanics/        two-body problem, Kepler elements, TLEs, passes
05-digital-comms-info-theory/     Shannon, modulation, FEC
06-satellite-systems-link-budgets/ transponders, GEO/MEO/LEO, link budgets
07-satellite-modems-waveforms/    DVB-S/S2, real modem architecture
08-sdr-gnuradio-labs/        accumulating hands-on receive labs
09-comsec-encryption/        TRANSEC/COMSEC concepts, DVB-CSA, TLS/IPsec over SATCOM
10-satcom-security-research/ public vuln research, hardening, legal boundaries
```

## Suggested sequencing

This isn't strictly linear — some tracks run concurrently:

- **Start immediately, in parallel:** `01-math-dsp-foundations`,
  `02-rf-electronics-fundamentals`, and `03-ham-radio-license`. None of these
  need hardware beyond Tier 0/1 (see `00-hardware-and-tools`), and licensing
  study is mostly memorization you can chip away at alongside the harder
  conceptual work.
- **Once you own an RTL-SDR (Tier 1, ~$40):** start `08-sdr-gnuradio-labs`
  in parallel — the early labs there (FM broadcast, ADS-B, AIS) don't need
  DSP mastery, just working gear, and build intuition that makes Module 01
  land better.
- **After 01 + 02 are solid:** move into `04-orbital-mechanics` and
  `05-digital-comms-info-theory` — both lean on the math from Module 01.
- **After 04 + 05:** `06-satellite-systems-link-budgets` and
  `07-satellite-modems-waveforms` — these combine orbital mechanics and
  digital comms into how real satellite links are engineered.
- **After 07:** `09-comsec-encryption` — encryption in SATCOM only makes
  sense once you understand the modem/waveform layer it sits on top of.
- **Last, but read the legal section early:** `10-satcom-security-research`
  ties everything together via public research and current hardening
  practice. Its legal/ethics section is worth reading as soon as you start
  any real-world signal hunting, not just at the end.
- **Once licensed (Module 03) and owning a TX-capable SDR (Tier 2):**
  TX-based labs in `08-sdr-gnuradio-labs` and AMSAT/SatNOGS work become
  available.

## Checkpoint philosophy

Each module's Checkpoint section is a self-test, not a gate enforced by
anything — the point is to be honest with yourself about whether you can
*do* the thing (derive it, compute it, decode it) before moving on, not just
recognize the vocabulary.
