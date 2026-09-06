# Module 04 — Orbital Mechanics

## Learning objectives

- Derive and use the two-body problem: why orbits are conic sections, and
  how Kepler's laws fall out of it.
- Read and use classical orbital elements and Two-Line Element (TLE) sets to
  describe and propagate a real satellite's position over time.
- Understand qualitatively why LEO, MEO, and GEO orbits imply very different
  SATCOM link characteristics (this feeds directly into Module 06).

## Prerequisites

Module 01 for the math maturity (differential equations, vector calculus).
No RF background needed — this module is physics/math, independent of the
RF track.

## Resources

- **"Orbital Mechanics for Engineering Students" by Howard Curtis** — modern,
  clearly written, widely used in aerospace engineering courses; a strong
  primary text given a solid math background.
- **"Fundamentals of Astrodynamics" by Bate, Mueller, and White** — the
  classic (originally USAF Academy) text, available cheaply as a Dover
  reprint; more terse than Curtis but excellent as a rigorous second pass.
- **Celestrak** (celestrak.org) — the standard public source of TLE data for
  active satellites, maintained by Dr. T.S. Kelso; also has good
  explanatory articles on TLE format and orbital element definitions.
- **Skyfield documentation** (Python package) — both a tool and a resource;
  its docs explain the practical side of orbit propagation (SGP4, timescales,
  topocentric coordinates) clearly.

## Hands-on labs

1. By hand (or symbolically in Python/sympy), derive the vis-viva equation
   from conservation of energy for the two-body problem, and use it to
   compute orbital velocity at perigee/apogee for a known satellite's
   elements.
2. Pull a real TLE from Celestrak (e.g. the ISS, or a NOAA weather
   satellite) and propagate it with Skyfield to compute its position at a
   given time — cross-check against gpredict's prediction for the same
   satellite/time.
3. Use gpredict to generate a pass prediction for your location for a LEO
   satellite (ISS or a NOAA bird) — note the pass duration, max elevation,
   and Doppler shift range. You'll use this exact pass to do a real receive
   in Module 08.
4. Compute, from first principles, why a GEO orbit sits at ~35,786 km
   altitude — derive it from setting orbital period equal to a sidereal
   day, don't just look up the number.
5. Compare orbital periods and coverage footprints for a LEO satellite
   (e.g. ISS, ~90 min period) vs. a GEO satellite (24 hr period,
   fixed ground footprint) — this comparison is the conceptual bridge into
   Module 06's GEO-vs-LEO SATCOM tradeoffs.

## Checkpoint

You can take a TLE you've never seen before and, using Skyfield or
equivalent, predict when a given satellite will next be visible from your
location and at what elevation — and you can explain in physical terms
(not just "the formula says so") why GEO satellites appear stationary and
LEO satellites don't.
