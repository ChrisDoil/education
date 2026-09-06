# Module 05 — iOS Artifact Analysis

## Learning objectives

- Parse and interpret core iOS artifacts: Messages, Photos (with metadata/
  geolocation), Safari history, Health data, and Keychain-decrypted
  credentials.
- Understand plist (binary and XML) parsing.
- Build a timeline from iOS artifacts alone.

## Prerequisites

Module 03.

## Resources

- **iLEAPP GitHub** — module source as a reference, same rationale as
  ALEAPP in Module 04.
- **Apple's plist format documentation**; Python's `plistlib` docs.
- **"Practical Mobile Forensics"** — iOS artifact chapters.
- **Elcomsoft blog** — Keychain decryption writeups.

## Hands-on labs

1. Run iLEAPP against your Module 03 backup/filesystem extraction; manually
   verify at least 5 recovered artifacts against your known-answer dataset.
2. Manually parse a binary plist (`plutil` or Python `plistlib`) without
   tool assistance and locate a specific known-answer data point in it.
3. Extract and review Keychain contents from your encrypted-backup
   extraction (Module 03, lab 2); identify what categories of credentials
   are recoverable.
4. Build a timeline combining Messages, Photos EXIF/geolocation, and Safari
   history for your known-answer dataset's activity window; cross-check
   specific timestamps against the equivalent Android timeline from
   Module 04 if you populated both test devices with correlated activity.

## Checkpoint

Given a raw iOS extraction with no prior tool run against it, can you
manually locate and correctly interpret Messages, Photos metadata, and
Keychain contents — and explain what a binary plist actually contains
without a parser telling you?
