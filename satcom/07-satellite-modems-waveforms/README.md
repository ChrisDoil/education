# Module 07 — Satellite Modems & Waveforms

## Learning objectives

- Understand DVB-S/S2, the dominant real-world satellite broadcast/data
  standard, well enough to explain its framing, synchronization, and coding
  choices — this is the single most useful concrete waveform to know for
  SATCOM security work, since it's what most commercial satellite modems
  and a huge fraction of VSAT/broadcast traffic actually run.
- Understand, at least at a block-diagram level, how a real satellite modem
  (as opposed to your Module 05 toy implementation) is architected.
- Be able to receive and decode a real public satellite signal end to end.

## Prerequisites

Module 05 (digital comms/modulation/FEC) is required — DVB-S2 is
essentially a production-grade version of everything built there
(QPSK/8PSK/16APSK modulation, LDPC+BCH concatenated FEC, framing).

## Resources

- **DVB-S2 specification (ETSI EN 302 307)** — free from ETSI's document
  portal; dense but authoritative on framing, modulation/coding modes, and
  physical-layer signaling. Don't try to read it cover to cover — use it as
  a reference once you know what you're looking for from a secondary
  source.
- **"Digital Satellite Communications" by Giovanni Corazza (ed.) or
  similar system-level texts** — for a narrative explanation of DVB-S2
  design choices before diving into the raw spec.
- **Vendor whitepapers (Comtech, iDirect, Newtec)** — commercial VSAT modem
  vendors publish whitepapers explaining their modem architectures and
  waveform choices in more approachable language than the standards
  documents; useful for connecting theory to real deployed hardware.
- **gr-dvbs2rx** (GNU Radio out-of-tree module) — an open-source DVB-S2
  receiver implementation; reading its source/flowgraphs is one of the best
  ways to see a real DVB-S2 receive chain, and it's directly usable for the
  labs below.

## Hands-on labs

1. Diagram the DVB-S2 physical layer frame structure (PLFRAME: header,
   payload, pilot symbols) from the spec/secondary sources, and identify
   where each element you learned in Module 05 (modulation symbols, FEC
   parity, synchronization) shows up.
2. Using `gr-dvbs2rx` (or `leandvb`, a lighter alternative), attempt to
   receive and lock onto a real DVB-S2 signal — either a captured IQ file
   from a public source, or (if you have Tier 3 dish/LNB hardware) a live
   GEO broadcast satellite signal.
3. Compare a NOAA APT signal decode (analog FM, simple) against a DVB-S2
   decode (complex digital, requires full sync/FEC chain) to feel the
   difference in complexity between the two ends of the SATCOM waveform
   spectrum — you'll do the APT decode concretely in Module 08.
4. Identify, from public information, what waveform a specific commercial
   VSAT service (e.g. a known iDirect or Hughes network) uses, and compare
   its design choices against DVB-S2's.

## Checkpoint

You can explain DVB-S2's frame structure and why it uses variable coding
and modulation (VCM/ACM) to adapt to changing link conditions, and you've
successfully synced onto and decoded at least one real digital satellite
signal (even just to the frame-lock stage, without needing to decode
service-layer content). This module is the direct waveform-layer
prerequisite for Module 09's encryption discussion, since COMSEC in SATCOM
is implemented on top of exactly this kind of waveform.
