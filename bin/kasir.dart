import 'dart:io';

void main() {
  // Data katalog oleh-oleh khas Medan menggunakan Map dan Record
  final Map<String, ({String nama, String kategori, int harga})> katalog = {
    'P01': (nama: 'Kopi Sidikalang 250 g', kategori: 'Kopi', harga: 45000),
    'P02': (nama: 'Kopi Gayo 250 g', kategori: 'Kopi', harga: 55000),
    'P03': (nama: 'Teh Kayu Aro 100 g', kategori: 'Teh', harga: 25000),
    'P04': (nama: 'Gula Aren 500 g', kategori: 'Pemanis', harga: 30000),
    'P05': (nama: 'Bolu Meranti', kategori: 'Makanan', harga: 80000),
  };

  print('=' * 54);
  print('             KATALOG TOKO OLEH-OLEH MEDAN             ');
  print('=' * 54);

  // TODO 1: tampilkan katalog sebagai tabel rapi (kode, nama, harga)
  //          dengan padRight/padLeft.
  print(
    '${'Kode'.padRight(6)}'
    '${'Nama Produk'.padRight(25)}'
    '${'Kategori'.padRight(11)}'
    '${'Harga'.padLeft(12)}',
  );
  print('-' * 54);

  for (final entry in katalog.entries) {
    final String kode = entry.key.padRight(6);
    final String nama = entry.value.nama.padRight(25);
    final String kategori = entry.value.kategori.padRight(11);
    final String harga = 'Rp ${entry.value.harga}'.padLeft(12);
    print('$kode$nama$kategori$harga');
  }
  print('=' * 54);
  print('');

  // Membaca input pesanan dari pengguna
  stdout.write('Pesanan (contoh: P01x2, P03x1): ');
  final String rawInput = stdin.readLineSync() ?? '';
  // Menghapus karakter BOM atau karakter tak terlihat jika ada
  final String input = rawInput.replaceAll('\uFEFF', '').trim();
  print('');

  // List untuk menampung pesanan yang valid
  final List<
          ({String kode, String nama, String kategori, int harga, int jumlah})>
      daftarPesanan = [];

  // List untuk mencatat pesanan yang ditolak
  final List<String> itemDitolak = [];

  // TODO 2: pecah input dengan split(',') lalu split('x') untuk tiap item.
  final List<String> rawItems = input.split(',');

  for (final rawItem in rawItems) {
    final String item = rawItem.trim();
    if (item.isEmpty) {
      continue;
    }

    // Mendukung pemisah 'x' maupun 'X'
    final List<String> parts = item.toLowerCase().split('x');
    if (parts.length != 2) {
      itemDitolak.add('$item (format harus KodexJumlah)');
      continue;
    }

    // Mengambil kode dan membersihkan karakter non-alfanumerik jika ada
    final String kode =
        parts[0].replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    final int? jumlah = int.tryParse(parts[1].trim());

    // Validasi jumlah: harus angka valid dan lebih dari 0
    if (jumlah == null || jumlah <= 0) {
      itemDitolak.add('$item (jumlah tidak valid)');
      continue;
    }

    // TODO 3: cari produk dengan katalog[kode]. Hasilnya NULLABLE:
    //          tangani kode yang tidak ada tanpa membuat program crash.
    final ({String nama, String kategori, int harga})? produk = katalog[kode];

    if (produk == null) {
      // Null safety: jika kode tidak ada di katalog, produk bernilai null
      itemDitolak.add('$item (kode produk tidak ditemukan)');
    } else {
      // Promosi tipe: di dalam blok ini, compiler menjamin produk bukan null
      daftarPesanan.add((
        kode: kode,
        nama: produk.nama,
        kategori: produk.kategori,
        harga: produk.harga,
        jumlah: jumlah,
      ));
    }
  }

  // TODO 4: hitung subtotal tiap item (map) dan total (fold);
  //          beri diskon 10% jika total >= 100000.
  final daftarItemDenganSubtotal = daftarPesanan.map((item) {
    final int subtotal = item.harga * item.jumlah;
    return (
      kode: item.kode,
      nama: item.nama,
      kategori: item.kategori,
      harga: item.harga,
      jumlah: item.jumlah,
      subtotal: subtotal,
    );
  }).toList();

  final int total = daftarItemDenganSubtotal.fold<int>(
    0,
    (sum, item) => sum + item.subtotal,
  );

  // Diskon 10% jika total belanja mencapai atau melebihi 100.000
  final double diskon = total >= 100000 ? total * 0.10 : 0.0;
  final double totalBayar = total - diskon;

  // Set kategori yang dibeli (menghilangkan duplikasi kategori secara otomatis)
  final Set<String> kategoriDibeli =
      daftarItemDenganSubtotal.map((item) => item.kategori).toSet();

  // TODO 5: cetak struk, Set kategori yang dibeli, dan daftar item yang ditolak.
  print('=' * 54);
  print('                    STRUK BELANJA                     ');
  print('=' * 54);

  if (daftarItemDenganSubtotal.isEmpty) {
    print('Tidak ada pesanan valid yang dapat diproses.');
  } else {
    print(
      '${'Nama Produk'.padRight(26)}'
      '${'Qty'.padLeft(4)}'
      '${'Harga'.padLeft(10)}'
      '${'Subtotal'.padLeft(14)}',
    );
    print('-' * 54);

    for (final item in daftarItemDenganSubtotal) {
      final String nama = item.nama.padRight(26);
      final String qty = item.jumlah.toString().padLeft(4);
      final String harga = 'Rp ${item.harga}'.padLeft(10);
      final String subtotal = 'Rp ${item.subtotal}'.padLeft(14);
      print('$nama$qty$harga$subtotal');
    }

    print('-' * 54);
    print('${'Total Belanja'.padRight(38)}: Rp $total');
    print(
      '${'Diskon (10%)'.padRight(38)}: Rp ${diskon.toStringAsFixed(0)}',
    );
    print(
      '${'Total Bayar'.padRight(38)}: Rp ${totalBayar.toStringAsFixed(0)}',
    );
    print('-' * 54);
    print('Kategori dibeli : ${kategoriDibeli.join(', ')}');
  }

  // Tampilkan daftar item yang ditolak jika ada
  if (itemDitolak.isNotEmpty) {
    print('-' * 54);
    print('Item yang ditolak:');
    for (final alasan in itemDitolak) {
      print('  * $alasan');
    }
  }

  print('=' * 54);
}
