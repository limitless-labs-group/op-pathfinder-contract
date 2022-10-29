import { ExternalProvider } from "@ethersproject/providers";
import { expect } from "chai";
import { ethers, network } from "hardhat";
import { MerkleTree } from "merkletreejs";
import { AWOptimismCityPathfinder } from "../typechain-types";
import { MerkleTreeUtil } from "../utils/MerkleTree";

describe("AWOptimismCityPathfinder", () => {
    let awOptimismCityPathfinder: AWOptimismCityPathfinder;
    let owner, addrs;

    const hardhatProvider = new ethers.providers.Web3Provider(network.provider as unknown as ExternalProvider);

    const MaxSchnaider = '0xb1D7daD6baEF98df97bD2d3Fb7540c08886e0299';
    const MaxSchnaiderSigner = new ethers.Wallet(process.env.MS_PRIVATE_KEY ?? "", hardhatProvider);

    const whitelist = [
        MaxSchnaider,
        "0x4B7E3FD09d45B97EF1c29085FCAe143444E422e8",
        "0x660FBab221eCD6F915a2b10e91471E7315A9FEC4",
    ];

    const tree: MerkleTree = MerkleTreeUtil.createMerkleTree(whitelist);
    const merkleRoot = MerkleTreeUtil.createMerkleRoot(tree);
    const merkleProof = MerkleTreeUtil.createMerkleProof(
        tree,
        MaxSchnaider
    );
    console.log(merkleRoot)

    beforeEach(async () => {
        [owner, ...addrs] = await ethers.getSigners();

        const AWOptimismCityPathfinder = await ethers.getContractFactory("AWOptimismCityPathfinder");
        awOptimismCityPathfinder = await AWOptimismCityPathfinder.deploy();

        owner.sendTransaction({
            to: MaxSchnaider,
            value: ethers.utils.parseEther('1000'),
        });
    });

    const connectMaxSchnaider = () => {
        awOptimismCityPathfinder = awOptimismCityPathfinder.connect(MaxSchnaiderSigner);
    };

    it("Should revert if not owner", async () => {
        await expect(awOptimismCityPathfinder.setWhitelistMerkleRoot(merkleRoot)).to.be.revertedWith('AWOptimismCityPathfinder: who da fuck r u?');
    });

    it("Should set new whitelist merkle root", async () => {
        connectMaxSchnaider();
        await awOptimismCityPathfinder.setWhitelistMerkleRoot(merkleRoot);
        expect(await awOptimismCityPathfinder.whitelistMerkleRoot()).to.be.equal(merkleRoot);
    });

    it("Should revert if claimer isnt whitelisted", async () => {
        await expect(awOptimismCityPathfinder.claim(merkleProof)).to.be.revertedWith('AWOptimismCityPathfinder: can not verify whitelisting');
    });

    it("Should claim if whitelisted", async () => {
        connectMaxSchnaider();
        await awOptimismCityPathfinder.setWhitelistMerkleRoot(merkleRoot);
        await awOptimismCityPathfinder.claim(merkleProof);
        expect(await awOptimismCityPathfinder.balanceOf(MaxSchnaider)).to.be.equal(1);
        expect(await awOptimismCityPathfinder.totalSupply()).to.be.equal(1);
    });

    it("Should airdrop to user if called by owner", async () => {
        connectMaxSchnaider();
        await awOptimismCityPathfinder.airdrop(MaxSchnaider);
        expect(await awOptimismCityPathfinder.balanceOf(MaxSchnaider)).to.be.equal(1);
        expect(await awOptimismCityPathfinder.totalSupply()).to.be.equal(1);
    });
});