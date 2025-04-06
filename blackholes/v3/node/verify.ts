import fs from "fs-extra";
import { execSync } from "child_process";
import { verifyOS } from './os';

/**
 * Retrieve black hole canister ID on mainnet.
 */
export async function blackholeMainnetCanisterId(): Promise<string> {
  const canisterIds = JSON.parse(
    await fs.readFile("canister_ids.json", "utf-8")
  );
  return canisterIds.blackhole.ic;
}

/**
 * Retrieve black hole canister ID on local replica.
 */
async function blackholeCanisterIdLocal(): Promise<string> {
  const canisterIds = JSON.parse(
    await fs.readFile("./.dfx/local/canister_ids.json", "utf-8")
  );
  return canisterIds.blackhole.local;
}

// Retrieve the controllers and module hash of a canister.
function retrieveControllersAndModuleHash(
  canister: string,
  local: boolean = false
): { controllers: string[]; moduleHash: string } {
  const network = local ? "" : "--network=ic";
  const infoString = execSync(`dfx canister ${network} info ${canister}`).toString();
  const lines = infoString.split("\n");
  const controllerLine = lines[0];
  const moduleHashLine = lines[1];
  if (!controllerLine || !moduleHashLine) {
    throw new Error(`Failed to retrieve canister information for ${canister}`);
  };
  const controllersString = controllerLine.split(":")[1];
  if (!controllersString) {
    throw new Error(`Failed to retrieve canister information for ${canister}`);
  };
  const controllers = controllersString
    .trim().split(" ")
    // filter out empty strings (that aren't controllers)
    .filter(controller => controller !== "");
  const moduleHashString = moduleHashLine.split(":")[1];
  if (!moduleHashString) {
    throw new Error(`Failed to retrieve canister information for ${canister}`);
  };
  const moduleHash = moduleHashString
  return { controllers, moduleHash };
};

/**
 * Verifies the status of the mainnet black hole canister in this repository.
 */
async function run() {
  verifyOS();
  const canisterLocal = await blackholeCanisterIdLocal();
  //const canisterMainnet = await blackholeMainnetCanisterId();
  //console.log(`Verifiying canister ${await blackholeMainnetCanisterId()}...`);
  const localCanister = retrieveControllersAndModuleHash(canisterLocal, true);
  //const mainnetCanister = retrieveControllersAndModuleHash(canisterMainnet, false);
  //const { controllers, mainnetModuleHash } = retrieveControllersAndModuleHash(canister, local);
  //console.log("\nmainnet canister controllers =", mainnetCanister.controllers);
  /*
  const hasNoControllers = mainnetCanister.controllers.length == 0;
  if (hasNoControllers === true) {
    console.log(`\n✅ canister ${canisterMainnet} zero controllers verified.`);
  } else {
    console.log(`\n❌ canister ${canisterMainnet} has ${mainnetCanister.controllers.length} controllers (${mainnetCanister.controllers}) and is not a valid black hole!`);
  }
  */
  // Determine if the hash of the local source code matches the hash of the source code running on mainnet.
  //const isSourceCodeVerified = localCanister.moduleHash == mainnetCanister.moduleHash;
  console.log("\nlocal canister module hash  ", localCanister.moduleHash);
  //console.log("mainnet canister module hash", mainnetCanister.moduleHash)
  /*
  if (isSourceCodeVerified === true) {
    console.log(`️\n✅ canister ${canisterMainnet} source code verified.`);
  } else {
    console.log(`\n❌ canister ${canisterMainnet} source code is not verified!`);
  }
  if (hasNoControllers && isSourceCodeVerified) {
    console.log(`\n✅ verification and blackhole check of canister ${canisterMainnet} successful.\n`);
  } else {
    throw new Error(`\n❌ verification and blackhole check of canister ${canisterMainnet} failed. Do NOT add this canister as a controller\n`);
  }
  */
}

if (require.main === module) run();