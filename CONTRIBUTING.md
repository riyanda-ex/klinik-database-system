# Kontribusi

## Aturan Mutlak
1. JANGAN PERNAH upload data pasien asli (nama, NIK, No. RM, No. BPJS, PDF rekam medis, backup DB asli).
2. Gunakan data sintetis: `PAS-001`, `SHA2('...')`, nama samaran `dr. Contoh`.
3. Semua perubahan harus lolos `python test.py` - wajib 15/15.
4. Satu PR untuk satu fitur / perbaikan.
5. Jangan ubah skema tanpa update `seed.sql` + `queries.sql`.

## Cara
1. Fork repo ini
2. Buat branch: `git checkout -b tambah-view`
3. Jalankan test: `python test.py`
4. Buat Pull Request dengan deskripsi jelas
