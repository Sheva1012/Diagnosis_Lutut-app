import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Opsional
import 'admin_sidebar.dart';
import '../services/admin/cedera_service.dart';

class AdminKelolaCedera extends StatefulWidget {
  const AdminKelolaCedera({Key? key}) : super(key: key);

  @override
  State<AdminKelolaCedera> createState() => _AdminKelolaCederaState();
}

class _AdminKelolaCederaState extends State<AdminKelolaCedera> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final CederaService _cederaService = CederaService();

  List<Map<String, dynamic>> _cederaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _cederaService.getAllCedera();
      setState(() {
        _cederaList = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  void _filterCedera(String query) async {
    if (query.isEmpty) {
      _loadData();
    } else {
      setState(() => _isLoading = true);
      try {
        final data = await _cederaService.searchCedera(query);
        setState(() {
          _cederaList = data;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- 1. Dialog Detail (Menampilkan Data Lengkap) ---
  void _showDetailDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFF1E88E5)),
              SizedBox(width: 10),
              Text("Detail Cedera"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem("Kode Cedera", item['kode_cedera'] ?? '-'),
                const Divider(),
                _buildDetailItem("Nama Cedera", item['nama_cedera'] ?? '-'),
                const Divider(),
                _buildDetailItem("Deskripsi", item['deskripsi'] ?? '-'),
                const Divider(),
                _buildDetailItem("Penyebab", item['penyebab'] ?? '-'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup", style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, color: Colors.black87), textAlign: TextAlign.justify),
      ],
    );
  }

  // --- 2. Dialog Form ---
  void _showFormDialog({Map<String, dynamic>? item}) {
    final isEdit = item != null;
    final TextEditingController kodeController = TextEditingController(text: item?['kode_cedera'] ?? '');
    final TextEditingController namaController = TextEditingController(text: item?['nama_cedera'] ?? '');
    final TextEditingController deskripsiController = TextEditingController(text: item?['deskripsi'] ?? '');
    final TextEditingController penyebabController = TextEditingController(text: item?['penyebab'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Cedera' : 'Tambah Cedera'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: kodeController,
                  decoration: const InputDecoration(labelText: 'Kode Cedera', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Cedera', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: deskripsiController,
                  decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: penyebabController,
                  decoration: const InputDecoration(labelText: 'Penyebab', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (kodeController.text.isNotEmpty && namaController.text.isNotEmpty && deskripsiController.text.isNotEmpty && penyebabController.text.isNotEmpty) {
                  Navigator.pop(context);
                  try {
                    if (isEdit) {
                      await _cederaService.updateCedera(item['id_cedera'], kodeController.text, namaController.text, deskripsiController.text, penyebabController.text);
                    } else {
                      await _cederaService.addCedera(kodeController.text, namaController.text, deskripsiController.text, penyebabController.text);
                    }
                    _loadData();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // --- 3. Hapus Data ---
  void _deleteCedera(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Cedera'),
        content: const Text('Yakin hapus data ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _cederaService.deleteCedera(id);
              _loadData();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        title: const Text('Data Cedera', style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
      ),
      drawer: const AdminSidebar(activePage: 'cedera'),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Filter & Add Button (Area Putih Terpisah)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterCedera,
                      decoration: const InputDecoration(
                        hintText: 'Cari Cedera...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.add_box, size: 40, color: Color(0xFF1E88E5)),
                  onPressed: () => _showFormDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Tabel Data (Card Style dengan Shadow)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  // Header Table
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    child: Row(
                      children: [
                        // Pengaturan Flex (Proporsi Lebar) agar muat semua
                        _buildHeaderCell('No', flex: 2),        // Cukup lebar
                        _buildHeaderCell('Kode', flex: 3),      // Sedikit lebih lebar
                        _buildHeaderCell('Nama', flex: 4),      // Nama Cedera
                        _buildHeaderCell('Deskripsi', flex: 4),     // Deskripsi (Singkat)
                        _buildHeaderCell('Penyebab', flex: 4),     // Penyebab (Singkat)
                        _buildHeaderCell('Aksi', flex: 5),      // Cukup untuk 3 ikon
                      ],
                    ),
                  ),
                  
                  // Isi Table
                  Expanded(
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator()) 
                      : _cederaList.isEmpty 
                        ? const Center(child: Text("Tidak ada data"))
                        : ListView.builder(
                            itemCount: _cederaList.length,
                            itemBuilder: (context, index) {
                              final item = _cederaList[index];
                              final bgColor = index % 2 == 0 ? Colors.white : Colors.grey[50];

                              return Container(
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _buildDataCell('${index + 1}', flex: 2, align: TextAlign.center),
                                    _buildDataCell(item['kode_cedera'] ?? '-', flex: 3, align: TextAlign.center, isBold: true),
                                    _buildDataCell(item['nama_cedera'] ?? '-', flex: 4, align: TextAlign.left),
                                    // Deskripsi & Penyebab ditampilkan singkat (ellipsis)
                                    _buildDataCell(item['deskripsi'] ?? '-', flex: 4, align: TextAlign.left),
                                    _buildDataCell(item['penyebab'] ?? '-', flex: 4, align: TextAlign.left),
                                    _buildActionCell(item, flex: 5),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Text(
          text, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87), 
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.visible,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {required int flex, required TextAlign align, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 60, // Tinggi baris
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        alignment: align == TextAlign.center ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text, 
          style: TextStyle(
            fontSize: 11, // Font size kecil agar muat
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87
          ), 
          textAlign: align, 
          maxLines: 3, // Maksimal 3 baris sebelum ...
          overflow: TextOverflow.ellipsis // Titik-titik jika kepanjangan
        ),
      ),
    );
  }

  Widget _buildActionCell(Map<String, dynamic> item, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 60,
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(onTap: () => _showDetailDialog(item), child: Container(padding: const EdgeInsets.all(4), child: const Icon(Icons.visibility, size: 18, color: Colors.blue))),
              const SizedBox(width: 2),
              InkWell(onTap: () => _showFormDialog(item: item), child: Container(padding: const EdgeInsets.all(4), child: const Icon(Icons.edit, size: 18, color: Colors.orange))),
              const SizedBox(width: 2),
              InkWell(onTap: () => _deleteCedera(item['id_cedera']), child: Container(padding: const EdgeInsets.all(4), child: const Icon(Icons.delete, size: 18, color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}