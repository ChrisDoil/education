# Combined Lab — Architecture & Build Plan

A lab that serves both `forensics/` (Windows DFIR VMs, isolated
attack-emulation network) and `satcom/` (RTL-SDR reception, GNU Radio)
curricula, reachable by SSH from home and while traveling, and
structured so Claude can inspect lab machines directly to help with
diagnosis and analysis.

See `current_hardware.md` for the hardware this plan is built around.

> **Plan history.** This plan was originally built around a Dell
> PowerEdge R720XD racked outside the home office; that's been shelved
> (see **Parked hardware**). A single-node interim plan then put
> everything on the NAS, which the N95's four cores made tight. The
> current plan restores a two-node split using a low-power mini PC as
> the hypervisor. Everything below is current.

## Design goals

1. **Reachable from anywhere.** Analysis has to work from a laptop while
   traveling, not just on the home LAN.
2. **Claude in the loop.** Claude needs direct access to the contents of
   lab machines — to diagnose lab breakage and to help interpret
   forensic artifacts while working through modules.
3. **SDR reception.** The RTL-SDR and its antenna are physically at home
   and must stay there; the lab has to serve their output over the
   network.
4. **Use the NAS.** It's small, quiet, office-appropriate, and already
   in hand.
5. **Over-the-air TV.** One antenna serving both the living-room smart TV
   and Wi-Fi devices, with no new cable pulled through the house.

## Two-node split

Both nodes live in the home office. Neither needs a rack, a wired drop
to another room, or a space that isn't air-conditioned — which is the
whole reason this shape replaced the R720XD design.

| Node | Hardware | Role | Power state |
|---|---|---|---|
| **Hub** | TerraMaster F2-424 (N95, 8GB, 2×8TB) | TrueNAS SCALE: ZFS storage, Tailscale endpoint/subnet router, always-on SDR server, WoL trigger | **Always on** (~15W) |
| **Forge** | Mini PC (Ryzen 7 7730U, 32GB, 1TB) | Proxmox VE: all forensics VMs | On demand (or just left on, ~15W idle) |

```
   Laptop / phone (anywhere)
            │
      Tailscale overlay
            │
┌───────────┴─────────────────┐   ┌─────────────────────────────┐
│ Hub — TerraMaster F2-424    │   │ Forge — mini PC             │
│ TrueNAS SCALE   always on   │   │ Proxmox VE    on demand     │
│ N95 4c/4t, 8GB, 2×2.5GbE    │   │ 7730U 8c/16t, 32GB, 2.5GbE  │
│                             │   │                             │
│ ZFS `tank` 2×8TB mirror     │   │ vmbr0 — LAN uplink          │
│   forensic-images/  ────────┼──►│  └─ Analysis VM             │
│   sdr-captures/       NFS   │   │       └─ Claude Code + repo │
│   vm-backups/    ◄──────────┼───┤                             │
│                    vzdump   │   │ vmbr1 — NO physical NIC     │
│ Tailscale subnet router     │   │  ├─ Windows Server 2022     │
│                             │   │  └─ Caldera VM              │
│ SDR container               │   │        ▲                    │
│  rtl_tcp / SpyServer        │   │        │ hypervisor-side    │
│  └─ RTL-SDR ─ window dipole │   │        │ evidence pull only │
│                             │   │        │ (no network path)  │
│ WoL trigger ────────────────┼──►│ (wake) │                    │
└─────────────────────────────┘   └────────┴────────────────────┘
```

Why this split rather than one box: the N95 is four cores with no
hyperthreading, which is fine for serving files, holding a VPN endpoint,
and streaming SDR samples, but leaves no room to run three VMs under
load. The 7730U is 8 cores / 16 threads — roughly 3.5× the N95 in
multithreaded terms at the same ~15W class — which removes the core
constraint entirely and lets all three VMs run concurrently instead of
in shifts.

## Node 1 — Hub (TerraMaster F2-424, always on)

Reflash to **TrueNAS SCALE**, replacing the stock TOS.

> An earlier revision of this plan put Proxmox on the NAS. That argument
> only held while the NAS was the hypervisor. It isn't anymore, so
> TrueNAS's better share management wins and Proxmox moves to Forge.

Responsibilities:

- **Storage.** 2×8TB WD Red Plus as a mirrored ZFS pool (`tank`):
  - `forensic-images/` — vetted practice images (NIST CFReDS, DFRWS
    challenge sets), hash-verified on download, exported read-only over
    NFS to the analysis VM.
  - `sdr-captures/` — IQ recordings and decoded output from
    `satcom/08-sdr-gnuradio-labs`.
  - `vm-backups/` — Proxmox `vzdump` target, so golden snapshots survive
    a failure of Forge's single VM drive. This is the main reason Forge
    doesn't need mirrored storage of its own.
- **Tailscale endpoint + subnet router.**
  `tailscale up --ssh --advertise-routes=<home-LAN-CIDR>`. The `--ssh`
  flag authenticates by Tailscale identity, so there are no SSH keys or
  fail2ban rules to maintain separately; `--advertise-routes` (approved
  once in the admin console) reaches LAN devices that don't run
  Tailscale themselves — including Forge before it's booted.
- **SDR server.** The dongle stays plugged in here, because this is the
  node that's always up. See Goal 3.
- **WoL trigger for Forge.** `wakeonlan <Forge-NIC-MAC>` from the Hub —
  same L2 segment, so a plain magic packet works. At ~15W idle you may
  decide to just leave Forge on; the trigger costs nothing to set up
  either way.

8GB is sufficient for this role. **Do not buy the 32GB DDR5 SODIMM** the
single-node revision of this plan called for — that requirement moved to
Forge.

## Node 2 — Forge (mini PC, Proxmox VE)

Install **Proxmox VE** bare metal, wiping the bundled Windows. (VMware's
free ESXi tier no longer exists post-Broadcom, so Proxmox is the obvious
free choice — and it has the specific capabilities this lab needs.)

Why Proxmox specifically:

- **`vmbr1` — a Linux bridge with no physical NIC attached at all.** This
  *is* the "host-only network with zero route to the internet or host
  LAN" that `forensics/windows/00-lab-setup` requires, and it's cleaner
  than a host-only adapter because there's no host-side interface to
  misconfigure. A single physical NIC is all this design ever needed,
  since `vmbr1` is defined by *not* having one.
- **Snapshot and rollback ergonomics** for the golden-snapshot-per-module
  workflow both forensics curricula assume.
- **`qm monitor <vmid>` → `dump-guest-memory`** captures a guest's RAM
  from outside the guest entirely. That's the gold-standard acquisition
  `forensics/windows/06-memory-forensics` contrasts against in-guest
  tools, and owning the hypervisor is what makes it available.

Network config:

- `vmbr0` — bridged to the home LAN. Proxmox management, plus the
  analysis VM (which needs the Hub's NFS export and internet access for
  tool updates; it runs no attack emulation).
- `vmbr1` — **no physical uplink.** Windows Server 2022 eval VM and the
  Caldera Linux VM live here and nowhere else.
- Verify isolation the way the module's checkpoint asks: from inside the
  Windows VM, confirm `ping 8.8.8.8` times out and DNS fails.

### Resource budget

| Guest | RAM | vCPU |
|---|---|---|
| Proxmox host | 4 GB | — |
| Windows Server 2022 DFIR VM | 8 GB | 4 |
| Caldera Linux VM | 4 GB | 2 |
| Analysis VM (Claude Code lives here) | 12 GB | 6 |
| Headroom | 4 GB | — |
| **Total** | **32 GB** | 8c/16t, all concurrent |

32GB is the right starting point, not 64GB. It covers the full budget
with headroom, and since the machine ships as 2×16GB both SO-DIMM slots
are already occupied — going to 64GB means discarding two new sticks for
a 2×32GB kit, which is a poor purchase to make while RAM prices are
elevated. Revisit when a lab actually pushes past 32GB.

## Goal 1 — Access from anywhere

Nothing is port-forwarded and nothing is exposed to the public internet.

| Target | Method |
|---|---|
| Hub | SSH / TrueNAS web UI over Tailscale |
| Forge host | SSH / Proxmox web UI over Tailscale — also the out-of-band console when a guest's networking is broken |
| Windows DFIR VM | RDP over Tailscale (tolerates travel latency far better than VNC) |
| Analysis VM | SSH, plus xrdp for Autopsy and other GUI work |
| SDR | `rtl_tcp` / SpyServer over Tailscale — see Goal 3 |

Confirm the path works from a phone on cellular data — genuinely "away,"
not just off Wi-Fi.

## Goal 2 — Claude in the loop

The point is for Claude to read real lab state — parser output,
timelines, logs, broken configs — rather than being told about it.

**Run Claude Code on the analysis VM, not only on the laptop.** SSH into
that VM over Tailscale and run `claude` there. It then has native shell
and filesystem access to the artifacts and tooling (Volatility3, plaso,
ALEAPP/iLEAPP, RegRipper output) instead of tunneling every read through
`ssh` calls from the laptop.

**Clone this repository onto the analysis VM.** Claude then sees the
module README, its objectives and its checkpoint sitting next to the
actual evidence output. That context is what turns "help me read this
artifact" into module-aware feedback rather than generic tool help, and
it means lab notes get written back into the right module folder.

**Do not put Claude on the isolated VMs.** That would defeat `vmbr1`.
Move artifacts *out* hypervisor-side instead, which preserves isolation
completely:

- **Memory:** `qm monitor <vmid>` → `dump-guest-memory -z <path>` writes
  the guest's RAM straight to host storage. Nothing is installed in the
  guest and nothing crosses the bridge.
- **Files:** attach a scratch virtio disk to the Windows VM, write KAPE
  or RegRipper output to it, detach it, and re-attach it read-only to
  the analysis VM. A deliberate sneakernet, not a network path.

**Data-handling caveat.** Anything Claude reads leaves the machine. That
is acceptable here *only* because both forensics curricula already
mandate synthetic known-answer data and vetted CFReDS/DFRWS images — see
the legal/ethics sections in `forensics/windows/README.md` and
`forensics/mobile/README.md`. That rule is now load-bearing rather than
merely good hygiene: never point Claude at real-case or third-party
evidence.

## Goal 3 — SDR over the network

The dongle stays plugged into the **Hub**, near whatever window or
antenna spot has the best sky view. It lives there rather than on Forge
specifically because the Hub is the node that's always up — SDR
reception shouldn't depend on whether the VM host happens to be booted.
Run it as a container with the USB device mapped through.

Travel exposes a bandwidth problem worth planning around: `rtl_tcp` at
2.4 MSPS is 8-bit I/Q, so **~4.8 MB/s ≈ 38 Mbit/s of raw samples**, which
will exceed a typical home upload link. Three approaches, in order of
preference:

1. **Run the flowgraph at home, analyze the output remotely.** Headless
   GNU Radio on the analysis VM writes IQ/decodes to `sdr-captures/`;
   you pull results, not samples. Best fit for
   `satcom/08-sdr-gnuradio-labs`, and now practical because Forge has
   cores to spare for a demod chain.
2. **SpyServer for interactive browsing.** It decimates server-side and
   ships only the slice you're tuned to — built for exactly this
   constraint. Pair with SDR++ on the laptop.
3. **`rtl_tcp` at a reduced rate** (1.024 MSPS ≈ 16 Mbit/s) when you
   genuinely need live samples in a remote flowgraph.

This satisfies `satcom/00-hardware-and-tools`' Tier 0/1 checkpoint with
the source relocated to a network block, and it decouples "where the
antenna cable runs" from "where the DSP work happens."

## Goal 5 — Over-the-air television

A household requirement rather than a curriculum one, but it shares the
RF domain with `satcom/` and rides the network this plan already builds,
so it belongs here. Target: live Honolulu broadcast TV on the
living-room Samsung TV *and* on the laptop, from one antenna, without
pulling new cable through the house.

**The antenna is not the thing that gets shared.** An antenna is passive
and terminates in one coax connector; what makes OTA reachable from
arbitrary devices is a **network tuner** — an ATSC demodulator with an
Ethernet port that republishes each channel as an HTTP stream. Splitting
coax to the living room would also work, and would actually look better
on the TV, but it needs a cable run — which this plan already rejected
once for Cat6 (see **Parked hardware**). So the coax stays short and
inside the office, and distribution moves onto the LAN, where the Wi-Fi
and Tailscale already reach everything.

```
Antenna (office window or attic, fixed aim ~WNW toward Palehua)
   │ RG-6 quad-shield, short run
HDHomeRun Flex Duo ── office switch ── home LAN
                                        ├─ Samsung TV (HDHomeRun Tizen app)
                                        ├─ Laptop (HDHomeRun app, or VLC on
                                        │    http://<tuner-ip>:5004/auto/v5.1)
                                        ├─ Hub (optional DVR → tank/ota-recordings/)
                                        └─ Tailscale ─► same streams while traveling
```

### Signal environment — measured, not assumed

Site survey run 2026-09-13 via RabbitEars for the actual location
(West Oahu, ~21.34°N / -158.01°W, 13' AGL). This **replaces** the
earlier estimates in this plan, two of which were wrong in ways that
changed the antenna decision.

| Item | Value |
|---|---|
| Distance to transmitters | **6.6–11.9 mi** — much closer than the 15–25 mi first assumed |
| Bearings | **Two clusters ~152° apart**, not one. See below |
| Aiming | **Do not aim.** No single direction reaches both clusters |
| Margins | **+46 to +65 dB** over threshold for every major. Signal is overwhelming |
| Bands needed | UHF **and VHF-Hi** — KHON is on RF 8, KHET on RF 11 |
| ATSC 3.0 | KHII-TV (RF 22) is the lighthouse. Every major also runs its own ATSC 1.0 transmitter, all strong |

**Cluster A — Palehua / Makakilo, ~307–311° true (~298–302° magnetic), 6.6–7.1 mi**

| Station | Net | RF | Margin |
|---|---|---|---|
| KGMB | CBS | 23 | +61.6 dB |
| KHII-TV | MyN | 22 | +60.7 |
| KHNL | NBC | 35 | +59.3 |
| KHET | PBS | **11** (VHF-Hi) | +60.8 |
| KIKU | IND | 19 | +60.9 |
| KALO | REL | 18 | +64.9 |
| KUPU | IND | 15 | +62.1 |
| KKAI | IND | 29 | +57.2 |
| KPXO-TV | ION | 32 | +56.4 |
| KWBN | Daystar | 26 | +23.5 |
| KAAH-TV | TBN | 27 | +21.1 |

**Cluster B — Honolulu side (Tantalus area), ~94–106° true (~85–96° magnetic), 8.3–11.9 mi**

| Station | Net | RF | Margin |
|---|---|---|---|
| KBFD-DT | Korean | 33 | +58.5 dB |
| KITV | **ABC** | 20 | +55.8 |
| KWHE | IND | 31 | +52.1 |
| KHON-TV | **FOX/CW** | **8** (VHF-Hi) | +46.6 |
| KHHI-LD | — | 36 | +15.8 |

The survey also lists KKAI, KPXO and KUPU from distant Kailua / Kaneohe /
Waimanalo translators at −21 to −33 dB. Ignore those; the same stations
arrive from Cluster A with 56–62 dB to spare.

#### What this changes

1. **ABC and FOX are in the opposite direction from everything else.**
   KITV and KHON sit ~152° away from the Palehua cluster. **A directional
   antenna cannot have both** — aiming at Palehua sacrifices ABC and FOX,
   aiming at Honolulu sacrifices CBS, NBC and PBS. So the earlier
   "fixed aim WNW, no rotator" line was wrong, and so was calling
   omnidirectional a compromise: here it is **the correct choice**, and
   the FLATenna stops being a probe and becomes the answer.
2. **Weak signal is not a risk; overload is.** Field strengths run to
   104 dBμV/m at 7 miles, +46–65 dB over threshold. The plan's earlier
   "no preamp" rule hardens into an absolute, and an **attenuator**
   becomes a plausible need instead of a remote one.
3. **VHF-Hi is confirmed, not hypothetical.** KHON on RF 8 and KHET on
   RF 11 mean a UHF-only antenna loses FOX/CW and PBS. The FLATenna
   covers VHF-Hi, which is the specific reason to keep it over a
   UHF-only panel.

#### The one station to verify

**KHON-TV (FOX/CW, RF 8.)** It is the only signal with three strikes at
once: VHF-Hi, where a 12×15" panel is electrically small; in Cluster B,
so it arrives off the panel's back or edge; and the lowest margin of any
major at +46.6 dB, rated only "Fair." Everything else has enough margin
to be indifferent to orientation. If one channel misbehaves, it will be
this one — check it first, and use it as the station to orient against.

Salt air still argues for indoor mounting — the same reasoning that
parked the R720XD — and at 7 miles nothing about this signal environment
justifies going outside.

> **Hardware ordered 2026-09-13, arriving Thursday.** Step-by-step
> bring-up, the attenuator decision procedure, and the results log are in
> **`ota_bringup.md`**; **`ota-survey.sh`** sweeps these RF channels and
> reports the tuner's own signal metrics.

### Prediction tools

Use **[RabbitEars Signal Search Map](https://rabbitears.info/searchmap.php)**
(address or coordinates + antenna height → per-station field strength, real
RF channel, distance, bearing, terrain-modeled; has a privacy shift for the
displayed pin). Cross-check against the
[FCC DTV map](https://www.fcc.gov/media/engineering/dtvmaps) and
[AntennaWeb](https://antennaweb.org), the latter for *magnetic* bearing —
local declination is ~9–10°E, which the survey above reflects. **Not
TVFool:** its database predates the FCC repack that moved nearly half of
all US RF channels, which is exactly the field that matters here.

### Interference — what actually matters here

Interference *between* stations is a non-issue: island isolation means no
co-channel conflict with other markets, and the two clusters are on
separate RF channels throughout. The real risks, reordered against the
measured data:

| Risk | Symptom | Fix |
|---|---|---|
| **Front-end overload** — now the top risk at +46–65 dB margins | Strength pins >100%; channels scan but won't lock; strong channels worse than weak ones | **6–10 dB attenuator.** Never an amplifier |
| **Multipath** | Fine by day, drops at night; high strength, low symbol quality | Reposition the panel. A directional fix is unavailable here — see Cluster B |
| **600 MHz LTE/5G** (T-Mobile band 71) | Trouble on RF 36 specifically | **LTE filter (~$15).** TV ends at RF 36 / 608 MHz; above is cellular. Only KHHI-LD is exposed, and it's already Poor |
| **FM broadcast** (88–108 MHz) | Broad desense, worst on VHF-Hi — i.e. on KHON and KHET | FM trap |

**No prediction site models multipath.** They compute path loss over
terrain and stop. With margins this large, multipath is now the *only*
plausible propagation failure, and the only instruments that reveal it are
the Flex Duo's symbol-quality readout and the RTL-SDR. For interference
specifically the SDR beats every site above: sweep 470–700 MHz at the
candidate window and read the real environment, including whether an LTE
carrier sits just above 608 MHz. Measurement instead of prediction, and
it's the same survey as lab 3 below.

### Antenna

The survey settles this: **Channel Master FLATenna 35 (`CM-4001HDBW`,
~$25)**, passive, UHF + VHF-Hi, 12 ft RG6 in the box. Not a probe — the
right part, for three reasons the measured data supplies:

- **Omnidirectional is required, not tolerated.** The two clusters are
  ~152° apart, so no single directional antenna covers both.
- **A rotator is worse than useless here.** This is a *network* tuner
  serving the TV and the laptop at once; the moment one client watches
  CBS (Cluster A) while another watches ABC (Cluster B), a steerable
  antenna cannot satisfy both. Omnidirectional isn't a concession to
  cost — it's structurally required by the design.
- **It covers VHF-Hi**, which KHON (RF 8) and KHET (RF 11) need.

Placement, given that 12 of 13 stations have +46 dB or better and are
therefore indifferent to orientation:

- A flat panel's lobes are broadside to the sheet, front and back. Set
  the face normal to roughly **295° / 115°** and both clusters fall in a
  lobe rather than off an edge.
- Keep metal off the back — foil-backed insulation, metal blinds,
  appliances, a monitor.
- Glass over drywall where there's a choice.
- Verify **KHON (RF 8)** first and orient against it; it's the only
  station with no margin to spare.

**Add an attenuator before you add anything else.** At +46–65 dB, if
channels scan but won't lock, the problem is overload, and 6–10 dB of
attenuation is the fix. Never an amplifier; specifically never the
amplified FLATenna variant (`CM-4001HDBWA`).

If the FLATenna genuinely falls short, the escalation is *not* a
directional antenna — the two-cluster geometry has ruled that out. In
order:

1. **Try other windows.** Free, and with margins this large, position
   beats hardware.
2. **If only KHON/KHET misbehave**, the problem is band, not direction:
   add a small dedicated VHF-Hi antenna and combine it with the panel
   through a **UVSJ** (UHF/VHF splitter-joiner). This is the most likely
   escalation.
3. **If one whole cluster is weak**, two panels into a combiner, one
   facing each cluster. Last resort — combiners add loss and can produce
   cancellation on channels both antennas hear.

This is a **second, separate antenna** from the RTL-SDR's kit dipole, and
the two are not interchangeable in either direction:

- **Frequency.** The FLATenna covers 174–216 and 470–608 MHz. No satcom
  band of interest falls in either window — 137 MHz (NOAA/Meteor), 145 MHz
  (2 m sats), 240–320 MHz (UHF milsatcom), 435 MHz (70 cm sats) and
  1.5–1.7 GHz (Inmarsat/Iridium/GOES/GPS) all miss it.
- **Polarization.** Satellites are circular to survive Faraday rotation
  and arbitrary spacecraft attitude; the FLATenna is linear-horizontal to
  match terrestrial TV. Linear-on-circular is a standing 3 dB loss.
- **Pattern.** The panel's lobes look at the horizon and its nulls are off
  its edges — which, wall-mounted, is where the sky is.

The dipole does, however, earn a **dual role**: it is the field-strength
meter used to pick the FLATenna's window in `ota_bringup.md` Phase 0, and
set to a 120° V-dipole with ~54 cm legs it is the standard cheap 137 MHz
NOAA/Meteor antenna for `satcom/`. One instrument, two curricula — which
is the combination that actually pays off here, rather than trying to make
one *antenna* serve both.

### Tuner

| Model | Tuners | Rough cost | Verdict |
|---|---|---|---|
| **Flex Duo** | 2 × ATSC 1.0 | ~$130 | **Buy this.** Covers TV + laptop concurrently |
| Flex Quatro | 4 × ATSC 1.0 | ~$180 | Only if 3+ concurrent streams, or recording while watching, matters |
| Flex 4K | 4 total, 2 do ATSC 3.0 | ~$200 | Skip |

Why skip the 4K despite Honolulu having real ATSC 3.0: **as of early
2026 no HDHomeRun can decrypt DRM-protected ATSC 3.0**, and on meeting
an encrypted 3.0 channel it silently falls back to that station's ATSC
1.0 version — so the premium buys a tuner that mostly hands back the
picture the cheaper box already gets. (The ZapperBox M1 *does* handle
DRM'd 3.0, but it's an HDMI set-top box, not a network tuner — wrong
shape for a "reachable from everything" requirement.) The one genuinely
interesting thing about ATSC 3.0 here is its *physical layer*, and the
RTL-SDR already shows that for free — see below.

The tuner has a single coax input and feeds all its tuners internally,
so no splitter is needed between antenna and tuner.

### Clients

| Device | Method |
|---|---|
| Samsung TV (living room) | Native **HDHomeRun app on Tizen** — auto-discovers the tuner on the LAN. No server, no transcoding, no subscription for live TV |
| Laptop | HDHomeRun app, or any player pointed at `http://<tuner-ip>:5004/auto/v<virtual-channel>`; VLC and mpv both handle the raw MPEG-2 TS |
| Phone | HDHomeRun app, on the LAN or over Tailscale |

The Samsung's own built-in tuner is still the best possible path *for
that one device* — it's a NextGen TV set, so it handles the DRM'd ATSC
3.0 the HDHomeRun can't. That's an argument for running coax to the
living room someday, not an argument against this design; the network
path is what makes every other device work.

### Watching from the road

Same bandwidth wall as Goal 3, for the same reason. ATSC 1.0 is a
**19.39 Mbit/s** multiplex per 6 MHz RF channel, and one HD subchannel
is typically 12–17 Mbit/s of MPEG-2 — so relaying a channel untouched
over Tailscale needs that much *upload* from home, which most
residential links won't provide. The fix mirrors the SDR case: don't
ship the raw stream.

- **On the LAN or Wi-Fi:** stream it raw. 17 Mbit/s is nothing here.
- **Over Tailscale:** put a transcoding DVR in front of it and pull a
  re-encoded 4–6 Mbit/s H.264 stream instead.

### Optional — DVR onto the Hub

The Hub is always on with an 8TB mirror, which is exactly what a DVR
wants. Not required for the stated goal — the live-TV apps work with no
server at all. When you do want it:

| Option | Cost | Fit |
|---|---|---|
| HDHomeRun DVR | ~$35/yr | Lowest friction — same app, records to an SMB share on the Hub |
| Channels DVR | paid | Best transcoding and remote-streaming story, which is what the travel case actually needs |
| Tvheadend / Jellyfin container | free | Fits the lab's self-hosted instinct, but neither has a first-party Tizen app, so the TV would need a Fire TV stick or Chromecast as its client |

If you add one, create a `tank/ota-recordings/` dataset alongside the
existing three, and keep it out of the `vzdump` scope — recordings are
replaceable and shouldn't inflate the backup set.

### Where this touches `satcom/`

Worth doing even though the TV works without it: these transmitters give
you a **strong, permanent, known-location signal 7 miles away** — a far
better teaching target than a marginal satellite pass, and the survey
above means every frequency below is already known rather than guessed.

The RTL-SDR **cannot demodulate ATSC.** A 6 MHz channel needs 6+ MSPS and
the Blog V3 tops out near 2.4 MSPS. But it does the part that matters
pedagogically. Channel-to-frequency, so any of these can be recomputed:

```
VHF-Hi (ch 7–13):  lower edge = 174 + 6 × (n − 7)   MHz
UHF    (ch 14–36): lower edge = 470 + 6 × (n − 14)  MHz
8VSB pilot = lower edge + 0.31 MHz
```

1. **Orient the panel with the SDR, not the TV's meter.** ATSC 1.0's 8VSB
   carries a pilot carrier 310 kHz above the lower channel edge —
   narrowband, strong, trivially visible inside a 2.4 MSPS window. The
   station to peak on is **KHON, RF 8 → pilot at 180.31 MHz**, because
   it's the one with no margin to spare. Watch the spike amplitude while
   repositioning. That's a real signal-strength meter, and it explains
   *why* a residual-sideband scheme carries a pilot at all (carrier
   recovery). Needs an F-to-SMA adapter to borrow the TV antenna for a
   few minutes. Ties to `satcom/02-rf-electronics-fundamentals`.
2. **8VSB against OFDM, on adjacent channels.** The market hands you an
   ideal pair: **KHII RF 22 (518–524 MHz)** is the ATSC 3.0 lighthouse
   and **KGMB RF 23 (524–530 MHz)** is ATSC 1.0 — 6 MHz apart, same site,
   same bearing, same distance, so nothing but the modulation differs.
   One shows a sharp pilot at 524.31 MHz; the other is a flat noise-like
   block with no discrete carrier. Let the pilot's presence *identify*
   which standard you're looking at rather than trusting the label. Two
   eras of modulation design in one screenshot — and ATSC 3.0's
   OFDM + LDPC is far closer to DVB-S2 than 8VSB is, which is the
   waveform family `satcom/07-satellite-modems-waveforms` is about. Ties
   to `05-digital-comms-info-theory` and `07`.
3. **Survey the whole band and check the LTE edge.** Sweep 470–608 MHz
   and confirm energy on the 14 RF channels the survey predicts (15, 18,
   19, 20, 22, 23, 26, 27, 29, 31, 32, 33, 35, 36), then keep going to
   700 MHz. TV ends at 608; anything strong above it is T-Mobile band 71,
   and **RF 36 (602–608 MHz, KHHI-LD)** is the one channel adjacent to it.
   This is measurement where the prediction sites can only model. Good
   first exercise for `satcom/08-sdr-gnuradio-labs`.

A fourth, free one: the two clusters are 152° apart, so sweeping the same
UHF channel while rotating the panel traces a real **antenna radiation
pattern** — the flat panel's broadside lobes and edge nulls, measured
rather than read off a datasheet. Ties back to `02`.

Nothing here transmits, so all of it stays inside the receive-only
boundary that applies before `satcom/03-ham-radio-license`.

## Gaps to fill

- **The mini PC itself.** Ryzen 7 7730U class, and critically **the
  SO-DIMM variant** — some units in this class ship 16GB LPDDR4X
  *soldered to the board* with no upgrade path, which is a hard 16GB
  ceiling and unusable for this budget. Confirm the listing specifies
  SO-DIMM slots (2×, up to 64GB) and 32GB installed before buying.
- **Verify the M.2 situation** on whichever unit you buy. Bundled drives
  in this class are sometimes **M.2 SATA** (~550 MB/s) rather than NVMe,
  and the second M.2 slot isn't always PCIe. If only one slot takes
  NVMe, run VMs on a single NVMe and rely on `vzdump` to the Hub — the
  plan already assumes that as the recovery path, so no mirror is
  required on Forge.
- **Don't pay a premium for a Windows license.** It gets wiped for
  Proxmox, it's OEM-tied to that board, and the DFIR VM uses the
  Windows Server 2022 eval ISO regardless.
- **SDR antenna placement.** A short USB extension and the kit dipole,
  window-mounted, per `satcom/00-hardware-and-tools` Tier 1.
- **TV antenna + network tuner** for Goal 5 — Channel Master FLATenna 35
  plus an HDHomeRun Flex Duo, both settled by the site survey. Add a
  **6–10 dB attenuator** to the same order; at +46–65 dB margins overload
  is the likeliest failure, and it's a $8 part.
- **F-to-SMA adapter** (~$5) so the RTL-SDR can borrow the TV antenna for
  the aiming and waveform-comparison labs in Goal 5.

No longer needed (these were requirements of the single-node revision):

- ~~32GB DDR5 SODIMM for the NAS~~ — 8GB is fine for storage, Tailscale
  and the SDR container.
- ~~2× NVMe for the NAS M.2 slots~~ — VM storage moved to Forge. The
  Hub's two M.2 slots (PCIe 3.0 ×1) are now optional; a mirrored special
  vdev for pool metadata is the only worthwhile use, and it can wait.

**Storage headroom remains fixed** on the Hub: both SATA bays are
consumed by the 8TB mirror, so growing `tank` later means swapping
drives or adding a USB enclosure.

### If the mini PC purchase doesn't happen

The fallback is the single-node build: Proxmox on the F2-424 with a
32GB DDR5 SODIMM (~$70–110) and NVMe in its M.2 slots. It works, but on
four cores you run the isolated Windows pair *or* the analysis VM, not
both, and CPU-heavy jobs (plaso timelining, Volatility on large images,
GNU Radio demod chains) need an ephemeral cloud instance joined to the
tailnet. The two-node split exists to avoid all of that.

## Build checklist

1. Flash TrueNAS SCALE onto the F2-424; create the mirrored ZFS `tank`
   pool with the `forensic-images/`, `sdr-captures/`, and `vm-backups/`
   datasets.
2. Install Tailscale on the Hub, enable Tailscale SSH, advertise the home
   LAN subnet, and approve the route in the admin console. Confirm
   reachability from a phone on cellular data.
3. Stand up the SDR container on the Hub with the RTL-SDR mapped
   through; confirm a GNU Radio flowgraph on the laptop pulls samples
   over Tailscale. Add SpyServer for interactive use.
4. Install Proxmox VE on Forge, wiping Windows. Add NVMe if the bundled
   drive turned out to be M.2 SATA.
5. Create `vmbr1` with no physical uplink. Configure and test WoL from
   the Hub.
6. Build the analysis VM on `vmbr0`. Install the mobile-forensics
   toolchain, Claude Code, and a clone of this repository. Mount
   `forensic-images/` read-only over NFS.
7. Build the Windows Server 2022 eval VM and the Caldera Linux VM per
   `forensics/windows/00-lab-setup` — install tooling first, then move
   them to `vmbr1`. Verify from inside the Windows VM that `ping
   8.8.8.8` times out and DNS resolution fails.
8. Take golden snapshots of all three VMs; configure `vzdump` from Forge
   to the Hub's `vm-backups/` dataset.
9. Rehearse the evidence-out path: `dump-guest-memory` from the Windows
   VM, then open it with Volatility3 on the analysis VM — without ever
   giving the Windows VM a network route.
10. **(Independent of 1–9.)** OTA bring-up — antenna, tuner, orientation,
    the attenuator decision, and both clients. Full procedure and results
    log in **`ota_bringup.md`**; the measurement tool is
    **`ota-survey.sh`**. Short version: network before RF, measure before
    attenuating, and orient against KHON (RF 8) because it is the only
    station without margin to spare.

## Checkpoint

From a laptop on a hotel or cellular connection, with nothing forwarded
to the public internet: connect to Tailscale, SSH into the Hub, wake
Forge, RDP into the Windows DFIR VM, capture its RAM from the hypervisor
side, and have Claude Code on the analysis VM read the resulting
Volatility output alongside the relevant module README — while a
SpyServer client on the same laptop is simultaneously tuned to live
spectrum from the RTL-SDR at home. If all of that works, every module in
both `forensics/` and `satcom/` has a home.

## Parked hardware — Dell PowerEdge R720XD

Owned, working, and deliberately not deployed. The original plan racked
it outside the home office as an on-demand Proxmox host. What killed it:

- **No suitable location.** A garage or utility-closet mount needs a
  wired Ethernet drop, and pulling Cat6 through the house isn't
  worthwhile for this.
- **Hawaii atmospherics.** Salt air, humidity, and heat in an
  un-conditioned space are hard on a server, and a closet mount would
  need active ventilation on top of the depth and access problems (the
  chassis is ~27" bare, ~30" with bezel and PSU handles, needing ~36" of
  clear depth).
- **Power cost.** 150–450W at roughly $0.40/kWh — among the highest
  electricity rates in the US — against ~15W for either node above.
- **RAM cost.** 16GB is unusable for this workload and DDR3 RDIMM prices
  haven't cooperated.

Honest accounting: the dual E5-2620 pair is faster than the N95 in raw
multithreaded terms (roughly 8–9k vs ~5.4k Passmark). It is *not* faster
than the 7730U, which lands near 19–20k at a fraction of the power — so
once Forge exists, the R720XD has no performance argument left, only a
capacity one.

**Revive it when** there's a basement or conditioned utility space with
an existing wired drop, and DDR3 RDIMM prices come down. At that point
it would be a bulk-capacity or many-VM node, not a replacement for
either machine above. It would also need a 4-post open-frame rack (~12U,
adjustable depth to 36", casters) and ReadyRails matching the chassis
depth; none of that is worth buying until the space exists.
