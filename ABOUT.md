# About This Repository

This repository is a small library of workflow specifications for AI-agent-assisted software development. The documents here are not product docs and not project templates in the usual sense. They are operating manuals for how to structure work so an agent can contribute repeatedly without losing context, reintroducing known mistakes, or encoding bad assumptions into the codebase.

The common thesis across the repository is simple:

- agent sessions are strong at local execution and weak at preserving intent across time;
- therefore the important project knowledge has to live in durable artifacts outside the code;
- and whenever a useful practice can be enforced by scripts, hooks, or validation gates, it should be, because instruction-only discipline decays.

These documents are written as working specifications, not doctrine. They make concrete claims about how agents behave, what failure modes matter, and which process constraints are worth the overhead. Those claims should be treated as hypotheses to refine against real projects.

## What is in here

### `agentic-dev-workflow.md`

The base workflow. It defines the general development loop for agent-driven projects: design elicitation, assumption audits, validation spikes, scoped implementation sessions, bug investigation (where the durable artifact is often understanding rather than a diff), end-of-session distillation, and periodic entropy-reduction passes. It also defines the durable project artifacts the workflow depends on: `SPEC.md`, `ASSUMPTIONS.md`, `DECISIONS.md`, and `LESSONS.md`.

Read this first. The other workflow documents extend it rather than replace it.

### `embedded-target-workflow.md`

An extension for projects that run on a remote embedded Linux target rather than on the development machine. Its focus is the build-deploy-run-collect loop, on-device repros, fault injection, capture strategy for environment-dependent bugs, and observability practices that let an agent work unattended against a stateful device.

This document is for situations where correctness depends on the real target environment: device-specific runtimes, physical links, unstable networks, hardware-bound media paths, or bugs that only appear on-device.

### `gstreamer-deepstream-workflow.md`

A narrower extension for GStreamer and NVIDIA DeepStream systems, especially Jetson deployments mixing Python application code, NVIDIA elements, and custom Rust plugins. It adds a debugging model for pipelines, reconnect failures, flow-localization, runtime graph dumps, source-fault simulation, thread and object-lifetime issues, and fork maintenance policy for custom GStreamer elements.

Use this when the project's core failure modes live in dynamic media pipelines rather than in ordinary request/response application logic.

### `workflow-prompts-and-templates.md`

The operational companion. It turns the workflow ideas into concrete prompts, standing rules, journal templates, and hook sketches. If `agentic-dev-workflow.md` explains the model, this file is the first place to look when implementing it in tooling.

## How to read the repository

The intended reading order is:

1. `agentic-dev-workflow.md`
2. `workflow-prompts-and-templates.md`
3. `embedded-target-workflow.md` if your code only really runs on a target device
4. `gstreamer-deepstream-workflow.md` if your embedded target is also a GStreamer/DeepStream video system

That order matters because the later documents assume the earlier ones. The embedded workflow inherits the same spec discipline and journaling model; the GStreamer workflow inherits both the general workflow and the embedded execution model.

## Who this is for

This repository is aimed at people who are already convinced that agents can write substantial amounts of code, but are not convinced that ordinary codebase habits are enough to keep long-running agent work coherent. The documents assume the human is still responsible for judgment, constraint setting, and design review, while the agent does most of the drafting, implementation, and mechanical iteration.

The workflows are especially aimed at projects with one or more of these properties:

- design intent is easy to lose between sessions;
- invalid assumptions are expensive and hard to notice early;
- environment-dependent bugs dominate the schedule;
- the codebase accumulates workaround layers faster than humans prune them;
- restarts or partial rewrites are realistic and should preserve knowledge rather than preserve every line of code.

## What these documents are trying to optimize for

The repository does not try to maximize raw coding speed. It tries to optimize for a different outcome: a project that can survive many agent sessions, bad sessions, false starts, and even full implementation restarts without repeatedly paying for the same confusion.

In practice that means emphasizing:

- explicit assumptions over implicit ones;
- durable negative knowledge over undocumented dead ends;
- reproducible validation over "the diff looks right";
- deletion and consolidation as scheduled work, not an aspirational virtue;
- hooks and gates where possible, because they outlast good intentions.

## Status

Everything here should be read as an evolving draft. The workflows are intentionally specific enough to test in real projects and revise where they are wrong. If a real codebase falsifies one of the assumptions in these documents, the right response is to update the workflow, not to defend it.


