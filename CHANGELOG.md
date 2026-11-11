# Changelog - Klinik Database System

Semua perubahan penting di repo ini dicatat di sini.
Format ini mengikuti standar internasional Keep a Changelog.

## [2.0.0] - 2026-11-11

### Ditambahkan
- 5 tabel lengkap: `pasien`, `dokter`, `obat`, `kunjungan`, `resep`
- 3 VIEW: `v_rekap_harian`, `v_stok_kritis`, `v_klaim_perlu_perbaikan`
- 1 Trigger: `trg_cegah_stok_negatif` - cegah stok negatif
- `seed.sql` - data sintetis 100% (5 pasien, 3 dokter, 6 obat, 5 kunjungan)
- `test.py` - 15 test otomatis
- Dukungan 10 jaminan nasional: JKN-PBI, JKN-MANDIRI, JKN-PPU, JKN-BP, JKN-BBL, JAMKESDA, JAMPERSAL, JKK, SWASTA, UMUM
- README badge profesional + layout center + tabel + contoh output

### Diperbaiki
- Anonimisasi pasien: NIK disimpan sebagai hash SHA-256, pasien hanya `PAS-001`
- Nama dokter diganti jadi nama samaran `dr. Contoh`, bukan nama asli
- README dari 3 paragraf jadi lengkap: masalah, solusi, fitur, cara pakai, struktur, contoh, keamanan
- Keamanan: tambah CHECK stok tidak negatif + Foreign Key + Index

### Keamanan
- Data pasien asli tidak pernah disimpan di repo
- Backup DB asli diblokir oleh `.gitignore`
- Tambah `SECURITY.md` + `CONTRIBUTING.md`

## [1.0.0] - 2026-11-10

### Ditambahkan
- Rilis awal: `schema.sql` dasar (4 tabel)
- `queries.sql` dasar (rekap + stok)
- `README.md` awal (3 paragraf)
- `LICENSE` MIT

### Catatan
- Versi 1.0 masih belum ada data sintetis, belum ada test, belum ada keamanan anonimisasi.
- Jangan pakai versi 1.0 untuk demo, pakai versi 2.0.
