# Module 05 — Process Injection & In-Memory Evasion

## Learning objectives

- Understand the mechanics of the major process-injection techniques used
  to hide malicious code inside a legitimate process: process hollowing,
  DLL injection, process doppelgänging, and reflective DLL loading.
- Be able to recognize the memory-level fingerprint each technique leaves
  behind, live, on a running system.

## Prerequisites

Module 01 (process/thread model). Work this module in tandem with Module 06
— injecting live and then immediately capturing memory of the same process
reinforces both.

## Resources

- **MITRE ATT&CK T1055 (Process Injection)** and its subtechniques.
- **"Practical Malware Analysis" (Sikorski & Honig)** — the code-injection
  chapters.
- **hasherezade's blog** (author of PE-sieve and Moneta) — detailed,
  practitioner-level write-ups of injection techniques and how her tools
  detect them; the most directly applicable resource for this module.
- Atomic Red Team atomics for T1055 subtechniques.

## Hands-on labs

1. From the golden snapshot, run an Atomic Red Team T1055 atomic (a
   hollowing or injection variant) against a benign target process.
2. Scan the resulting process with **PE-sieve** and **Moneta**; correctly
   identify the injected memory region and name the injection technique
   from the tool output.
3. Use **System Informer** to compare the injected process's parent/child
   relationship and memory-region layout against a clean instance of the
   same process — note the anomalies that gave it away independent of the
   scanner output.
4. Immediately capture memory of the injected process (feeds directly into
   Module 06) before rolling back the snapshot.

## Checkpoint

Given a live lab VM with an unknown T1055 atomic run against it, can you
find the injected process and correctly name the injection technique using
PE-sieve/Moneta output alone, without being told what ran?
