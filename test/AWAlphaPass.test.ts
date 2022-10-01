import { ExternalProvider } from "@ethersproject/providers";
import { expect } from "chai";
import { ethers, network } from "hardhat";
import { MerkleTree } from "merkletreejs";
import { AWAlphaPass } from "../typechain-types";
import { MerkleTreeUtil } from "../utils/MerkleTree";

describe("AWAlphaPass", () => {
    let awAlphaPass: AWAlphaPass;
    let owner, addrs;

    const hardhatProvider = new ethers.providers.Web3Provider(network.provider as unknown as ExternalProvider);

    const MaxSchnaiderAddr = '0xb1D7daD6baEF98df97bD2d3Fb7540c08886e0299';
    const MaxSchnaiderSigner = new ethers.Wallet(process.env.MS_PRIVATE_KEY ?? "", hardhatProvider);

    const whitelist = [
        MaxSchnaiderAddr,
        "0x4B7E3FD09d45B97EF1c29085FCAe143444E422e8",
        "0x660FBab221eCD6F915a2b10e91471E7315A9FEC4",
    ];

    const tree: MerkleTree = MerkleTreeUtil.createMerkleTree(whitelist);
    const merkleRoot = MerkleTreeUtil.createMerkleRoot(tree);
    const merkleProof = MerkleTreeUtil.createMerkleProof(
        tree,
        MaxSchnaiderAddr
    );

    beforeEach(async () => {
        [owner, ...addrs] = await ethers.getSigners();

        const AWAlphaPass = await ethers.getContractFactory("AWAlphaPass");
        awAlphaPass = await AWAlphaPass.deploy();

        owner.sendTransaction({
            to: MaxSchnaiderAddr,
            value: ethers.utils.parseEther('1000'),
        });
    });

    const connectMaxSchnaider = () => {
        awAlphaPass = awAlphaPass.connect(MaxSchnaiderSigner);
    };

    it("Should revert if not owner", async () => {
        connectMaxSchnaider();
        await expect(awAlphaPass.setWhitelistMerkleRoot(merkleRoot)).to.be.revertedWith('Ownable: caller is not the owner');
    });

    it("Should set new whitelist merkle root", async () => {
        await awAlphaPass.setWhitelistMerkleRoot(merkleRoot);
        expect(await awAlphaPass.whitelistMerkleRoot()).to.be.equal(merkleRoot);
    });

    it("Should revert if claimer isnt whitelisted", async () => {
        connectMaxSchnaider();
        await expect(awAlphaPass.claim(merkleProof)).to.be.revertedWith('AWAlphaPass: Cant verify whitelisting');
    });

    it("Should claim if whitelisted", async () => {
        await awAlphaPass.setWhitelistMerkleRoot(merkleRoot);
        connectMaxSchnaider();
        await awAlphaPass.claim(merkleProof);
        expect(await awAlphaPass.balanceOf(MaxSchnaiderAddr)).to.be.equal(1);
        expect(await awAlphaPass.totalSupply()).to.be.equal(1);
    });

    it("Should claim to user if called by owner", async () => {
        await awAlphaPass.claimTo(MaxSchnaiderAddr);
        expect(await awAlphaPass.balanceOf(MaxSchnaiderAddr)).to.be.equal(1);
        expect(await awAlphaPass.totalSupply()).to.be.equal(1);
    });
});