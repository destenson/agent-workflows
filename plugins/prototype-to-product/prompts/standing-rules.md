--- STANDING RULES (prototype-to-product) ---
1. One item per commit: each commit closes one HARDENING.md item and says which. Don't bundle unrelated hardening into one change — the ledger maps to history, and a fix that fails review should revert without taking others with it.
2. Surface, don't paper over: hardening a prototype means handling the edge cases it ignored, not hiding them. Do not add fallbacks or graceful-degradation paths that mask a failure unless the release bar explicitly calls for that degradation.
3. Hold the bar, both ways: work only what the release bar requires — adding scope past it is gold-plating. Remove a ledger item the moment it is closed, and add any newly-found prototype-grade gap to the ledger rather than fixing it silently.
