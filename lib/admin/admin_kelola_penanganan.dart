import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import '../services/admin/penanganan_service.dart';
import '../services/admin/cedera_service.dart';

class AdminKelolaPenanganan extends StatefulWidget {
  const AdminKelolaPenanganan({Key? key}) : super(key: key);

  @override
  State<AdminKelolaPenanganan> createState() => _AdminKelolaPenangananState();
}

class _AdminKelolaPenangananState extends State<AdminKelolaPenanganan> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  final PenangananService _penangananService = PenangananService();
  final CederaService _cederaService = CederaService();

  List<Map<String, dynamic>> _penangananList = [];
  List<Map<String, dynamic>> _cederaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _penangananService.getAllPenanganan(),
        _cederaService.getAllCedera(),
      ]);

      setState(() {
        _penangananList = results[0];
        _cederaList = results[1];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  void _filterPenanganan(String query) {
    if (query.isEmpty) {
      _loadAllData();
    } else {
      setState(() {
        _penangananList = _penangananList.where((item) {
          final awal = item['penanganan_awal']?.toString().toLowerCase() ?? '';
          final lanjutan = item['penanganan_lanjutan']?.toString().toLowerCase() ?? '';
          final cedera = item['cedera']?['nama_cedera']?.toString().toLowerCase() ?? '';
          
          return awal.contains(query.toLowerCase()) || 
                 lanjutan.contains(query.toLowerCase()) || 
                 cedera.contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  // --- 1. Dialog Detail ---
  void _showDetailDialog(Map<String, dynamic> item) {
    final namaCedera = item['cedera']?['nama_cedera'] ?? '-';
    final awal = item['penanganan_awal'] ?? '-';
    final lanjutan = item['penanganan_lanjutan'] ?? '-';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF1E88E5)),
              const SizedBox(width: 10),
              const Text("Detail Penanganan"),
            ],
          ),
          content: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem("Nama Cedera", namaCedera, isTitle: true),
                  const Divider(thickness: 1.5, height: 30),
                  _buildDetailItem("Penanganan Awal", awal),
                  const SizedBox(height: 20),
                  _buildDetailItem("Penanganan Lanjutan", lanjutan),
                ],
              ),
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

  Widget _buildDetailItem(String label, String content, {bool isTitle = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(fontSize: isTitle ? 16 : 14, fontWeight: isTitle ? FontWeight.bold : FontWeight.normal, color: Colors.black87, height: 1.4),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  // --- 2. Form Dialog ---
  void _showFormDialog({Map<String, dynamic>? item}) {
    final isEdit = item != null;
    int? selectedCederaId = item?['cedera']?['id_cedera'];
    final awalCtrl = TextEditingController(text: item?['penanganan_awal'] ?? '');
    final lanjutCtrl = TextEditingController(text: item?['penanganan_lanjutan'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Penanganan' : 'Tambah Penanganan'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(labelText: 'Pilih Cedera', border: OutlineInputBorder()),
                      value: selectedCederaId,
                      isExpanded: true,
                      items: _cederaList.map((c) => DropdownMenuItem(value: c['id_cedera'] as int, child: Text(c['nama_cedera']))).toList(),
                      onChanged: (val) => setDialogState(() => selectedCederaId = val),
                    ),
                    const SizedBox(height: 16),
                    TextField(controller: awalCtrl, decoration: const InputDecoration(labelText: 'Penanganan Awal', border: OutlineInputBorder()), maxLines: 3),
                    const SizedBox(height: 16),
                    TextField(controller: lanjutCtrl, decoration: const InputDecoration(labelText: 'Penanganan Lanjutan', border: OutlineInputBorder()), maxLines: 3),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedCederaId != null && awalCtrl.text.isNotEmpty) {
                      Navigator.pop(context);
                      try {
                        if (isEdit) {
                          await _penangananService.updatePenanganan(item['id_penanganan'], selectedCederaId!, awalCtrl.text, lanjutCtrl.text);
                        } else {
                          await _penangananService.addPenanganan(selectedCederaId!, awalCtrl.text, lanjutCtrl.text);
                        }
                        _loadAllData();
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
      },
    );
  }

  // --- 3. Hapus Data ---
  void _deletePenanganan(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Yakin hapus data ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await _penangananService.deletePenanganan(id);
              _loadAllData();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
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
        title: const Text('Kelola Penanganan', style: TextStyle(color: Colors.white, fontSize: 18)),
        leading: IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
      ),
      drawer: const AdminSidebar(activePage: 'penanganan'),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Filter & Add Button
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
                      onChanged: _filterPenanganan,
                      decoration: const InputDecoration(
                        hintText: 'Cari Penanganan...',
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
                  decoration: BoxDecoration(color: const Color(0xFF1E88E5), borderRadius: BorderRadius.circular(8)),
                  child: IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: () => _showFormDialog()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // --- TABEL DATA ---
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
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildHeaderCell('No', flex: 1), _buildDivider(),
                          _buildHeaderCell('Cedera', flex: 2), _buildDivider(), // Flex Dikecilkan (3 -> 2)
                          _buildHeaderCell('Awal', flex: 3), _buildDivider(),
                          _buildHeaderCell('Lanjut', flex: 3), _buildDivider(),
                          _buildHeaderCell('Aksi', flex: 3), // Flex Dibesarkan (2 -> 3) agar ikon muat
                        ],
                      ),
                    ),
                  ),

                  // Content List
                  Expanded(
                    child: _isLoading 
                      ? const Center(child: CircularProgressIndicator()) 
                      : _penangananList.isEmpty 
                        ? const Center(child: Text("Tidak ada data"))
                        : ListView.builder(
                            itemCount: _penangananList.length,
                            itemBuilder: (context, index) {
                              final item = _penangananList[index];
                              final namaCedera = item['cedera']?['nama_cedera'] ?? '-';
                              final awal = item['penanganan_awal'] ?? '-';
                              final lanjutan = item['penanganan_lanjutan'] ?? '-';

                              return Container(
                                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _buildDataCell('${index + 1}', flex: 1, align: TextAlign.center), _buildDivider(),
                                      _buildDataCell(namaCedera, flex: 2, align: TextAlign.left), _buildDivider(), // Flex 2
                                      _buildDataCell(awal, flex: 3, align: TextAlign.left), _buildDivider(),
                                      _buildDataCell(lanjutan, flex: 3, align: TextAlign.left), _buildDivider(),
                                      _buildActionCell(item), // Flex 3 (dari function di bawah)
                                    ],
                                  ),
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
    return Expanded(flex: flex, child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4), alignment: Alignment.center, child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)));
  }

  Widget _buildDataCell(String text, {required int flex, required TextAlign align}) {
    return Expanded(flex: flex, child: Container(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4), alignment: align == TextAlign.center ? Alignment.center : Alignment.centerLeft, child: Text(text, style: const TextStyle(fontSize: 12), textAlign: align, maxLines: 2, overflow: TextOverflow.ellipsis)));
  }

  Widget _buildActionCell(Map<String, dynamic> item) {
    // Flex Aksi dibesarkan menjadi 3
    return Expanded(
      flex: 3, 
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Detail
              InkWell(onTap: () => _showDetailDialog(item), child: Container(padding: const EdgeInsets.all(4), child: const Icon(Icons.visibility, size: 18, color: Colors.blue))),
              const SizedBox(width: 4),
              // Edit
              InkWell(onTap: () => _showFormDialog(item: item), child: Container(padding: const EdgeInsets.all(4), child: const Icon(Icons.edit, size: 18, color: Colors.orange))),
              const SizedBox(width: 4),
              // Hapus
              InkWell(onTap: () => _deletePenanganan(item['id_penanganan']), child: Container(padding: const EdgeInsets.all(4), child: const Icon(Icons.delete, size: 18, color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() => Container(width: 1, color: Colors.grey.shade300);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}