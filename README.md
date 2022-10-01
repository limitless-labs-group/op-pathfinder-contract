
# AW Alpha Pass smart contract project bootstrapped with Foundry + Hardhat

## Use with Foundry

Make sure to install foundry locally first: https://book.getfoundry.sh/getting-started/installation

```
git clone https://github.com/atlantis-world-core/alpha-pass-contract.git
cd alpha-pass-contract
forge install
```
### Test

```
forge test -vv
```

### Deploy

```
forge create src/AWAlphaPass.sol:AWAlphaPass --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --legacy
```

### Send transaction

```
cast send <CONTRACT_ADDRESS> "claimTo(address)()" <ADDRESS> --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --legacy --gas 1000000
```

## Use with Hardhat

```
npm install
npm run test
```