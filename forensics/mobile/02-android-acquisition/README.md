# Module 02 — Android Acquisition

## Learning objectives

- Perform logical acquisition of Android devices (`adb backup`/`pull`,
  content providers).
- Perform filesystem acquisition where root/exploit access is available.
- Understand physical acquisition concepts (chip-off, JTAG/ISP) even
  without hands-on access to that hardware.
- Understand File-Based Encryption's (FBE) effect on what's recoverable at
  each acquisition tier.

## Prerequisites

Modules 00, 01.

## Resources

- **XDA Developers forums** — practical, device-specific root/bootloader-
  unlock knowledge; the primary practitioner resource for Android.
- **"Practical Mobile Forensics"** — Android acquisition chapters.
- **Magnet Forensics blog** — clear explainers of the logical/filesystem/
  physical acquisition-tier vocabulary that's standard across the field.
- **ALEAPP GitHub** — useful as a reference for what input format/structure
  it expects from an acquisition.

## Hands-on labs

1. Perform an adb-based logical acquisition of your Android test device
   (`adb backup`, or content-provider pulls where backup is restricted);
   document exactly what is and isn't captured vs. your known-answer
   dataset.
2. Where the test device supports it, unlock the bootloader and root it
   (Magisk) to perform a filesystem-level pull (`adb pull` of `/data`);
   compare recovered artifact completeness against the logical acquisition.
3. Research (write up — don't attempt without proper hardware) chip-off and
   JTAG/ISP acquisition: what physical acquisition captures that filesystem
   acquisition can't (unallocated space, deleted data before TRIM), and why
   practitioners and courts treat it as a last resort given the device-
   destruction risk.
4. Attempt acquisition against a locked test device (screen lock, no known
   PIN) and document exactly where you hit a wall — that wall is the
   boundary FBE and lock state impose, and understanding it matters as much
   as the successful path.

## Checkpoint

Given an Android test device, can you correctly choose and justify the
least-invasive acquisition method that will actually capture the artifacts
you need, and explain what you'd lose at each less-thorough tier?
