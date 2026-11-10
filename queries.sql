-- 1. Cari pasien berdasarkan nama
SELECT * FROM pasien WHERE nama LIKE '%Riyanda%';

-- 2. Rekap kunjungan harian
SELECT tanggal_kunjungan, COUNT(*) as total_kunjungan 
FROM kunjungan GROUP BY tanggal_kunjungan;

-- 3. Stok obat yang menipis (kurang dari 10)
SELECT * FROM obat WHERE stok < 10;

-- 4. Riwayat kunjungan pasien + nama dokter
SELECT p.nama, d.nama_dokter, k.tanggal_kunjungan, k.keluhan
FROM kunjungan k
JOIN pasien p ON k.id_pasien = p.id_pasien
JOIN dokter d ON k.id_dokter = d.id_dokter;

-- 5. Total pasien
SELECT COUNT(*) as total_pasien FROM pasien;
