## Introduction

- This repository contains the [source code](blackhole.mo) for canister [`cpbhu-5iaaa-aaaad-aalta-cai`](https://dashboard.internetcomputer.org/canister/cpbhu-5iaaa-aaaad-aalta-cai), version 3 (V3) of the the CycleOps balance checker canister
- It uses the [Reproducible Build Template from research-ag](https://github.com/research-ag/motoko-build-template), allowing anyone to build this canister and verify its module hash locally.
- You can also run the V3 GitHub action attached to this repository in order to verify that `cpbhu-5iaaa-aaaad-aalta-cai` is:
  - blackholed, with 0 controllers
  - running the same wasm binary generated from ([./blackhole.mo](blackhole.mo))

<br/>

# Verification of the Blackholed Balance Checker canister

## Easy Mode: Use a GH Action

This will only take a few clicks!

1. Fork this repository.
2. Navigate to the actions tab of your new repo.
3. Select the "Verify Black Hole Canister V3" action on the left.
4. Click the "Run workflow" button to dispatch the action.

You can view the output of this action to confirm that 1) the canister has no controllers, 2) the mainnet wasm matches the contents of this repository. The final step to be 100% confident that this canister can do no harm is to audit the source code of this repo.

## Alternative: Verify on your local machine

This repository uses the [Reproducible Build Motoko Template Standard from research-ag](https://github.com/research-ag/motoko-build-template). In this folder, follow the instructions listed to download the [prequisite tools](https://github.com/research-ag/motoko-build-template?tab=readme-ov-file#prerequisites) there in order to spin up docker and build the [canister code](./src/blackhole.mo) with the correct version of dfx and the motoko compiler inside of a linux x86_64 environment.

Once you have docker set up and running, from this repository you can verify the hash of the wasm by running

```
docker-compose run --rm wasm
```


The resulting hash should match `dfcf37d4ee18bfe77a12197feaf4686f160d717383f0cf525f9d30e60fec204d`, which matches the hash running on [ICP mainnet](https://dashboard.internetcomputer.org/canister/cpbhu-5iaaa-aaaad-aalta-cai)