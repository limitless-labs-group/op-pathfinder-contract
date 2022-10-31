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
import { ECDSA } from"openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract AWOptimismCityPathfinder is ERC721 {
    /**
     * enumerable
     */
    uint256 public totalSupply = 0;
    mapping(address => uint256) public ownedTokenId;

    /**
     * init
     */
    constructor() ERC721("Optimism City Pathfinder", "OPCP") {}

    /**
     * ownership
     */
    address public constant AtlantisWorld = 0x036C545Ae4f68059b4C83f7E3814429d4c73c089;
    address public constant MaxSchnaider = 0xb1D7daD6baEF98df97bD2d3Fb7540c08886e0299;

    modifier onlyOwner() {
        require(msg.sender == AtlantisWorld || msg.sender == MaxSchnaider, "AWOptimismCityPathfinder: Who da fuck r u?");
        _;
    }

    modifier signedByOwner(bytes calldata signature) {
        bytes32 hash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(msg.sender)));
        address signer = ECDSA.recover(hash, signature);
        require(signer == AtlantisWorld || signer == MaxSchnaider, 'AWOptimismCityPathfinder: Invalid signature');
        _;
    }

    /**
     * airdrop
     */
    function airdrop(address to) external onlyOwner {
        uint256 tokenId = totalSupply + 1;
        totalSupply++;
        ownedTokenId[msg.sender] = tokenId;
        _safeMint(to, tokenId);
    }

    /**
     * claim
     */
    mapping(address => bool) public hasClaimed;

    modifier onlySingleClaim() {
        require(!hasClaimed[msg.sender], "AWOptimismCityPathfinder: Reward is already claimed");
        _;
    }

    function claim(bytes calldata signature) external signedByOwner(signature) onlySingleClaim {
        uint256 tokenId = totalSupply + 1;
        totalSupply++;
        hasClaimed[msg.sender] = true;
        ownedTokenId[msg.sender] = tokenId;
        _safeMint(msg.sender, tokenId);
    }

    /**
     * metadata
     */
    string public constant baseURI = "ipfs://bafkreibikjwbjdj2yo3agy2szjkgd6v3cq4l6zthx34jnzthva2aa3nhtm";

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        return baseURI;
    }
}