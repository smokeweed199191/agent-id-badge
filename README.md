# Agent ID Badge — Free Soulbound Badge for Binance Agent ID Holders

Independent community project for the **Binance Agent ID Hackathon** (18 Nov – 9 Des 2026).
Not affiliated with or endorsed by Binance.

## What it is

A free ERC-721 badge. Any address holding a Binance Agent ID (`.ai`, SPACE ID
contract `0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F` on BNB Chain) can mint
**one badge, free** (value 0 — the minter only pays their own network gas).
The badge is **soulbound**: it cannot be transferred or sold.

- Contract: `contract/src/AgentIDBadge.sol` (single file, no external dependencies)
- Tests: `contract/test/AgentIDBadge.t.sol` — 9/9 pass (`forge test`)
- Deploy gas (estimated on BSC mainnet, 2 RPCs): **1.150.758 gas**
  (~0,0000575 BNB at 0,05 gwei; ~0,000115 BNB at 0,1 gwei)
- Frontend: `frontend/` — static page + tiny Node server (`npm start`), deployable on Railway
- Deployed contract address: **0x4741d1c90a4cd15ae98a7d6d270c6d9d6ed19fc8** — [BscScan](https://bscscan.com/address/0x4741d1c90a4cd15ae98a7d6d270c6d9d6ed19fc8), deploy tx [0x07b1390b…](https://bscscan.com/tx/0x07b1390b54924fd7c9bbd5942831b97e2b956d4ed1516d5e2baf7638d3f867c2) (block 134346863). Test mint #2 oleh arsap.ai OK; totalSupply 2 per 19 Nov 2026 ~00:00 WIB.

## Permissions / admin disclosure (required by the hackathon rules)

- **No owner. No admin functions.** There is no `owner`, no pause, no mint-by-admin,
  no withdraw, no upgrade, no fee setter.
- The contract **cannot receive BNB** (no payable function, no receive/fallback).
- `mint()` is the only state-changing function. It checks
  `AgentID.balanceOf(msg.sender) > 0` and `hasMinted[msg.sender] == false`, then
  mints token ID `totalSupply + 1` to the caller.
- `transferFrom` / `safeTransferFrom` / `approve` / `setApprovalForAll` always revert
  with `Soulbound()`.
- The contract promises **no returns, rewards, or airdrops**. The badge has no monetary value.

## How to mint (for holders)

1. Open the frontend, connect your wallet (Binance Wallet, MetaMask, or any injected
   wallet). No QR pairing, no login is stored anywhere.
2. The page checks on-chain that your address holds an Agent ID.
3. Press **Mint my free badge** and confirm in your wallet (value 0, you only pay gas).

## BscScan verification

- Compiler: solc **0.8.24**, optimizer **enabled**, runs **200**, license **MIT**.
- No constructor arguments. Flattened source: `AgentIDBadge.flattened.sol`.
- Verify via the BscScan web form (Contract → Verify & Publish) or
  `forge verify-contract --chain 56 --compiler-version v0.8.24+commit.e11b9ed9
  --optimizer-runs 200 <address> src/AgentIDBadge.sol:AgentIDBadge`
  (needs a BscScan API key).

## Deploy (for the deployer)

See `DEPLOY.md`. Summary: the Binance Agentic Wallet CLI (`baw` 1.12.0) **cannot
deploy contracts** (`contract-call` requires `--to`), so deployment must be done
from a wallet whose key the deployer controls (e.g. Remix + OKX/Binance app browser).
The compiled creation bytecode is in `creation-bytecode.txt`; the ABI in
`AgentIDBadge.abi.json`.
