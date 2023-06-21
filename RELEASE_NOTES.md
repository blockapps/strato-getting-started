# STRATO Getting Started release notes

## 4.2.0

STRATO versions supported: v9.0+

- Added Support for Docker Compose V2, with backwards compatibility for Docker Compose V1

## 4.1.1

STRATO versions supported: v9.0+

- Added the check for STRIPE env vars when running STRATO with the Marketplace

## 4.1.0

STRATO versions supported: v9.0+

- Added support for Marketplace app bundled with newer STRATO versions


## 4.0.2

STRATO versions supported: v9.0+

- Updated genesis-block.json to match the Mercata Beta network

## 4.0.1

STRATO versions supported: v9.0+

- Added the STRATO Mercata Beta genesis-block.json to be used by default
- Fixed the ASCII logo formatting in the stdout


## 4.0.0

STRATO versions supported: v9.0+

- Added support for STRATO nodes v9.0+ with STRATO Vault separated from the STRATO Node
- Added `vault` script to manage STRATO Vault deployment
- Moved `--set-password` flag to `vault` executable
- Changed `--get-address`, `--get-pubkey`, `--get-validators` to use Metadata API endpoint to get node info from STRATO Vault
- Added `--get-metadata` to get the full Metadata API JSON response
- Added support for `VAULT_URL` var
- Added description for `OAUTH_VAULT_PROXY_ALT_CLIENT_ID` and `OAUTH_VAULT_PROXY_ALT_CLIENT_SECRET` variables
- Deprecated `--drop-chains` in favor of `--wipe` (with STRATO Vault now being a separate application)
- Removed the `--blockstanbul` flag as a previously deprecated
- Removed `EXT_STORAGE_<...>` variables  from help topic as previously deprecated
- Removed `-m` option as previously deprecated
- Replaced OAUTH_JWT_USERNAME_PROPERTY with OAUTH_JWT_USER_ID_CLAIM
- Removed the deprecated blockstanbulPrivateKey support
- Removed the deprecated strato.sh symlink to strato

## 3.4.3

STRATO versions supported: v6.0.2+

- Fixed compatibility with more GitHub release page changes to download docker-compose.yml asset

## 3.4.2

STRATO versions supported: v6.0.2+

- Fixed compatibility with updated GitHub release page to download docker-compose.yml asset
- Removed `wget` dependency

## 3.4.1

STRATO versions supported: v6.0.2+

- Use `sslCertFileType=pem` by default
- Updated dummy SSL/TLS certificate

## 3.4.0

STRATO versions supported: v6.0.2+

- Added the check for single-member private chains when running with `--drop-chains` flag

## 3.3.0

STRATO versions supported: v6.0.2+

- Added `--get-single-node-chains` mode to fetch the list of private chains not shared to the network

## 3.2.1

STRATO versions supported: v6.0.2+

- Added the randomly generated networkID if not provided in --single mode

## 3.2.0

STRATO versions supported: v6.0.2+

- Added `--get-validators` flag
- Made the blockstanbul mode the default, `--blockstanbul` flag is now deprecated
- Changed the `isAdmin` default value from `false` to `true`
- Updated the README
- Cleaned out the old deprecated code
- Done a touch of refactoring

## 3.1.0

STRATO versions supported: v6.0.2+

- Removed OAUTH_ENABLED environment variable as obsolete (always true, non-OAuth mode is deprecated)
- Removed legacy support for STRATO versions 5 and older

## 3.0.4

STRATO versions supported: v4.0+

- Fixed the password not being set on slower machines due to race condition on node initial start
- Minor optimization fix for strato generation router script

## 3.0.3

STRATO versions supported: v4.0+

- Added --get-pubkey flag to obtain the node's public key

## 3.0.2

STRATO versions supported: v4.0+

- Remove blocdata docker volume on --drop-chains

## 3.0.1

STRATO versions supported: v4.0+

- Fix for backward compatibility for STRATO prior to version 5.5

## 3.0.0

STRATO versions supported: v4.0+

- Added support for STRATO 6.0
- Added router file to keep backward compatibility with STRATO 4 and 5

## 2.18.0

STRATO versions supported: v4.0+

- Remove docker volumes whether or not the down command was successful (for cases when docker network can't be removed etc.)

## 2.17.0

STRATO versions supported: v4.0+

- Fix for --fetch-logs not working correctly on some linux distributions

## 2.16.0

STRATO versions supported: v4.0+

- Fix for single node upgrade flow

## 2.15.0

STRATO versions supported: v4.0+

- scriptgen compatible with STRATO versions below 5.2.0
- updated formatting of scripts generated with scriptgen

## 2.14.0

STRATO versions supported: v4.0+

- scriptgen to add blockstanbul public key into generated run.sh scripts

## 2.13.0

STRATO versions supported: v4.0+

- scriptgen to add blockstanbulAdmins variable into generated run.sh scripts

## 2.12.0

STRATO versions supported: v4.0+

- OAUTH_SCOPE added to --help output

## 2.11.0

STRATO versions supported: v4.0+

- Added support for "port" in node-list.json syntax to alter the default STRATO port

## 2.10.1

STRATO versions supported: v4.0+

- Fail verbosely when no password can be read

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
