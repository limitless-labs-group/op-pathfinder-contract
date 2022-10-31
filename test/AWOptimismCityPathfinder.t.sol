// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { AWOptimismCityPathfinder } from "src/AWOptimismCityPathfinder.sol";
import { ECDSA } from"openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract AWOptimismCityPathfinderTest is Test {
    AWOptimismCityPathfinder awOptimismCityPathfinder;

    address MaxSchnaider = 0xb1D7daD6baEF98df97bD2d3Fb7540c08886e0299;

    function setUp() public {
        awOptimismCityPathfinder = new AWOptimismCityPathfinder();
    }

    function testOwnership() public {
        vm.expectRevert(bytes("AWOptimismCityPathfinder: Who da fuck r u?"));
        awOptimismCityPathfinder.airdrop(MaxSchnaider);
    }

    function testAirdrop() public {
        vm.prank(MaxSchnaider);
        awOptimismCityPathfinder.airdrop(MaxSchnaider);
        assertEq(awOptimismCityPathfinder.balanceOf(MaxSchnaider), 1);
        assertEq(awOptimismCityPathfinder.totalSupply(), 1);
    }

    // function testClaimOnInvalidSignature() public {
    //     vm.prank(MaxSchnaider);
    //     vm.expectRevert(bytes("AWOptimismCityPathfinder: Invalid signature"));
    //     awOptimismCityPathfinder.claim('0xd6aed7c7746865ecabc04c305c3e986729c8c2b3dd815f0fa580fec2a27cbb182256abb872ed3b3ae210910e0ffe0898c59ff08f76c9d807fa29f8176ed9bdb71b');
    // }

    // function testClaim() public {
    //     vm.prank(MaxSchnaider);
    //     awOptimismCityPathfinder.claim(merkleProof);
    //     assertEq(awOptimismCityPathfinder.balanceOf(MaxSchnaider), 1);
    //     assertEq(awOptimismCityPathfinder.totalSupply(), 1);
    // }

    // function testDoubleClaim() public {
    //     awOptimismCityPathfinder.setWhitelistMerkleRoot(merkleRoot);
    //     vm.prank(MaxSchnaider);
    //     awOptimismCityPathfinder.claim(merkleProof);
    //     vm.expectRevert(bytes("AWOptimismCityPathfinder: Alpha pass is already claimed"));
    //     awOptimismCityPathfinder.claim(merkleProof);
    // }

    function testTokenURI() public {
        assertEq(awOptimismCityPathfinder.tokenURI(10), awOptimismCityPathfinder.baseURI());
    }
}