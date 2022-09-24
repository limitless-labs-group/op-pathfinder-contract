// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import { AWAlphaPass } from "src/AWAlphaPass.sol";
import { Merkle } from "@murky/Merkle.sol";

contract NFTTokenTest is Test {
    AWAlphaPass awAlphaPass;

    address MaxSchnaider = 0xb1D7daD6baEF98df97bD2d3Fb7540c08886e0299;

    Merkle m = new Merkle();
    bytes32[] whitelist;
    bytes32 merkleRoot;
    bytes32[] merkleProof;

    function setUp() public {
        awAlphaPass = new AWAlphaPass();
        whitelist = new bytes32[](4);
        whitelist[0] = bytes32("0x00"); 
        whitelist[1] = bytes32("0x01"); 
        whitelist[2] = keccak256(abi.encode(MaxSchnaider)); 
        whitelist[3] = bytes32("0x03");
        merkleRoot = m.getRoot(whitelist); 
        merkleProof = m.getProof(whitelist, 2);
    }

    function testOwnable() public {
        vm.prank(MaxSchnaider);
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        awAlphaPass.setWhitelistMerkleRoot(merkleRoot);
    }

    function testWhitelist() public {
        awAlphaPass.setWhitelistMerkleRoot(merkleRoot);
        assertEq(awAlphaPass.whitelistMerkleRoot(), merkleRoot);
        assertTrue(awAlphaPass.isWhitelisted(MaxSchnaider, merkleProof));
    }

    function testClaimUnwhitelisted() public {
        vm.prank(MaxSchnaider);
        vm.expectRevert(bytes("AWAlphaPass: Can't verify whitelisting"));
        awAlphaPass.claim(merkleProof);
    }

    function testClaim() public {
        awAlphaPass.setWhitelistMerkleRoot(merkleRoot);
        vm.prank(MaxSchnaider);
        awAlphaPass.claim(merkleProof);
        assertEq(awAlphaPass.balanceOf(MaxSchnaider), 1);
        assertEq(awAlphaPass.totalSupply(), 1);
    }

    function testDoubleClaim() public {
        awAlphaPass.setWhitelistMerkleRoot(merkleRoot);
        awAlphaPass.claimTo(MaxSchnaider);
        vm.prank(MaxSchnaider);
        vm.expectRevert(bytes("AWAlphaPass: Alpha pass is already claimed"));
        awAlphaPass.claim(merkleProof);
    }

    function testClaimTo() public {
        awAlphaPass.claimTo(MaxSchnaider);
        assertEq(awAlphaPass.balanceOf(MaxSchnaider), 1);
        assertEq(awAlphaPass.totalSupply(), 1);
    }

    function testTokenURI() public {
        assertEq(awAlphaPass.tokenURI(10), awAlphaPass.baseURI());
    }
}