# Module 09 — Capstone: Blind Multi-Stage Investigation

## Learning objectives

- Run a full, blind DFIR investigation against a multi-stage Caldera
  adversary emulation spanning several ATT&CK tactics, including Defense
  Evasion.
- Produce a short incident report to the standard you'd want from a real
  investigation: timeline, techniques identified (mapped to ATT&CK IDs),
  and recommended detections/mitigations.

This is the integrative checkpoint for the entire curriculum — every tool
and mental model from Modules 00–08 should get used here.

## Prerequisites

Modules 00–08, all complete.

## Resources

- **MITRE Caldera documentation** — adversary-profile authoring guide, for
  building (or selecting) the multi-stage operation you'll investigate.
- **MITRE ATT&CK Navigator** — useful for laying out the techniques you
  identify against the full matrix in your report.
- A public SANS incident-report template (search "SANS incident report
  template") as a structural starting point.

## Hands-on labs

1. Build or select a multi-stage Caldera adversary profile that spans
   initial execution, persistence, one or more Defense Evasion techniques,
   and an injection/memory-resident component — deliberately covering
   ground from Modules 03–07.
2. Run it against a fresh golden-snapshot lab VM **without reading the
   operation's technique list beforehand** — this needs to be blind to be a
   real test. (If working solo, write the profile weeks ahead and let
   yourself forget the details, or have someone else trigger it.)
3. Investigate using only the tools and skills from Modules 00–08: identify
   initial execution, persistence mechanisms, evasion/anti-forensics
   actions, and any injection or memory-resident components.
4. Write a short incident report: a timeline of what happened, each
   technique identified and mapped to its ATT&CK ID, and recommended
   detections/mitigations for each.
5. Compare your report against Caldera's actual operation log and score
   yourself — note anything you missed and why (which artifact would have
   caught it, and which module covers that artifact).

## Checkpoint

Does your independently-written incident report correctly identify at
least 80% of the techniques Caldera actually ran, including every Defense
Evasion technique in the chain?
