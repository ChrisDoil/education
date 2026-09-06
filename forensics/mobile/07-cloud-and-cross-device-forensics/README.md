# Module 07 — Cloud and Cross-Device Forensics

## Learning objectives

- Understand cloud-based acquisition: iCloud (via authenticated access) and
  Google Account/Takeout, and what's recoverable there vs. only on-device.
- Correlate artifacts across multiple devices/accounts belonging to the
  same subject.
- Understand — conceptually, ahead of the licensing/legal work this
  curriculum defers for now (see the top-level legal/ethics note) — that
  cloud/account-level acquisition typically requires a different, higher
  bar of legal authority than device-level acquisition.

## Prerequisites

Module 06.

## Resources

- **Elcomsoft Phone Breaker documentation** — even without owning a
  license, its public docs explain iCloud acquisition mechanics well.
- **Google Takeout documentation.**
- **"Practical Mobile Forensics"** — cloud forensics chapter.

## Hands-on labs

1. Using your own test Apple ID/Google account (never a real client or
   third-party account), pull an iCloud backup and/or Google Takeout export
   for your known-answer test data.
2. Compare what's present in the cloud extraction vs. the on-device
   extractions from Modules 02/03 — identify at least 3 artifacts present
   in one but not the other, and explain why.
3. If you populated both test devices with correlated known-answer activity
   (e.g., the same conversation from both sides), build a cross-device
   timeline merging Android + iOS + cloud sources into one coherent
   narrative.

## Checkpoint

Given artifacts from a device, its cloud account, and a second correlated
device, can you build one merged, correctly-ordered timeline — and point to
specific evidence for why each cross-device link is real, not just
plausible?
