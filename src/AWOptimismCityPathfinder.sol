// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

/**
 * ▄▀█ ▀█▀ █░░ ▄▀█ █▄░█ ▀█▀ █ █▀   █░█░█ █▀█ █▀█ █░░ █▀▄
 * █▀█ ░█░ █▄▄ █▀█ █░▀█ ░█░ █ ▄█   ▀▄▀▄▀ █▄█ █▀▄ █▄▄ █▄▀
 *
 * Atlantis World is building the Web3 social metaverse by connecting Web3 with social, 
 * gaming and education in one lightweight virtual world that's accessible to everybody.
 */

import { ERC721 } from "solmate/tokens/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

contract AWOptimismCityPathfinder is ERC721 {
    /**
     * supply
     */
    uint256 public totalSupply = 0;

    /**
     * init
     */
    constructor() ERC721("Optimism City Pathfinder", "OPCP") {}

    /**
     * ownership
     */
    address public constant AtlantisWorld = 0x036C545Ae4f68059b4C83f7E3814429d4c73c089;
    address public constant MaxSchnaider = 0xb1D7daD6baEF98df97bD2d3Fb7540c08886e0299;

    modifier onlyOwners() {
        require(msg.sender == AtlantisWorld || msg.sender == MaxSchnaider, "AWOptimismCityPathfinder: who da fuck r u?");
        _;
    }

    /**
     * whitelisting
     */
    bytes32 public whitelistMerkleRoot;

    modifier onlyWhitelisted(bytes32[] calldata proof) {
        require(isWhitelisted(msg.sender, proof), "AWOptimismCityPathfinder: can not verify whitelisting");
        _;
    }
    function setWhitelistMerkleRoot(bytes32 _whitelistMerkleRoot) external onlyOwners {
        whitelistMerkleRoot = _whitelistMerkleRoot;
    }
    function isWhitelisted(address addr, bytes32[] calldata proof) public view returns (bool) {
        bytes32 leaf = keccak256(abi.encode(addr));
        bool verified = MerkleProof.verify(proof, whitelistMerkleRoot, leaf);
        return verified;
    }

    /**
     * airdrop
     */
    function airdrop(address to) external onlyOwners {
        uint256 tokenId = totalSupply + 1;
        totalSupply++;
        _safeMint(to, tokenId);
    }

    /**
     * claim
     */
    mapping(address => bool) addressToClaimed;

    modifier onlySingleClaim() {
        require(!addressToClaimed[msg.sender], "AWOptimismCityPathfinder: reward is already claimed");
        _;
    }

    function claim(bytes32[] calldata proof) external onlyWhitelisted(proof) onlySingleClaim {
        uint256 tokenId = totalSupply + 1;
        totalSupply++;
        addressToClaimed[msg.sender] = true;
        _safeMint(msg.sender, tokenId);
    }

    /**
     * metadata
     */
    string public constant baseURI = "ipfs://bafkreiaxxf6ji3xgrdmhqzrehvxwac7lt255uzwkssugeoc4d6gsrzsz5e";

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return baseURI;
    }
}