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
