# Module 02 — Timeline & Artifact Analysis

## Learning objectives

- Build a full super-timeline of the lab VM from multiple artifact sources.
- Establish a documented baseline of "normal" activity — boot sequence,
  logon, typical process tree — so later modules' injected TTPs are
  detectable by contrast rather than guesswork.

## Prerequisites

Module 01 (core artifact literacy).

## Resources

- **Plaso / `log2timeline`** documentation — the standard open-source
  super-timelining engine.
- **KAPE + Timeline Explorer** (Eric Zimmerman) — target/module-based
  collection feeding directly into a sortable/filterable timeline view.
- **SANS "Timeline Analysis" poster** (free PDF).
- SANS DFIR blog posts on timeline analysis methodology (search
  "sans dfir timeline analysis") — practical pivoting/filtering technique,
  not just tool usage.

## Hands-on labs

1. Run a KAPE target + module collection against the lab VM, producing a
   Timeline Explorer-ready CSV.
2. Separately, run Plaso (`log2timeline.py` → `psort.py`) against the same
   image and compare coverage/format against the KAPE-based timeline.
3. From a clean golden-snapshot boot, walk through and document the
   **baseline**: boot sequence, service startup order, logon sequence, and
   the process tree of a normal idle desktop. Save this as
   `baseline-normal-activity.md` in this module folder — you'll diff against
   it starting in Module 03.
4. Practice filtering and time-window pivoting in Timeline Explorer: given a
   specific timestamp, find everything that happened in the surrounding
   ±5 minutes across all artifact sources at once.

## Checkpoint

You can produce a timeline covering a recent window of lab VM activity and
correctly narrate the boot/logon/normal-process sequence purely from
artifacts, without having watched it happen live. If yes, you have the
baseline every subsequent module's "what changed" analysis depends on.
