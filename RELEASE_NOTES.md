# STRATO Getting Started release notes

## 2.10.0

STRATO versions supported: v4.0+

- Global in-memory password setting for STRATO 4.5+ with OAuth enabled

## 2.9.1

STRATO versions supported: v4.0+

- --drop-chains behavior fixed to remove the zookeeper volume

## 2.9.0

STRATO versions supported: v4.0+

- Support for STRATO container upgrade: --upgrade-strato --down and --drop-chains flags added, --remove flag deprecated

## 2.8.3

STRATO versions supported: v4.0+

- License agreement link changed in README.md

## 2.8.3

STRATO versions supported: v4.0+

- fixed issue with temporary directory creation and too verbose output in fetchlogs script

## 2.8.2

STRATO versions supported: v4.0+

- Automatically remove transient containers used for key generation

## 2.8.1

STRATO versions supported: v4.0+

- fetchlogs `--as-dir` flag added to output logs as directory and to not archive

## 2.8.0

STRATO versions supported: v4.0+

- fetchlogs python script added to fetch STRATO node logs and database dump (optional)
- `--fetch-logs` and `--fetch-logs-with-db` wrapper entrypoints to fetch logs easily
- minor refactoring


## 2.7.3

STRATO versions supported: v4.0+

- Fix for wrong "Node failed to start" message when running STRATO 4.3 or earlier

## 2.7.2

STRATO versions supported: v4.0+

- Suppress the unused variable warning messages in docker-compose

## 2.7.1

STRATO versions supported: v4.0+

- Wait for STRATO containers to become healthy
- -v|--version flag added
- BasicAuth is now off by default
- Minor refactoring

## 2.7

STRATO versions supported: v4.0+

- STRATO v4.3 compatibility
- Added the check of minimum required strato-getting-started version for docker-compose.yml provided
- Added OAuth help topic
- Some refactoring

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
