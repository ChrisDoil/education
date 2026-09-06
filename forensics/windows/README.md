# Windows DFIR & Anti-Forensics/Evasion Curriculum

A self-paced, hands-on path into digital forensics and incident response
(DFIR), focused specifically on how malware and APT-level tooling hide their
presence and capabilities on Windows systems — anti-forensics, defense
evasion, in-memory/fileless techniques, and kernel-level concealment — taught
from the investigator's side: for every hiding technique, the matching
detection method.

## Legal/ethics note (read first)

Everything in this curriculum runs inside an isolated, offline lab VM you
build in Module 00. Two rules keep this entirely safe and legal:

1. **Simulated TTPs only, never live malware.** Every "attack" in this
   curriculum is executed with Atomic Red Team or MITRE Caldera — open-source
   adversary-emulation frameworks that reproduce the *behavior* of real
   techniques (an ATT&CK technique ID, run safely) without ever introducing
   an actual malicious binary. You get the same forensic artifacts a real
   intrusion would leave, with none of the risk of handling live samples.
2. **Total lab isolation.** The lab VM(s) run on a host-only virtual network
   with no route to the internet or your host's LAN, and every module
   assumes you're working from a snapshot you can roll back. Module 00 covers
   setting this up and verifying it before anything else runs.

## How this repo is organized

Each numbered module is self-contained: `README.md` with **Learning
objectives → Prerequisites → Resources → Hands-on labs → Checkpoint**.
Modules are numbered in a suggested order, but some can run in parallel —
see the sequencing notes below. Add your own notes, parser output, and
timelines inside each module folder as you go; the repo is meant to grow
with you.

```
00-lab-setup/                 hypervisor, isolated Windows VM, tool install, golden snapshot
01-windows-forensic-fundamentals/  process/registry/NTFS/event-log model, core artifacts
02-timeline-artifact-analysis/     super-timelines, establishing a "normal" baseline
03-persistence-and-lolbins/        run keys, services, tasks, WMI, LOLBins
04-anti-forensics/            timestomping, log clearing/tampering, artifact wiping
05-process-injection/         hollowing, DLL injection, doppelgänging, reflective loading
06-memory-forensics/          Volatility3, hidden/injected code, unlinked processes
07-fileless-and-scripting-evasion/ PowerShell obfuscation, AMSI concepts, script logging
08-rootkit-concealment/       DKOM, driver hooking, EDR evasion — detection-focused
09-capstone/                  blind multi-stage Caldera intrusion + full investigation
```

## Suggested sequencing

- **00 → 01 → 02 → 03 → 04, in order.** Each of these builds tooling or
  vocabulary the next one assumes: you need the lab (00) and core artifact
  literacy (01) before timelines mean anything (02), and you need timeline
  skill before persistence-hunting (03) and anti-forensics detection (04)
  are more than vocabulary exercises.
- **05 and 06 in tandem.** Process injection (05) is best learned with live
  process inspection *and* a memory capture of the same injected process, so
  work these two together rather than strictly sequentially — inject, then
  immediately capture memory and analyze both.
- **07 after 03 and 06.** Fileless/scripting evasion combines persistence
  concepts (03) with the memory-resident mindset from 06.
- **08 after 06.** Rootkit concealment is a conceptual/detection extension
  of the memory-forensics skills from 06 — it leans on being comfortable
  reading kernel-object output before asking what's *missing* from it.
- **09 last, always.** The capstone assumes every prior module's tools and
  mental models.

## Checkpoint philosophy

Each module's Checkpoint section is a self-test, not a gate enforced by
anything — the point is to be honest with yourself about whether you can
*find and prove* the thing (in a live VM, a timeline, a memory image) before
moving on, not just recognize the vocabulary.
