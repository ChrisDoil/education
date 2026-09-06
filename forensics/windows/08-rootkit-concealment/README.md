# Module 08 — Rootkit Concealment

## Learning objectives

- Understand Direct Kernel Object Manipulation (DKOM) and driver-based
  hooking conceptually: how kernel-level tooling hides processes, files,
  and network connections from userland (and even some kernel) queries.
- Know what EDR evasion looks like at a conceptual level.
- Understand what forensic artifacts survive despite kernel-level
  concealment — the point of this module is knowing where to look, not
  building a rootkit.

This module is intentionally **detection-focused, not build-focused** —
loading unsigned kernel drivers hits Windows driver-signing enforcement
immediately and adds real risk/complexity for little learning payoff versus
the case-study and diffing approach below.

## Prerequisites

Module 06 (comfort reading kernel-object output from Volatility3 is
required before you can recognize what's *missing* from it).

## Resources

- **"Rootkits and Bootkits" (Matrosov, Rodionov, Bratus)** — the standard
  reference for this entire module.
- **"Windows Internals" (Russinovich, Solomon, Ionescu)** — the kernel
  object manager and driver-model chapters, as background.
- Public analysis write-ups of real, documented rootkits (e.g., Necurs,
  Drovorub, ZeroAccess — search vendor threat-intel blogs) as case studies.
- Volatility3's kernel-object-related plugins (module/driver enumeration
  plugins) for exploring what legitimate driver enumeration looks like.

## Hands-on labs

1. Case-study exercise: read one public rootkit analysis write-up in full,
   extract its IOCs and behavioral indicators, and map each one to a
   specific MITRE ATT&CK Defense Evasion technique.
2. On the lab VM, enumerate loaded drivers and compare the list against your
   Module 00 golden-snapshot baseline — practice the driver-diffing
   methodology you'd use to spot an unexpected addition.
3. Run Volatility3's kernel-object plugins against the Module 06 memory
   image to see what a normal, fully-legitimate driver/module enumeration
   looks like — this is the baseline you'd need to notice an anomaly against.

## Checkpoint

For the specific documented rootkit you studied, can you explain exactly
which forensic artifact eventually exposed it, despite its kernel-level
concealment from live queries?
