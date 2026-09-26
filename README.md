# azure-lab-toolchain

Pinned container image for Azure lab automation runs: Azure CLI, Bicep, gh, git, jq, curl, rclone.
Slim multi-stage build (no pip/build tooling in the final image), published to GHCR as
`ghcr.io/azure-lab-automation-el/azure-lab-toolchain:latest`.

Why: one pinned toolchain for every lab workflow instead of whatever versions the runner image happens
to carry this week, and zero per-run tool setup. Build is manual (`workflow_dispatch`) or on Dockerfile changes.
