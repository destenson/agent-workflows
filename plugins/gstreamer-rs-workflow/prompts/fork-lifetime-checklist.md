--- FORKED ELEMENT — task/object-lifetime checklist (gstreamer-rs-workflow) ---
This file is in the forked element, the fork's known weak area. Before changing reconnection or task-spawning logic, confirm the change honors these rules:

1. Tasks hold WEAK references to the element (downgrade on capture, upgrade per use, treat a failed upgrade as the exit signal). A strong clone in a task that never exits is a leak-per-reconnect-cycle.
2. Teardown stops AND joins every task it started. The NULL state change is the contract point: when it returns, nothing the element spawned is still running. Cancellation must be waited on, not just signaled.
3. One generation of tasks at a time. A generation counter / cancellation token per connection attempt; each task checks it belongs to the current generation before acting. This is the reconnect race the fault-server timing sweeps exist to flush out.
4. Don't hold the element's locks across blocking points (network await, pad push, state-change call). Lock, copy what's needed, unlock, then block.

Each rule maps to an invariant the N-cycle reconnect repro checks: thread/task count back to baseline after every cycle, refcounts as expected, shutdown completes within a deadline. If you broke one in the field, add a LESSONS.md entry naming the rule and how it presented.
