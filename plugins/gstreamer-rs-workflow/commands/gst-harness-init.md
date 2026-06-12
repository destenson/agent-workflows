---
description: Copy the GStreamer harness and RTSP fault-server contract stubs into the project for implementation.
---

Copy the contract stubs from `${CLAUDE_PLUGIN_ROOT}/templates/harness/` into the project's `harness/` directory and `${CLAUDE_PLUGIN_ROOT}/templates/faults/` into the project's `faults/` directory. For any file that already exists in the destination, leave it untouched and report it as skipped — never overwrite a real implementation with a stub.

These are **contracts, not implementations**: each stub documents its arguments, exit-code meaning, and artifact location in a header comment, and exits non-zero with "TODO: implement" until filled in. They extend the embedded workflow's `harness/` inventory (build/deploy/run/collect-diag/device-reset/backtrace/loop) with the GStreamer-specific additions, and add the RTSP fault server. Implement them per project against the real application's control endpoint and the device's GStreamer version.

After copying, report which files were created and which were skipped, and remind the user that `harness/plugin-check.sh` and the fault scripts should be added to the agent permission allowlist so host-tier iteration runs unattended.
