# About This Repository

This repository contains workflow documents for AI-agent-assisted software development. The documents are not product specifications or project code; they are operating guides for how to run development work with agents so that design intent, assumptions, and lessons survive across sessions.

The central idea is that agent labor makes code generation cheap, but it does not make judgment, validation, or durable project memory automatic. These workflows are therefore built around durable artifacts, explicit validation, and narrow operating loops that an agent can execute reliably.

## What Is Here

- `PRINCIPLES.md` distills the ideas common to all of these workflows into a numbered, citable canon. It is the shortest way to understand what the workflows optimize for and why; the other documents are the detailed application of these principles to specific kinds of work.
- `agentic-dev-workflow.md` describes the core workflow for agent-driven development in general-purpose software projects. It covers the lifecycle from design interview through assumption audit, spikes, implementation sessions, entropy-reduction passes, and restart protocol.
- `embedded-target-workflow.md` extends the core workflow for projects that run on a remote embedded Linux device. It focuses on scripted build/deploy/run loops, reproducible on-device repros, diagnostic capture, network fault injection, and the different policies needed for Rust and Python on embedded targets.
- `workflow-prompts-and-templates.md` contains the operational pieces that make the workflow executable: hook prompts, standing rules, and templates for the durable artifacts such as `ASSUMPTIONS.md`, `DECISIONS.md`, and `LESSONS.md`.

## Who This Is For

These documents are for people using coding agents as part of real software delivery, especially when:

- project intent is being lost between sessions,
- assumptions are turning out to be wrong late in implementation,
- the same dead ends keep getting rediscovered,
- code entropy is accumulating faster than teams can pay it down,
- or the execution environment is specialized enough that local development is a poor proxy for reality.

The intended human role is not "write everything and ask the agent to type it in." The human acts as design reviewer, domain oracle, and final judge of trade-offs. The agent does the drafting, implementation, and iteration work inside a workflow that makes its reasoning durable and its mistakes easier to detect.

## How To Read It

If you are new to the material, read in this order:

1. `PRINCIPLES.md` for the ideas all the workflows share, in brief.
2. `agentic-dev-workflow.md` for the core model.
3. `workflow-prompts-and-templates.md` for the prompts, standing rules, and artifact formats that operationalize that model.
4. `embedded-target-workflow.md` only if your code executes primarily on a remote device or in an environment that cannot be reproduced well on the development host.
5. `c-suite-plugin.md` only if you are building a plugin for the C-Suite executive orchestration system.
6. `gstreamer-deepstream-workflow.md` if your embedded target is also a GStreamer/DeepStream video system

## What The Workflow Optimizes For

Across the documents, the workflow consistently optimizes for a few things:

- preserving the "why" outside the codebase,
- forcing contact with reality early through spikes and repros,
- making good practices structural through hooks and scripts rather than memory,
- treating dead ends as first-class project knowledge,
- and keeping restart from a corrected spec cheaper than rehabilitating a drifted implementation.

This is not a claim that every project should use every part of the system. The documents describe a bias: when working with agents, unrecorded reasoning disappears quickly, so the workflow spends effort on durable context and executable loops rather than on hoping a future session will infer the same conclusions.

## Relationship Between The Documents

`agentic-dev-workflow.md` is the base workflow. `embedded-target-workflow.md` is a specialization for a harder execution environment, not a replacement. `workflow-prompts-and-templates.md` is the companion operations manual that turns the base ideas into prompts, rules, hooks, and artifact scaffolding.

In short:

- the workflow document explains the model,
- the embedded document adapts the model to on-device development,
- and the prompts/templates document provides the reusable machinery.

## Status

These documents describe a working approach, not settled doctrine. Several claims in them are explicitly hypotheses from limited experience. They should be refined against real project use, especially where the proposed hooks, gates, or journaling practices produce more friction than signal.


