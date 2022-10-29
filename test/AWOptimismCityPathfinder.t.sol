// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { AWOptimismCityPathfinder } from "src/AWOptimismCityPathfinder.sol";
import { Merkle } from "murky/Merkle.sol";

contract AWOptimismCityPathfinderTest is Test {
    AWOptimismCityPathfinder awOptimismCityPathfinder;

    address MaxSchnaider = 0xb1D7daD6baEF98df97bD2d3Fb7540c08886e0299;

    Merkle tree = new Merkle();
    bytes32[] whitelist = [
        keccak256(abi.encode(MaxSchnaider)),
        keccak256(abi.encode(0x4B7E3FD09d45B97EF1c29085FCAe143444E422e8)),
        keccak256(abi.encode(0x660FBab221eCD6F915a2b10e91471E7315A9FEC4))
    ];
    bytes32 merkleRoot = tree.getRoot(whitelist);
    bytes32[] merkleProof = tree.getProof(whitelist, 0);

    function setUp() public {
        awOptimismCityPathfinder = new AWOptimismCityPathfinder();
    }

    function testOwnership() public {
        vm.expectRevert(bytes("AWOptimismCityPathfinder: who da fuck r u?"));
        awOptimismCityPathfinder.setWhitelistMerkleRoot(merkleRoot);
    }

    function testWhitelist() public {
        vm.prank(MaxSchnaider);
        awOptimismCityPathfinder.setWhitelistMerkleRoot(merkleRoot);
        console.logBytes32(merkleRoot);
        assertEq(awOptimismCityPathfinder.whitelistMerkleRoot(), merkleRoot);
        assertTrue(awOptimismCityPathfinder.isWhitelisted(MaxSchnaider, merkleProof));
    }

    function testClaimUnwhitelisted() public {
        vm.prank(MaxSchnaider);
        vm.expectRevert(bytes("AWOptimismCityPathfinder: can not verify whitelisting"));
        awOptimismCityPathfinder.claim(merkleProof);
    }

    function testClaim() public {
        vm.prank(MaxSchnaider);
        awOptimismCityPathfinder.setWhitelistMerkleRoot(merkleRoot);
        assertTrue(awOptimismCityPathfinder.isWhitelisted(MaxSchnaider, merkleProof));
        // awOptimismCityPathfinder.claim(merkleProof);
        // assertEq(awOptimismCityPathfinder.balanceOf(MaxSchnaider), 1);
        // assertEq(awOptimismCityPathfinder.totalSupply(), 1);
    }

    // function testDoubleClaim() public {
    //     awOptimismCityPathfinder.setWhitelistMerkleRoot(merkleRoot);
    //     vm.prank(MaxSchnaider);
    //     awOptimismCityPathfinder.claim(merkleProof);
    //     vm.expectRevert(bytes("AWOptimismCityPathfinder: Alpha pass is already claimed"));
    //     awOptimismCityPathfinder.claim(merkleProof);
    // }

    function testAirdrop() public {
        vm.prank(MaxSchnaider);
        awOptimismCityPathfinder.airdrop(MaxSchnaider);
        assertEq(awOptimismCityPathfinder.balanceOf(MaxSchnaider), 1);
        assertEq(awOptimismCityPathfinder.totalSupply(), 1);
    }

    function testTokenURI() public {
        assertEq(awOptimismCityPathfinder.tokenURI(10), awOptimismCityPathfinder.baseURI());
    }
}