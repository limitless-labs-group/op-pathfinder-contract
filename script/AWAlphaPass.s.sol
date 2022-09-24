// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Script} from 'forge-std/Script.sol';
import {AWAlphaPass} from "src/AWAlphaPass.sol";

contract Deploy is Script {
  function run() external returns (AWAlphaPass awAlphaPass) {
    vm.startBroadcast();
    awAlphaPass = new AWAlphaPass();
    vm.stopBroadcast();
  }
}

// deploy cmd
// forge create src/AWAlphaPass.sol:AWAlphaPass --rpc-url https://opt-goerli.g.alchemy.com/v2/kWZ8YJZFfStiHTBmEFzVkID9KKrKI8ZD --private-key <KEY> --legacy