-- Seed Data SINTETIS - BUKAN DATA ASLI
-- Jalankan setelah schema.sql: SOURCE seed.sql;
USE klinik_db;

-- Pasien contoh
INSERT INTO pasien (kode_pasien, nik_hash, tanggal_lahir, jenis_kelamin, golongan_darah, alergi, kode_jaminan) VALUES
('PAS-001', SHA2('3201010101900001', 256), '1990-05-20', 'L', 'O+', 'penicillin', 'JKN-PBI'),
('PAS-002', SHA2('3201010101900002', 256), '1985-11-11', 'P', 'A+', NULL, 'JKN-MANDIRI'),
('PAS-003', SHA2('3201010101900003', 256), '2000-01-15', 'P', 'B+', NULL, 'UMUM'),
('PAS-004', SHA2('3201010101900004', 256), '1978-03-08', 'L', 'AB+', 'sulfa', 'JAMKESDA'),
('PAS-005', SHA2('3201010101900005', 256), '1995-07-22', 'P', 'O-', NULL, 'JAMPERSAL');

-- Dokter contoh (nama samaran)
INSERT INTO dokter (kode_dokter, nama_samaran, spesialisasi, no_str_hash) VALUES
('DOK-001', 'dr. Contoh Umum', 'Umum', SHA2('STR-CONTOH-001', 256)),
('DOK-002', 'dr. Contoh Anak', 'Anak', SHA2('STR-CONTOH-002', 256)),
('DOK-003', 'dr. Contoh Gigi', 'Gigi', SHA2('STR-CONTOH-003', 256));

-- Obat contoh (harga contoh)
INSERT INTO obat (kode_obat, nama_obat, stok, stok_minimal, harga, tanggal_expired, is_fornas) VALUES
('OBT-001', 'Paracetamol', 50, 10, 5000, '2027-06-30', 1),
('OBT-002', 'Amoxicillin', 5, 10, 12000, '2027-01-15', 1),
('OBT-003', 'Oralit', 0, 10, 3000, '2027-03-01', 1),
('OBT-004', 'Vitamin C', 20, 10, 8000, '2025-01-01', 0),
('OBT-005', 'Omeprazole', 8, 10, 15000, '2026-12-20', 1),
('OBT-006', 'Cetirizine', 40, 10, 7000, '2027-09-01', 1);

-- Kunjungan contoh
INSERT INTO kunjungan (kode_kunjungan, id_pasien, id_dokter, tanggal_kunjungan, diagnosis, kode_icd10, kode_jaminan, status_klaim) VALUES
('KUN-001', 1, 1, '2026-11-11', 'demam', 'R50.9', 'JKN-PBI', 'LAYAK_KLAIM'),
('KUN-002', 2, 1, '2026-11-11', 'hipertensi', 'I10', 'JKN-MANDIRI', 'LAYAK_KLAIM'),
('KUN-003', 3, 2, '2026-11-10', 'diare', 'A09.9', 'UMUM', 'BELUM_DIAJUKAN'),
('KUN-004', 4, 1, '2026-11-10', 'demam', 'J00', 'JAMKESDA', 'PERLU_PERBAIKAN'),
('KUN-005', 5, 1, '2026-11-09', 'flu', 'J11.1', 'JAMPERSAL', 'LAYAK_KLAIM');

-- Resep contoh
INSERT INTO resep (id_kunjungan, id_obat, jumlah, aturan_pakai) VALUES
(1, 1, 10, '3x1'),
(2, 5, 10, '1x1'),
(3, 3, 5, '3x1'),
(5, 6, 10, '1x1');
