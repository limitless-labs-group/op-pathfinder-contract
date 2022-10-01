// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { AWAlphaPass } from "src/AWAlphaPass.sol";
import { Merkle } from "murky/Merkle.sol";

contract AWAlphaPassTest is Test {
    AWAlphaPass awAlphaPass;

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
        awAlphaPass = new AWAlphaPass();
    }

    function testOwnable() public {
        vm.prank(MaxSchnaider);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        awAlphaPass.setWhitelistMerkleRoot(merkleRoot);
    }

    function testWhitelist() public {
        awAlphaPass.setWhitelistMerkleRoot(merkleRoot);
        console.logBytes32(merkleRoot);
        assertEq(awAlphaPass.whitelistMerkleRoot(), merkleRoot);
        assertTrue(awAlphaPass.isWhitelisted(MaxSchnaider, merkleProof));
    }

    function testClaimUnwhitelisted() public {
        vm.prank(MaxSchnaider);
        vm.expectRevert(bytes("AWAlphaPass: Cant verify whitelisting"));
        awAlphaPass.claim(merkleProof);
    }

    function testClaim() public {
        awAlphaPass.setWhitelistMerkleRoot(merkleRoot);
        vm.prank(MaxSchnaider);
        awAlphaPass.claim(merkleProof);
        assertEq(awAlphaPass.balanceOf(MaxSchnaider), 1);
        assertEq(awAlphaPass.totalSupply(), 1);
    }

    // function testDoubleClaim() public {
    //     awAlphaPass.setWhitelistMerkleRoot(merkleRoot);
    //     vm.prank(MaxSchnaider);
    //     awAlphaPass.claim(merkleProof);
    //     vm.expectRevert(bytes("AWAlphaPass: Alpha pass is already claimed"));
    //     awAlphaPass.claim(merkleProof);
    // }

    function testClaimTo() public {
        awAlphaPass.claimTo(MaxSchnaider);
        assertEq(awAlphaPass.balanceOf(MaxSchnaider), 1);
        assertEq(awAlphaPass.totalSupply(), 1);
    }

    function testTokenURI() public {
        assertEq(awAlphaPass.tokenURI(10), awAlphaPass.baseURI());
    }
}