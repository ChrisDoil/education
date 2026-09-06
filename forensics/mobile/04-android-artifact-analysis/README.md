# Module 04 — Android Artifact Analysis

## Learning objectives

- Parse and interpret core Android artifacts: SQLite databases (contacts,
  SMS/MMS, call logs), `shared_prefs` XML, and app-specific data stores.
- Build a timeline from Android artifacts alone.
- Recover deleted SQLite records via WAL/journal carving and freelist
  analysis.

## Prerequisites

Module 02.

## Resources

- **ALEAPP GitHub** — its module source is itself a great reference for
  "which file holds which artifact."
- **"SQLite Forensics"** (Paul Sanderson / Sanderson Forensics materials) —
  the canonical reference on WAL/journal/freelist-based deleted-record
  recovery.
- **DB Browser for SQLite documentation.**

## Hands-on labs

1. Run ALEAPP against your Module 02 filesystem acquisition; manually
   verify at least 5 recovered artifacts against your known-answer dataset.
2. Open the SMS/MMS and contacts databases directly with DB Browser for
   SQLite — no tool assistance — and locate the same records ALEAPP found.
   Build the muscle memory of doing it by hand before trusting the
   automated parser.
3. Delete a text message and a contact from the test device, re-acquire,
   and attempt to recover the deleted record from the SQLite WAL file or
   freelist pages — document whether you succeeded and why or why not.
4. Build a simple timeline (spreadsheet or script) combining timestamps
   from at least 3 different artifact sources (SMS, call log, and one
   app's database) for your known-answer dataset's activity window.

## Checkpoint

Given a raw Android filesystem acquisition with no prior tool run against
it, can you manually locate and correctly interpret the SMS, call log, and
contacts databases — and recover at least one deliberately deleted record?
