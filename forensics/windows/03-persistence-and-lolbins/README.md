# Module 03 — Persistence & Living-off-the-Land

## Learning objectives

- Know the major persistence categories APTs use on Windows: registry run
  keys, services, scheduled tasks, and WMI event subscriptions.
- Understand Living-off-the-Land binaries (LOLBins) — legitimate,
  signed Windows binaries abused to execute or hide malicious behavior — and
  how to recognize their abuse rather than their mere presence.

## Prerequisites

Modules 00–02 (lab, artifact literacy, timeline/baseline skill).

## Resources

- **MITRE ATT&CK Persistence tactic (TA0003)** — the technique matrix this
  whole module is organized around.
- **LOLBAS project** (lolbas-project.github.io) — the canonical catalog of
  living-off-the-land binaries, scripts, and libraries, with abuse examples.
- **SANS "Hunt Evil" poster** (free PDF) — persistence-focused hunting
  reference.
- **Sysinternals Autoruns** documentation — what it enumerates and, just as
  important, what it doesn't.
- Atomic Red Team atomics for T1547 (Boot/Logon Autostart), T1053
  (Scheduled Task/Job), and T1546 (Event-Triggered Execution, incl. WMI).

## Hands-on labs

1. From the golden snapshot, run several Atomic Red Team persistence
   atomics against the lab VM: a registry run-key atomic (T1547.001), a
   scheduled-task atomic (T1053.005), and a WMI event-subscription atomic
   (T1546.003).
2. Run Autoruns over the VM and correctly flag the atomics you just ran
   against the noise of legitimate autostart entries. Cross-reference each
   flagged entry against your Module 02 baseline to confirm it's new.
3. Use the timeline from Module 02's tooling to establish exactly when each
   persistence mechanism was added, and what process created it.
4. Pick 2–3 real LOLBins from LOLBAS (e.g., `mshta.exe`, `regsvr32.exe`,
   `certutil.exe`) and research how each has been abused for execution or
   download in real intrusions; note what a LOLBin abuse looks like in
   Sysmon process-creation logs vs. its legitimate use.

## Checkpoint

Given a lab VM with several unlabeled Atomic Red Team persistence atomics
run against it, blind (without being told which ran), can you find and
correctly categorize all of them using Autoruns plus your timeline?
