---
name: gst-lifetime-review
description: Diagnose or review GStreamer object-lifetime and threading bugs across the Python application and the Rust forked element — leaks per reconnect cycle, shutdown hangs, crashes mid-reconnect. Use for those symptoms, and as the review checklist for any change to the forked element's reconnection/task logic.
---

# Threads and object lifetimes

These bugs have two halves — Python application side and Rust element side — with confusingly similar symptoms (leaks per reconnect cycle, hangs at shutdown, crashes mid-reconnect). First job: tell them apart.

**Distinguishing Python-side from element-side leaks** (do this first; it's cheap): the `leaks` tracer reports C-level GStreamer objects alive at exit, but not *who* holds them. If it shows leaked elements, check Python first — `gc` inspection, or simply whether dropping the suspect Python references and forcing a collection releases them. Python-side leaks release; element-internal leaks survive that test.

## Python side: references and callbacks

- **A Python reference is a strong reference.** Anything a Python variable, list, or closure still points to stays alive after the pipeline goes NULL and is discarded. Reconnect logic that rebuilds pipelines while old callbacks, probe handles, or element references linger accumulates live C-side objects. Closures capturing pipeline objects can form Python/GObject reference cycles that collect late or never.
- **Callbacks arrive on GStreamer's threads, not yours.** Pad probes, `pad-added`, sync bus handlers run on the streaming thread that fired them. The GIL makes the interpreter safe to enter; it does not make *application state* handling safe, nor heavy work / state changes from inside the callback legal (that's the deadlock class, reached from Python). Discipline: callbacks record and hand off (`GLib.idle_add`, or push to a queue) and return immediately; pipeline manipulation happens on one designated thread.
- **Multiple Python threads on one element** are safe for individual property reads/writes (GStreamer locks those) but not for compound check-then-act sequences on pipeline state — that's a race regardless of the GIL.

## Rust element side: tasks spawned for reconnection

The fork's known weak area. These rules double as the review checklist for any change to the element:

1. **Tasks hold weak references to the element.** Cloning an element handle bumps a refcount; a task capturing a strong clone keeps the element alive as long as it runs — a task that never exits is an element that never disposes (leak per cycle), and if the element also stores the task handle, nothing ever frees. Capture a downgraded (weak) ref, upgrade per use, treat a failed upgrade as the exit signal.
2. **Teardown stops and joins every task it started.** The NULL state change is the contract point: when it returns, nothing spawned may still run. A reconnect task outliving teardown operates on a half-dead element (posting to an undrained bus, pushing into deflowed pads) — the "crash/hang during teardown" row. Cancellation must be *waited on*, not just signaled.
3. **One generation of tasks at a time.** A disconnect fires a new connection task while the old transport task still drains; two generations now touch shared session state. Cure: a generation counter / cancellation token per attempt, each task checking it belongs to the current generation before acting.
4. **Don't hold the element's locks across blocking points** (network await, pad push, state-change call) — invites lock-order deadlocks with GStreamer's streaming/state locks. Lock, copy, unlock, then block.

Each rule maps to an invariant the N-cycle reconnect repro checks mechanically: thread/task count back to baseline after every cycle, refcounts as expected, shutdown within a deadline (a hang at NULL is almost always a task join that never finishes). Field violations get a LESSONS.md entry naming the rule and how it presented — the symptom-to-rule mapping is the expensive part to rediscover.
