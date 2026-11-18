# BUILD — Agent ID Badge (Binance Agent ID Hackathon)

> Konsep 1 dari SCOPE.md. Status: **DEPLOYED + TEST MINT OK (19 Nov 2026 ~00:00 WIB)**. User approved ("gas aja", 18 Nov ~22:19 WIB).
> Kontrak live: **0x4741d1c90a4cd15ae98a7d6d270c6d9d6ed19fc8** — deploy tx 0x07b1390b54924fd7c9bbd5942831b97e2b956d4ed1516d5e2baf7638d3f867c2 (block 134346863), deployer OKX 0xa666…, gas 1.140.539 (~0,000057 BNB ≈ Rp600). Test mint #2 oleh agent wallet (arsap.ai): tx 0x179c223398eac864f8dd7f27ca61e306e3b5535112393f7e1b0b486b2de5fade (block 134347680), totalSupply 2. Badge #1 sudah dimiliki 0xDbe747d877F81661Ead1cA440D636a99BBCe837f (orang asing, bukan wallet user).
> Aturan keras: deploy HANYA saat gas ≤0,1 gwei; jangan top-up; jangan minta seed/key.

## 0. Pre-flight live check (18 Nov ~22:2x WIB)

| Cek | RPC 1 (bsc-dataseed) | RPC 2 (bsc.publicnode) |
|---|---|---|
| Block | 134334352 | 134334362 |
| Gas price | 0,05 gwei | 0,05 gwei |
| Saldo wallet agent 0x620F…0189 | 0,00023456 BNB (234.556.275.862.724 wei) | sama |
| Agent ID balanceOf | 1 | 1 |

- Gas 0,05 gwei ≤ 0,1 gwei → **GATE LULUS**. Budget gas: 234.556.275.862.724 / 50.000.000 = ~4.691.125 gas.
- Deploy estimasi 1,0–1,5 jt gas = ~0,00005–0,000075 BNB. Sisa margin ~0,00016 BNB.

## 1. Tooling

- forge 1.9.0 + cast (foundry, `~/.foundry/bin`) ✓
- baw 1.12.0 (`~/workspace/.npm-global/bin/baw`) ✓ — TIDAK ada perintah deploy; deploy lewat `contract-call preview/execute` (cek apakah `--to` bisa kosong).
- Railway CLI: TIDAK terinstall; ada sesi lama di `~/.railway/sessions/` (15 Nov). Gatekeeper dulu deploy via Railway dashboard/GitHub (repo smokeweed199191/agent-games-gatekeeper, server.cjs + `npm start`).
- BscScan API key: BELUM dicek (env kosong). Verifikasi kemungkinan via form web (parent/browser) atau API key.

## 2. Kontrak — AgentIDBadge (ERC-721 soulbound, free mint)

- File: `contract/src/AgentIDBadge.sol` (single-file, tanpa dependensi eksternal — gampang diverifikasi di BscScan).
- `mint()`: gratis (value 0), gate `AgentID.balanceOf(msg.sender) > 0`, 1 badge/alamat, tokenId urut dari 1.
- Soulbound: `transferFrom` / `safeTransferFrom` / `approve` / `setApprovalForAll` revert.
- `tokenURI`: on-chain SVG (data URI JSON+base64, dibuat di kontrak) — badge mandiri, tidak tergantung hosting.
- TIDAK ADA fungsi owner/admin sama sekali (no mint/pause/withdraw oleh siapa pun) — didokumentasikan di README.
- **Hasil: `forge build` OK (solc 0.8.24, optimizer on, runs 200); `forge test` 9/9 PASS** (mint holder OK, non-holder revert, double-mint revert, transfer revert, approve revert, tokenURI OK + nonexistent revert, supportsInterface, mint gratis/tidak ambil BNB).
- Deploy gas terestimasi mainnet (2 RPC, `cast estimate`): **1.150.758 gas** — 0,0000575379 BNB @0,05 gwei; 0,0001150758 BNB @0,1 gwei. Bytecode 5.057 byte.
- Commit lokal: `45fd837` ("Agent ID Badge: ERC-721 soulbound free minter (9/9 tests pass)") — BELUM push (butuh PAT user).
- Artefak: `creation-bytecode.txt`, `AgentIDBadge.abi.json`, `AgentIDBadge.flattened.sol` (174 baris, buat verifikasi BscScan).

## 3. Deploy — ✅ LIVE (18 Nov 2026 ~23:54 WIB, via browser Mises)

**Deploy BERHASIL — bukan via Remix (HP user kepanasan, browser keluar sendiri), bukan via halaman deploy di Bitget (baca saldo/gas stuck: provider timeout + fetch diblokir), tapi via browser Mises yang lancar.**
- Tx deploy: `0x07b1390b54924fd7c9bbd5942831b97e2b956d4ed1516d5e2baf7638d3f867c2`, block 134346863, status 1.
- Kontrak: **0x4741d1c90a4cd15ae98a7d6d270c6d9d6ed19fc8** — BscScan: https://bscscan.com/address/0x4741d1c90a4cd15ae98a7d6d270c6d9d6ed19fc8
- Deployer: OKX `0xa6664671f96874463834a5f48701c6c0464daa65`. Gas dipakai 1.140.539 (~0,000057 BNB ≈ Rp600). OKX sisa 0,000043 BNB.
- Terverifikasi on-chain (bsc-dataseed): code 5.028 byte, `name()` = "Agent ID Badge", `symbol()` = "AIDB", `AGENT_ID()` = 0x60B9…22F (benar), `totalSupply()` = 0 saat deploy.
- Test mint #2 oleh agent wallet (arsap.ai) 19 Nov ~00:00 WIB: tx `0x179c223398eac864f8dd7f27ca61e306e3b5535112393f7e1b0b486b2de5fade`, block 134347680, gas 100.464 (~0,000012 BNB ≈ Rp126), `ownerOf(2)` = agent, totalSupply 2. Gate Agent ID terbukti jalan.
- Badge #1 sudah dimiliki `0xDbe747d877F81661Ead1cA440D636a99BBCe837f` (bukan wallet user) sebelum test mint — pelajaran: amankan tokenId 1 segera setelah deploy kontrak free-mint, sebelum verifikasi panjang.
- **`baw` 1.12.0 TIDAK BISA deploy kontrak — terverifikasi, bukan tebakan.** `baw contract-call preview` tanpa `--to` → `{"success": false, "error": {"code": 2, "name": "SERVICE_ERROR", "message": "to is required for EVM contract-call"}}`. Tidak ada perintah deploy di `baw --help`. `wallet send` cuma kirim token, tidak ada field data. Deploy dari VM butuh private key — DILARANG (tidak pernah minta/pegangan seed/key user).

## 4. Verifikasi BscScan + repo publik

- Verifikasi: BELUM — alamat kontrak sudah ada (0x4741d1c90a4cd15ae98a7d6d270c6d9d6ed19fc8). Setting siap: solc 0.8.24, optimizer on, runs 200, file `AgentIDBadge.flattened.sol`, no constructor args. BscScan API key: tidak ada — verifikasi via form web (BscScan diblokir Cloudflare buat cloud browser → dari browser HP user, Mises lancar).
- Repo GitHub publik: BELUM push (butuh PAT user, transient — sama seperti Gatekeeper). Commit lokal siap (`45fd837`) + update alamat kontrak (belum commit).
- `frontend/config.json`: SUDAH diisi contractAddress = 0x4741d1c90a4cd15ae98a7d6d270c6d9d6ed19fc8 (19 Nov ~00:05 WIB).

## 5. Frontend (Railway) — kode SELESAI, deploy BELUM

- File: `frontend/index.html` (connect injected wallet, cek Agent ID on-chain, tombol Mint, tampilkan total minted + preview badge), `frontend/config.json` (contractAddress SUDAH diisi 0x4741d1c90a4cd15ae98a7d6d270c6d9d6ed19fc8), `frontend/server.cjs` + `package.json` (`npm start`).
- Smoke test lokal: `node server.cjs` → `GET /` 200, `GET /config.json` 200 ✓.
- **Deploy Railway BELUM: `railway whoami` → "Unauthorized. Please login with `railway login`"** (sesi lama 15 Nov tidak berlaku di CLI 5.75.0). Jalur Gatekeeper dulu: token workspace Railway user (transient, TIDAK tercatat) + GraphQL API + push GitHub via PAT user. Keduanya butuh user kirim ulang token/PAT.

## 6. Blocker / catatan

- **BLOCKER 1 — deploy kontrak:** SELESAI 18 Nov ~23:54 WIB via browser Mises (deploy tx di atas). `baw` tetap tidak bisa deploy — jangan coba lagi.
- **BLOCKER 2 — deploy frontend + repo publik:** butuh Railway workspace token + GitHub PAT user (keduanya transient, tidak tercatat).
- **BLOCKER 3 — verifikasi BscScan:** alamat kontrak sudah ada; verifikasi via form web dari browser HP user (Mises) karena BscScan diblokir Cloudflare buat cloud browser; tanpa API key.
- Yang SUDAH selesai dan tidak tergantung deploy: kontrak + 9/9 test + estimasi gas + bytecode/ABI/flattened + frontend + smoke test + README + DEPLOY.md + commit lokal.
- Promo X (Community Promotion) SUDAH selesai di sisi user (submit form "Berhasil Dikirim" 18 Nov ~22:18 WIB) — bukan bagian build ini.
