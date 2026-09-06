# Module 01 — Windows Forensic Fundamentals

## Learning objectives

- Know the Windows-specific internals every later module assumes: the
  process/thread model, registry hive structure, NTFS and the MFT, and
  Windows Event Log architecture.
- Be fluent in the core artifact set investigators reach for first:
  Prefetch, Amcache, Shimcache/AppCompatCache, LNK files, Jump Lists, and
  ShellBags.

Given a strong general security background, this module should move fast on
concepts you already know (processes, file systems in general) and slow down
specifically on the Windows-particular artifact formats and where each one
lives on disk/in the registry — that's the part a general background doesn't
already cover.

## Prerequisites

Module 00 (working lab + toolchain). General OS/security fundamentals are
assumed solid; no prior Windows-forensics exposure is assumed.

## Resources

- **"File System Forensic Analysis" by Brian Carrier** — the canonical
  NTFS/MFT deep dive; read the NTFS chapters specifically.
- **"Windows Internals" by Russinovich, Solomon, and Ionescu** — reference
  (not cover-to-cover) for the process/thread model and registry
  architecture chapters.
- **SANS "Windows Forensic Analysis" poster** (free PDF) — a dense
  single-page map of where every major artifact lives; keep it open while
  you work through the labs.
- **13Cubed** (YouTube, free) — excellent, artifact-by-artifact Windows
  forensics walkthroughs; good companion to the reading above.
- Eric Zimmerman's tool documentation for each parser used below.

## Hands-on labs

1. Acquire a forensic image of the lab VM with FTK Imager (live or offline
   acquisition — try both).
2. Parse the MFT with `MFTECmd` and correlate a handful of files you know
   you created/modified against their MFT records.
3. Open the `SYSTEM`, `SOFTWARE`, and a user's `NTUSER.DAT` hives in
   Registry Explorer; identify the keys most relevant to persistence and
   execution evidence (you'll use these directly in Module 03).
4. Run an executable on the lab VM, then find evidence of that execution in
   **three independent artifacts**: Prefetch (`PECmd`), Amcache
   (`AmcacheParser`), and Shimcache (`AppCompatCacheParser`). Note where each
   one agrees and where their timestamps/semantics differ.
5. Review Windows Event Log architecture (channels, providers, EVTX format)
   in Event Viewer; note the key Event IDs you'll reuse throughout this
   curriculum (4624/4625 logon, 4688 process creation, 7045 service install).

## Checkpoint

Given an unknown executable's name, you can locate at least three
independent artifacts proving it ran and roughly when, and you can explain
what each artifact type actually records (and doesn't) without looking it
up. If yes, Modules 02–04 will make sense without backtracking into this one.
