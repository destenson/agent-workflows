# DEVICE.md — {target name}

The agent's operating map for the target. Loaded into context at session start by the embedded-target plugin. Keep it current; a stale map misleads diagnosis.

## Access
- Host/IP, user, ssh config alias; ControlMaster settings
- VS Code remote notes if relevant

## Harness commands
- One line each: what it does, expected duration, artifact location, exit-code meaning
- (Source of truth is `harness/`; this section is the quick reference.)

## Services & layout
- Service/unit names, restart commands, config paths, log paths
- Scratch dirs safe to clear in `device-reset.sh`

## Stack pins
- Python interpreter version (JetPack/L4T release), `uv` lockfile location
- GPU-stack package versions (torch, TensorRT bindings) — the NVIDIA Jetson builds for this L4T release
- Rust target triple, .deb package name, systemd unit name

## Constraints & safety
- Commands that must NOT be run (e.g. anything touching radio config / bricking risks)
- Disk/CPU/memory limits relevant to capture and logging
- Hard timeout values per command class (mirror harness/env.sh)

## Network
- Topology, peers, radio characteristics
- Data-plane interface name (`TARGET_IF` for faults/)
- Which conditions are injectable (faults/ scripts) vs. physical-only

## Known quirks
- Slow-boot behaviors, clock drift, flaky interfaces — anything that misleads diagnosis
