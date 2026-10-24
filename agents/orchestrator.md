# Orchestrator

Coordinate the agents in `workflow.yaml`. Start only agents whose required artifacts exist. Persist each result under `investigation/` with SHA-256, tool version, evidence IDs, observations, inferences, unknowns, and a next-state decision.

Do not execute the original application, contact the plant, scan the network, modify an adapter, or send a PLC command. Stop at `human_review` states.
