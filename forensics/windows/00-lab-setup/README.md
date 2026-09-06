# Module 00 — Lab Setup

## Learning objectives

- Have an isolated Windows VM lab, verified to have zero network route to
  the internet or your host LAN, that every later module runs against.
- Have the full analysis toolchain installed and smoke-tested before you
  need it mid-lab.
- Have a "golden snapshot" to roll back to after every module's exercises.

## Prerequisites

None — this is the starting point. Basic comfort with a hypervisor and
Windows administration is assumed.

## Tool set, by tier

### Tier 0 — hypervisor & OS

- **VirtualBox** or **VMware Workstation Pro** (free for personal use) —
  either works fine; Workstation Pro has slightly better snapshot UX,
  VirtualBox is fully free and open source.
- **Windows Server 2022 evaluation ISO** (Microsoft Evaluation Center,
  180-day eval) — preferred over a Windows 10/11 eval (90 days) purely for
  the longer license window given how long this curriculum runs. Either
  works technically; adjust artifact expectations slightly (Server has some
  different defaults) if you use client Windows instead.
- A second, small **Linux VM** on the same isolated network to host
  **MITRE Caldera**'s server component (used from Module 03 onward).

### Tier 1 — isolation & snapshotting

- Configure the hypervisor's virtual network as **host-only** (VirtualBox:
  "Host-only Adapter"; VMware: a custom isolated vSwitch with no NAT/bridge).
  Both the Windows VM and the Caldera Linux VM sit on this network so Caldera
  can reach its agent, but nothing reaches the internet or your real LAN.
- Snapshot immediately after each meaningful setup step, and always
  **before** running anything from Modules 03 onward — you'll want to roll
  back to a clean state between labs.

### Tier 2 — analysis toolchain (install on the Windows VM unless noted)

- **Sysmon** with a solid public config (SwiftOnSecurity's or Olaf Hartong's
  modular config) — the single highest-value install in this curriculum;
  nearly every later module leans on Sysmon logs.
- **Eric Zimmerman's tools** (via `Get-ZimmermanTools.ps1`) — MFTECmd,
  RegistryExplorer, AmcacheParser, AppCompatCacheParser, PECmd, JLECmd,
  Timeline Explorer, and friends.
- **KAPE** — targeted artifact collection + the KapeFiles target/module
  definitions.
- **Volatility3** — memory forensics (Module 06 onward); install on either
  the Windows VM or your host, since it analyzes memory *images*, not live
  memory.
- **Autopsy** + **FTK Imager** (free) — disk imaging and case-file
  organization.
- **PE-sieve** and **Moneta** — in-memory injection detection (Module 05).
- **System Informer** (spiritual successor to Process Hacker) — live
  process/handle/memory inspection.
- **Autoruns** (Sysinternals) — persistence enumeration (Module 03).
- **Atomic Red Team** (`invoke-atomicredteam` PowerShell module + the
  `atomics` technique library) — safe, scoped technique simulation.
- **MITRE Caldera** — installed on the Linux VM; runs the multi-stage
  adversary emulation used from Module 03 through the Module 09 capstone.

## Resources

- Microsoft Evaluation Center (search "Windows Server evaluation ISO") —
  official, legal source for the eval image.
- Eric Zimmerman's tools documentation and blog (ericzimmerman.github.io) —
  the reference for every EZ tool used in this curriculum.
- KapeFiles GitHub repo — target/module definitions, and good reading for
  what artifacts KAPE considers worth collecting and why.
- Atomic Red Team GitHub (`redcanaryco/atomic-red-team`) — technique
  library, organized by ATT&CK ID.
- MITRE Caldera documentation — server setup, agent deployment, adversary
  profile authoring.

## Hands-on labs

1. Install the hypervisor, install Windows Server 2022 (eval) into a VM on a
   host-only network, and confirm from inside the guest that internet access
   fails (e.g., `ping 8.8.8.8` times out, no DNS resolution).
2. Install and configure Sysmon; confirm events are landing in
   `Microsoft-Windows-Sysmon/Operational`.
3. Install the full Tier 2 toolchain and smoke-test each: run MFTECmd
   against `C:\$MFT`, open Autoruns and confirm it enumerates entries,
   confirm PE-sieve/Moneta launch and scan a benign process without error.
4. Stand up the Linux VM, install Caldera, and confirm a Sandcat agent
   deployed to the Windows VM successfully checks in.
5. Take the **golden snapshot** once everything above is confirmed working.

## Checkpoint

From a clean boot of the lab VM: network isolation is verified (no internet,
no host-LAN route), Sysmon events are flowing, every Tier 2 tool launches and
runs against trivial input without error, a Caldera agent is checked in, and
you have a golden snapshot saved. If all of that's true, every later module
is unblocked.
