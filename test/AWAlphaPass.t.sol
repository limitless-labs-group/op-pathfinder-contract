// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {AWAlphaPass} from "src/AWAlphaPass.sol";

contract NFTTokenTest is Test {
    AWAlphaPass awAlphaPass;

    address MaxSchnaider = 0xb1D7daD6baEF98df97bD2d3Fb7540c08886e0299;

    function setUp() public {
        awAlphaPass = new AWAlphaPass();
    }

    function testClaimTo() public {
        awAlphaPass.claimTo(MaxSchnaider);
        assertEq(awAlphaPass.balanceOf(MaxSchnaider), 1);
        assertEq(awAlphaPass.totalSupply(), 1);
    }

    function testClaim() public {
        bytes32 proof = keccak256(abi.encodePacked(MaxSchnaider));
        awAlphaPass.claim(proof);
    }
}