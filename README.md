<div align="center">

# 🏥 Klinik Database System

### Sistem Database Klinik Aman, Ternormalisasi & Siap JKN Nasional

![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Tests](https://img.shields.io/badge/Tests-15%2F15%20Passing-brightgreen?style=for-the-badge&logo=githubactions&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Production%20Ready-success?style=for-the-badge)

![Version](https://img.shields.io/badge/Version-2.0-blue)
![Standard](https://img.shields.io/badge/Standard-3NF%20%2B%20FHIR%20Ready-orange)
![Security](https://img.shields.io/badge/Security-Anonymized%20%2B%20SHA--256-red)
![Indonesia](https://img.shields.io/badge/Indonesia-JKN%20%2B%20BPJS-red)
![Klinik](https://img.shields.io/badge/Klinik-Al%20Madina%20Husada-teal)

**Sistem database klinik lengkap & aman: pasien anonim, dokter, obat, kunjungan, resep, rekap harian, cek stok kritis, & cek klaim BPJS.**

Dibuat untuk **Klinik Al Madina Husada, Nganjuk.**

</div>

> [!WARNING]
> **Disclaimer:** Skema demo untuk portfolio & pembelajaran. BUKAN sistem produksi RS. Data di repo ini 100% sintetis, bukan data pasien asli. Produksi wajib enkripsi + audit log.

---

## 📸 Preview

| Fitur | Hasil |
| --- | --- |
| 📊 Rekap Harian | `v_rekap_harian` - total kunjungan per hari |
| 💊 Stok Kritis | `v_stok_kritis` - expired / menipis / habis |
| 🛡️ Klaim BPJS | `v_klaim_perlu_perbaikan` - cegah klaim ditolak |
| 🔒 Anonimisasi | NIK -> hash SHA-256, pasien hanya `PAS-001` |

## 🌐 Masalah

- ❌ Pencatatan pasien & stok obat klinik masih manual, rawan salah & lambat saat dicari
- ❌ Data pasien asli rawan bocor kalau disimpan tanpa anonimisasi
- ❌ Klaim BPJS sering ditolak karena data kunjungan tidak rapi

## 💡 Solusi

Database ternormalisasi **3NF** dengan:

- 🔒 **Anonimisasi:** NIK disimpan sebagai hash SHA-256, pasien hanya `PAS-001`
- 🛡️ **Keamanan:** CHECK stok tidak negatif, Trigger cegah stok negatif, Foreign Key
- 🇮🇩 **JKN Nasional:** Kolom `kode_jaminan` untuk JKN-PBI, JKN-Mandiri, Jamkesda, Jampersal, JKK, Swasta, Umum
- ⚡ **Otomatis:** 3 VIEW (rekap harian, stok kritis, klaim perlu perbaikan)

## ✨ Fitur Utama

- ✅ 5 Tabel: `pasien`, `dokter`, `obat`, `kunjungan`, `resep`
- ✅ 3 VIEW: rekap harian, stok kritis, klaim perlu perbaikan
- ✅ 1 Trigger: cegah stok negatif
- ✅ 12 Query siap pakai: rekap, stok, klaim, riwayat pasien, nilai stok
- ✅ Seed data sintetis 5 pasien, 3 dokter, 6 obat, 5 kunjungan
- ✅ 15 Test Otomatis

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
