-- Queries - Klinik Database System V2.0
-- Semua query pakai data anonim, tidak ada NIK asli
USE klinik_db;

-- 1. REKAP HARIAN - untuk laporan harian klinik
SELECT * FROM v_rekap_harian LIMIT 30;

-- 2. CEK STOK KRITIS - obat habis / menipis / mau expired / expired
SELECT * FROM v_stok_kritis;

-- 3. KLAIM PERLU PERBAIKAN - biar klaim BPJS tidak ditolak
SELECT * FROM v_klaim_perlu_perbaikan;

-- 4. CARI PASIEN BERDASARKAN KODE (bukan nama asli)
-- Ganti 'PAS-001' sesuai kebutuhan
SELECT kode_pasien, tanggal_lahir, jenis_kelamin, golongan_darah, alergi, kode_jaminan
FROM pasien
WHERE kode_pasien = 'PAS-001';

-- 5. RIWAYAT KUNJUNGAN 1 PASIEN
SELECT k.kode_kunjungan, k.tanggal_kunjungan, k.diagnosis, k.kode_icd10, k.kode_jaminan, k.status_klaim, d.nama_samaran AS dokter
FROM kunjungan k
JOIN dokter d ON k.id_dokter = d.id_dokter
JOIN pasien p ON k.id_pasien = p.id_pasien
WHERE p.kode_pasien = 'PAS-001'
ORDER BY k.tanggal_kunjungan DESC;

-- 6. TOTAL PASIEN PER JAMINAN - untuk laporan JKN nasional
SELECT kode_jaminan, COUNT(*) AS total_pasien
FROM pasien
GROUP BY kode_jaminan
ORDER BY total_pasien DESC;

-- 7. TOTAL KUNJUNGAN PER POLI / DIAGNOSIS (TOP 10)
SELECT diagnosis, kode_icd10, COUNT(*) AS total
FROM kunjungan
GROUP BY diagnosis, kode_icd10
ORDER BY total DESC
LIMIT 10;

-- 8. NILAI STOK TOTAL (stok x harga contoh)
SELECT SUM(stok * harga) AS total_nilai_stok FROM obat;

-- 9. OBAT PALING SERING DIRESEPKAN
SELECT o.nama_obat, SUM(r.jumlah) AS total_diresepkan
FROM resep r
JOIN obat o ON r.id_obat = o.id_obat
GROUP BY o.nama_obat
ORDER BY total_diresepkan DESC;

-- 10. CEK OBAT EXPIRED - WAJIB DIMUSNAHKAN, JANGAN DIJUAL
SELECT kode_obat, nama_obat, stok, tanggal_expired
FROM obat
WHERE tanggal_expired < CURDATE();

-- 11. CEK PASIEN ALERGI PENICILLIN - peringatan keselamatan
SELECT kode_pasien, golongan_darah, alergi
FROM pasien
WHERE LOWER(alergi) LIKE '%penicillin%';

-- 12. UPDATE STOK SETELAH RESEP - contoh transaksi aman
-- START TRANSACTION;
-- UPDATE obat SET stok = stok - 10 WHERE kode_obat = 'OBT-001' AND stok >= 10;
-- COMMIT;
