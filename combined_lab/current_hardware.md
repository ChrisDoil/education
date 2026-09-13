# Current hardware

As-purchased inventory the build plan in `README.md` is built around.

## Hub — NAS (in service)

TERRAMASTER F2-424 NAS Storage 2Bay - N95 Quad-Core CPU, 8GB DDR5 RAM,
2.5GbE Port x 2, Network Attached Storage with High Performance
(Diskless)

Verified specs (from TerraMaster's F2-424 specification page) — these are
load-bearing for the build plan, so they're recorded here rather than
left to the marketing blurb:

| Item | Spec |
|---|---|
| CPU | Intel N95, 4 cores / 4 threads, 3.4 GHz burst, 15W |
| RAM | 8GB DDR5 non-ECC SODIMM, **1 slot**, max 32GB |
| Drive bays | 2 (3.5"/2.5" SATA) |
| M.2 | 2 × NVMe, PCIe 3.0 ×1 each |
| Network | 2 × 2.5GbE RJ-45 |
| Other I/O | 2 × USB 3.2 (10Gbps), 1 × HDMI 2.0b |

Note the single SODIMM slot: the RAM upgrade is a *replacement* of the
8GB stick, not an addition. The 32GB maximum is TerraMaster's own rating
and exceeds Intel's official 16GB cap for Alder Lake-N.

## Storage

Western Digital 8TB WD Red Plus NAS Internal Hard Drive HDD - 5640 RPM,
SATA 6 Gb/s, CMR, 256 MB Cache, 3.5" - WD80EFPX (2x)

Both bays are consumed by these. No free bay for a SATA SSD — hence the
VM datastore living on the M.2 slots.

## SDR

RTL-SDR Blog V3 R860 RTL2832U 1PPM TCXO HF Bias Tee SMA Software Defined
Radio with Dipole Antenna Kit

## OTA television (ordered 2026-09-13, arriving Thursday)

For `README.md` **Goal 5**. Separate from the SDR above — different
antenna, different demodulator, different band priorities.

Parts settled by the RabbitEars site survey of 2026-09-13 (West Oahu,
13' AGL), which superseded the initial estimates. Two findings drove the
choice: transmitters are at **6.6–11.9 mi**, not 15–25, with **+46 to
+65 dB** margins on every major; and they sit in **two clusters ~152°
apart** (Palehua ~308° true, Honolulu side ~100° true) rather than one
bearing. Full tables under Goal 5.

| Item | Spec / model | Paid | Status |
|---|---|---|---|
| Network tuner | SiliconDust HDHomeRun **Flex Duo**, `HDFX-2US` (2 × ATSC 1.0, Ethernet, single coax in) | $109.99 | **Ordered** |
| Antenna | Channel Master **FLATenna**, non-amplified — flat indoor, passive, omnidirectional, UHF + VHF-Hi, gain 3 dB VHF / 6 dB UHF, 12 ft RG6 included | $35.00 | **Ordered** |
| Attenuator | Holland Electronics **`FAM-10`** — 10 dB fixed, inline F, 75 Ω, passband covers VHF-Hi and UHF | $6.41 | **Ordered** — install only on symptom, per `ota_bringup.md` Phase 3 |
| F-to-SMA adapter set | exgoofit `B07D28P28J`, 6 pcs — 2× **F female → SMA male** (the one needed), 2× F male → SMA, 2× F female → SMA female. SMA, not RP-SMA | ~$8 | **Ordered** — unblocks Phase 5 labs 1 and 4 on arrival |
| 20 dB attenuator pad | The SDR overloads where the tuner does not; 10 dB may not be enough | ~$6 | **Consider** — add to the adapter order |

Total spent: **~$159.**

Connector note for later: the F↔SMA set is the boundary between the 75 Ω
world where affordable RF hardware lives (LNBs, dishes, splitters, the
`FAM` pads) and the 50 Ω world the SDR lives in. The 75/50 mismatch costs
0.18 dB — a resistive minimum-loss match would cost ~5.7 dB, so on receive
the plain adapter is the correct answer, not a compromise. Beware
**RP-SMA**: it threads on perfectly and carries no signal.

No separate coax purchase — the FLATenna ships with 12 ft of RG6, enough
if the chosen window is within that of the office switch.

**Do not buy the amplified variant** (`CM-4001HDBWA`). At 7 miles with
+46–65 dB of margin the signal is already far past adequate; a preamp
only pushes the tuner front end toward overload.

### Why the FLATenna, specifically

Its omnidirectional pattern was initially recorded here as a compromise.
The survey reversed that — it is the **correct** choice:

- **No directional antenna can cover both clusters.** ABC (KITV, RF 20)
  and FOX/CW (KHON, RF 8) are ~152° away from CBS/NBC/PBS. Aiming at
  either cluster sacrifices the other.
- **A rotator is ruled out by the design, not just by cost.** The Flex
  Duo serves the TV and the laptop simultaneously; one client on CBS
  (Cluster A) and another on ABC (Cluster B) cannot share a steered
  antenna. Omnidirectional is structurally required.
- **VHF-Hi is confirmed in use.** KHON on RF 8 and KHET on RF 11 mean a
  UHF-only panel loses FOX/CW and PBS.
- Channel Master publishes real gain figures and is an actual antenna
  manufacturer, unlike the generic listings below.

Remaining weakness, worth knowing before it surprises anyone: the panel
is 12×15", so it is electrically small at VHF-Hi (a half-wave element
there wants 28–33"). **KHON, RF 8** is therefore the one station at risk
— VHF-Hi, in the far cluster, and the lowest margin of any major at
+46.6 dB, rated only "Fair." If exactly one channel misbehaves, it is
this one, and the fix is a small dedicated VHF-Hi antenna combined
through a UVSJ — not a directional, and not an amplifier.

### Considered and rejected — amplified flat panels

E.g. Vansky `VS-TX01` and the many near-identical "50 mile range"
listings. Rejected on two counts, recorded here so the question doesn't
get re-litigated:

- **Not directional, despite how they're marketed.** A flat panel has
  negligible front-to-back rejection. (As it turns out this is moot —
  the two-cluster geometry means directivity would be a *liability* here
  — but the marketing claim is still false.)
- **The amplifier is a liability at this distance.** Vansky's own
  documentation says to detach it inside 20 miles, and the survey puts
  the transmitters at 7. More generally: a preamp raises signal and noise
  together, so it can only recover loss occurring *after* the antenna (a
  long coax run). It cannot recover SNR the antenna never captured, and
  it does nothing for multipath. Same noise-figure reasoning as
  `satcom/02-rf-electronics-fundamentals` and the link budgets in `06`.

They also publish no gain figure or radiation pattern, where Channel
Master publishes both. At equal price, prefer the one with a spec sheet.

**Rule going forward:** with +46–65 dB of margin already in hand, no
antenna purchase should ever be aimed at *more signal*. If something
fails, the cause will be overload, multipath, or VHF-Hi aperture — and
the answers are an attenuator, repositioning, or a UVSJ-combined VHF
antenna respectively. Never an amplifier.

### Acceptance thresholds (Flex Duo web UI, per channel)

| Metric | Target | Meaning |
|---|---|---|
| **Symbol Quality** | **100%** | Anything less is uncorrected errors. This is the deciding number. |
| Signal Quality (SNR) | 100%; ≥80% tolerable | Below ~80% brings 8VSB cliff-effect dropouts |
| Signal Strength | 75–100% | Well above 100% means front-end overload — insert the attenuator |

Check **KHON (RF 8)** first; every other major has enough margin to be
indifferent to orientation. A pattern of *strong* channels failing while
weak ones pass is the overload signature, not a weak-signal one.

## Forge — Dell R720XD (owned, parked — see README "Parked hardware")

TBF Item ID: 98978.
This item has been Tested for Key Functions, Ready for Resale.

Dell PowerEdge R720XD E14S Server 16x2.5 2*INTEL XEON E5-2620 16GB SEE NOTES

Brand: DELL
Manufacturer Part Number: POWEREDGE R720XD
Model: E14S
Item Condition: Used
Product Condition: Minor Cosmetic Damage (scuffs or scratches), See Pictures
Testing: Tested & Working
Accessories: Missing accessories (Software, cables, manual, remote, etc.)
Box Condition: No Original box

Approx Shipping Weight and Dimensions:
Weight (lbs):  45.00
Dimensions:  32.00" x 24.00" x 6.00" inches

Items Included / Notes (If it is not pictured, it is probably not included)

Unit does not contain a hard drive. COA, License, OS (operating system),
and other software not included. You MUST reload the unit to gain
original factory functionality.
RaidCardModel: perc h710
videochip: MATROX G200ER2
mobopn: 0C4Y3R
2* PSUs

Power Requirements: Requires a standard computer power cord, included
Input Voltage: 100-240 volt

Seller: TBF Computing, 1090 Cobb Industrial Drive, Marietta, GA 30066.
