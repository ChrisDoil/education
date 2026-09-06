# Module 04 — Anti-Forensics

## Learning objectives

- Understand the core anti-forensics techniques attackers use to cover
  their tracks: timestomping, Windows Event Log clearing/tampering, and
  artifact/file wiping.
- For each technique, know the secondary artifact that survives it —
  anti-forensics rarely erases everything, and knowing where the gaps are
  is the actual skill.

## Prerequisites

Modules 00–03 (this module leans directly on your MFT and event-log
skills from Module 01 and your timeline/baseline from Module 02).

## Resources

- **MITRE ATT&CK T1070 (Indicator Removal)** and its subtechniques
  (T1070.001 clear event logs, T1070.006 timestomp) — the organizing
  framework for this module.
- Atomic Red Team atomics for T1070 subtechniques.
- Blog posts on `$LogFile`/`$UsnJrnl` forensics by Eric Zimmerman and other
  SANS FOR508 instructors (search "MFT $LogFile $UsnJrnl forensics") — this
  is where deleted/tampered evidence often still lives.
- **"File System Forensic Analysis" (Carrier)** — the anti-forensics /
  file-recovery chapters, as a refresher on NTFS internals from Module 01's
  vantage point.

## Hands-on labs

1. Timestomp a file on the lab VM (Atomic Red Team T1070.006), then detect
   the tampering by comparing `$STANDARD_INFORMATION` vs. `$FILE_NAME`
   timestamps in the MFT (`MFTECmd` reports both) — timestomping tools
   typically only rewrite one of the two.
2. Clear the Security event log (T1070.001 atomic), then prove it happened:
   the clearing action itself generates Event ID 1102, and a genuine gap in
   otherwise-continuous logon/logoff activity is visible against your
   Module 02 baseline.
3. Delete a file that was used in an earlier module's atomic, then recover
   evidence of its prior existence via `$UsnJrnl` (`MFTECmd` supports `$J`
   parsing) and MFT slack space.
4. Write up, for each technique above, exactly what the attacker's action
   deleted or altered and exactly what it *couldn't* touch.

## Checkpoint

Without being told it happened, can you detect timestomping purely from an
`$SI`/`$FN` mismatch, and can you prove an event log was cleared even though
the clearing action is the very thing recorded about it?
