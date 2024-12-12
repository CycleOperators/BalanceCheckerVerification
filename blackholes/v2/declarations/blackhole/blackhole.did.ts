import { IDL } from "@dfinity/candid";
export const idlFactory : IDL.InterfaceFactory = ({ IDL }) => {
  const Result_1 = IDL.Variant({
    'ok' : IDL.Tuple(IDL.Vec(IDL.Principal), IDL.Nat),
    'err' : IDL.Text,
  });
  const DefiniteCanisterSettings = IDL.Record({
    'freezing_threshold' : IDL.Nat,
    'controllers' : IDL.Vec(IDL.Principal),
    'memory_allocation' : IDL.Nat,
    'compute_allocation' : IDL.Nat,
  });
  const CanisterStatus = IDL.Record({
    'status' : IDL.Variant({
      'stopped' : IDL.Null,
      'stopping' : IDL.Null,
      'running' : IDL.Null,
    }),
    'memory_size' : IDL.Nat,
    'cycles' : IDL.Nat,
    'settings' : DefiniteCanisterSettings,
    'idle_cycles_burned_per_day' : IDL.Nat,
    'module_hash' : IDL.Opt(IDL.Vec(IDL.Nat8)),
  });
  const CanisterStatusResult = IDL.Variant({
    'ok' : CanisterStatus,
    'err' : IDL.Text,
  });
  const Result = IDL.Variant({
    'ok' : IDL.Vec(CanisterStatusResult),
    'err' : IDL.Text,
  });
  const StatusChecker = IDL.Service({
    'canisterStatus' : IDL.Func([IDL.Principal], [Result_1], []),
    'canisterStatuses' : IDL.Func(
        [IDL.Vec(IDL.Principal), IDL.Nat],
        [Result],
        [],
      ),
  });
  return StatusChecker;
};

