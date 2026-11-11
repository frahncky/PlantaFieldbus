# Investigation handoff

When new evidence is added, follow `docs/automation-plan.md` in order. Prefer REA for shipped binaries and retained PCAP analysis. Record each conclusion as observed, inferred, or unknown, including evidence IDs and hashes.

Do not execute the System302 payload, scan the plant, change the network
configuration, or send PLC commands during investigation and protocol
discovery. Stop after phase 3 until a human approves the inferred protocol and
adapter design.

PLC state changes, including RUN/HOLD, remain disabled by default. They may be
implemented only as a separate commissioning activity after all of the
following are recorded: explicit authorization for the specific controller,
validated vendor protocol and compatible adapter, verified controller
project/backup, reviewed I/O and interlock mapping, an on-site operator with an
accessible emergency stop, and an auditable dry-run/test procedure. Approval
of this repository change alone is not authorization to transmit a command.
