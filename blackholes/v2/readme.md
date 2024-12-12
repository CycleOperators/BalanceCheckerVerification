## Introduction

- This repository contains the [source code](blackhole.mo) for canister `5vdms-kaaaa-aaaap-aa3uq-cai`, the CycleOps balance checker canister
- It contains scripts allowing a user to verify that canister `5vdms-kaaaa-aaaap-aa3uq-cai` is:
  - blackholed, with 0 controllers
  - running the same wasm binary generated from ([./blackhole.mo](blackhole.mo))

<br/>

# Verification of the Blackholed Balance Checker canister

## Easy Mode: Use a GH Action

This will only take a few clicks!

1. Fork this repository.
2. Navigate to the actions tab of your new repo.
3. Select the "Verify Black Hole Canister" action on the left.
4. Dispatch the action.

You can view the output of this action to confirm that 1) the canister has no controllers, 2) the mainnet wasm matches the contents of this repository. The final step to be 100% confident that this canister can do no harm is to audit the source code of this repo.

## Alternative: Verify on your local machine

_NOTE: Currently, this method is only supported for macOS, as the wasm hash generated will vary depending on operating system._

To verify the CycleOps balance checker canister's black hole status from your local machine:

1. Clone this repository
2. Install version 0.24.0 of dfx via dfxvm `DFX_VERSION=0.20.0 sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)"`. [dfx](https://internetcomputer.org/docs/current/references/cli-reference/dfx-parent/) is the DFINITY command-line execution environment for creating, deploying, and managing the dapps you develop for the IC.
3. Install vessel from (https://github.com/dfinity/vessel). Vessel is used to fix the version of the [motoko-base](https://github.com/dfinity/motoko-base) library used in the project to 0.12.1.
4. The following command:

   a. Spins up a local dfx instance and deploys a copy of the CycleOps balance checker canister from the code in `blackhole.mo` in this repository.

   b. It then compares the wasm hash of that module against the hash of the wasm module stored in `5vdms-kaaaa-aaaap-aa3uq-cai`, the canister id of the CycleOps balance checker canister running on main net.

   c. It also verifies that `5vdms-kaaaa-aaaap-aa3uq-cai` has no controllers.

   ```sh
   npm run verify-blackhole
   ```

5. You should see the following in the local logs:

   ![successful action logs](./assets/local-log.png)

<br/>

# What is a Black Hole Canister

A canister can be considered a “black hole” only if it is verifiably immutable, i.e. it can never be upgraded. To meet this criteria, an internet computer canister must:

1. Have no controllers
2. Have verifiable source code
3. Have source code that cannot change controllers or source code

See also [Paul Liu's original black hole repository](https://github.com/ninegua/ic-blackhole). Note that canister lists itself as a controller so that it can access its own status via the management canister, but [since canisters are now allowed to query their own status](https://github.com/dfinity/interface-spec/commit/4d412720e02b0846cb1e22b37bdeda3173ea9390), this is no longer necessary.

<br/>

# How Verification Works

This repository makes verification of this canister as easy as a few clicks. Here's how the [verification script](./node/verify.ts) works.

**Verification Setup & Local Deployment:** [`npm run setup`](package.json#L7) starts up a fresh local replica, then creates a local deployment of the canister directly from the code in [./blackhole.mo](./blackhole.mo) and removes its controllers.

**Controller Verification:** Inside the [retrieveControllersAndModuleHash()](./node/verify.ts#L25) method, we call the `dfx canister info` command [./node/verify.ts#L30](./node/verify.ts#L30) with `5vdms-kaaaa-aaaap-aa3uq-cai` in order to read the controllers of that canister. We then verify that this canister has no controllers [./node/verify.ts#L52](./node/verify.ts#L52) on mainnet and verify that there are none ([`./node/verify.ts#L30`](./node/verify.ts#L30)).

**Source Code Verification:** Next, we ensure that the code running on mainnet is indeed to code in this open source repository, by comparing the mainnet wasm hash against the wasm hash from a locally deployed version of the source code. The same `dfx canister info` call is executed within the [retrieveControllersAndModuleHash()](./node/verify.ts#L25) function on both the locally deployed version of the blackhole [./blackhole.mo](blackhole.mo) and the `5vdms-kaaaa-aaaap-aa3uq-cai` canister running on main net [./canister_ids.json](./canister_ids.json) in order to retrieve both wasm module hashes. Lastly, we verify that the hash of the canister deployed from source matches the balance checker canister on mainnet [./node/verify.ts#L59](./node/verify.ts#L59).

**Source Code Audit:** The final step in gaining confidence in this canister is to audit the source code ([./blackhole.mo](blackhole.mo)).

<br/>

# Context

As a user of CycleOps, it may be necessary for the balance checker canister to be made a controller of your canister. This allows the balance checker canister to query the cycles balance of your canisters, without the necessity of deploying new code to your canister.

Of course, controller status is not to be taken lightly. That’s why the balance checker canister 1) has publicly available source code, so that anyone can audit the code and verify the safety of passing controller status to the canister, and 2) is blackholed, so that it is effectively immutable and its code can never be updated.

Users should not just take our word for this, and so it must be possible to verify that 1) the canister is indeed blackholed, and 2) the canister is strictly running the exact code in the open source repository, and not anything else.

We provide users with a methodology to perform these validations independently, quickly, and easily. With these measures, it is our opinion that this pattern is beyond reproach for the vast majority of cases, which is to say that it does not present any security risk to end users, and it is also our opinion that reasonable third party engineers will come to the same conclusion. That said, we invite critique and questioning, and encourage end-users to make a determination about the “trustlessness” of this mechanism for themselves, i.e. you should not need to trust us in order to be confident in this pattern.

<br/>

# Disclaimers

- This repository does not contain a license, meaninig reuse is only on permitted on per-use case basis. Please contact the CycleOps team if you would like to use this code in your application.
- This software is provided "as is", without warranty of any kind. In no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software
