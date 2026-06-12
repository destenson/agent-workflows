---
name: harness-setup
description: Build or fill in the build-deploy-run-collect harness for a remote embedded target — the scripted loop an agent drives unattended. Use when setting up a new device project or when harness commands are missing or hand-run.
---

# Harness setup

The write→compile→deploy→run→collect cycle stays hands-on only as long as it lives in someone's head. Every step becomes a script with machine-readable output; then an agent can drive the whole cycle unattended. Templates are in this plugin's `templates/harness/` (copied into the project by `/device-init`).

The command inventory, each returning a structured exit code and writing artifacts to a predictable location:

- `harness/build.sh` — cross-compile; nonzero on failure.
- `harness/deploy.sh` — language-aware (see Stack Policy below).
- `harness/run.sh <script>` — execute a repro/test on-device with a hard timeout; pull back exit code + stdout/stderr.
- `harness/collect-diag.sh` — bundle journalctl, dmesg, app logs, counters, version info, recent pcap ring window → one timestamped tarball.
- `harness/device-reset.sh` — restore known state; run before every repro.
- `harness/backtrace.sh` — non-interactive crash analysis (`gdb -batch` / gdbserver) → text backtrace.
- `harness/loop.sh <repro>` — build → deploy → device-reset → run → collect-diag. The single command the agent iterates with.

Requirements that make these agent-compatible:
- **Hard timeouts everywhere.** A device hang must fail the run, never stall the caller.
- **Cores enabled on-device**; `backtrace.sh` makes crashes yield text, not an interactive session.
- **Idempotent reset.** Without reset-before-run, agent-driven runs drift and chase their own residue.

## Stack policy (Jetson / systemd / Rust + Python)
- **Python: the device is the only runtime.** JetPack pins the interpreter and the CUDA/cuDNN/TensorRT stack to the L4T release; a laptop can't replicate it. Edit locally, execute via `harness/run.sh`. `uv` with a committed lockfile; `uv sync` on-device is a deploy step. Pin GPU-stack packages to the NVIDIA Jetson builds; record them in DEVICE.md.
- **Rust: one artifact, properly installed.** Cross-compile to aarch64, ship as a `.deb` (`cargo-deb`), `dpkg -i`, systemd unit in the package — so the debugged artifact is byte-identical to production. Verification ladder, cheapest first: (1) `cargo check`/`cargo test` on host for hardware-independent logic; (2) on-device `harness/loop.sh` only for environment- and hardware-dependent behavior.
- **Diagnostics packaging: split .debs.** `myapp.deb` lean for production; `myapp-diag.deb` (siphon, episodic-capture watcher, fault scripts, analysis helpers) only on dev/in-test devices, never on deployed units. The per-bug part (watcher signatures) is config in `signatures.d/`, outside the package.
