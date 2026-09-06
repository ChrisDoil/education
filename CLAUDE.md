# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

This is not a software project — it's a personal, self-paced learning repository containing hands-on technical curricula as Markdown. There is no build, lint, or test tooling, and no source code to compile or run. Work here means writing/editing curriculum content (READMEs, notes) or, when the user is actively doing a lab, helping them with the commands/config/code for that lab in place (which may itself involve real tools like Volatility3, GNU Radio, Atomic Red Team, etc., depending on the module).

Three curricula currently exist:

- **`forensics/windows/`** — Windows DFIR & Anti-Forensics/Evasion Curriculum. Detection-focused: for every adversary hiding technique taught, the matching investigator-side detection method.
- **`forensics/mobile/`** — Mobile Device Forensics Curriculum. Android and iOS acquisition, artifact analysis, app/cloud forensics, and stalkerware/spyware detection. Purely technical for now (explicitly, per the user) — the eventual goal is a private mobile forensics practice, but licensing, chain-of-custody, and business content are deliberately out of scope until a later phase.
- **`satcom/`** — SATCOM Security Learning Curriculum. Goes from software/security background with weak RF knowledge up through orbital mechanics, digital comms theory, satellite modems/waveforms, and COMSEC, using amateur-affordable gear (SDR dongles, ham radio, budget spectrum analyzer).

`forensics/` itself is just a parent grouping directory with a short index `README.md` (no legal/ethics content or modules of its own) — the two forensics curricula underneath it are otherwise identical in structure/independence to `satcom/`.

`networking/` exists but is currently empty — likely a future curriculum track, not yet started.

Each curriculum (`forensics/windows/`, `forensics/mobile/`, `satcom/`) has its own top-level `README.md` covering scope, a legal/ethics note, module list, and suggested sequencing — read those before making structural changes to a curriculum. When drafting new module content in any curriculum, match the existing modules' level of specificity (named tools/texts/commands, numbered hands-on labs, a concrete self-test checkpoint) rather than writing generic placeholders.

## Structure convention

All three curricula follow the same pattern, and any new module or curriculum added should match it:

- Modules are numbered directories (`00-...`, `01-...`, ...) reflecting a suggested but not strictly linear order — top-level READMEs document which modules are parallelizable vs. strictly sequential.
- Every module directory has its own self-contained `README.md` structured as: **Learning objectives → Prerequisites → Resources → Hands-on labs → Checkpoint**.
- Checkpoints are self-tests, not enforced gates — the point is proving you can *do* the thing (derive it, compute it, decode it, find it), not just recognize the vocabulary.
- Module folders are meant to accumulate the user's own notes, code, parser output, timelines, and captures as they work through labs — don't treat a module directory as read-only reference material.

## Legal/ethics constraints (all three curricula)

Each curriculum's top-level README has a legal/ethics section that materially constrains what labs should do — read it before helping with hands-on work in that track:

- **`forensics/windows/`**: all labs run inside an isolated, offline lab VM (built in module `00-lab-setup`) with no route to the internet or host LAN. Attacks are simulated via Atomic Red Team or MITRE Caldera (ATT&CK technique emulation) — never live/real malware.
- **`satcom/`**: RF spectrum is regulated. Labs before module `03-ham-radio-license` are receive-only and require no license. Transmitting requires the amateur license covered in module 03. Module `10-satcom-security-research` covers the legal boundary between passive signal analysis and decoding communications content not intended for the recipient (wiretap-law territory) — relevant as soon as any real-world (non-lab) signal hunting starts, not just at that module.
- **`forensics/mobile/`**: only examine devices/accounts the user owns outright and populates themselves with synthetic "known-answer" test data — never a real third party's device or account. Practice data must come from vetted sources (NIST CFReDS, DFRWS challenge images) since unvetted "recovered" mobile data dumps carry real-privacy and even CSAM risk. Offering these services commercially requires licensing (often a PI license) and chain-of-custody rigor not yet covered in this curriculum — don't suggest this content is sufficient for real client work.

When assisting with lab work, keep suggestions inside these boundaries (e.g., don't propose live malware samples, real-network transmission, or decoding third-party traffic) even if not explicitly re-stated in the specific module.
