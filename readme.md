## Introduction

This repository contains the source code, and steps to reproduce builds for different versions of CycleOps blackhole canisters.


### CycleOps Blackhole Versions

There are currently 3 CycleOps blackholes. Each new version provides additional canister metrics.

* V1 - original
  * Canister - [5vdms-kaaaa-aaaap-aa3uq-cai](https://dashboard.internetcomputer.org/canister/5vdms-kaaaa-aaaap-aa3uq-cai)
  * Code - [blackholes/v1/blackhole.mo](./blackholes/v1/blackhole.mo)
  * Verification
    * [With a GitHub Action](./blackholes/v1/readme.md#easy-mode-use-a-gh-action)
    * [On your local Machine](./blackholes/v1/readme.md#alternative-verify-on-your-local-machine)
* V2 - V1 + reserved cycles & query call metrics
  * Canister - [2daxo-giaaa-aaaap-anvca-cai](https://dashboard.internetcomputer.org/canister/2daxo-giaaa-aaaap-anvca-cai)
  * Code - [blackholes/v2/blackhole.mo](./blackholes/v2/blackhole.mo)
  * Verification
    * [With a GitHub Action](./blackholes/v2/readme.md#easy-mode-use-a-gh-action)
    * [On your local Machine](./blackholes/v2/readme.md#alternative-verify-on-your-local-machine)
* **V3 (latest, V2 + detailed canister memory metrics e.g. heap/stable/snapshot)**
  * Canister - [cpbhu-5iaaa-aaaad-aalta-cai](https://dashboard.internetcomputer.org/canister/cpbhu-5iaaa-aaaad-aalta-cai)
  * Code - [blackholes/v3/src/blackhole.mo](./blackholes/v3/src/blackhole.mo)
  * Verification
    * [With a GitHub Action](./blackholes/v3/readme.md#easy-mode-use-a-gh-action)
    * [On your local Machine](./blackholes/v3/readme.md#alternative-verify-on-your-local-machine)