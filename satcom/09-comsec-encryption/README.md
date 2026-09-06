# Module 09 — COMSEC & Encryption for SATCOM

## Learning objectives

- Understand the vocabulary and concepts of COMSEC (Communications
  Security) and TRANSEC (Transmission Security) as distinct from ordinary
  network encryption — what problem each solves in a SATCOM context.
- Understand, at a conceptual/architectural level, how dedicated encryption
  devices are integrated into a satellite link (in-line bulk encryptors,
  key management), without needing (or being able to legally obtain)
  classified implementation details.
- Understand a real, legally-studyable satellite encryption system in
  depth: DVB-CSA (satellite/cable TV conditional access), as a concrete
  stand-in for the broader class of problems.
- Understand the specific challenges of running standard IP-layer
  encryption (TLS, IPsec) over satellite links.

## Prerequisites

Module 07 (satellite modems/waveforms) — COMSEC in SATCOM is implemented
as a layer on top of the modem/waveform, so understanding the waveform
first is what makes the encryption layer make sense architecturally.

## Scope note

This module deliberately stays at the unclassified, conceptual/public-
information level throughout. Military/government Type 1 satellite
encryptors (the KG/KIV device families and similar) are classified or
controlled systems — this curriculum covers *what problem they solve and
roughly how COMSEC architecture works*, using public unclassified
overviews, not implementation details, which aren't publicly available
and shouldn't be sought out.

## Resources

- **NSA/CSS public COMSEC overview materials** — the NSA publishes some
  unclassified explanatory material on COMSEC concepts (key management
  hierarchy, red/black separation, the general idea of Type 1 encryption)
  aimed at a general audience; useful for vocabulary and high-level
  architecture, not implementation.
- **"Red/black" architecture as a general concept** — widely documented in
  unclassified information-security literature (the separation between
  plaintext "red" and encrypted "black" signal domains); worth
  understanding since it recurs across COMSEC system design generally, not
  just satellite-specific systems.
- **DVB Common Scrambling Algorithm (DVB-CSA) public documentation and
  academic cryptanalysis papers** — DVB-CSA is a real, deployed, and
  publicly analyzed encryption scheme protecting satellite/cable TV
  conditional access; multiple academic papers exist on its (weak, by
  modern standards) cryptographic design and historical attacks against
  it, making it an excellent legal case study in "how does encryption
  actually get bolted onto a broadcast satellite waveform."
- **RFC 2401 and successors (IPsec architecture), and general TLS/DTLS
  literature** — for understanding standard IP-layer crypto, which is what
  most modern commercial VSAT/satellite-internet traffic actually relies
  on above the modem layer.
- **Published research/whitepapers on satellite-link performance-enhancing
  proxies (PEPs) and how they interact badly with end-to-end encryption**
  — satellite links have unusually high latency and often asymmetric
  paths; TCP PEPs used to compensate for this historically conflicted with
  end-to-end TLS, which is a well-documented, genuinely satellite-specific
  security/performance tradeoff worth understanding.

## Hands-on labs

1. Diagram the red/black separation concept for a generic satellite ground
   terminal: where does plaintext traffic enter, where does the encryptor
   sit, what crosses the RF boundary — and map this onto the modem
   architecture from Module 07.
2. Read at least one academic cryptanalysis paper on DVB-CSA and summarize,
   in your own words, what made the original algorithm weak and how it was
   eventually broken in practice.
3. Set up a simple TLS connection over a deliberately high-latency,
   lossy simulated link (e.g. using `tc netem` on Linux to inject latency/
   loss) and observe handshake and throughput behavior — this builds real
   intuition for why satellite links historically needed special handling
   (PEPs) that plain end-to-end encryption complicates.
4. Research and summarize, from public sources only, how a specific
   commercial VSAT provider describes its encryption/security posture
   (many publish high-level security whitepapers for enterprise
   customers) — compare it against the conceptual red/black model from
   lab 1.

## Checkpoint

You can explain the difference between COMSEC and TRANSEC, describe
red/black separation, and can discuss DVB-CSA's design and historical
weaknesses in specific technical detail (not just "it was broken"). You
understand why satellite links' latency/asymmetry characteristics create
real tension with straightforward end-to-end encryption deployment. This
sets up Module 10, where these concepts meet real-world documented
SATCOM security incidents.
