# 🏥 Klinik Database System

[MySQL](https://img.shields.io/badge/MySQL-8.0-blue)
[Tests](https://github.com/riyanda-ex/klinik-database-system/actions/workflows/test.yml/badge.svg)
[License](https://img.shields.io/badge/License-MIT-green)
[Standard](https://img.shields.io/badge/Standard-3NF%20%2B%20FHIR%20Ready-orange)
[Status](https://img.shields.io/badge/Status-Selesai-green)
[Klinik](https://img.shields.io/badge/Klinik-Al%20Madina%20Husada-teal)

Sistem database klinik lengkap & aman: manajemen pasien anonim, dokter, obat, kunjungan, resep, rekap harian, cek stok kritis, & cek klaim BPJS. Terhubung ke sistem JKN nasional Indonesia.

Dibuat untuk Klinik Al Madina Husada, Nganjuk.

> **Disclaimer:** Skema demo untuk portfolio & pembelajaran. BUKAN sistem produksi RS. Data di repo ini 100% sintetis, bukan data pasien asli. Produksi wajib enkripsi + audit log.

## 🌐 Masalah
- Pencatatan pasien & stok obat klinik masih manual, rawan salah & lambat saat dicari.
- Data pasien asli rawan bocor kalau disimpan tanpa anonimisasi.
- Klaim BPJS sering ditolak karena data kunjungan tidak rapi.

## 💡 Solusi
Database ternormalisasi 3NF dengan:
- **Anonimisasi:** NIK disimpan sebagai hash SHA-256, pasien hanya `PAS-001`
- **Keamanan:** CHECK stok tidak negatif, Trigger cegah stok negatif, Foreign Key
- **JKN Nasional:** Kolom `kode_jaminan` untuk JKN-PBI, JKN-Mandiri, Jamkesda, Jampersal, JKK, Swasta, Umum
- **Otomatis:** 3 VIEW (rekap harian, stok kritis, klaim perlu perbaikan)

## ✨ Fitur
- 5 Tabel: `pasien`, `dokter`, `obat`, `kunjungan`, `resep`
- 3 VIEW: rekap harian, stok kritis (expired / menipis / habis), klaim perlu perbaikan
- 1 Trigger: cegah stok negatif
- 12 Query siap pakai: rekap, stok, klaim, riwayat pasien, nilai stok
- Seed data sintetis 5 pasien, 3 dokter, 6 obat, 5 kunjungan
- 15 Test Otomatis

## 🚀 Cara Pakai
```bash
# 1. Buat database
mysql -u root -p < schema.sql

# 2. Isi data contoh (sintetis)
mysql -u root -p < seed.sql

# 3. Jalankan query
mysql -u root -p klinik_db < queries.sql

# 4. Jalankan test
python test.py
