# Feel-pass (README + try-it · 2026-09-05)

Cold open of the public README as a stranger who has two DGX Sparks and Joey’s 1× recipe.

1. **Cold open:** Title says the job in one line (same picture, one GPU, slower). At a glance table is first. The table screenshot shows YES/NO before any compose flags.
2. **Primary path:** Try-it is a clone + `./setup.sh` + `./start.sh`. setup.sh is check-only (does not start H3). Missing Joey recipe / image / checkpoint prints a FAIL line with what to clone.
3. **Break / error:** `./start.sh xyz` prints usage. Baked image trap is in the README so “I set CUDNN in .env and still got SDPA” has an answer.
4. **Loading / empty:** No web UI. First `./start.sh` can sit 10–15 min while weights load; README does not pretend it is instant. Empty clone has no weights — setup.sh fails closed.
5. **Would a stranger keep this?** **yes** — if they already run Joey 1× or the 2× fork. Not a from-zero weight download.

Evidence: `docs/screenshots/quality-speed-table.png` (comparison table, not model output).
