# Module 07 — Fileless & Scripting Evasion

## Learning objectives

- Recognize common PowerShell obfuscation patterns used to evade static
  detection and casual log review.
- Understand AMSI's role and how bypasses conceptually work — at a
  detection-focused level, not as a weaponization exercise.
- Know exactly which logging (ScriptBlock logging, Module logging) plus
  Sysmon events reconstruct fileless execution that never touches disk.

## Prerequisites

Module 03 (persistence/execution concepts) and Module 06 (memory-resident
mindset).

## Resources

- **MITRE ATT&CK T1027 (Obfuscated Files or Information)** and **T1620
  (Reflective Code Loading)**.
- Microsoft's own **PowerShell ScriptBlock logging** documentation — how it
  works and what it captures even through several layers of obfuscation.
- Public **Mandiant/FireEye blog** write-ups on PowerShell-based APT
  tradecraft (search their blog for "PowerShell" case studies) — real-world
  grounding for the patterns you're studying.
- Atomic Red Team atomics for obfuscated PowerShell execution.

## Hands-on labs

1. Enable ScriptBlock logging, Module logging, and Sysmon on the lab VM
   (some of this may already be on from Module 00 — confirm all three).
2. Run an Atomic Red Team obfuscated-PowerShell atomic; find the
   deobfuscated content that Windows itself recovers via Event ID 4104
   (ScriptBlock logging), even though the on-disk/on-the-wire form was
   obfuscated.
3. Correlate Sysmon Event ID 1 (process creation) with the 4104 events to
   reconstruct the full execution chain of a fileless attack: what spawned
   PowerShell, what it ran, and what it did — without a single new file
   touching disk.

## Checkpoint

Given a scripted attack run blind, can you reconstruct exactly what the
PowerShell executed purely from logs, even though the payload never touched
disk?
