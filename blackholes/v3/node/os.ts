import os from "os";

export function verifyOS(): void {
  /*
  const isMac = os.platform() === "linux";
  if (!isMac)
    throw new Error(
      "Verification must be performed on linux! The easiest way to do this is with a github action, or by following the docker instructions in this readme. See https://github.com/CycleOperators/BalanceCheckerVerification for github action instructions. This is due to differences in build environments resulting in different wasm hashes."
    );
  */
}

if (!module.parent) verifyOS();
