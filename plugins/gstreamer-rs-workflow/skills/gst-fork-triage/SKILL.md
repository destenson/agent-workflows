---
name: gst-fork-triage
description: Apply fork policy before debugging the forked gstreamer-rs element (rtspsrc2) — check upstream first, verify the running binary is ours, and decide whether recovery logic should move from the Python workaround down into the element. Use when a bug is suspected in the forked element or before migrating an app-level workaround.
---

# Fork policy (gst-plugins-rs)

The forked element is the one component whose internals we control — so it's the most likely home of our bugs, and where recovery behavior should ultimately live. Its known weak area is task/lifetime discipline (`gst-lifetime-review` is the first checklist to apply, before suspecting protocol logic).

Before and during a fork bug hunt:

- **Check upstream first.** The fork tracks upstream gst-plugins-rs, where `rtspsrc2` is under active development. Check upstream's log and merge requests for the area before debugging: the bug may already be fixed, or upstream may have grown its own version of a forked feature — in which case rebasing onto it and dropping our copy beats fixing and carrying ours. Keep a short record (FORK.md or DECISIONS.md) of what the fork adds, why, and each piece's upstream status; pieces with no fork-specific coupling get submitted upstream to shrink what we maintain.
- **Verify the binary is ours before believing any result.** The plugin's version string carries `git describe`, injected at build time; `plugin-check.sh` asserts it after deploy and before each repro. Three independent causes make you debug an old binary while believing it's new: `GST_PLUGIN_PATH` search-path ordering, a distro-packaged copy shadowing ours, and a stale registry cache at `~/.cache/gstreamer-1.0/`. This is a hard gate, not a habit.
- **Build the one crate, not the tree.** Only the workspace member with our element is built and shipped. Cross builds resolve GStreamer via pkg-config, so they need a sysroot with the *device's* GStreamer dev packages, and the gstreamer-rs version feature flags (`v1_16`, `v1_20`, …) must not exceed the device's GStreamer version — newer APIs can fail to load or misbehave subtly. Set from DEVICE.md; enforce in the build script.
- **Move recovery logic down into the element, deliberately.** An app-level Python workaround is a legitimate mitigation but also evidence: it proves the element fails its contract under some condition. The element is the right home for recovery — it owns the transport, RTP session, and timers, so it can rebuild a connection in place where the app can only tear down and rebuild around a black box. Each workaround gets: a LESSONS.md entry (trigger + what it does), a repro derived from its trigger, and a migration task whose acceptance criterion is the workaround's own behavior — implemented in the element, verified by the repro, after which the Python crutch is removed and the repro stays in the regression suite.
