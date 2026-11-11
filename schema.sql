-- Klinik Database System - V2.0 FINAL PERFECT
-- Standar: MySQL 8.0 / MariaDB + ISO 8601 + Normalisasi 3NF
-- Keamanan: TIDAK ADA nama / NIK / No. BPJS asli. Hanya ID anonim.
-- Semua data di repo ini SINTETIS untuk demo.
-- DISCLAIMER: Skema demo untuk portfolio & pembelajaran.
-- Produksi RS wajib enkripsi, audit log, dan backup sesuai Permenkes.

CREATE DATABASE IF NOT EXISTS klinik_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE klinik_db;

-- ================= TABEL 1: PASIEN (ANONIM) =================
CREATE TABLE IF NOT EXISTS pasien (
  id_pasien INT AUTO_INCREMENT PRIMARY KEY,
  kode_pasien VARCHAR(20) NOT NULL UNIQUE COMMENT 'Contoh: PAS-001, bukan NIK asli',
  nik_hash CHAR(64) NULL COMMENT 'SHA-256 dari NIK, bukan NIK asli. Boleh NULL untuk demo',
  tanggal_lahir DATE NOT NULL,
  jenis_kelamin ENUM('L', 'P') NOT NULL,
  golongan_darah VARCHAR(3) NULL COMMENT 'A+, A-, B+, B-, AB+, AB-, O+, O-',
  alergi TEXT NULL,
  kode_jaminan VARCHAR(20) NOT NULL DEFAULT 'UMUM' COMMENT 'JKN-PBI, JKN-MANDIRI, JKN-PPU, JAMKESDA, JAMPERSAL, JKK, SWASTA, UMUM',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_pasien_kode (kode_pasien),
  INDEX idx_pasien_jaminan (kode_jaminan),
  CONSTRAINT chk_golongan_darah CHECK (golongan_darah IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', NULL))
) ENGINE=InnoDB;

-- ================= TABEL 2: DOKTER =================
CREATE TABLE IF NOT EXISTS dokter (
  id_dokter INT AUTO_INCREMENT PRIMARY KEY,
  kode_dokter VARCHAR(20) NOT NULL UNIQUE COMMENT 'Contoh: DOK-001',
  nama_samaran VARCHAR(100) NOT NULL COMMENT 'Nama samaran untuk demo, bukan nama asli',
  spesialisasi VARCHAR(50) NOT NULL,
  no_str_hash CHAR(64) NULL COMMENT 'Hash STR, bukan nomor asli',
  is_aktif TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_dokter_spesialisasi (spesialisasi)
) ENGINE=InnoDB;

-- ================= TABEL 3: OBAT =================
CREATE TABLE IF NOT EXISTS obat (
  id_obat INT AUTO_INCREMENT PRIMARY KEY,
  kode_obat VARCHAR(20) NOT NULL UNIQUE COMMENT 'Contoh: OBT-001',
  nama_obat VARCHAR(100) NOT NULL,
  stok INT NOT NULL DEFAULT 0,
  stok_minimal INT NOT NULL DEFAULT 10,
  harga DECIMAL(12,2) NOT NULL DEFAULT 0 COMMENT 'Harga contoh, bukan harga beli asli',
  tanggal_expired DATE NOT NULL,
  is_fornas TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_obat_nama (nama_obat),
  INDEX idx_obat_expired (tanggal_expired),
  CONSTRAINT chk_stok_tidak_negatif CHECK (stok >= 0),
  CONSTRAINT chk_stok_minimal_tidak_negatif CHECK (stok_minimal >= 0),
  CONSTRAINT chk_harga_tidak_negatif CHECK (harga >= 0)
) ENGINE=InnoDB;

-- ================= TABEL 4: KUNJUNGAN =================
CREATE TABLE IF NOT EXISTS kunjungan (
  id_kunjungan INT AUTO_INCREMENT PRIMARY KEY,
  kode_kunjungan VARCHAR(20) NOT NULL UNIQUE COMMENT 'Contoh: KUN-001',
  id_pasien INT NOT NULL,
  id_dokter INT NOT NULL,
  tanggal_kunjungan DATE NOT NULL,
  diagnosis VARCHAR(100) NOT NULL,
  kode_icd10 VARCHAR(10) NOT NULL COMMENT 'Contoh: R50.9, I10',
  kode_jaminan VARCHAR(20) NOT NULL DEFAULT 'UMUM',
  status_klaim VARCHAR(30) NOT NULL DEFAULT 'BELUM_DIAJUKAN' COMMENT 'LAYAK_KLAIM, PERLU_PERBAIKAN, DITOLAK, BELUM_DIAJUKAN',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_pasien) REFERENCES pasien(id_pasien) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (id_dokter) REFERENCES dokter(id_dokter) ON DELETE RESTRICT ON UPDATE CASCADE,
  INDEX idx_kunjungan_tanggal (tanggal_kunjungan),
  INDEX idx_kunjungan_icd (kode_icd10),
  INDEX idx_kunjungan_jaminan (kode_jaminan)
) ENGINE=InnoDB;

-- ================= TABEL 5: RESEP (Penghubung) =================
CREATE TABLE IF NOT EXISTS resep (
  id_resep INT AUTO_INCREMENT PRIMARY KEY,
  id_kunjungan INT NOT NULL,
  id_obat INT NOT NULL,
  jumlah INT NOT NULL,
  aturan_pakai VARCHAR(100) NOT NULL DEFAULT '3x1',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_kunjungan) REFERENCES kunjungan(id_kunjungan) ON DELETE CASCADE,
  FOREIGN KEY (id_obat) REFERENCES obat(id_obat) ON DELETE RESTRICT,
  CONSTRAINT chk_jumlah_resep CHECK (jumlah > 0),
  UNIQUE KEY uniq_kunjungan_obat (id_kunjungan, id_obat)
) ENGINE=InnoDB;

-- ================= VIEW 1: REKAP HARIAN =================
CREATE OR REPLACE VIEW v_rekap_harian AS
SELECT
  tanggal_kunjungan,
  COUNT(*) AS total_kunjungan,
  COUNT(DISTINCT id_pasien) AS total_pasien_unik,
  SUM(CASE WHEN kode_jaminan LIKE 'JKN%' THEN 1 ELSE 0 END) AS total_jkn,
  SUM(CASE WHEN kode_jaminan = 'UMUM' THEN 1 ELSE 0 END) AS total_umum
FROM kunjungan
GROUP BY tanggal_kunjungan
ORDER BY tanggal_kunjungan DESC;

-- ================= VIEW 2: STOK KRITIS =================
CREATE OR REPLACE VIEW v_stok_kritis AS
SELECT
  kode_obat, nama_obat, stok, stok_minimal, tanggal_expired,
  CASE
    WHEN tanggal_expired < CURDATE() THEN 'EXPIRED - JANGAN DIJUAL'
    WHEN tanggal_expired <= DATE_ADD(CURDATE(), INTERVAL 90 DAY) THEN 'MAU EXPIRED'
    WHEN stok = 0 THEN 'STOK HABIS'
    WHEN stok <= stok_minimal THEN 'STOK MENIPIS'
    ELSE 'AMAN'
  END AS status_stok
FROM obat
WHERE stok <= stok_minimal OR tanggal_expired <= DATE_ADD(CURDATE(), INTERVAL 90 DAY)
ORDER BY tanggal_expired ASC;

-- ================= VIEW 3: KLAIM PERLU PERBAIKAN =================
CREATE OR REPLACE VIEW v_klaim_perlu_perbaikan AS
SELECT
  k.kode_kunjungan, k.tanggal_kunjungan, p.kode_pasien,
  k.diagnosis, k.kode_icd10, k.kode_jaminan, k.status_klaim
FROM kunjungan k
JOIN pasien p ON k.id_pasien = p.id_pasien
WHERE k.status_klaim IN ('PERLU_PERBAIKAN', 'DITOLAK')
ORDER BY k.tanggal_kunjungan DESC;

-- ================= TRIGGER: CEGAH STOK NEGATIF =================
DELIMITER //
CREATE TRIGGER IF NOT EXISTS trg_cegah_stok_negatif
BEFORE UPDATE ON obat
FOR EACH ROW
BEGIN
  IF NEW.stok < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stok tidak boleh negatif';
  END IF;
END //
DELIMITER ;

-- ============================================================
-- AUDIT LOG - Mencatat Semua Perubahan Data (Audit Trail)
-- Standar produksi RS: siapa, kapan, apa yang diubah
-- Versi MySQL 8.0
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_log (
  id_log INT AUTO_INCREMENT PRIMARY KEY,
  nama_tabel VARCHAR(50) NOT NULL,
  id_record INT NOT NULL,
  aksi VARCHAR(10) NOT NULL CHECK (aksi IN ('INSERT', 'UPDATE', 'DELETE')),
  data_lama TEXT NULL,
  data_baru TEXT NULL,
  diubah_oleh VARCHAR(50) DEFAULT 'system',
  diubah_pada TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_audit_tabel (nama_tabel),
  INDEX idx_audit_waktu (diubah_pada)
) ENGINE=InnoDB;

DELIMITER //

-- Trigger: Catat setiap perubahan di tabel pasien
CREATE TRIGGER IF NOT EXISTS trg_pasien_audit_update
AFTER UPDATE ON pasien
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (nama_tabel, id_record, aksi, data_lama, data_baru)
    VALUES (
        'pasien',
        OLD.id_pasien,
        'UPDATE',
        CONCAT('kode=', OLD.kode_pasien, ', jaminan=', OLD.kode_jaminan),
        CONCAT('kode=', NEW.kode_pasien, ', jaminan=', NEW.kode_jaminan)
    );
END //

-- Trigger: Catat setiap hapus pasien
CREATE TRIGGER IF NOT EXISTS trg_pasien_audit_delete
AFTER DELETE ON pasien
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (nama_tabel, id_record, aksi, data_lama, data_baru)
    VALUES (
        'pasien',
        OLD.id_pasien,
        'DELETE',
        CONCAT('kode=', OLD.kode_pasien, ', jaminan=', OLD.kode_jaminan),
        NULL
    );
END //

-- Trigger: Catat setiap perubahan stok obat
CREATE TRIGGER IF NOT EXISTS trg_obat_audit_update
AFTER UPDATE ON obat
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (nama_tabel, id_record, aksi, data_lama, data_baru)
    VALUES (
        'obat',
        OLD.id_obat,
        'UPDATE',
        CONCAT('kode=', OLD.kode_obat, ', stok=', OLD.stok),
        CONCAT('kode=', NEW.kode_obat, ', stok=', NEW.stok)
    );
END //

-- Trigger: Catat setiap kunjungan baru
CREATE TRIGGER IF NOT EXISTS trg_kunjungan_audit_insert
AFTER INSERT ON kunjungan
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (nama_tabel, id_record, aksi, data_lama, data_baru)
    VALUES (
        'kunjungan',
        NEW.id_kunjungan,
        'INSERT',
        NULL,
        CONCAT('pasien=', NEW.id_pasien, ', dokter=', NEW.id_dokter, ', diagnosis=', NEW.diagnosis)
    );
END //

DELIMITER ;
