# Mobile Device Forensics Curriculum

A self-paced, hands-on path into mobile device forensics — Android and iOS
acquisition, artifact analysis, app-level and cloud forensics, and mobile
malware/stalkerware detection — building the technical foundation for
professional-quality forensic casework on smartphones.

## Legal/ethics note (read first)

Mobile devices and accounts are far more likely than a lab VM to hold real
private information, even in a learning context. Four rules keep this
curriculum entirely safe and legal:

1. **Only examine devices and accounts you own outright and control
   end-to-end.** Every device in this curriculum should be one you bought
   (ideally secondhand, factory reset) and populated yourself with synthetic
   "known-answer" test data — never a device or account belonging to someone
   else, and never one still logged into anyone else's real accounts.
2. **Never practice on downloaded "real-world" data of unknown provenance.**
   Use vetted, purpose-built forensic training corpora only (NIST CFReDS,
   DFRWS challenge images, vendor training images). Random images/backups
   found online can carry real personal data or worse — CSAM is a known risk
   in unvetted "recovered" mobile data dumps — and you do not want that
   anywhere near your own hardware.
3. **Full-filesystem/jailbreak-based extraction is inherently more invasive
   than logical acquisition.** Understand and document what you're altering
   on a device before you do it, exactly as defensible real casework would
   require.
4. **This curriculum is scoped to technical skill-building only.** Actually
   offering mobile forensics services to investigators or clients requires
   jurisdiction-specific licensing (many US states require a private
   investigator license to offer forensic services commercially),
   evidence-handling standards, chain-of-custody procedures, and probably
   liability insurance and legal counsel — none of that is covered here yet.
   Treat this curriculum as the technical foundation that work would sit on
   top of, not a substitute for it.

## How this repo is organized

Each numbered module is self-contained: `README.md` with **Learning
objectives → Prerequisites → Resources → Hands-on labs → Checkpoint**.
Modules are numbered in a suggested order, but several can run in parallel —
see the sequencing notes below. Add your own notes, extractions, and
timelines inside each module folder as you go; the repo is meant to grow
with you.

```
00-lab-setup-and-tools/          forensic workstation, test devices, acquisition/analysis toolchain
01-mobile-os-internals/          Android + iOS filesystem, sandbox, and encryption architecture
02-android-acquisition/          logical/filesystem/physical acquisition, FBE boundaries
03-ios-acquisition/              backup + full filesystem extraction, BFU/AFU boundaries
04-android-artifact-analysis/    SQLite/shared_prefs parsing, deleted-record recovery, timelines
05-ios-artifact-analysis/        plist/SQLite/Keychain parsing, timelines
06-app-and-messaging-forensics/  WhatsApp/Signal/Telegram and other third-party app artifacts
07-cloud-and-cross-device-forensics/  iCloud/Google account acquisition, multi-device correlation
08-mobile-malware-and-stalkerware-forensics/  MVT, spyware/stalkerware indicators
09-capstone/                     full multi-device simulated investigation + findings report
```

## Suggested sequencing

- **00 → 01, in order.** Tooling and OS/encryption fundamentals everything
  else assumes.
- **02 and 03 can run in parallel** (or in whichever order you acquire test
  devices) — there's no dependency between the Android and iOS acquisition
  tracks.
- **04 depends on 02; 05 depends on 03.** Do a platform's artifact-analysis
  module only after you've acquired on that platform.
- **06 needs both 04 and 05**, since it deliberately spans both platforms.
- **07 after 06.** Cloud/cross-device correlation builds on app-level
  fluency.
- **08 can run any time after 04/05**, in parallel with 06/07 if you like —
  it only needs artifact-analysis skill, not the app/cloud modules.
- **09 last, always.** The capstone assumes every prior module's tools and
  mental models.

## Checkpoint philosophy

Each module's Checkpoint section is a self-test, not a gate enforced by
anything — the point is to be honest with yourself about whether you can
*find and prove* the thing (in a device extraction, a timeline, a
cross-device correlation) before moving on, not just recognize the
vocabulary.
