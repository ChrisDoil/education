# OTA TV bring-up procedure

Step-by-step for the hardware ordered 2026-09-13, arriving Thursday.
Design rationale lives in `README.md` **Goal 5**; the parts table and the
reasoning behind each choice live in `current_hardware.md`. This file is
just the procedure, and the place to paste results as they come in.

## What was ordered

| Part | Model | Paid |
|---|---|---|
| Network tuner | SiliconDust HDHomeRun Flex Duo `HDFX-2US` | $109.99 |
| Antenna | Channel Master FLATenna (non-amplified, 12' RG6 included) | $35.00 |
| Attenuator | Holland Electronics `FAM-10`, 10 dB fixed, inline F, 75 Ω | $6.41 |
| | | **$151.40** |

Also ordered: an **exgoofit F↔SMA adapter set** (`B07D28P28J`, ~$8, 6 pcs)
containing the F-female → SMA-male part needed to put the TV antenna on the
RTL-SDR. Nothing for television depends on it, and it arrives separately —
**Phase 5** labs 2 and 3 run on the kit dipole regardless, and labs 1 and 4
unblock when it lands. See Phase 5.

## Prerequisites

- The RabbitEars survey for this location: https://www.rabbitears.info/s/2984749
- A free port on the office switch, and the router's DHCP table
- `hdhomerun-config` on the WSL box: `sudo apt install hdhomerun-config`
- The HDHomeRun app installed on the Samsung TV (Tizen store) and laptop

> **WSL2 networking caveat.** WSL2 sits behind NAT on a virtual NIC, so
> UDP *broadcast* discovery does not reach the LAN — `hdhomerun_config
> discover` will likely find nothing. Outbound unicast to a LAN IP works
> fine, so the fix is simply to **use the tuner's IP address directly**
> everywhere below rather than relying on discovery. (Alternatively set
> `networkingMode=mirrored` in `.wslconfig`, but that is a bigger change
> than this needs.)

---

## Phase 0 — before the boxes arrive

Two parts: work out the orientation on paper, then **verify it by
measurement** — the RTL-SDR and its kit dipole are already in hand, so
this does not have to wait for Thursday.

**Deriving the panel orientation.** A flat panel's lobes are broadside to
the sheet, **front and back**, which is what makes it usable here at all.
So you don't point it at a cluster — you set its axis to straddle both:

```
Cluster A (Palehua)      299° magnetic
Cluster B (Honolulu)      91° magnetic
  reflect B through 180°:  91 + 180 = 271°
  bisect 299 and 271:     → 285° magnetic   (≈294° true)
```

So: **face normal ~285° magnetic.** A phone compass reads magnetic by
default, so use 285° directly — don't apply the ~9.3° declination twice.

Shortlist windows that can face that way, and prefer ones with:
- glass rather than drywall in the path
- nothing metallic behind the panel — foil-backed insulation, metal
  blinds, a monitor, a fridge
- ≤12 ft of cable run to the switch (that is all the coax you have)

### Survey the candidate windows *now*, with the SDR

The kit dipole plus the RTL-SDR is a perfectly good field-strength meter
for this band, and using it before the FLATenna arrives means Thursday
starts from a known-good window instead of a guess. Mount nothing; just
hold the dipole at each candidate window and compare.

Dipole setup for TV — three details that matter:

- **Horizontal, not vertical.** ATSC is horizontally polarized. A vertical
  dipole costs you 10–20 dB for no reason, and vertical is the default
  intuition.
- **Elements broadside to the signal**, i.e. the whips run perpendicular to
  the direction the station is in — a dipole's nulls are off its ends.
- **Element length** — each leg is a quarter wave:

  | Target | λ/4 per leg | Use |
  |---|---|---|
  | RF 8 / 11 (VHF-Hi, 183 / 201 MHz) | 41 / 37 cm | **long** whips (23–100 cm) |
  | RF 15–23 (476–530 MHz) | ~14 cm | short whips fully out, or long whips retracted |
  | RF 29–36 (560–608 MHz) | ~12–13 cm | **short** whips (5–13 cm) |

Use the kit's 3 m RG174 extension so the dongle can sit at the desk while
the dipole is at the glass; ~1.5 dB of loss at these frequencies, which is
nothing against +46 dB of margin.

What to record per window: relative amplitude of **KHON's 8VSB pilot at
180.31 MHz** (the station with least margin, and the VHF-Hi one) and of
**KGMB's at 524.31 MHz** (a UHF representative from the other cluster).
The window that does best on *both* is the one to mount on — that tradeoff
is the whole reason the panel has to straddle two directions.

> This measures the *location*, not the FLATenna, so it needs no F-to-SMA
> adapter. It is also a genuine dry run for Phase 5's labs.

## Phase 1 — tuner on the network, before any RF

Deliberately do this with **no antenna connected.** Network faults and RF
faults should never be debugged at the same time.

1. Flex Duo → office switch, then power.
2. Find its address in the router's DHCP table (look for a SiliconDust
   MAC), then confirm from WSL:

   ```bash
   curl -s http://<tuner-ip>/discover.json | python3 -m json.tool
   ```

   Expect `ModelNumber: HDFX-2US`, `TunerCount: 2`, a `DeviceID`, and a
   firmware version.
3. **Set a DHCP reservation** for that MAC. The Tizen app and the survey
   script both get easier with a stable address.
4. Note the `DeviceID` — `ota-survey.sh` accepts either it or the IP.

**Pass criterion:** `discover.json` returns valid JSON over the LAN. No
antenna, no lock, no channels yet — that is expected.

## Phase 2 — antenna up, attenuator still in the box

Mount the FLATenna at the chosen window at ~285° magnetic, run the coax
to the tuner, and **leave the FAM-10 out.** You cannot tell whether you
need attenuation until you have measured without it.

```bash
HDHR=<tuner-ip> ./ota-survey.sh | tee ota-survey-$(date +%F)-no-pad.txt
```

The script walks the 16 RF channels the survey predicts, tunes each
directly, and reports the tuner's own `ss` / `snq` / `seq`. It needs no
channel scan — it measures physics, not the lineup.

Reading the output:

| Column | Meaning | Want |
|---|---|---|
| `lock` | demodulator locked | `8vsb` |
| `ss` | signal strength | 75–100; **>100 is the overload warning** |
| `snq` | signal quality (SNR) | 100, ≥80 tolerable |
| `seq` | **symbol quality** | **100. This is the deciding number** |

Expected oddity, not a fault: **RF 22 (KHII) should fail to lock.** It is
the market's ATSC 3.0 lighthouse and the Flex Duo is ATSC 1.0 only. A
strong signal that won't lock on RF 22 is the correct result.

Re-run the script while nudging the panel. With +46–65 dB of margin on
everything but KHON, most channels will be indifferent — **orient against
KHON (RF 8)**, the only station without margin to spare.

**Pass criterion:** `seq=100` on RF 8, 11, 20, 23, 35 (FOX/CW, PBS, ABC,
CBS, NBC). Everything else is a bonus.

## Phase 3 — the attenuator decision

Only now, and only if Phase 2 showed the overload signature: `ss` pinned
at 100 with `seq` below 100, *especially if the strongest channels are
worse than the weaker ones.*

```bash
# insert the FAM-10 at the tuner end of the coax, then:
HDHR=<tuner-ip> ./ota-survey.sh | tee ota-survey-$(date +%F)-fam10.txt
diff ota-survey-*-no-pad.txt ota-survey-*-fam10.txt
```

This is a falsifiable test, so honour the result:

| Observation | Conclusion |
|---|---|
| `ss` drops ~10, `seq` rises to 100 | It was overload. Leave the pad in |
| `ss` drops ~10, `seq` unchanged at 100 | Pad is unnecessary. Remove it — don't keep margin you aren't using |
| `ss` drops ~10, `seq` gets *worse* | Not overload. Remove the pad; the problem is multipath or VHF aperture |

If it turns out to be multipath (high `ss`, low `seq`, no improvement from
the pad), the fix is repositioning, not hardware — a directional antenna
is unavailable here, per Goal 5.

## Phase 4 — clients

1. **Channel scan.** Easiest from the HDHomeRun app or the tuner's web UI
   at `http://<tuner-ip>/`. Then read the resulting lineup — this is
   authoritative for stream URLs, rather than assuming virtual channels:

   ```bash
   curl -s http://<tuner-ip>/lineup.json | python3 -m json.tool
   ```

2. **Laptop.** Play any lineup entry's `URL` field directly:

   ```bash
   vlc "http://<tuner-ip>:5004/auto/v<virtual-channel>"
   ```

3. **Samsung TV.** Open the HDHomeRun Tizen app; it should auto-discover
   the tuner on the LAN. No server, no transcoding, no subscription.

4. **The test that validates the design.** Tune the TV to a **Cluster A**
   station (KGMB/CBS, RF 23) and the laptop to a **Cluster B** station
   (KITV/ABC, RF 20) **at the same time.** Both holding simultaneously is
   the proof that the omnidirectional-antenna decision was correct — a
   directional antenna or a rotator fails this test by construction.

   Note this consumes both tuners. Two concurrent streams is the ceiling,
   which is also why DVR-while-watching isn't on the table with a Duo.

**Pass criterion:** two streams from opposite clusters, concurrently,
with no dropouts over several minutes.

## Phase 5 — SDR labs *(2 and 3 Thursday; 1 and 4 when the adapter lands)*

Only the labs that must look **through the FLATenna** need the F-to-SMA
adapter (ordered; arrives separately from the Thursday shipment). The
RTL-SDR's kit dipole telescopes across both bands of
interest — a quarter wave is ~42 cm at 180 MHz and ~13 cm at 550 MHz,
both inside the supplied elements' range — and at 7 miles it will hear
these transmitters easily. So:

| Lab (see `README.md` Goal 5) | Needs adapter? |
|---|---|
| 1. Peak the FLATenna on KHON's 8VSB pilot, 180.31 MHz | **Yes** — the point is to measure the panel. Adapter ordered |
| 2. KHII RF 22 (OFDM) vs KGMB RF 23 (8VSB) in the waterfall | **No** — kit dipole is fine |
| 3. Sweep 470–700 MHz, find the LTE edge above 608 | **No** — kit dipole, and arguably better: it characterises the *environment*, not the panel |
| 4. Trace the panel's radiation pattern by rotating it | **Yes** — adapter ordered |

Two cautions before connecting the SDR to anything, both consequences of
being 7 miles from the transmitters rather than 20:

- **Don't hang the adapter directly off the dongle.** A rigid F↔SMA
  adapter plus 12 ft of RG6 levers on the SMA jack, which is a known
  failure point on these dongles. Put the kit's 3 m SMA extension between
  dongle and adapter so the load lands on cable, not on the board.
- **Disable the Blog V3's bias tee.** It would push ~4.5 V into a passive
  antenna that presents a DC short. Off is the default; just don't enable
  it.
- **Expect the SDR to overload where the tuner didn't.** The R820T2 has a
  far weaker front end than the Flex Duo, and what saturates it is *total*
  power across the whole band — 14 strong channels at once, not the one
  you are tuned to. Symptoms are a rising noise floor, spurious images and
  phantom carriers. Fix: manual (not automatic) tuner gain set low, plus
  the `FAM-10` inline. **The attenuator is more likely to be needed for
  these labs than for the television.** 10 dB may not be enough; a 20 dB
  pad is worth adding to the adapter order.

VHF-Hi needs no special mode — 174–216 MHz sits well inside the R820T2's
~24–1766 MHz range, so direct sampling / Q-branch is irrelevant here.

## Checkpoint

Live Honolulu broadcast TV playing on the living-room Samsung and on the
laptop **simultaneously, from stations in opposite directions**, off one
$35 antenna, with no cable pulled through the house — and a saved
`ota-survey-*.txt` showing `seq=100` on all five majors, so the next
person to ask "do I need an amplifier?" can be answered with measurements
instead of a guess.

---

## Results log

Paste survey output and notes here as Phases 2–4 happen.

- [ ] Phase 0 — candidate windows surveyed with SDR + kit dipole, winner chosen
- [ ] Phase 1 — `discover.json` reachable, DHCP reservation set
- [ ] Phase 2 — baseline survey captured, orientation settled
- [ ] Phase 3 — attenuator decision made and justified by the diff
- [ ] Phase 4 — concurrent two-cluster playback confirmed
- [ ] Phase 5 — labs 2 and 3 (kit dipole)
- [ ] Phase 5 — labs 1 and 4 (adapter ordered; do on arrival)
