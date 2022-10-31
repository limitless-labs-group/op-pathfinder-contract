import { ExternalProvider } from "@ethersproject/providers";
import { expect } from "chai";
import { ethers, network } from "hardhat";
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { AWOptimismCityPathfinder } from "../typechain-types";

describe("AWOptimismCityPathfinder", () => {
    let awOptimismCityPathfinder: AWOptimismCityPathfinder;
    let deployer: SignerWithAddress, addrs: SignerWithAddress[];

    const hardhatProvider = new ethers.providers.Web3Provider(network.provider as unknown as ExternalProvider);

    const MaxSchnaider = '0xb1D7daD6baEF98df97bD2d3Fb7540c08886e0299';
    const MaxSchnaiderWallet = new ethers.Wallet(process.env.MS_PRIVATE_KEY ?? "", hardhatProvider);

    beforeEach(async () => {
        [deployer, ...addrs] = await ethers.getSigners();

        const AWOptimismCityPathfinder = await ethers.getContractFactory("AWOptimismCityPathfinder");
        awOptimismCityPathfinder = await AWOptimismCityPathfinder.deploy();

        deployer.sendTransaction({
            to: MaxSchnaider,
            value: ethers.utils.parseEther('1000'),
        });
    });

    const connectMaxSchnaider = () => {
        awOptimismCityPathfinder = awOptimismCityPathfinder.connect(MaxSchnaiderWallet);
    };

    it("Should revert if not an owner", async () => {
        await expect(awOptimismCityPathfinder.airdrop(MaxSchnaider)).to.be.revertedWith('AWOptimismCityPathfinder: Who da fuck r u?');
    });

    it("Should airdrop to user if called by owner", async () => {
        connectMaxSchnaider();
        await awOptimismCityPathfinder.airdrop(MaxSchnaider);
        expect(await awOptimismCityPathfinder.balanceOf(MaxSchnaider)).to.be.equal(1);
        expect(await awOptimismCityPathfinder.totalSupply()).to.be.equal(1);
    });

    it("Should revert if invalid signature", async () => {
        const hash = ethers.utils.solidityKeccak256(['address'], [deployer.address])
        const signature = await deployer.signMessage(ethers.utils.arrayify(hash))
        await expect(awOptimismCityPathfinder.claim(signature)).to.be.revertedWith('AWOptimismCityPathfinder: Invalid signature');
    });

    it("Should claim if valid signature", async () => {
        const hash = ethers.utils.solidityKeccak256(['address'], [deployer.address])
        const signature = await MaxSchnaiderWallet.signMessage(ethers.utils.arrayify(hash))
        await awOptimismCityPathfinder.claim(signature);
        expect(await awOptimismCityPathfinder.balanceOf(deployer.address)).to.be.equal(1);
        expect(await awOptimismCityPathfinder.totalSupply()).to.be.equal(1);
    });

    it("Should revert double claim", async () => {
        const hash = ethers.utils.solidityKeccak256(['address'], [deployer.address])
        const signature = await MaxSchnaiderWallet.signMessage(ethers.utils.arrayify(hash))
        await awOptimismCityPathfinder.claim(signature);
        expect(await awOptimismCityPathfinder.balanceOf(deployer.address)).to.be.equal(1);
        expect(await awOptimismCityPathfinder.totalSupply()).to.be.equal(1);
        await expect(awOptimismCityPathfinder.claim(signature)).to.be.revertedWith('AWOptimismCityPathfinder: Reward is already claimed');
    });
});