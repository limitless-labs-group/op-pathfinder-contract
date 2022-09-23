// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/**
 * ▄▀█ ▀█▀ █░░ ▄▀█ █▄░█ ▀█▀ █ █▀   █░█░█ █▀█ █▀█ █░░ █▀▄
 * █▀█ ░█░ █▄▄ █▀█ █░▀█ ░█░ █ ▄█   ▀▄▀▄▀ █▄█ █▀▄ █▄▄ █▄▀
 *
 * Atlantis World is building the Web3 social metaverse by connecting Web3 with social, 
 * gaming and education in one lightweight virtual world that's accessible to everybody.
 */

import {ERC721} from "@solmate/tokens/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract AWAlphaPass is ERC721, Ownable {
    uint256 public totalSupply = 0;
    string public baseURI = "ipfs://bafkreifwketchptowimgirw5zxbcunp53azihwfz3kh5kw3qcbofazj5ea";
    bytes32 public whitelistMerkleRoot;

    constructor() ERC721("Atlantis World Alpha Pass", "AWAP") {}

    modifier onlyUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    modifier onlyWhitelisted(bytes32[] calldata proof) {
        bytes32 leaf = keccak256(abi.encode(msg.sender));
        bool verified = MerkleProof.verify(proof, whitelistMerkleRoot, leaf);
        require(verified, "Can't verify whitelisting");
        _;
    }

    modifier onlySingleClaim() {
        require(!(balanceOf(msg.sender) > 0), "Alpha pass is already claimed");
        _;
    }

    function setWhitelistMerkleRoot(bytes32 _whitelistMerkleRoot) external onlyOwner {
        whitelistMerkleRoot = _whitelistMerkleRoot;
    }

    function claimTo(address to) external onlyOwner {
        uint256 tokenId = totalSupply + 1;
        _safeMint(to, tokenId);
        totalSupply++;
    }

    function claim(bytes32[] calldata proof) external onlyUser onlyWhitelisted(proof) onlySingleClaim {
        uint256 tokenId = totalSupply + 1;
        _safeMint(msg.sender, tokenId);
        totalSupply++;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return string(abi.encodePacked(baseURI));
    }
}