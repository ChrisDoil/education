# OTA TV bring-up procedure

Step-by-step for the hardware ordered 2026-09-13 (all arrived 2026-09-19,
adapter set included). Design rationale lives in `README.md` **Goal 5**;
the parts table and the reasoning behind each choice live in
`current_hardware.md`. This file is the procedure, and the place to paste
results as they come in.

## Status — resume here (as of 2026-09-20)

**Where it stands.** Tuner is on the network (Phase 1 done, `192.168.5.56`,
reserved). Antenna window is decided (Phase 0 done): **workout room,
north window** — the only one of four surveyed that hears both transmitter
clusters, and the best KHON by 5 dB. Attenuator is ruled out for the TV
chain (Phase 3 done). Phase 2 is **in progress**: the panel was surveyed
at the hallway window in four orientations and that window fails on
cluster B (ABC and the other Honolulu stations) in every orientation, and
on VHF because of a noise floor 6 dB worse than the rest of the house.

**Blocking step.** Get the panel to the workout room while the tuner stays
wired to the eero in the hallway. Plan: the house has a coax wall jack in
each room, wiring unknown. Find the splitter where the runs terminate,
confirm which run feeds the cable modem (never put the antenna on that),
take the workout-room and hallway runs off the splitter and join them with
an F-81 barrel (~$3, not yet bought; plus a short RG6 jumper for
tuner-to-wall). Then Phase 2 again with the panel on the workout-room
jack: pass = `seq=100` on RF 8, 11, 20, 23, 35.

**Fallback if the jacks aren't usable:** 50 ft RG6 + barrel from the
workout room to the hallway tuner (~3 dB), or the tuner in the workout
room on a 5 GHz Wi-Fi extender's Ethernet port (bridge for the tuner only).

**Tools.** `ota-survey.sh` (tuner-side survey, picks a free tuner; run from
any machine on the LAN: `HDHR=192.168.5.56 SETTLE=4 ./ota-survey.sh`),
`ota-window.sh` (SDR-side window survey, rtl_power; KHON/KITV/KGMB),
`setup-sdr-windows.ps1` + `setup-sdr-wsl.sh` (new machine). Survey files
`ota-survey-*.txt`, `long_whips_*`, `short_whips_*` are the raw results
summarised in the Results log at the bottom. Tuner 0 is often held by the
HDHomeRun app on the desktop PC; the survey script uses tuner 1 then.

**Learned the hard way.** The cable modem sits upstream of the eero — a
device plugged into it is invisible to the LAN. `http://192.168.4.1` is
an eero; there is no web UI, use the app. WSL2 needs usbipd-win for the
dongle. `sdrpp` is not in Ubuntu 26.04 apt (Kali only); `rtl-sdr` is all
`ota-window.sh` needs. A survey where every channel reports identical
numbers is a tuner locked by a client, not a result.

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

> **Setting up a second machine** (e.g. the laptop for surveying other
> windows): `setup-sdr-windows.ps1` in an admin PowerShell, then
> `setup-sdr-wsl.sh` inside WSL. Together they do everything the two
> caveats below describe.
>
> **WSL2 USB caveat (for every SDR step — Phase 0 and Phase 5).** WSL2
> has no USB stack; the dongle is forwarded from Windows with usbipd-win.
> Once, in an admin PowerShell: `winget install usbipd`, then
> `usbipd list` (the dongle is the `0bda:2838` row) →
> `usbipd bind --hardware-id 0bda:2838`. Then, **every time the dongle is
> replugged or WSL restarts:** `usbipd attach --wsl --hardware-id 0bda:2838`
> (add `--auto-attach` and leave the window open to skip this). Hardware
> ID rather than `--busid` because the BUSID follows the physical port and
> this dongle will move between windows. On the
> Kali side everything is in apt — `sudo apt install sdrpp rtl-sdr` — and
> WSLg draws the GUI. Blacklist `dvb_usb_rtl28xxu` so the kernel's DVB
> driver can't claim the dongle first. Verify with `lsusb` then
> `rtl_test -t` before opening SDR++. USB-over-IP adds overhead: if the
> waterfall stutters, drop to 1.024 MSPS.
>
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
- ≤12 ft of cable run to an Ethernet port (that is all the coax you
  have). *Updated 2026-09-20:* the cable router lives at the **hallway**
  window, so the tuner can plug straight into it there; the office would
  need a Wi-Fi repeater, which is the wrong transport for two ~19 Mbps
  constant-rate streams.

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
  the direction the station is in — a dipole's nulls are off its ends. In
  practice: two **matched** whips screwed into both sockets of the base,
  swung out to a straight line (180°, not a V), and the whole thing laid
  *across* the window parallel to the glass like a horizontal bar. A dipole
  does not "point"; the signal arrives on its flat side. Suction-cup it to
  the glass and step back a metre — a body next to it shifts the reading.
- **Same rig at every window.** Manual gain (AGC off), same value each
  time, same whips at the same length. Phase 0 is a relative comparison,
  so consistency matters more than resonance. Per window: long pair at
  41 cm for KHON, then swap to the short pair fully out for KGMB.
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

1. Flex Duo → a LAN port on the **eero** (or a switch hanging off one),
   then power. **Not the cable modem** — the modem is upstream of the eero,
   and a device plugged into it is outside the 192.168.4.0/22 network
   entirely (learned the hard way, 2026-09-20). The eero gateway has one
   LAN port; a 5-port unmanaged switch on it is the standard answer. Keep
   the tuner, eero, modem and their power bricks at the far end of the
   coax from the antenna — they are VHF noise sources (see the window 2
   noise-floor question in the Results log).
2. Find its address in the **eero app → Devices** (there is no router web
   page; `http://192.168.4.1` redirects to eero's block page). Look for
   "HDHomeRun" or a `00:18:DD` MAC. Or sweep from WSL:
   `for i in $(seq 1 254); do curl -s -m1 http://192.168.4.$i/discover.json
   | grep -q DeviceID && echo 192.168.4.$i; done` (the network is a /22,
   so .5, .6, .7 are possible too). Then confirm:

   ```bash
   curl -s http://<tuner-ip>/discover.json | python3 -m json.tool
   ```

   Expect `ModelNumber: HDFX-2US`, `TunerCount: 2`, a `DeviceID`, and a
   firmware version.
3. **Set a DHCP reservation** for that MAC — eero app → the device →
   *Reservations & Port Forwarding*. The Tizen app and the survey script
   both get easier with a stable address.
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

### Phase 0 — window survey (2026-09-19)

Rig: RTL-SDR Blog V3 via usbipd-win into WSL2, Kali apt `rtl-sdr`. Kit
dipole horizontal, straight line, across the glass. Numbers come from
`./ota-window.sh` (rtl_power, 10 kHz bins, 10 s integration, bias-T
off). Uncalibrated — only differences between windows mean anything.
**`data-noise` is the deciding column** (8VSB decodes at ~15 dB; it is
bin-width independent, `pilot-noise` is not).

Protocol, settled at window 1: **two sweeps per window.** Long whips at
41 cm → read the KHON row only. Short whips fully out → read the KGMB row
only. The short pair is deaf at 180 MHz (data-noise ≈ 0), and the long
pair understates UHF, so each row is only valid from its own pair. Gain
is fixed per band across all windows: **29.7 dB for the KHON sweep,
20.7 dB for the KGMB sweep** (see the gain test under window 1).

| Window | Whips / gain | KHON RF 8 pilot-noise | **KHON data-noise** | KGMB RF 23 pilot-noise | **KGMB data-noise** | Noise floor VHF / UHF |
|---|---|---|---|---|---|---|
| 1 — office, faces 310° mag | long, 29.7 | 15.9 dB | **6.1 dB** | *(29.0)* | *(11.2)* | -37.1 / -36.5 |
| 1 — office, faces 310° mag | short, 29.7 | *(2.0)* | *(-0.3)* | 35.4 | 15.7 | -41.4 / -31.4 |
| 1 — office, faces 310° mag | **short, 20.7** | *(1.0)* | *(-0.1)* | 34.8 | **15.2** | -45.4 / -39.4 |
| 2 — hallway, faces 215° mag, laptop | long, 29.7 | 9.8 | **4.4** ⚠ | *(37.6)* | *(19.5)* | **-31.2** / -46.1 |
| 2 — same, dipole ~1 m off the glass | short, 29.7 | *(20.0)* | *(2.3)* | 24.5 | 8.8 | -43.8 / -46.1 |
| 2 — same, dipole at the glass | short, 29.7 | *(21.1)* | *(3.1)* | 44.7 | **22.2** | -44.6 / -45.9 |
| 3 — workout room, **north** window, laptop | short, 29.7 | *(27.5)* | *(**8.9**)* ‼ | 40.7 | **22.5** | **-44.4** / -46.2 |
| 3 — workout room, **east** window | short, 29.7 | *(27.6)* | *(**10.1**)* ‼ | 34.7 | 13.5 | **-45.1** / -46.2 |
| 3 — workout room, **north** window | **long, 29.7** | 29.9 | **11.4** ★ | *(43.9)* | *(18.6)* | -37.0 / -46.0 |
| 3 — workout room, **north** window | short, 20.7 | *(15.2)* | *(2.0)* | 33.1 | 12.5 | -46.1 / -46.3 — KITV RF 20: 0.6 (dongle floor) |
| 3 — workout room, **north** window | **short, 29.7** | *(28.2)* | *(10.2)* | 39.8 | 15.3 | -44.5 / -45.3 — **KITV RF 20: 13.6** ★ |
| 3 — workout room, **east** window | long, 29.7 | 9.4 | 5.3 | *(33.1)* | *(18.7)* | -37.9 / -46.2 |

★ **Best KHON reading of the survey.** Long whips at the north window:
data-noise 11.4 (office 6.1, hallway 4.4), pilot at −7.1 absolute — 14 dB
hotter than either other window — and data 5.5 dB stronger. The east
window a few feet away is 6 dB worse on KHON; VHF indoors is that
position-sensitive. Correction to the short-whip note above: on the long
whips the RF 7 reference reads −37 in the office, north and east alike,
so that is the house-wide VHF floor and the short whips were simply not
hearing it; the **hallway at −31 is the anomaly**, and the workout room's
KHON advantage is mostly signal, not quiet. Still unmeasured here: KITV
(cluster B). First KITV reading, north at 20.7: **0.6 dB — absent.**
Caveat: the UHF noise column here is −46 at 20.7 *and* at 29.7, i.e. the
dongle's own floor, not external noise — this room is quiet enough that
the 20.7 rule (set for the hallway's busy band) leaves the dongle deaf.
Re-tested at 29.7: **KITV 13.6 dB, within 1.7 dB of KGMB** — the two
clusters arrive nearly equal here, where the hallway had cluster B 15–30
dB down in every orientation. The 20.7 rule is a hallway artefact; in a
quiet room use 29.7 for both bands.

**Phase 0 verdict: workout room, north window.** KHON 11.4 (long whips),
KITV 13.6, KGMB 15.3–22.5 — all three at or near the 8VSB threshold on a
rig that is worse than the Flex Duo + FLATenna on every axis. The only
window that sees both clusters. East not needed (6 dB worse on KHON).
Transport: house coax — a jack in the workout room and one in the
hallway, wiring unknown. Plan: find the splitter, confirm which run is
the modem's, take the two runs off the splitter and join them with an
F-81 barrel, then Phase 2 with the panel on the workout-room jack and
the tuner on the hallway jack.

‼ **Windows 3 (2026-09-20).** KHON at 9–10 dB *on the short whips*, which
read −0.3 in the office and 2–3 in the hallway — the same deaf antenna.
Two causes visible in the raw columns: KHON's pilot is 4–6 dB hotter here
in absolute terms than the resonant long whips got anywhere else, and the
**VHF noise floor is −44/−45, i.e. 7–13 dB below the office and hallway.**
This room does not have the VHF noise problem the hallway could not
rotate away from (see Phase 2). North matches the hallway's best on KGMB.
East faces Honolulu — cluster B, which the hallway cannot see through the
house. Pending: long-whip KHON and short-whip KITV/KGMB at 20.7 at both
windows (`ota-window.sh` now reports KITV RF 20 as the cluster B probe).
Also pending: how the tuner reaches the LAN from that room (eero satellite
port, or ~50 ft RG6 back to the hallway tuner, ~3 dB).

*Italics = wrong pair for that band, kept only to show why the protocol
is two sweeps.*

**UHF gain test, window 1.** Short whips at 29.7 put the KGMB pilot at
+4.0 and raised the UHF noise floor 5 dB over the long-whip run, which
looked like front-end compression. Re-sweeping at 20.7 dropped noise,
pilot and data together by 8.0 / 8.6 / 8.4 dB and left data-noise at
15.2 vs 15.7 — the linear outcome, not compression (compression would
have dropped the floor faster than the signal and *raised* data-noise).
So the floor rise was real pickup: the UHF band here is busy and its
noise arrives via the antenna, not the dongle. Gain therefore buys no
SNR on UHF, and 20.7 gives 9 dB of headroom for a better window.
**Decision: UHF sweeps at 20.7 for every window.** VHF stays at 29.7 —
untested, and KHON is weak enough that dongle noise may matter there.

**Window 2 (2026-09-20, laptop + same dongle).** UHF: **+7 dB over the
office** (22.2 vs 15.2), and the two short-whip runs show 13 dB of
difference from dipole position alone — at the glass is the number that
matters, since that is where the panel goes. Short whips were run at
29.7 not 20.7; ranking is unaffected (UHF shown linear at 29.7), pilot at
-1.3 is as hot as it should get. KHON: reads worse (4.4 vs 6.1) but the
*signal* is ~3.4 dB **stronger** than at the office (data -26.8 vs
-31.0, noise-corrected); the SNR loss is entirely a **VHF noise floor
6 dB higher** (-31.2 vs -37.1). ⚠ Pending control: laptop at the office
window, long whips, on battery. Office floor reads ~-37 on the laptop →
the noise belongs to window 2 and the Flex Duo would see it too → office
keeps KHON. Reads ~-31 → the noise is the laptop (USB / charger) and the
tuner never sees it → **window 2 wins both bands.** Third candidate:
the **cable modem / router / power bricks are at this window**, and that
noise *would* reach the Flex Duo. If the laptop proves clean, sweep the
hallway with the dipole near vs far from the router (or with the router
powered off for one sweep) — if the floor follows the router, the fix is
placement: antenna at the far end of the coax from it. Network tilts the
decision toward the hallway regardless: the tuner plugs straight into
the router there, versus a Wi-Fi repeater for the office. Raw outputs:
`long_whips_1`, `short_whips_1`, `short_whips_2`.

Notes, window 1: textbook 8VSB signature in SDR++ — quiet floor below
180.3, pilot spike at 180.30 with no PPM correction, flat raised data
floor above it. SDR++ eyeball gave ~7 dB KHON data-noise, agreeing with
rtl_power; its ~30 dB pilot figure is higher only because its FFT bins
are narrower. KHON at 6 dB is under the decode threshold on *this* rig,
which is a worse front end and a smaller antenna than the Flex Duo +
FLATenna will be; a baseline for comparing windows, not a verdict on the
station. Spurs at ~180.05 and ~181.2 MHz, ignored.

- [x] Phase 0 — four windows surveyed (office, hallway, workout N, workout
      E). **Winner: workout room, north window** — the only one that hears
      both clusters, and the best KHON by 5 dB. 2026-09-20.
- [x] Phase 1 — `discover.json` reachable (2026-09-20): `HDFX-2US`,
      DeviceID `10990608`, firmware 20260326, **192.168.5.56** on the eero
      LAN port. First attempt was on the cable modem upstream of the eero
      and was invisible to the whole network. DHCP reservation set in
      the eero app — done, 192.168.5.56 reserved.
- [~] Phase 2 — **hallway window surveyed and rejected** (2026-09-20).
      Four orientations, files `ota-survey-2026-09-20-hallway-*.txt`:
      loose placement, flat on the glass far from the modem, edge-on at
      285° (pos 1), on the side wall at 305° (pos 2). Palehua majors
      (CBS 23, NBC 35) are position-proof at ss 83–88 / seq 100. Cluster
      B never locks: KITV 20 best was ss 69 at pos 2, and the lock
      threshold here is ~75–78 — the house is between this window and
      Honolulu, and rotation only moved it ~10 dB. VHF-Hi: KHON 8 never
      locks at ss 77–82 (power without a signal = noise/multipath), KHET
      11 flips between seq 100 and 0 with small moves. Both consistent
      with the hallway's 6 dB worse VHF floor from Phase 0. First
      "mounted" run showed 16 identical PASS rows — tuner 0 was streaming
      KGMB to the desktop's HDHomeRun app; `ota-survey.sh` now detects
      that. **Next:** panel to the workout-room north window via the house
      coax (see Status at top), then re-survey.
- [x] Phase 3 — **decided by the baseline: no attenuator.** RF 11 pins
      ss=100 with seq=100 (no overload); every failure is on the weak
      side. FAM-10 stays out of the TV chain; it is for the SDR in Phase 5.
- [ ] Phase 4 — concurrent two-cluster playback confirmed
- [ ] Phase 5 — labs 2 and 3 (kit dipole)
- [ ] Phase 5 — labs 1 and 4 (adapter set in hand; needs the panel
      settled first)
