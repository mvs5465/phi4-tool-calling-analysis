# AGENTS.md

Instructions for human + AI contributors in this repository.

## Product

- `phi4-tool-calling-analysis` is a research repo for prompt-engineering experiments around `phi4-mini` tool calling.
- The repo is primarily a results and analysis artifact, not a product app.

## Structure

- `README.md` is the main synthesized analysis.
- `data/responses/` stores captured model outputs from the experiment iterations.
- Treat the repo as a study record first and a tooling project second.

## Working Rules

- Preserve reproducibility: do not rewrite experimental results casually.
- When updating conclusions, keep the README tied to the actual captured response set.
- Add new experiment batches in a way that keeps old results inspectable.
- Prefer clear notes about methodology changes over implicit shifts in evaluation criteria.

## Verification

- For documentation-only updates, verify that the README still matches the stored artifacts.
- For any new tooling added later, document the run path in the README in the same change.
