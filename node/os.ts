import os from "os";

export function verifyOS(): void {
  const isMac = os.platform() === "darwin";
  if (!isMac)
    throw new Error(
      "Verification must be performed on macos! The easiest way to do this is with a github action (see https://github.com/CycleOperators/BalanceCheckerVerification). This is due to differences in build environments resulting in different wasm hashes."
    );
}

if (!module.parent) verifyOS();
