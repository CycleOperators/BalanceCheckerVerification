/// CycleOps Status Checker V3 Implementation

import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import { print; trap } "mo:base/Debug";
import Error "mo:base/Error";
import Principal "mo:base/Principal";
import Result "mo:base/Result";

/// The canister status checker actor responsible for monitoring the cycles balances of customer-owned canisters
/// CycleOps spins up a blackholed version of this canister.
///
/// The caller is the original creator of this service. This cannot change throughout the lifecycle of the canister
/// as it can only be created once. Any subsequent upgrades by other controllers cannot change this field.
/// The access control implemented in this canister's public APIs means that the CycleOps Service is the only
/// caller with the ability to invoke the public methods of this canister.
shared actor class StatusChecker(CYCLEOPS_CANISTER_ID : Principal) = this {
  /////////////////////////////////////////
  // Required Management Canister Types //
  ///////////////////////////////////////

  // The status checker calls the canister_status endpoint of the IC management canister
  // in order to retrieve cycles balances from customer canisters.
  type ManagementCanisterActor = actor {
    canister_status : shared ({ canister_id : Principal }) -> async CanisterStatus;
  };
  type MemoryMetrics = {
      wasm_memory_size : Nat;
      stable_memory_size : Nat;
      global_memory_size : Nat;
      wasm_binary_size : Nat;
      custom_sections_size : Nat;
      canister_history_size : Nat;
      wasm_chunk_store_size : Nat;
      snapshots_size : Nat;
  };
  // The management canister's canister_status response type
  type CanisterStatus = {
    status : { #stopped; #stopping; #running };
    settings : DefiniteCanisterSettings;
    module_hash : ?Blob;
    memory_size : Nat;
    memory_metrics : MemoryMetrics;
    cycles : Nat;
    idle_cycles_burned_per_day : Nat;
    // New fields tracked in V2 of the blackhole
    reserved_cycles : Nat;
    query_stats : QueryStats;
  };
  type DefiniteCanisterSettings = {
    controllers : [Principal];
    compute_allocation : Nat;
    memory_allocation : Nat;
    freezing_threshold : Nat;
    // New fields tracked in V2 of the blackhole
    reserved_cycles_limit : Nat;
    log_visibility : { #controllers; #allowed_viewers : [Principal]; #public_ };
    wasm_memory_limit : Nat;
  };
  type QueryStats = {
    num_calls_total : Nat;
    num_instructions_total : Nat;
    request_payload_bytes_total : Nat;
    response_payload_bytes_total : Nat;
  };

  // Instantiate the management canister actor
  let ic : ManagementCanisterActor = actor ("aaaaa-aa");

  ///////////////////////////////////////////////////////////
  // Public APIs, gated by the CYCLEOPS_SERVICE_PRINCIPAL //
  /////////////////////////////////////////////////////////

  // A result type for handling canister status failures
  type CanisterStatusResult = Result.Result<CanisterStatus, Text>;
  // Attempts to return the controller, and cycles balance of a single canister principal
  // If the canister is not controlled by the cycleops service, then the controllers will be
  // returned by the error message, but the cycles balance returned will not be available
  public shared ({ caller }) func canisterStatus(
    canisterId : Principal
  ) : async CanisterStatusResult {
    trapIfNotCycleOps(caller);

    try {
      let statusResponse = await ic.canister_status({
        canister_id = canisterId;
      });
      #ok(statusResponse);
    } catch (error) {
      #err(Error.message(error));
    };
  };

  /// checks the canister status of itself or anything it is the controller of
  public shared ({ caller }) func canisterStatuses(canisterPrincipals : [Principal], batchSize : Nat) : async Result.Result<[CanisterStatusResult], Text> {
    // only allow the service that created the status checker to call canister_status
    trapIfNotCycleOps(caller);

    try {
      let statusResults = await* batchCanisterStatusCalls(canisterPrincipals, batchSize);
      #ok(statusResults);
    } catch (error) {
      #err(Error.message(error));
    };
  };

  /////////////////////////////////////////////////
  // Private Helper Functions (Not public-APIs) //
  ///////////////////////////////////////////////

  /// Traps if the caller is not the CycleOps Service
  /// Used to prevent unauthorized access to sensitive canister metric data
  private func trapIfNotCycleOps(caller : Principal) : () {
    if (caller != CYCLEOPS_CANISTER_ID) trap("Not Authorized");
  };

  /// Takes in an array of canister principals and a batch size, and executes canister status calls
  /// in batches, such that the size of each batch is <= batchSize
  /// returns a list of CanisterStatusResult (CanisterStatus or error message)
  ///
  /// Concurrently request the canister statuses of all principals passed, breaking the concurrent canister status
  /// requests into batches in order to get around the following issue
  /// >  `"Canister trapped explicitly: could not perform self call" issue at around 500`
  /// See https://forum.dfinity.org/t/canister-output-message-queue-limits-and-ic-management-canister-throttling-limits/15972
  ///
  /// Note: The shifting between an Array and a Buffer right now is because in Motoko async functions cannot accept
  /// var parameters (needs an Array), and appending to an Array is very inefficient (use Buffer instead)
  private func batchCanisterStatusCalls(
    canisterPrincipals : [Principal],
    batchSize : Nat,
  ) : async* [CanisterStatusResult] {
    let size = canisterPrincipals.size();
    var batchNumber = 0;
    var canisterStatuses = Buffer.Buffer<CanisterStatusResult>(size);

    while (batchNumber * batchSize < size) {
      let startIndex = batchNumber * batchSize;
      let batchLength = if (startIndex + batchSize > size) {
        size - startIndex : Nat;
      } else { batchSize };
      print(
        "batch checking statuses of canisters, batch=" # debug_show (batchNumber) # " from: " # debug_show (startIndex) # " - " # debug_show (startIndex + batchLength)
      );

      // from the larger canisterPrincipals subarray, creates a subArray of <batchSize> principals
      // starting at the startIndex (inclusive) and going until size batchLength is reached
      let subArrayCanisterPrincipals = Array.subArray(canisterPrincipals, startIndex, batchLength);
      // get all canister statuses for each principal in the subArray
      let statusesInBatch = await* awaitAllCanisterStatuses(subArrayCanisterPrincipals);
      // the batch is finished, append all canisters statuses to the larger canisterStatuses Buffer
      canisterStatuses.append(Buffer.fromArray<CanisterStatusResult>(statusesInBatch));
      // increment the batch number
      batchNumber += 1;
    };

    print("finished fetching canister statuses for " # debug_show (canisterStatuses.size()) # " canisters");
    // return the array of canister statuses
    Buffer.toArray(canisterStatuses);
  };

  // Concurrently (in parallel) request the canister statuses of all principals passed
  //
  // Note: The shifting between an Array and a Buffer right now is because in Motoko async functions cannot accept
  // var parameters (needs an Array), and appending to an Array is very inefficient (use Buffer instead)
  //
  private func awaitAllCanisterStatuses(canisterPrincipals : [Principal]) : async* [CanisterStatusResult] {
    let ids = Buffer.fromArray<Principal>(canisterPrincipals);
    let calls = Buffer.Buffer<Result.Result<async CanisterStatus, Text>>(canisterPrincipals.size());
    var i = 0;

    // Use a loop to initiate each asynchronous call without waiting for it to complete
    label l loop {
      if (i >= ids.size()) { break l };

      let res = try {
        #ok(ic.canister_status({ canister_id = canisterPrincipals[i] }));
      } catch (error) { #err(Error.message(error)) }; // catch synchronous errors (i.e. canister output queue)

      calls.add(res);
      i += 1;
    };

    i := 0;
    let awaitedCalls = Buffer.Buffer<CanisterStatusResult>(calls.size());

    // Use a loop to await each initiated asynchronous call that was made to getCanisterStatus in the previous loop
    label l loop {
      if (i >= ids.size()) { break l };

      switch (calls.get(i)) {
        case (#ok(call)) {
          let res = try { #ok(await call) }
          // Catch asynchronous errors (i.e. not controller of canister)
          catch (err) { #err(Error.message(err)) };

          awaitedCalls.add(res);
        };
        case (#err(message)) { awaitedCalls.add(#err(message)) };
      };
      i += 1;
    };

    // return array of awaited canister_status calls
    Buffer.toArray(awaitedCalls);
  };

  /// Simple inspect message blocker to prevent ingress requests (outside the IC) other than the creator from calling this canister
  /// (helps to prevent DDOS or cycle drain attacks)
  system func inspect({
    caller : Principal;
    msg : {
      #canisterStatus : () -> (Principal);
      #canisterStatuses : () -> ([Principal], Nat);
    };
  }) : Bool { caller == CYCLEOPS_CANISTER_ID };
};

