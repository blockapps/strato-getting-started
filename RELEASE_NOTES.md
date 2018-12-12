# STRATO Getting Started release notes

## 2.6.1

- export blockstabul variable hotfix

## 2.6.0

- `--single` now runs a solo PBFT-blockstanbul node
- `--lazy` is added to run a single lazy mining PoW node (former --single)
- `--blockstanbul|-pbft` is added to run PBFT-blockstanbul node (equal to blockstanbul=true variable)
- `--stop` now only stops containers (can be started again)
- `--start` is added to start the stopped containers
- `--remove` is added to stop and remove containers, keep volumes (former --stop)
- Simple PBFT-blockstanbul variables checks added
- `--scriptgen` now generates scripts with --blockstanbul flag instead blockstanbul=true variable
- Some refactoring
