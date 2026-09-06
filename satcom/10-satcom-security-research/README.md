# Module 10 — SATCOM Security Research & Hardening

## Learning objectives

- Survey the significant public research on satellite communications
  security, and be able to explain the technical substance of the major
  findings (not just headlines).
- Understand current, practical SATCOM hardening guidance from
  standards/regulatory bodies.
- Understand clearly where the legal line sits between passive signal
  analysis and activity that crosses into wiretap-law or unauthorized-
  access territory — this section should be read early, not saved for
  last, if you start doing any real-world signal hunting outside this
  repo's labs.

## Prerequisites

This module is the synthesis point — it draws on all prior modules,
especially 07 (modems/waveforms) and 09 (COMSEC/encryption). Work through
those first so the research here reads as confirmation/extension of
concepts you already have, not as new vocabulary.

## Resources — public research to read

- **Ruben Santamarta (IOActive), "A Wake-up Call for SATCOM Security"**
  (and follow-up work) — foundational public research on vulnerabilities
  in commercial satellite terminal firmware (VSAT/BGAN/maritime/aviation
  terminals); the original Black Hat presentation and IOActive's published
  whitepaper are both public.
- **James Pavur (Oxford), published research and conference talks on GEO
  satellite broadband eavesdropping** — demonstrated that a large amount
  of real-world satellite internet traffic (from consumer/maritime/
  aviation VSAT links) is broadcast unencrypted and can be received with
  cheap equipment; directly relevant given this curriculum's hardware
  tier. Look for his DEF CON/Black Hat talks and academic papers
  (including work with Ivan Martinovic's group at Oxford).
  Note: this research is explicitly framed as receive-only, passive
  academic work done under specific ethical/legal review — read how the
  researchers scoped their own legality before treating it as a template.
- **DEF CON SATCOM village talks** (recorded talks are typically posted
  publicly after the conference) — an ongoing venue specifically for
  SATCOM security research; browsing recent years' talk lists is a good
  way to find current work.
- **CISA / national CERT advisories on satellite/SATCOM systems** — for
  more recent, operationally-focused vulnerability disclosures (e.g. the
  2022 Viasat KA-SAT incident during the Russia-Ukraine conflict received
  extensive public technical analysis from multiple firms and is a good
  case study in real-world SATCOM security impact).

## Resources — hardening guidance

- **CISA/NSA joint guidance on SATCOM security** — US government agencies
  have published joint cybersecurity advisories specifically about
  securing SATCOM networks, aimed at operators; useful as a checklist of
  what "good" looks like from a defender's perspective.
- **Vendor security advisories from VSAT/terminal manufacturers**
  (Hughes, Viasat, iDirect, etc.) — reading how vendors respond to
  disclosed vulnerabilities (patch cadence, architecture changes) is
  informative alongside the original research.

## Hands-on / research exercises

1. Pick one Santamarta/IOActive finding and reproduce the *analysis*, not
   the exploit: read the original firmware/protocol documentation
   referenced (where public) and confirm you understand the vulnerability
   class (e.g. hardcoded credentials, insecure update mechanisms) well
   enough to explain it to someone else.
2. Write a short technical summary of the Viasat KA-SAT incident: what
   was attacked, how, and what the publicly documented root cause was —
   use it as a case study connecting Module 09's COMSEC concepts to a
   real operational failure.
3. Using only your Tier 1/3 receive-only hardware and skills from Module
   08, and staying strictly within the legal/ethics boundaries below,
   observe what unencrypted vs. encrypted traffic looks like at the
   signal level on any public/legal signal you can identify (e.g. compare
   a plaintext NOAA APT transmission against an encrypted DVB
   conditional-access broadcast) — the point is building the instinct
   to visually/spectrally distinguish "this is designed to be public" from
   "this expects protection," which is exactly the instinct the published
   researchers describe developing.
4. Draft your own short "hardening checklist" for a hypothetical VSAT
   deployment, drawing on the CISA/NSA guidance and the failure modes from
   the research above — a good exercise for consolidating the whole
   curriculum into something practically usable.

## Legal & ethics boundary (important)

- **Passive spectrum monitoring and signal analysis** (looking at what
  frequencies are in use, signal strength, modulation type, whether a
  signal appears encrypted) is generally legal receive-only activity in
  most jurisdictions, including the labs throughout this curriculum.
- **Decoding the content of communications not intended for you** —
  actually reading traffic, messages, or data carried by a signal you're
  not an intended recipient of — is where things cross into wiretap-law
  territory in the US (and equivalent laws elsewhere) even if the
  underlying signal is unencrypted and technically easy to decode.
  Published academic research in this space (like Pavur's) was done under
  institutional ethical review and specific legal analysis for their
  jurisdiction — that framework is part of what makes it legitimate
  research rather than something else, and it isn't a blanket permission
  slip.
- **Never transmit without a license** for the band/service in question
  (Module 03 covers getting licensed for the bands this curriculum uses).
- When in doubt about a specific activity's legality in your jurisdiction,
  treat "receive-only, don't look at content, don't transmit unlicensed"
  as the safe default, and research the specific legal framework (e.g. in
  the US, the Wiretap Act and FCC regulations) before doing anything that
  goes beyond it.

## Checkpoint

You can explain at least two major public SATCOM security research
findings in technical depth, connect them back to the COMSEC/waveform
concepts from Modules 07 and 09, and can clearly articulate — for your own
jurisdiction — where passive research ends and legally risky activity
begins. This is the intended capstone of the curriculum: informed,
legally-grounded understanding of how satellite communications systems
actually fail and how they're hardened against it.
