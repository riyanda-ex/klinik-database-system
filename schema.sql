-- Database Klinik
CREATE DATABASE IF NOT EXISTS klinik_db;
USE klinik_db;

-- Tabel Pasien
CREATE TABLE pasien (
  id_pasien INT AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(100) NOT NULL,
  tanggal_lahir DATE,
  no_hp VARCHAR(20),
  alamat TEXT
);

-- Tabel Dokter
CREATE TABLE dokter (
  id_dokter INT AUTO_INCREMENT PRIMARY KEY,
  nama_dokter VARCHAR(100) NOT NULL,
  spesialis VARCHAR(50)
);

-- Tabel Obat
CREATE TABLE obat (
  id_obat INT AUTO_INCREMENT PRIMARY KEY,
  nama_obat VARCHAR(100) NOT NULL,
  stok INT DEFAULT 0,
  harga INT
);

-- Tabel Kunjungan
CREATE TABLE kunjungan (
  id_kunjungan INT AUTO_INCREMENT PRIMARY KEY,
  id_pasien INT,
  id_dokter INT,
  tanggal_kunjungan DATE,
  keluhan TEXT,
  FOREIGN KEY (id_pasien) REFERENCES pasien(id_pasien),
  FOREIGN KEY (id_dokter) REFERENCES dokter(id_dokter)
);
