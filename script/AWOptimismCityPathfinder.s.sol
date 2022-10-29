// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {Script} from 'forge-std/Script.sol';
import {AWOptimismCityPathfinder} from "src/AWOptimismCityPathfinder.sol";

contract Deploy is Script {
  function run() external returns (AWOptimismCityPathfinder awOptimismCityPathfinder) {
    vm.startBroadcast();
    awOptimismCityPathfinder = new AWOptimismCityPathfinder();
    vm.stopBroadcast();
  }
}
