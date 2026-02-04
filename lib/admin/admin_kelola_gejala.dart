import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Opsional
import 'admin_sidebar.dart';
import '../services/admin/gejala_service.dart';

class AdminKelolaGejala extends StatefulWidget {
  const AdminKelolaGejala({Key? key}) : super(key: key);

  @override
  State<AdminKelolaGejala> createState() => _AdminKelolaGejalaState();
}

class _AdminKelolaGejalaState extends State<AdminKelolaGejala> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final GejalaService _gejalaService = GejalaService();

  List<Map<String, dynamic>> _gejalaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _gejalaService.getAllGejala();
      setState(() {
        _gejalaList = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  void _filterGejala(String query) async {
    if (query.isEmpty) {
      _loadData();
    } else {
      setState(() => _isLoading = true);
      try {
        final data = await _gejalaService.searchGejala(query);
        setState(() {
          _gejalaList = data;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- 1. Dialog Detail ---
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
              Text("Detail Gejala"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem("Kode Gejala", item['kode_gejala'] ?? '-'),
                const Divider(),
                _buildDetailItem("Nama Gejala", item['nama_gejala'] ?? '-'),
                const Divider(),
                _buildDetailItem("Pertanyaan", item['pertanyaan'] ?? '-'),
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
    final TextEditingController kodeController = TextEditingController(text: item?['kode_gejala'] ?? '');
    final TextEditingController namaController = TextEditingController(text: item?['nama_gejala'] ?? '');
    final TextEditingController tanyaController = TextEditingController(text: item?['pertanyaan'] ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Gejala' : 'Tambah Gejala'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: kodeController,
                  decoration: const InputDecoration(labelText: 'Kode Gejala', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Gejala', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tanyaController,
                  decoration: const InputDecoration(labelText: 'Pertanyaan', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                if (kodeController.text.isNotEmpty && namaController.text.isNotEmpty && tanyaController.text.isNotEmpty) {
                  Navigator.pop(context);
                  try {
                    if (isEdit) {
                      await _gejalaService.updateGejala(item['id_gejala'], kodeController.text, namaController.text, tanyaController.text);
                    } else {
                      await _gejalaService.addGejala(kodeController.text, namaController.text, tanyaController.text);
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
  void _deleteGejala(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Gejala'),
        content: const Text('Yakin hapus data ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _gejalaService.deleteGejala(id);
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
        title: const Text('Data Gejala', style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
      ),
      drawer: const AdminSidebar(activePage: 'gejala'),
      backgroundColor: Colors.grey[100], // Background utama abu-abu
      body: Column(
        children: [
          // Bagian Header (Search & Add) - Background Putih Sendiri
          Container(
            color: Colors.white, // Box putih untuk area search
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // Warna field search beda
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterGejala,
                      decoration: const InputDecoration(
                        hintText: 'Cari Gejala...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 45, height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => _showFormDialog(),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16), // Jarak antara search dan tabel

          // Bagian Tabel Data - Dalam Container Putih Terpisah (Seperti Card)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16), // Margin kiri kanan
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                        // Proporsi Flex diatur ulang agar muat dan tidak overflow
                        _buildHeaderCell('No', flex: 2), // Cukup lebar utk "10"
                        _buildHeaderCell('Kode', flex: 3),
                        _buildHeaderCell('Nama Gejala', flex: 5), 
                        _buildHeaderCell('Pertanyaan', flex: 5),
                        _buildHeaderCell('Aksi', flex: 4), // Cukup lebar utk 3 ikon
                      ],
                    ),
                  ),
                  
                  // Isi Table
                  Expanded(
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator()) 
                      : _gejalaList.isEmpty 
                        ? const Center(child: Text("Tidak ada data"))
                        : ListView.builder(
                            itemCount: _gejalaList.length,
                            itemBuilder: (context, index) {
                              final item = _gejalaList[index];
                              
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center, 
                                  children: [
                                    _buildDataCell('${index + 1}', flex: 2, align: TextAlign.center),
                                    _buildDataCell(item['kode_gejala'] ?? '-', flex: 3, align: TextAlign.center, isBold: true),
                                    _buildDataCell(item['nama_gejala'] ?? '-', flex: 5, align: TextAlign.left),
                                    _buildDataCell(item['pertanyaan'] ?? '-', flex: 5, align: TextAlign.left),
                                    _buildActionCell(item, flex: 4),
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
        // Menghapus border kanan agar terlihat lebih bersih, atau bisa dikembalikan jika suka
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Text(
          text, 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black87), 
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, {required int flex, required TextAlign align, bool isBold = false}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 55, // Tinggi baris tetap agar rapi
        padding: const EdgeInsets.symmetric(horizontal: 4), // Padding kiri kanan kecil
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
        ),
        alignment: align == TextAlign.center ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text, 
          style: TextStyle(
            fontSize: 11, // Font size pas untuk tabel padat
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black87
          ), 
          textAlign: align, 
          maxLines: 2, // Maksimal 2 baris agar tidak merusak layout
          overflow: TextOverflow.ellipsis 
        ),
      ),
    );
  }

  Widget _buildActionCell(Map<String, dynamic> item, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        height: 55,
        alignment: Alignment.center,
        child: FittedBox( // Skala otomatis agar ikon tidak overflow
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(onTap: () => _showDetailDialog(item), child: Container(padding: const EdgeInsets.all(4), child: const Icon(Icons.visibility, size: 18, color: Colors.blue))),
              // const SizedBox(width: 2), // Jarak antar ikon sangat kecil
              InkWell(onTap: () => _showFormDialog(item: item), child: Container(padding: const EdgeInsets.all(4), child: const Icon(Icons.edit, size: 18, color: Colors.orange))),
              // const SizedBox(width: 2),
              InkWell(onTap: () => _deleteGejala(item['id_gejala']), child: Container(padding: const EdgeInsets.all(4), child: const Icon(Icons.delete, size: 18, color: Colors.red))),
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