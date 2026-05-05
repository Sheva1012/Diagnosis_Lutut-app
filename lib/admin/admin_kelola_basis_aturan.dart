import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_sidebar.dart';
import 'admin_theme.dart';
import 'admin_pagination.dart';
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

  // Pagination
  int _currentPage = 1;
  final int _rowsPerPage = 15;

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
        _currentPage = 1;
      });
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      setState(() => _isLoading = false);
    }
  }

  // 1. Dialog Detail (Fitur Baru)
  void _showDetailDialog(Map<String, dynamic> item) {
    final kodeGejala = item['gejala']?['kode_gejala'] ?? '-';
    final namaGejala = item['gejala']?['nama_gejala'] ?? '-';
    final namaCedera = item['cedera']?['nama_cedera'] ?? '-';
    final bobot = item['bobot_cf_pakar']?.toString() ?? '-';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AdminTheme.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.rule_folder_outlined, color: AdminTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Detail Aturan",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AdminTheme.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AdminTheme.stroke),
                const SizedBox(height: 16),
                
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildDetailCard("Gejala", "$kodeGejala - $namaGejala", Icons.monitor_heart_outlined),
                        _buildDetailCard("Cedera Terkait", namaCedera, Icons.personal_injury_outlined),
                        _buildDetailCard("Bobot Pakar (CF)", bobot, Icons.percent_rounded),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      "Tutup",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminTheme.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminTheme.stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AdminTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AdminTheme.ink,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
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
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AdminTheme.primarySoft,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(isEdit ? Icons.edit_document : Icons.add_circle_outline, color: AdminTheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isEdit ? 'Edit Aturan' : 'Tambah Aturan',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AdminTheme.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AdminTheme.stroke),
                    const SizedBox(height: 16),
                    
                    // Form Fields
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                labelText: 'Pilih Gejala',
                                labelStyle: GoogleFonts.poppins(fontSize: 12),
                                filled: true,
                                fillColor: AdminTheme.primarySoft,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AdminTheme.stroke)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AdminTheme.stroke)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminTheme.primary, width: 1.2)),
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
                              decoration: InputDecoration(
                                labelText: 'Pilih Cedera',
                                labelStyle: GoogleFonts.poppins(fontSize: 12),
                                filled: true,
                                fillColor: AdminTheme.primarySoft,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AdminTheme.stroke)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AdminTheme.stroke)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminTheme.primary, width: 1.2)),
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
                              style: GoogleFonts.poppins(fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Bobot CF (0.0 - 1.0)',
                                labelStyle: GoogleFonts.poppins(fontSize: 12),
                                filled: true,
                                fillColor: AdminTheme.primarySoft,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AdminTheme.stroke)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AdminTheme.stroke)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminTheme.primary, width: 1.2)),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              side: BorderSide(color: Colors.grey[300]!),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text("Batal", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
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
                                  Fluttertoast.showToast(
          msg: 'Error: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminTheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            child: Text("Simpan", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
        title: Text('Hapus Aturan', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Yakin hapus aturan ini?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _aturanService.deleteBasisAturan(id);
                _loadAllData();
              } catch (e) {
                Fluttertoast.showToast(
          msg: 'Error: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
              }
            },
            child: Text('Hapus', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
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
        title: Text(
          'Data Basis Aturan',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AdminTheme.appBarGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: const AdminSidebar(activePage: 'aturan'),
      backgroundColor: AdminTheme.bg,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AdminTheme.primaryDark, AdminTheme.primary],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: AdminTheme.primaryDark.withOpacity(0.28), blurRadius: 18, offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Basis Aturan', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text('Atur relasi gejala, cedera, dan bobot CF pakar.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.9))),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), shape: BoxShape.circle),
                    child: const Icon(Icons.rule_rounded, color: Colors.white, size: 36),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdminTheme.stroke),
                boxShadow: [BoxShadow(color: AdminTheme.ink.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 6))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: AdminTheme.primarySoft, borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text('Filter cedera', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                          value: _selectedCederaFilter,
                          items: [
                            const DropdownMenuItem(value: 'Semua', child: Text('Semua Cedera')),
                            ..._cederaList.map((c) => DropdownMenuItem(value: c['nama_cedera'] as String, child: Text(c['nama_cedera'] as String))),
                          ],
                          onChanged: (val) => setState(() { _selectedCederaFilter = val == 'Semua' ? null : val; _currentPage = 1; }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), shape: const StadiumBorder()),
                    onPressed: () => _showFormDialog(),
                    icon: const Icon(Icons.add),
                    label: Text('Tambah', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AdminTheme.stroke), boxShadow: [BoxShadow(color: AdminTheme.ink.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 6))]),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [AdminTheme.headerLight, AdminTheme.headerDark]),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildHeaderCell('No', flex: 1), _buildDivider(),
                          _buildHeaderCell('Kode', flex: 2), _buildDivider(),
                          _buildHeaderCell('Nama Gejala', flex: 3), _buildDivider(),
                          _buildHeaderCell('Cedera', flex: 3), _buildDivider(),
                          _buildHeaderCell('Bobot', flex: 2), _buildDivider(),
                          _buildHeaderCell('Aksi', flex: 3),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: AdminTheme.primary,
                      onRefresh: _loadAllData,
                      child: _isLoading
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [SizedBox(height: 260, child: Center(child: CircularProgressIndicator(color: AdminTheme.primary)))],
                            )
                          : filteredList.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: const [SizedBox(height: 260, child: Center(child: Text("Tidak ada data")))],
                                )
                              : Builder(
                                  builder: (context) {
                                    final totalPages = calculateTotalPages(filteredList.length, _rowsPerPage);
                                    final paginatedList = getPaginatedList(filteredList, _currentPage, _rowsPerPage);
                                    final startIndex = (_currentPage - 1) * _rowsPerPage;
                                    return ListView.builder(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      itemCount: paginatedList.length,
                                      itemBuilder: (context, index) {
                                        final item = paginatedList[index];
                                        final globalIndex = startIndex + index;
                                        final kodeGejala = item['gejala']?['kode_gejala'] ?? '-';
                                        final namaGejala = item['gejala']?['nama_gejala'] ?? '-';
                                        final namaCedera = item['cedera']?['nama_cedera'] ?? '-';
                                        final bobot = item['bobot_cf_pakar']?.toString() ?? '0';
                                        final bgColor = index.isEven ? Colors.white : AdminTheme.rowAlt;

                                        return Container(
                                          decoration: BoxDecoration(
                                            color: bgColor,
                                            border: Border(
                                              bottom: BorderSide(color: AdminTheme.stroke),
                                            ),
                                          ),
                                          child: IntrinsicHeight(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                _buildDataCell('${globalIndex + 1}', flex: 1, align: TextAlign.center),
                                                _buildDivider(),
                                                _buildDataCell(kodeGejala, flex: 2, align: TextAlign.center),
                                                _buildDivider(),
                                                _buildDataCell(namaGejala, flex: 3, align: TextAlign.left),
                                                _buildDivider(),
                                                _buildDataCell(namaCedera, flex: 3, align: TextAlign.left),
                                                _buildDivider(),
                                                _buildDataCell(bobot, flex: 2, align: TextAlign.center),
                                                _buildDivider(),
                                                _buildActionCell(item),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                    ),
                  ),
                  // Pagination controls
                  Builder(
                    builder: (context) {
                      final totalPages = calculateTotalPages(filteredList.length, _rowsPerPage);
                      return AdminPagination(
                        currentPage: _currentPage,
                        totalPages: totalPages,
                        onPageChanged: (page) => setState(() => _currentPage = page),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: AdminTheme.ink),
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
          style: GoogleFonts.poppins(fontSize: 12, color: AdminTheme.ink),
          textAlign: align,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildActionCell(Map<String, dynamic> item) {
    return Expanded(
      flex: 3,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                tooltip: 'Detail',
                icon: Icons.visibility,
                color: AdminTheme.primary,
                onTap: () => _showDetailDialog(item),
              ),
              const SizedBox(width: 6),
              _buildActionButton(
                tooltip: 'Edit',
                icon: Icons.edit,
                color: AdminTheme.accent,
                onTap: () => _showFormDialog(item: item),
              ),
              const SizedBox(width: 6),
              _buildActionButton(
                tooltip: 'Hapus',
                icon: Icons.delete,
                color: AdminTheme.danger,
                onTap: () => _deleteAturan(item['id_aturan']),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String tooltip,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.14),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() => Container(width: 1, color: AdminTheme.stroke);
}
