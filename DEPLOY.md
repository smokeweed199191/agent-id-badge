# DEPLOY — Agent ID Badge

> Status 18 Nov 2026 ~22:40 WIB: **deploy BELUM terjadi — blocker, baca §1 dulu.**

## 1. Blocker: `baw` tidak bisa deploy kontrak

Terverifikasi 18 Nov ~22:35 WIB (bukan tebakan):

```
$ baw contract-call preview --binanceChainId 56 --from 0x620F…0189 \
    --value 0 --inputData 0x<creation bytecode> --json
{ "success": false, "error": { "code": 2, "name": "SERVICE_ERROR",
  "message": "to is required for EVM contract-call" } }
```

- `baw` 1.12.0 **tidak punya perintah deploy**. Satu-satunya jalur external-sign
  (`contract-call preview/execute`) wajib isi `--to` — deploy butuh `to` kosong.
- `baw wallet send` cuma kirim token ke alamat penerima (tidak ada field data).
- Deploy dari VM butuh private key wallet — **dilarang**: tidak pernah minta/pegangan
  seed atau private key user.
- Kesimpulan: deploy HARUS dari wallet yang kuncinya dipegang user (HP), bukan dari
  agent wallet via `baw`.

## 2. Jalur deploy yang bisa jalan: Remix dari HP user

**Persiapan (sekali, oleh Entong — sudah siap):**
- Source kontrak: `contract/src/AgentIDBadge.sol` (atau `AgentIDBadge.flattened.sol`).
- Tidak ada constructor argument. Tidak ada value (deploy value 0).
- Gas deploy terestimasi: **1.150.758 gas** (~0,0000575 BNB di 0,05 gwei).

**Langkah (user, dari HP — OKX app browser, karena OKX wallet yang dipakai buat deploy):**
1. Buka **OKX app → Discover/Browser → remix.ethereum.org**.
2. Buat file baru `AgentIDBadge.sol`, paste seluruh isi `AgentIDBadge.flattened.sol`.
3. Tab **Solidity Compiler**: pilih compiler **0.8.24**, centang **Enable optimization**,
   runs **200**, klik **Compile**.
4. Tab **Deploy & Run**: Environment **Injected Provider** (pilih OKX Wallet),
   pastikan network **BNB Smart Chain (56)**.
5. Pilih contract **AgentIDBadge**, klik **Deploy**, konfirmasi di wallet.
   Biaya ≈ 0,00006 BNB saat gas 0,05 gwei. **Deploy HANYA saat gas murah.**
6. Salin alamat kontrak hasil deploy → kirim ke Entong.

**Catatan soal BNB buat gas deploy:**
- Saldo BNB ada di **agent wallet** (0,0002346 BNB), BUKAN di OKX wallet.
- Supaya OKX wallet bisa deploy, perlu kirim dulu ~0,0001 BNB dari agent wallet ke
  alamat OKX `0xa6664671f96874463834a5f48701c6c0464daa65` (via `baw wallet send` —
  ini transfer biasa, BISA lewat baw; butuh persetujuan user karena ini pindah dana).
- Alternatif: user top-up BNB ke OKX dari sumber lain. Jangan top-up dari uang user
  tanpa perintah eksplisit.

## 3. Setelah deploy (oleh Entong)

1. Verifikasi alamat kontrak + deployer di 2 RPC (`cast call` / `cast code`).
2. Isi `frontend/config.json` → `contractAddress` = alamat hasil deploy.
3. Verifikasi source di BscScan (form web: solc 0.8.24, optimizer on, runs 200,
   file `AgentIDBadge.flattened.sol`, no constructor args).
4. Push repo ke GitHub publik (butuh PAT user, transient — sama seperti Gatekeeper).
5. Deploy frontend ke Railway (butuh Railway workspace token user + repo GitHub —
   sama seperti Gatekeeper; CLI login saat ini Unauthorized).
6. Update `BUILD.md` + `README.md` dengan alamat kontrak + link BscScan + URL frontend.
7. Submit hackathon (sebelum 9 Des 15:00 WIB) — langkah terpisah, user yang submit
   atau Entong setelah produk live + terverifikasi.
