# Binance Agent ID Hackathon — SCOPE

> Scoping saja. BELUM deploy, BELUM keluar uang, BELUM submit apa pun.
> Dibuat: 18 Nov 2026 ~22:15 WIB. Sumber aturan: pengumuman resmi Binance
> (https://www.binance.com/en/support/announcement/detail/95f5dbe0ea674a48a739b59e046648bf).

## 1. Aturan yang penting

**Jadwal**
- Submit: 18 Nov 2026 08:00 UTC → **9 Des 2026 08:00 UTC (15:00 WIB)**.
- Review internal: 9–17 Des. Public review: 17–20 Des. Hadiah cair ≤14 hari kerja setelah itu.

**Total hadiah: 60.000 USDC**, dibagi 3:
| Kategori | Total | Cara menang |
|---|---|---|
| Project Awards | 29.000 USDC | Top 10 by metrik on-chain (jumlah alamat Agent ID yang interaksi, volume/jumlah tx). 1st $10.000, 2nd $6.000, 3rd $4.000, 4th $3.000, 5th $2.000, 6–10 $800. |
| Innovation Award | 29.000 USDC | Panel juri (Binance Wallet + BNB Chain), top 10, nominal sama. Dinilai: kedalaman integrasi Agent ID 30%, practicality 25%, kelengkapan produk 25%, inovasi 20%. |
| Community Promotion | 2.000 USDC | 20 pemenang × $100. Post X original soal proyek peserta + hashtag #BinanceWalletHackathon + #AgenticWallet, submit link via survei Binance. |

**Syarat ikut (proyek)**
- Kontrak deploy di BNB Chain, source terverifikasi + open-source di BscScan.
- Aktif pakai Agent ID buat use case nyata (access control, payments, identity).
- Proyek baru maupun lama boleh; tiap tim cuma 1 proyek.
- **Innovation Award: produk harus live + minimal 30 alamat Agent ID interaksi selama periode submit.** Ini syarat keras.
- Hadiah proyek dikirim ke alamat reward yang diisi waktu submit. Pemenang 2 kategori award (20 proyek) masing-masing dapat 1 slot klaim Agent ID 2-digit.
- Tiap proyek cuma bisa dapat 1 award.

**Red lines (langgar 1 saja = diskualifikasi langsung)**
- Dilarang QR login web buat Agentic Wallet (user tidak boleh scan QR / masukin pairing code di website pihak ketiga; sesi login user tidak boleh disimpan di server).
- Dilarang bypass konfirmasi transaksi user (operasi aset: transfer/trade/approval — user harus lihat + konfirmasi sendiri).
- Dilarang transfer tanpa izin (scheduled collection, transfer otomatis ke alamat tetap, transfer ekstra tersembunyi, minta unlimited approval diam-diam).
- Kontrak harus open-source + izin owner (mint, ubah tax, pause, freeze, tarik dana) didokumentasikan jelas.
- Dilarang pakai brand Binance/BNB buat nyamar jadi resmi.
- Dilarang kumpulin seed phrase, private key, API secret, pairing code.
- Dilarang janjiin return ("passive income", "automatic money-making").
- Produk trading wajib tampilkan risk warning di halaman.
- **Agent ID dilarang dibungkus jadi alat "cari wallet orang lain pakai nama".**
- Dilarang manipulasi volume / daftar akun massal buat interaksi palsu.

## 2. Agent ID di on-chain — terverifikasi langsung

Kontrak: **`0x60b9262456de011f7d15a54cdd8c48baaa8b022f`** (SPACE ID Agent ID, ERC-721, non-transferable).

Dicek live 18 Nov ~22:15 WIB di **2 RPC** (bsc-dataseed.binance.org + bsc.publicnode.com):
- `name()` = **"SPACE ID Agent ID"**, `symbol()` = **"AI"**. Kode kontrak ada (8.756 byte).
- `balanceOf(0x620FdE721b441f9F664e60A5d63E109F5E6e0189)` = **1 di kedua RPC** → wallet agent (arsap.ai) confirmed pegang 1 Agent ID.
- `totalSupply()` dan `tokenOfOwnerByIndex()` **revert** — kontrak TIDAK implement ERC721Enumerable. Jadi TIDAK ada cara on-chain buat list token ID / nama dari alamat.

**Pola integrasi (satu-satunya yang didukung, sesuai pengumuman):**
```solidity
interface IAgentID { function balanceOf(address owner) external view returns (uint256); }
IAgentID constant AGENT_ID = IAgentID(0x60b9262456de011f7d15a54cdd8c48baaa8b022f);

modifier onlyAgentIDHolder() {
    require(AGENT_ID.balanceOf(msg.sender) > 0, "Agent ID required");
    _;
}
```
- Gate di `mint()` / `vote()` / `claim()` pakai modifier di atas. Tidak perlu (dan tidak bisa) baca nama `.ai` dari kontrak ini — nama hanya ada di metadata/registry SPACE ID off-chain.
- Resolusi nama `.ai` → alamat butuh registry SPACE ID (SID) terpisah — nambah kompleksitas + risiko, hindari kalau bisa.

**Biaya gas (live, 18 Nov ~22:15 WIB)**
- Gas price BSC saat ini: **0,05 gwei** (sangat murah; pernah ~1 gwei di jam sibuk).
- Saldo wallet agent: **0,0002346 BNB** (~Rp2.460). Budget gas di 0,05 gwei = ~4,69 juta gas.
- Deploy kontrak sederhana (ERC-721 mint): ~1,0–1,5 juta gas → **~0,00005–0,000075 BNB (~Rp900–1.350)**. MUAT.
- Deploy kontrak menengah (voting/escrow): ~2–3 juta gas → **~0,0001–0,00015 BNB (~Rp1.800–2.700)**. MUAT, tapi sisakan reserve.
- **Peringatan:** kalau gas naik ke ~1 gwei, deploy 1,5 juta gas = 0,0015 BNB → TIDAK MUAT. Deploy HANYA saat gas ≤0,1 gwei, dan cek dulu sebelum broadcast.
- Frontend: Railway (sudah dipakai buat Gatekeeper) — $0.

## 3. Konsep dApp — yang BENAR-BENAR pakai Agent ID di alur inti

**Realita yang tidak bisa ditawar:** user tanpa audiens (X @jojocmah 13 hari, ~0 follower; akun lama suspended), tanpa budget marketing, tanpa komunitas. Satu-satunya magnet yang bisa narik holder Agent ID adalah **sesuatu yang GRATIS buat mereka** (mereka cuma bayar gas sendiri ~0,05 gwei ≈ Rp0,0x per tx). Distribusi cuma lewat: post user sendiri di Binance Square + X + grup Telegram/Discord BNB Chain/agent + hashtag hackathon. Tidak ada jalan lain yang gratis.

| # | Konsep | Effort build | Peluang 30+ holder interaksi (3 minggu, 0 audiens) | Gas deploy |
|---|---|---|---|---|
| **1** | **Agent ID Badge — "Proof of Agent" free minter.** Holder Agent ID mint 1 NFT badge gratis (1/alamat, non-transferable, gambar generatif sederhana). Kontrak cek `balanceOf > 0` di `mint()`. Use case: identity / proof-of-holder. | RENDAH (1–2 hari: 1 kontrak ERC-721 + frontend 1 halaman) | **RENDAH–SEDANG (~15–25%)** — paling besar dari ketiganya, karena gratis + simpel + alasan jelas buat holder (koleksi badge). Tapi tetap butuh postingan user nyebar ke tempat yang tepat. | ~0,00005–0,00008 BNB |
| **2** | **Agent Wall — voting harian gratis.** Holder Agent ID vote on-chain tiap hari buat 1 pertanyaan (mis. proyek agent minggu ini). Hasil publik. Kontrak cek `balanceOf > 0` di `vote()`. Use case: identity-gated governance mini. | SEDANG (3–4 hari: kontrak round harian + frontend + konten pertanyaan tiap hari) | RENDAH (~10%) — vote itu gratis tapi tidak ada hadiahnya; orang tidak punya alasan kuat buat datang tiap hari. Butuh maintenance konten harian. | ~0,0001 BNB |
| **3** | **Tip antar Agent — kirim tip pakai nama .ai.** Holder A tip holder B; kontrak escrow + claim, kedua pihak wajib pegang Agent ID. Use case: payments + identity. | SEDANG–TINGGI (4–6 hari: escrow + claim + resolusi nama `.ai`→alamat via registry SPACE ID, itu integrasi kedua yang rawan) | RENDAH (<10%) — two-sided: butuh pen-tip DAN penerima; tidak ada insentif buat tip orang asing. Paling lemah buat bootstrap dari nol. | ~0,0001–0,00015 BNB |

**Yang TIDAK masuk daftar (sengaja dibuang):**
- Direktori / leaderboard "cari wallet orang dari nama .ai" — **DILARANG eksplisit di red lines.**
- Faucet/token gratis — butuh modal buat isi pool; user nol modal.
- Apa pun yang minta user connect QR Agentic Wallet di web — **DILARANG eksplisit.**

**Penilaian jujur soal 30 holder:**
- **Project Awards (top 10 by metrik): praktis 0%.** Proyek yang sudah punya ratusan–ribuan user akan isi top 10. Proyek baru dari nol tidak bisa kejar dalam 3 minggu.
- **Innovation Award: satu-satunya jalur teoretis, tapi tetap long shot.** Butuh (a) 30 holder interaksi — peluang ~15–25% buat konsep 1 dengan promosi manual maksimal, (b) panel juri menilai produk layak top 10 — di luar kontrol kita.
- **Community Promotion ($100 × 20): ini uang yang realistis.** Gratis, tidak butuh build, tidak butuh 30 holder. Draft post X bisa dibuat kapan saja; user yang post dari HP-nya.

## 4. Rekomendasi

**Verdict: BANGUN konsep 1 (Agent ID Badge) sebagai tiket lotre murah — TAPI hanya setelah post promo X selesai, dan dengan hard stop.**

Alasan: biaya nyaris nol (deploy ~Rp1.000 + 1–2 hari kerja Entong; filing bug bounty lagi ke-block nunggu Studio wave, watcher make.fun jalan otomatis — kapasitas ada). Upside kalau tembus Innovation top 10: minimal $800. Expected value kasar: ~20% × $800 = $160 lawan biaya ~Rp1.000. Tapi ini TETAP lotre — jangan anggap bakal menang, jangan korbankan garapan lain buat ini.

**Hard stop: 30 Nov 2026.** Kalau sampai 30 Nov jumlah minter unik <15 alamat Agent ID, STOP promosi + stop pengembangan. Fokus balik ke bug bounty + make.fun. Jangan kejar 30 holder dengan cara apa pun yang melanggar red lines (no fake account, no beli interaksi).

**Langkah pertama kalau lanjut (berurutan):**
1. **Promo X dulu (hari ini):** draft post Community Promotion (soal proyek peserta hackathon / ekosistem Agent ID) → user post dari @jojocmah pakai #BinanceWalletHackathon + #AgenticWallet → submit link via survei Binance. $100, tanpa build.
2. **User konfirmasi build:** "gas badge" + setuju gas deploy ~0,00005–0,00008 BNB dari wallet agent (deploy HANYA saat gas ≤0,1 gwei).
3. **Kontrak (hari 1):** ERC-721 `AgentIDBadge`, `mint()` gratis (value 0) + modifier `onlyAgentIDHolder`, max 1/alamat, non-transferable (sesuai semangat Agent ID). Repo GitHub publik, source terverifikasi di BscScan.
4. **Frontend (hari 1–2):** 1 halaman di Railway — tombol connect (injected wallet: Binance Wallet/MetaMask; JANGAN pakai QR pairing Agentic Wallet), tombol Mint, tampilkan badge + jumlah minter. Tampilkan risk/disclaimer secukupnya; JANGAN janjiin return/hadiah.
5. **Submit proyek** (sebelum 9 Des 15:00 WIB): nama proyek, website, alamat kontrak, deskripsi pemakaian Agent ID, alamat reward (wallet agent).
6. **Distribusi (user, dari HP):** post di Binance Square + X + grup Telegram/Discord BNB Chain & komunitas agent; pantau jumlah minter unik on-chain tiap hari (baca event Transfer/mint).
7. **30 Nov — checkpoint hard stop:** <15 minter → stop. ≥15 → lanjut dorong sampai 9 Des.

**Yang TIDAK dilakukan:** tidak ada deploy tanpa perintah user; tidak ada janji menang; tidak ada interaksi palsu; tidak ada pungutan biaya dari holder (mint gratis, mereka cuma bayar gas sendiri).
