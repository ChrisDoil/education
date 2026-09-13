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
- **Antenna placement.** A short USB extension and the kit dipole,
  window-mounted, per `satcom/00-hardware-and-tools` Tier 1.

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
