// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/**
 * ▄▀█ ▀█▀ █░░ ▄▀█ █▄░█ ▀█▀ █ █▀   █░█░█ █▀█ █▀█ █░░ █▀▄
 * █▀█ ░█░ █▄▄ █▀█ █░▀█ ░█░ █ ▄█   ▀▄▀▄▀ █▄█ █▀▄ █▄▄ █▄▀
 *
 * Atlantis World is building the Web3 social metaverse by connecting Web3 with social, 
 * gaming and education in one lightweight virtual world that's accessible to everybody.
 */

import { ERC721 } from "@solmate/tokens/ERC721.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract AWAlphaPass is ERC721, Ownable {
    uint256 public totalSupply = 0;
    string public baseURI = "ipfs://bafkreid5jb3arfd75i7srp7vafheud5qu7gv6wif4pbfz5eyyyz6l6qqcy";
    bytes32 public whitelistMerkleRoot;

    constructor() ERC721("Atlantis World Alpha Pass", "AWAP") {}

    modifier onlyWhitelisted(bytes32[] calldata proof) {
        require(isWhitelisted(msg.sender, proof), "AWAlphaPass: Can't verify whitelisting");
        _;
    }

    modifier onlySingleClaim() {
        require(!(balanceOf(msg.sender) > 0), "AWAlphaPass: Alpha pass is already claimed");
        _;
    }

    function setWhitelistMerkleRoot(bytes32 _whitelistMerkleRoot) external onlyOwner {
        whitelistMerkleRoot = _whitelistMerkleRoot;
    }

    function isWhitelisted(address addr, bytes32[] calldata proof) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encode(addr));
        bool verified = MerkleProof.verify(proof, whitelistMerkleRoot, leaf);
        return verified;
    }

    function claimTo(address to) external onlyOwner {
        uint256 tokenId = totalSupply + 1;
        _safeMint(to, tokenId);
        totalSupply++;
    }

    function claim(bytes32[] calldata proof) external onlyWhitelisted(proof) onlySingleClaim {
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
        return baseURI;
    }
}