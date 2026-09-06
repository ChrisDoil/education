# Combined Lab — Architecture & Build Plan

A single physical lab that serves both `forensics/` (Windows DFIR VMs,
isolated attack-emulation network) and `satcom/` (RTL-SDR reception,
GNU Radio) curricula, while staying power-efficient and reachable by SSH
from home and while away.

See `current_hardware.md` for the as-purchased hardware list this plan is
built around.

## Design goals (from the ask)

1. Remote start — don't pay to keep the power-hungry box on 24/7.
2. Host and run multiple VMs for forensics testing (Windows DFIR + mobile
   forensics work).
3. SSH-reachable from home Wi-Fi and from anywhere else.
4. Run the SATCOM/SDR (RTL-SDR) work.

## Two-node split

The hardware naturally splits into an **always-on, low-power node** and an
**on-demand, high-power node**. Don't run everything on one box — the
Dell is too power-hungry (and loud) to leave on 24/7, but you need
*something* always reachable to wake it up, hold your VPN endpoint, and
babysit the SDR.

This split also settles a physical-placement decision: **Forge lives
outside the home office** (garage/basement/utility closet — see the
noise notes under Node 2), and **Hub lives in the home office** (quiet
enough to sit on a desk/shelf, and it's where you'd want local console
access anyway). You never need to be in the same room as Forge for
normal use — that's the entire point of the remote-start/Tailscale
design — only for the initial build and any future hardware changes.

| Node | Hardware | Role | Power state |
|---|---|---|---|
| **Hub** | TERRAMASTER F4-424 Pro (i3-N305, 32GB, 2×8TB WD Red Plus) | TrueNAS SCALE: storage, Tailscale endpoint/subnet router, SDR-over-IP server, WoL/iDRAC trigger | **Always on** (N305 idles in the ~10-20W range) |
| **Forge** | Dell PowerEdge R720XD (2× Xeon E5-2620, 16GB — needs RAM/drives, see gaps below) | Proxmox VE: all forensics VMs (Windows DFIR lab, Caldera, mobile forensics workstation) | **Off by default**, remotely powered on when needed |

```
                         ┌─────────────────────────┐
        Internet ───────►│   Tailscale (overlay)    │
                         └─────────────┬────────────┘
                                       │
                     ┌─────────────────┴─────────────────┐
                     │           Home LAN (Wi-Fi)          │
                     └───┬─────────────────────────┬──────┘
                         │                         │
              ┌──────────▼─────────┐    ┌──────────▼───────────┐
              │  Hub (TerraMaster)  │    │  Forge (R720XD)       │
              │  TrueNAS SCALE      │    │  Proxmox VE           │
              │  - Tailscale node   │    │  - iDRAC7 (mgmt NIC)  │
              │    + subnet router  │    │  - vmbr0: LAN uplink  │
              │  - rtl_tcp/Soapy    │    │  - vmbr1: ISOLATED    │
              │    (RTL-SDR host)   │    │    (no uplink at all) │
              │  - ZFS pool (2×8TB) │    │        │              │
              │  - WoL/racadm       │    │   ┌────┴────┐         │
              │    trigger scripts  │    │   │ Win DFIR │ Caldera │
              └─────────────────────┘    │   │  VM      │  VM    │
                                          │   └─────────┘         │
                                          └───────────────────────┘
```

## Node 1 — Hub (TerraMaster, always on)

Reflash to **TrueNAS SCALE** (bare metal, replaces stock TOS). This gets
you ZFS (checksummed pools — worth having under any forensic-image work,
even practice-grade) plus Docker apps and a KVM VM for anything that
needs to run continuously.

Responsibilities:

- **Storage.** 2×8TB WD Red Plus as a mirrored ZFS pool. Hosts:
  - `forensic-images/` — vetted practice images (NIST CFReDS, DFRWS
    challenge sets) for `forensics/mobile/`, hash-verified on download,
    shared read-only via NFS/SMB to whatever VM is doing the analysis.
  - `vm-backups/` — Proxmox backup target (`vzdump` over NFS/SSH) so
    golden snapshots of the DFIR VMs survive even if the R720XD's local
    array dies.
  - General SDR capture storage (IQ recordings, decoded SATCOM data from
    `satcom/08-sdr-gnuradio-labs`).
- **Tailscale endpoint + subnet router.** Install the Tailscale app,
  `tailscale up --advertise-routes=<home-LAN-CIDR> --ssh`. This is the
  one thing that makes "remote start" and "remote SSH" both work:
  - The `--ssh` flag turns on Tailscale SSH, so you authenticate via your
    Tailscale identity instead of managing SSH keys/fail2ban separately.
  - `--advertise-routes` (approved once in the Tailscale admin console)
    lets any device on your tailnet reach *other* LAN devices that don't
    run Tailscale themselves — specifically the R720XD's iDRAC interface,
    which has no Tailscale client of its own.
- **RTL-SDR host.** Plug the RTL-SDR into the NAS (via a short USB
  extension routed toward whatever window/antenna spot has the best
  sky view) and run `rtl_tcp` (or `SoapySDRServer` if you want
  SoapyRemote) as an always-on service/Docker container. GNU Radio
  flowgraphs — from a laptop, or from a VM on the R720XD when it's
  up — then use a `rtl_tcp` source block pointed at the Hub's Tailscale
  IP instead of needing the dongle plugged in locally. This decouples
  "where the antenna cable runs" from "where the DSP work happens" and
  means SATCOM reception labs work over Tailscale too, not just at home.
- **Remote-start trigger for Forge.** A small script (cron-callable or
  run ad hoc over Tailscale SSH) that powers on the R720XD:
  - Preferred: hit iDRAC's Redfish API or `racadm serveraction powerup`
    against the iDRAC IP — works from a full power-off state and doesn't
    depend on the host's NIC drivers/BIOS Wake-on-LAN settings.
  - Fallback: `wakeonlan <R720XD-NIC-MAC>` sent from the Hub (same L2
    segment, so a plain WoL magic packet works) if you'd rather not deal
    with iDRAC licensing/networking.

## Node 2 — Forge (Dell R720XD, on-demand)

Install **Proxmox VE** bare metal. (VMware's free ESXi tier no longer
exists post-Broadcom acquisition, so Proxmox is the obvious free choice
here — it also has better native snapshot ergonomics for the
"golden snapshot, roll back every module" workflow both forensics
curricula assume.)

Network config directly implements `forensics/windows/00-lab-setup`'s
isolation requirement:

- `vmbr0` — bridged to the home LAN, used only for Proxmox's own
  management access (reachable via the Hub's Tailscale subnet route).
- `vmbr1` — a Linux bridge with **no physical NIC attached at all**.
  This *is* the "host-only network with zero route to the internet or
  host LAN" the Windows DFIR module calls for — cleaner than VirtualBox's
  host-only adapter because there's no accidental host-side interface to
  misconfigure. Put the Windows Server 2022 eval VM and the Caldera Linux
  VM on `vmbr1` only.
- Verify isolation the same way the module's checkpoint asks: from inside
  the Windows VM, confirm `ping 8.8.8.8` times out and DNS resolution
  fails.

VM plan:

- **Windows DFIR lab VM** (Windows Server 2022 eval) + **Caldera Linux
  VM**, both on `vmbr1`, per `forensics/windows/00-lab-setup`.
- **Mobile forensics workstation VM** (Linux, on `vmbr0` since it just
  needs to reach the Hub's NFS share and the internet for tool updates —
  it isn't running attack emulation, so it doesn't need the isolated
  network).
- Golden snapshots for each, `vzdump` backups shipped to the Hub NFS
  share on a schedule.

Power/noise notes: R720XD-generation PowerEdge servers are dual-PSU,
dual-Xeon 2U boxes with small, high-RPM Delta fans — genuinely loud
(idle noise plus a much louder fan-ramp on every boot), not just
"server-room background hum." That's why it's powered off between
sessions rather than run as a second always-on box, and why **it's
racked outside the home office** (garage/basement/utility closet) —
an open-frame rack does nothing to dampen that noise, so location is
the actual fix, not the rack itself.

## Gaps to fill (not yet in `current_hardware.md`)

- **VM storage for the R720XD.** It's listed diskless with 16×2.5" bays
  and a PERC H710. The 2×8TB drives are 3.5" and belong in the
  TerraMaster, not here. Buy at minimum 2× SATA SSD (RAID1 via the H710)
  for Proxmox OS + VM datastore — 480GB–1TB each is plenty to start.
- **RAM for the R720XD.** 16GB is thin for hosting a Windows Server VM +
  a Linux Caldera VM + a mobile-forensics VM concurrently. Worth bumping
  to 64–128GB (cheap on the used market for DDR3 RDIMMs on this
  generation) before you're running more than one VM at a time.
- **iDRAC license check.** Confirm what iDRAC7 tier this unit has
  (Express vs. Enterprise). Express is enough for basic remote
  power on/off via `racadm`/Redfish, which is all this plan needs;
  Enterprise would additionally give you a remote virtual console/KVM,
  which is nice-to-have for out-of-band troubleshooting but not required.
- **Antenna placement for the RTL-SDR.** A short USB extension cable
  and a window-mounted dipole (per `satcom/00-hardware-and-tools` Tier 1)
  — not strictly "missing," just needs physical placement near the Hub.
- **A rack for the R720XD.** It's a 2U rackmount chassis with no rails
  or rack in the current inventory. Going with an **open-frame 4-post
  rack** (~12U is plenty for one 2U server plus room to grow) —
  cheapest option, best airflow. It does nothing to dampen fan noise,
  but that's fine since Forge is racked in the garage/basement/utility
  closet, not the office (see Node 2 above). You'll also want rails
  rated for the R720XD's depth (Dell ReadyRails or generic sliding
  rails matching its chassis depth), since the used listing's "missing
  accessories" note means rails likely weren't included.
- **A network drop to wherever Forge ends up.** Since it's relocating
  out of the office, run (or confirm you already have) wired Ethernet
  from your router/switch to that space — a rack server on Wi-Fi isn't
  a good idea for VM traffic, backups to the Hub, or iDRAC reliability.
  If pulling new Cat6 isn't practical, a MoCA or powerline bridge is a
  reasonable fallback, but plan for actual cable if you can.

## Build checklist

1. Flash TrueNAS SCALE onto the TerraMaster; create the mirrored ZFS pool
   on the 2×8TB drives.
2. Install Tailscale on the Hub, enable Tailscale SSH, advertise the home
   LAN subnet, and approve the route in the Tailscale admin console.
   Confirm you can reach the Hub's Tailscale IP from a phone on cellular
   data (i.e., genuinely "away," not just off Wi-Fi).
3. Stand up `rtl_tcp` on the Hub with the RTL-SDR attached; confirm a
   GNU Radio flowgraph on another machine can pull samples from it over
   the network (satisfies `satcom/00-hardware-and-tools`'s Tier 0/1
   checkpoint, just relocated to a network source block).
4. Confirm iDRAC network access on the R720XD and test a remote
   power-on via `racadm`/Redfish from the Hub; fall back to
   `wakeonlan` if iDRAC access isn't available yet.
5. Run/confirm a wired Ethernet drop to Forge's relocated spot
   (garage/basement/utility closet); buy and assemble the open-frame
   rack there and rail/mount the R720XD in it.
6. Buy/install the R720XD's VM-datastore SSDs (and RAM, if bumping it),
   configure RAID1 on the PERC H710, install Proxmox VE.
7. Create `vmbr1` with no physical uplink; build the Windows Server 2022
   eval VM and Caldera Linux VM on it per
   `forensics/windows/00-lab-setup`; verify no internet/LAN route from
   inside the Windows VM.
8. Configure Proxmox `vzdump` backups to the Hub's NFS share; take the
   golden snapshot once the Tier 2 toolchain is installed and smoke-tested.
9. Confirm the full remote path end-to-end: from cellular data →
   Tailscale → SSH into the Hub → trigger R720XD power-on → SSH into
   Proxmox → console into the Windows DFIR VM.

## Checkpoint

You can, starting from your phone on cellular data with the R720XD
powered off: connect to Tailscale, SSH into the Hub, remotely power on
the R720XD via iDRAC (or WoL), SSH into Proxmox once it's up, and reach
a running Windows DFIR VM console — while a GNU Radio flowgraph on a
laptop is simultaneously pulling live samples from the RTL-SDR over
`rtl_tcp` via the same Tailscale connection. If all of that works, every
module in both `forensics/` and `satcom/` has a home.
