# Module 06 — App and Messaging Forensics

## Learning objectives

- Go beyond OS-level artifacts into third-party app data: messaging apps
  (WhatsApp, Signal, Telegram), social/media apps, and cloud-sync apps.
- Understand end-to-end encryption's practical effect on device-level
  forensic recoverability — what's still on-device in plaintext vs. what
  genuinely isn't.
- Recover deleted in-app data using the same SQLite carving techniques from
  Module 04, applied to third-party app databases.

## Prerequisites

Modules 04, 05.

## Resources

- Cellebrite/Magnet/Elcomsoft blogs' app-specific forensic breakdowns —
  check current posts, since app data formats change often and this is one
  of the fastest-moving areas of the field.
- **Signal's own security documentation** — useful for understanding, from
  the vendor's side, exactly what device-level forensics can and can't
  defeat.
- **ALEAPP/iLEAPP app-specific parser modules** — a reference for which
  fields matter for each app.

## Hands-on labs

1. Install WhatsApp (or Signal/Telegram) on both test devices, exchange
   messages between them, and locate the resulting message database on
   each platform.
2. Compare what's recoverable from an unencrypted local backup vs. a full
   filesystem extraction for the same app — note specifically whether
   message content is encrypted at rest on-device, independent of
   transport encryption.
3. Delete an in-app conversation and attempt recovery using the SQLite
   carving technique from Module 04.
4. Pick one additional app category (social media, cloud storage, or
   browser) and produce a short artifact map — which files/tables hold
   which forensically relevant data. This is the kind of app-specific
   reference sheet you'll build many more of in real casework.

## Checkpoint

For a messaging app you've never examined before, can you locate its data
directory, identify its message store format, and correctly state — based
on evidence, not marketing claims — whether its "end-to-end encryption"
leaves plaintext recoverable at rest on the device?
