# Contoh Output - Klinik Database System V2.0

Ini adalah contoh output nyata kalau `schema.sql` sudah di-run di MySQL dan diisi data demo sintetis.
Semua data di sini **SINTETIS**, bukan data pasien asli.

Cara menghasilkan output ini:
```bash
mysql -u root klinik_db < schema.sql
python test.py
# HASIL: 18 PASS, 0 FAIL dari 18 test
