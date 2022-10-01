import { getAddress, isAddress } from "ethers/lib/utils";
import { MerkleTree } from "merkletreejs";
import { ethers } from "ethers";
const { keccak256 } = ethers.utils;

const abiEncode = (addr: string) => Buffer.from(addr.substring(2).padStart(32 * 2, '0'), "hex");

export class MerkleTreeUtil {
  public static createMerkleTree = (addrs: string[]): MerkleTree => {
    const leaves = addrs.map((addr) =>
      keccak256(abiEncode(addr))
    );
    return new MerkleTree(leaves, keccak256, {
      sort: true,
    });
  };

  public static createMerkleProof = (
    tree: MerkleTree,
    addr: string,
    index?: number
  ): string[] => {
    const leave = keccak256(abiEncode(addr))
    return tree.getHexProof(leave, index);
  };

  public static createMerkleRoot = (tree: MerkleTree): string =>
    tree.getHexRoot();

  public static formatAddrs = (addrs: string[]): string[] =>
    addrs
      .filter((addr) => isAddress(addr))
      .map((addr) => getAddress(addr.trim()));
}