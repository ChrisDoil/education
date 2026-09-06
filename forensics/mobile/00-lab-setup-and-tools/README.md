# Module 00 — Lab Setup and Tools

## Learning objectives

- Have a forensic workstation with the core mobile acquisition/analysis
  toolchain installed and smoke-tested before you need it mid-lab.
- Own a small set of test devices you control end-to-end, populated with a
  synthetic "known-answer" test dataset you document as you create it.
- Understand the tool landscape's tiers — free/open-source (ALEAPP/iLEAPP,
  Autopsy, MVT, libimobiledevice, adb) vs. commercial (Cellebrite UFED/
  Physical Analyzer, Magnet AXIOM, MSAB XRY) — what each can and can't do,
  since commercial tools dominate real casework but open-source tooling
  covers nearly everything needed to learn the underlying techniques.

## Prerequisites

None — this is the starting point for the curriculum. General command-line
comfort is assumed; prior forensics background (e.g. `forensics/`'s Windows
DFIR track) is helpful for the artifact-literacy mindset but not required.

## Tool set, by tier

### Tier 0 — workstation & test devices

- A Linux (Ubuntu works well) or Windows workstation, VM or bare metal —
  most open-source mobile forensic tooling is Linux/Python-first, but
  libimobiledevice and adb both run fine on Windows too.
- **Test devices**: buy 1–2 cheap secondhand Android phones (ideally
  different OEMs/Android versions) and, budget permitting, an older iPhone.
  For iPhone, chip generation matters a lot later (Module 03) — an
  A11-or-earlier device (iPhone 8/X or older) is checkm8-exploitable, which
  unlocks full filesystem extraction labs that a newer device can't do
  without commercial tooling.
- Unlike disk forensics, mobile acquisition rarely uses a hardware write
  blocker — acquiring from a live, running device inherently writes to it to
  some degree. Understanding *that* difference, and documenting what each
  acquisition method touches, is a core mobile-vs-disk-forensics mindset
  shift you'll build through this module and the next.

### Tier 1 — acquisition tools

- **adb** (Android Debug Bridge) + Android Platform Tools
- **libimobiledevice** suite (`idevice_id`, `ideviceinfo`,
  `idevicebackup2`) for iOS
- **checkra1n** (checkm8-based) for iOS full filesystem extraction on
  supported hardware (Module 03)
- **Magnet ACQUIRE** (free) — logical/backup-style acquisition for both
  platforms
- **ALEAPP** and **iLEAPP** (Android/iOS Logs Events And Protobuf Parser) —
  free parsing frameworks; huge value for self-study since their source is
  itself a reference for "which file holds which artifact"

### Tier 2 — analysis tools

- **DB Browser for SQLite**
- A plist tool (`plutil`, or Python's `plistlib`) for iOS property lists
- A hex editor (HxD, ImHex, or similar)
- Python 3 + pandas, for building timelines by hand
- **Mobile Verification Toolkit (MVT)** — Amnesty International's spyware/
  stalkerware indicator tool (used in Module 08, install now)
- **Autopsy**, with its Android module, for case-file organization

Commercial tools (Cellebrite, Magnet AXIOM, MSAB XRY) dominate real casework
and are worth knowing conceptually even without owning a license — their
public documentation and vendor blogs (see Resources) are worth reading.

## Resources

- **NIST CFReDS** (Computer Forensic Reference Data Sets) — the standard,
  legal-to-use source of mobile forensic practice images.
- **"Practical Mobile Forensics"** (Bommisetty, Tamma, Mahalik) — the
  standard text for this whole curriculum; recent editions cover both
  platforms end to end.
- **SANS FOR585** (Smartphone Forensic Analysis In-Depth) course poster —
  free, and a genuinely good syllabus reference even without taking the
  paid course.
- **ALEAPP** / **iLEAPP** GitHub repos and docs.
- **libimobiledevice** project docs.

## Hands-on labs

1. Set up the workstation with the full Tier 1/2 toolchain; smoke-test
   `adb devices` and `ideviceinfo` against a connected test device.
2. Acquire your test device(s), factory reset them, and populate each with
   synthetic test data you create yourself (contacts, texts between two of
   your own numbers, photos with known EXIF/GPS data, browser history,
   installed apps) — write down exactly what you put on the device and
   when. This "known-answer" dataset is what you'll validate every later
   module's findings against.
3. Download a NIST CFReDS mobile image and confirm ALEAPP/iLEAPP parses it
   end to end with no errors.
4. Run a full acquisition-tooling smoke test: an `adb backup`/logical pull
   from the Android device, an `idevicebackup2` backup from the iOS device
   (if applicable), and confirm the output files exist and are readable.

## Checkpoint

From a clean workstation, can you connect a test device, pull a basic
logical extraction with open-source tooling alone, and parse it with
ALEAPP/iLEAPP without errors? And do you have a documented known-answer test
dataset you populated yourself, to grade every later module's analysis
against ground truth?
