import 'package:flutter/material.dart';
import 'admin_sidebar.dart';
import '../services/admin/basis_aturan_service.dart';
import '../services/admin/gejala_service.dart';
import '../services/admin/cedera_service.dart';

class AdminKelolaBasisAturan extends StatefulWidget {
  const AdminKelolaBasisAturan({Key? key}) : super(key: key);

  @override
  State<AdminKelolaBasisAturan> createState() => _AdminKelolaBasisAturanState();
}

class _AdminKelolaBasisAturanState extends State<AdminKelolaBasisAturan> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Services
  final BasisAturanService _aturanService = BasisAturanService();
  final GejalaService _gejalaService = GejalaService();
  final CederaService _cederaService = CederaService();

  // Data Lists
  List<Map<String, dynamic>> _aturanList = [];
  List<Map<String, dynamic>> _gejalaList = [];
  List<Map<String, dynamic>> _cederaList = [];

  // Filter & Loading
  String? _selectedCederaFilter;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // Load Data
  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _aturanService.getAllBasisAturan(),
        _gejalaService.getAllGejala(),
        _cederaService.getAllCedera(),
      ]);

      setState(() {
        _aturanList = results[0];
        _gejalaList = results[1];
        _cederaList = results[2];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  // 1. Dialog Detail (Fitur Baru)
  void _showDetailDialog(Map<String, dynamic> item) {
    // Ambil data dengan aman (handle null)
    final kodeGejala = item['gejala']?['kode_gejala'] ?? '-';
    final namaGejala = item['gejala']?['nama_gejala'] ?? '-';
    final namaCedera = item['cedera']?['nama_cedera'] ?? '-';
    final bobot = item['bobot_cf_pakar']?.toString() ?? '-';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: const [
              Icon(Icons.info_outline, color: Color(0xFF1E88E5)),
              SizedBox(width: 10),
              Text("Detail Aturan"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailItem("Kode Gejala", kodeGejala),
                const Divider(),
                _buildDetailItem("Nama Gejala", namaGejala),
                const Divider(),
                _buildDetailItem("Nama Cedera", namaCedera),
                const Divider(),
                _buildDetailItem("Bobot Pakar (CF)", bobot),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Tutup",
                style: TextStyle(
                  color: Color(0xFF1E88E5),
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }

  // 2. Dialog Form (Tambah / Edit)
  void _showFormDialog({Map<String, dynamic>? item}) {
    final isEdit = item != null;
    int? selectedGejalaId = item?['gejala']?['id_gejala'];
    int? selectedCederaId = item?['cedera']?['id_cedera'];

    // Pastikan key sesuai database: bobot_cf_pakar
    final bobotCtrl = TextEditingController(
      text: item?['bobot_cf_pakar']?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit Aturan' : 'Tambah Aturan'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Gejala',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedGejalaId,
                      isExpanded: true,
                      items: _gejalaList.map((gejala) {
                        return DropdownMenuItem<int>(
                          value: gejala['id_gejala'],
                          child: Text(
                            "${gejala['kode_gejala']} - ${gejala['nama_gejala']}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedGejalaId = val),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Cedera',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedCederaId,
                      isExpanded: true,
                      items: _cederaList.map((cedera) {
                        return DropdownMenuItem<int>(
                          value: cedera['id_cedera'],
                          child: Text(
                            "${cedera['kode_cedera']} - ${cedera['nama_cedera']}",
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedCederaId = val),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: bobotCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Bobot CF (0.0 - 1.0)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedGejalaId != null &&
                        selectedCederaId != null &&
                        bobotCtrl.text.isNotEmpty) {
                      Navigator.pop(context);
                      try {
                        double bobot = double.parse(bobotCtrl.text);
                        if (isEdit) {
                          await _aturanService.updateBasisAturan(
                            item['id_aturan'],
                            selectedGejalaId!,
                            selectedCederaId!,
                            bobot,
                          );
                        } else {
                          await _aturanService.addBasisAturan(
                            selectedGejalaId!,
                            selectedCederaId!,
                            bobot,
                          );
                        }
                        _loadAllData();
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  // 3. Hapus Data
  void _deleteAturan(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Aturan'),
        content: const Text('Yakin hapus aturan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _aturanService.deleteBasisAturan(id);
                _loadAllData();
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList =
        _selectedCederaFilter == null || _selectedCederaFilter == 'Semua'
        ? _aturanList
        : _aturanList.where((item) {
            final namaCedera = item['cedera']?['nama_cedera'] as String?;
            return namaCedera == _selectedCederaFilter;
          }).toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        title: const Text(
          'Data Basis Aturan',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: const AdminSidebar(activePage: 'aturan'),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Filter & Add
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text(
                          'Filter Cedera',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: _selectedCederaFilter,
                        items: [
                          const DropdownMenuItem(
                            value: 'Semua',
                            child: Text('Semua Cedera'),
                          ),
                          ..._cederaList.map(
                            (c) => DropdownMenuItem(
                              value: c['nama_cedera'] as String,
                              child: Text(c['nama_cedera'] as String),
                            ),
                          ),
                        ],
                        onChanged: (val) => setState(
                          () => _selectedCederaFilter = val == 'Semua'
                              ? null
                              : val,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 45,
                  height: 45,
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
          const SizedBox(height: 8),

          // Tabel Data
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  // Header
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildHeaderCell('No', flex: 1), _buildDivider(),
                          _buildHeaderCell('Kode', flex: 2),
                          _buildDivider(), // Kode Gejala
                          _buildHeaderCell('Nama Gejala', flex: 3),
                          _buildDivider(),
                          _buildHeaderCell('Cedera', flex: 3), _buildDivider(),
                          _buildHeaderCell('Bobot', flex: 2), _buildDivider(),
                          _buildHeaderCell(
                            'Aksi',
                            flex: 3,
                          ), // Flex 3 agar muat 3 tombol
                        ],
                      ),
                    ),
                  ),

                  // Content List
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : filteredList.isEmpty
                        ? const Center(child: Text("Tidak ada data"))
                        : ListView.builder(
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final item = filteredList[index];

                              final kodeGejala =
                                  item['gejala']?['kode_gejala'] ?? '-';
                              final namaGejala =
                                  item['gejala']?['nama_gejala'] ?? '-';
                              final namaCedera =
                                  item['cedera']?['nama_cedera'] ?? '-';
                              final bobot =
                                  item['bobot_cf_pakar']?.toString() ?? '0';

                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _buildDataCell(
                                        '${index + 1}',
                                        flex: 1,
                                        align: TextAlign.center,
                                      ),
                                      _buildDivider(),
                                      _buildDataCell(
                                        kodeGejala,
                                        flex: 2,
                                        align: TextAlign.center,
                                      ),
                                      _buildDivider(),
                                      _buildDataCell(
                                        namaGejala,
                                        flex: 3,
                                        align: TextAlign.left,
                                      ),
                                      _buildDivider(),
                                      _buildDataCell(
                                        namaCedera,
                                        flex: 3,
                                        align: TextAlign.left,
                                      ),
                                      _buildDivider(),
                                      _buildDataCell(
                                        bobot,
                                        flex: 2,
                                        align: TextAlign.center,
                                      ),
                                      _buildDivider(),
                                      _buildActionCell(item),
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
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDataCell(
    String text, {
    required int flex,
    required TextAlign align,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        alignment: align == TextAlign.center
            ? Alignment.center
            : Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontSize: 11),
          textAlign: align,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildActionCell(Map<String, dynamic> item) {
    return Expanded(
      flex: 3, // Cukup untuk 3 tombol
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lihat Detail
              InkWell(
                onTap: () => _showDetailDialog(item),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.visibility,
                    size: 18,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Edit
              InkWell(
                onTap: () => _showFormDialog(item: item),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.edit, size: 18, color: Colors.orange),
                ),
              ),
              const SizedBox(width: 4),
              // Hapus
              InkWell(
                onTap: () => _deleteAturan(item['id_aturan']),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.delete, size: 18, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() => Container(width: 1, color: Colors.grey.shade300);
}
