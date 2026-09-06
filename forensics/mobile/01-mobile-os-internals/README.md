# Module 01 — Mobile OS Internals

## Learning objectives

- Explain Android's architecture: partition layout (boot, system, vendor,
  userdata), filesystem (ext4/F2FS), the per-UID app sandbox/permission
  model, APK structure, and the Android Keystore.
- Explain iOS's architecture: the APFS container/volume layout, the app
  sandbox/data-container model, Keychain, Secure Enclave, and Data
  Protection classes.
- Understand the encryption landscape on both platforms (FBE on Android,
  Data Protection on iOS) and how it constrains which acquisition methods
  are even possible before vs. after first unlock.

## Prerequisites

Module 00.

## Resources

- **Android Open Source Project (AOSP) documentation** — filesystem and
  security architecture, straight from the source.
- **Apple Platform Security Guide** (official, free PDF) — the canonical
  reference for iOS security architecture, Secure Enclave, and Data
  Protection classes.
- **"Practical Mobile Forensics"** — OS architecture chapters.
- **Elcomsoft blog** and **Objective-See blog** — practitioner-level iOS
  internals writing that stays current as Apple changes things.

## Hands-on labs

1. On a rooted/test Android device, walk the partition layout via
   `adb shell`; identify the boot, system, vendor, userdata, and data
   partitions.
2. Enumerate an app's sandboxed data directory on Android
   (`/data/data/<package>`) and identify each subdirectory's forensic
   purpose (databases, `shared_prefs`, cache, files).
3. Unpack an APK (`apktool` or `jadx`) and identify the permissions
   declared in `AndroidManifest.xml`.
4. On the iOS side, use `ideviceinfo` to enumerate device info and
   determine Data Protection status (encrypted, passcode set, hardware
   encryption enabled).
5. Diagram — paper or digital — the Before First Unlock (BFU) vs. After
   First Unlock (AFU) state for iOS, and write in your own words why BFU
   acquisitions are so much more limited than AFU ones.

## Checkpoint

Given an unfamiliar Android or iOS device, can you correctly state its
encryption state (FBE, BFU/AFU) and predict — before attempting any
acquisition — what acquisition methods should even be possible?
