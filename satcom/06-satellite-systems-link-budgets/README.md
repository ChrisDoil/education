# Module 06 — Satellite Systems & Link Budgets

## Learning objectives

- Understand how a satellite communications system is actually engineered
  end to end: transponders, footprints, uplink/downlink asymmetry.
- Compute a real link budget (EIRP, path loss, G/T, C/N) and use it to
  explain why a given system's design choices (orbit, frequency band,
  modulation) make sense.
- Understand the tradeoffs between GEO, MEO, and LEO constellations for
  SATCOM specifically (as opposed to the purely orbital-mechanics framing
  from Module 04).

## Prerequisites

Module 02 (RF fundamentals, dB math), Module 04 (orbital mechanics), and
Module 05 (modulation/capacity) all feed directly into this module — it's
where those three tracks combine into "how a real satellite link works."

## Resources

- **"Satellite Communications Systems Engineering" by Pratt, Bostian, and
  Allnutt** — the standard textbook specifically on SATCOM system
  engineering; covers link budgets, transponders, and system tradeoffs in
  depth.
- **"Satellite Communications" by Timothy Pratt and Charles Bostian**
  (an earlier/related text) — a somewhat gentler alternative or companion
  if the systems-engineering text above is too dense on a first pass.
- **Public GEO transponder specifications** — commercial satellite operators
  (e.g. SES, Intelsat, Eutelsat) publish transponder specs (EIRP contours,
  footprint maps, frequency plans) for their fleets; searching for a
  specific satellite's "coverage map" or "transponder specifications" turns
  up real numbers to plug into your link budget calculations.
- **Celestrak** (carried over from Module 04) also documents frequency
  allocations and satellite categories useful for this module.

## Hands-on labs

1. Compute a full link budget for a real GEO transponder (using published
   EIRP and footprint data) to a ground terminal of a given antenna size —
   work through uplink and downlink separately, then combine into overall
   C/N.
2. Compare that link budget to a hypothetical LEO satellite link at the
   same frequency — hold data rate constant and see how dramatically the
   required ground antenna size or transmit power changes with orbital
   altitude. This should make the LEO-mega-constellation trend (Starlink
   and similar) intuitive from first principles rather than just "because
   it's the new thing."
3. Take the BER-vs-SNR curves you generated in Module 05 and use them
   together with your Module 06 link budget to predict whether a given
   link would work reliably at its designed data rate — then see if that
   matches the real system's published performance.
4. Map out, for a satellite of your choosing, its full transponder plan
   (how many transponders, what bandwidth each, what services ride on
   which transponder) from public documentation — this builds the mental
   model needed for Module 07's DVB-S2 material.

## Checkpoint

Given a satellite's orbit, transmit power, antenna gain, and frequency, you
can compute a link budget and state whether a given ground terminal and
modulation scheme will close the link — and you can explain, quantitatively
(not just "LEO is closer"), why LEO constellations can use much smaller
ground terminals than GEO systems for the same data rate.
