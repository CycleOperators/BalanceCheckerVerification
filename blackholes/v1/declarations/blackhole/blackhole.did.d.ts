import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface CanisterStatus {
  'status' : { 'stopped' : null } |
    { 'stopping' : null } |
    { 'running' : null },
  'memory_size' : bigint,
  'cycles' : bigint,
  'settings' : DefiniteCanisterSettings,
  'idle_cycles_burned_per_day' : bigint,
  'module_hash' : [] | [Uint8Array | number[]],
}
export type CanisterStatusResult = { 'ok' : CanisterStatus } |
  { 'err' : string };
export interface DefiniteCanisterSettings {
  'freezing_threshold' : bigint,
  'controllers' : Array<Principal>,
  'memory_allocation' : bigint,
  'compute_allocation' : bigint,
}
export type Result = { 'ok' : Array<CanisterStatusResult> } |
  { 'err' : string };
export type Result_1 = { 'ok' : [Array<Principal>, bigint] } |
  { 'err' : string };
export interface StatusChecker {
  'canisterStatus' : ActorMethod<[Principal], Result_1>,
  'canisterStatuses' : ActorMethod<[Array<Principal>, bigint], Result>,
}
export interface _SERVICE extends StatusChecker {}
