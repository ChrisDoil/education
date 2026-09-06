# Module 03 — iOS Acquisition

## Learning objectives

- Perform iOS logical acquisition via unencrypted and encrypted local
  backups (`idevicebackup2`, iTunes/Finder-compatible format).
- Perform full filesystem extraction on a checkm8-vulnerable test device
  using checkra1n and a forensic extraction agent.
- Understand what's categorically inaccessible on modern, non-jailbreakable
  iOS hardware without a commercial exploit (e.g. GrayKey) — and that this
  is the honest current state of the field, not a tooling gap you can close
  yourself.

## Prerequisites

Modules 00, 01.

## Resources

- **libimobiledevice documentation.**
- **checkra1n documentation** and the **checkm8 vulnerability writeup**
  (axi0mX) — understanding *why* checkm8 works (a BootROM-level,
  unpatchable flaw on affected chips) explains its forensic significance.
- **Elcomsoft blog** — consistently the best open practitioner writing on
  iOS acquisition-tier boundaries.
- **Apple Platform Security Guide** — Data Protection classes matter
  directly here.

## Hands-on labs

1. Take an unencrypted local backup of your iOS test device via
   `idevicebackup2`; parse it with iLEAPP and compare recovered artifacts
   to your known-answer dataset.
2. Take an encrypted local backup (set a backup password) and note what
   additional data becomes available (Keychain items) vs. the unencrypted
   backup — a deliberate, teachable contrast.
3. If your test device is checkm8-vulnerable (A11 or earlier), perform a
   checkra1n-based full filesystem extraction; compare recovered artifact
   completeness (deleted data, full SQLite WAL contents, system-level logs)
   against the backup-based extraction.
4. Write up, in your own words, the BFU vs. AFU distinction from Module 01
   as it specifically applies to what you were and weren't able to do in
   this module's labs.

## Checkpoint

Given an iOS test device of known chip generation and lock state, can you
correctly predict which acquisition tier (backup vs. full filesystem vs.
"not possible without commercial tooling") applies before you start — and
were you right, when you tried?
