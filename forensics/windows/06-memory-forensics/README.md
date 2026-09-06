# Module 06 — Memory Forensics

## Learning objectives

- Acquire and analyze a memory image with Volatility3.
- Find injected/hidden code and unlinked processes from a memory image
  alone, with no live access to the system — connecting directly to what
  you found live in Module 05.

## Prerequisites

Module 05 — ideally worked in tandem, using the memory capture from that
module's labs.

## Resources

- **"The Art of Memory Forensics" (Ligh, Case, Levy, Walters)** — the
  canonical text for this entire module; read the process/injection
  detection chapters closely.
- **Volatility3 documentation** and plugin reference.
- **13Cubed** (YouTube, free) — memory forensics walkthroughs, including
  Volatility3-specific content.

## Hands-on labs

1. Acquire a memory image of the lab VM mid-injection (WinPmem or
   equivalent) — reuse the capture from Module 05's last lab if you have it.
2. Run `windows.pslist`, `windows.psscan`, and `windows.pstree` in
   Volatility3; identify any process visible in `psscan` but not `pslist` —
   a classic sign of a process attempting to unlink itself from the active
   process list.
3. Run `windows.malfind` to locate injected memory regions; compare the
   result against the live PE-sieve/Moneta findings from Module 05 — do
   they agree?
4. Dump and hash the injected code region for reference.

## Checkpoint

From a memory image alone — no live access to the system it came from —
can you identify an injected process and extract the injected code?
