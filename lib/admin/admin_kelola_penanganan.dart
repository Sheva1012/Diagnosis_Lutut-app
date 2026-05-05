import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_sidebar.dart';
import 'admin_theme.dart';
import 'admin_pagination.dart';
import '../services/admin/penanganan_service.dart';
import '../services/admin/cedera_service.dart';

class AdminKelolaPenanganan extends StatefulWidget {
  const AdminKelolaPenanganan({Key? key}) : super(key: key);

  @override
  State<AdminKelolaPenanganan> createState() => _AdminKelolaPenangananState();
}

class _AdminKelolaPenangananState extends State<AdminKelolaPenanganan> {
  static const double _rowVPad = 8;
  static const double _rowHPad = 6;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  final PenangananService _penangananService = PenangananService();
  final CederaService _cederaService = CederaService();

  List<Map<String, dynamic>> _penangananList = [];
  List<Map<String, dynamic>> _cederaList = [];
  bool _isLoading = true;

  // Pagination
  int _currentPage = 1;
  final int _rowsPerPage = 15;

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

  void _filterPenanganan(String query) {
    if (query.isEmpty) {
      _loadAllData();
    } else {
      setState(() {
        _penangananList = _penangananList.where((item) {
          final awal = item['penanganan_awal']?.toString().toLowerCase() ?? '';
          final lanjutan =
              item['penanganan_lanjutan']?.toString().toLowerCase() ?? '';
          final cedera =
              item['cedera']?['nama_cedera']?.toString().toLowerCase() ?? '';

          return awal.contains(query.toLowerCase()) ||
              lanjutan.contains(query.toLowerCase()) ||
              cedera.contains(query.toLowerCase());
        }).toList();
        _currentPage = 1;
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
                      child: const Icon(Icons.medical_services_outlined, color: AdminTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Detail Penanganan",
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
                        _buildDetailCard("Nama Cedera", namaCedera, Icons.personal_injury_outlined),
                        _buildDetailCard("Penanganan Awal", awal, Icons.first_page_rounded),
                        _buildDetailCard("Penanganan Lanjutan", lanjutan, Icons.health_and_safety_outlined),
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

  // --- 2. Form Dialog ---
  void _showFormDialog({Map<String, dynamic>? item}) {
    final isEdit = item != null;
    int? selectedCederaId = item?['cedera']?['id_cedera'];
    final awalCtrl = TextEditingController(
      text: item?['penanganan_awal'] ?? '',
    );
    final lanjutCtrl = TextEditingController(
      text: item?['penanganan_lanjutan'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
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
                            isEdit ? 'Edit Penanganan' : 'Tambah Penanganan',
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
                              decoration: _inputDecoration('Pilih Cedera'),
                              value: selectedCederaId,
                              isExpanded: true,
                              style: GoogleFonts.poppins(fontSize: 13, color: AdminTheme.ink),
                              items: _cederaList
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c['id_cedera'] as int,
                                      child: Text(c['nama_cedera']),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setDialogState(() => selectedCederaId = val),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: awalCtrl,
                              decoration: _inputDecoration('Penanganan Awal'),
                              style: GoogleFonts.poppins(fontSize: 13, color: AdminTheme.ink),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: lanjutCtrl,
                              decoration: _inputDecoration('Penanganan Lanjutan'),
                              style: GoogleFonts.poppins(fontSize: 13, color: AdminTheme.ink),
                              maxLines: 3,
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
                              if (selectedCederaId != null && awalCtrl.text.isNotEmpty) {
                                Navigator.pop(context);
                                try {
                                  if (isEdit) {
                                    await _penangananService.updatePenanganan(
                                      item['id_penanganan'],
                                      selectedCederaId!,
                                      awalCtrl.text,
                                      lanjutCtrl.text,
                                    );
                                  } else {
                                    await _penangananService.addPenanganan(
                                      selectedCederaId!,
                                      awalCtrl.text,
                                      lanjutCtrl.text,
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

  // --- 3. Hapus Data ---
  void _deletePenanganan(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Hapus Data',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Yakin hapus data ini?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: AdminTheme.ink),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminTheme.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _penangananService.deletePenanganan(id);
              _loadAllData();
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPenanganan = _penangananList.length;
    final totalCedera = _cederaList.length;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          'Kelola Penanganan',
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AdminTheme.primaryDark, AdminTheme.primary],
            ),
          ),
        ),
      ),
      drawer: const AdminSidebar(activePage: 'penanganan'),
      backgroundColor: AdminTheme.bg,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF4EB), Color(0xFFFFFBF7)],
              ),
            ),
          ),
          Positioned(top: -40, right: -60, child: _buildGlow(140, AdminTheme.primary)),
          Positioned(bottom: -80, left: -40, child: _buildGlow(180, AdminTheme.accent)),
          SafeArea(
            top: false,
            child: Column(
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
                        BoxShadow(
                          color: AdminTheme.primaryDark.withOpacity(0.28),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kelola Penanganan',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Atur rekomendasi penanganan untuk setiap cedera.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildStatPill(
                                    'Tampil',
                                    _isLoading ? '-' : '$totalPenanganan',
                                    icon: Icons.list_alt_outlined,
                                  ),
                                  _buildStatPill(
                                    'Cedera',
                                    _isLoading ? '-' : '$totalCedera',
                                    icon: Icons.healing_outlined,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.16),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.medical_services_outlined,
                            color: Colors.white,
                            size: 36,
                          ),
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
                      boxShadow: [
                        BoxShadow(
                          color: AdminTheme.ink.withOpacity(0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterPenanganan,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AdminTheme.ink,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Cari penanganan, cedera, atau tindakan...',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AdminTheme.primary,
                              ),
                              filled: true,
                              fillColor: AdminTheme.primarySoft,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: () => _showFormDialog(),
                          icon: const Icon(Icons.add),
                          label: Text(
                            'Tambah',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AdminTheme.stroke),
                      boxShadow: [
                        BoxShadow(
                          color: AdminTheme.ink.withOpacity(0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFFFFE3D7), Color(0xFFFFD8C7)],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                _buildHeaderCell('No', flex: 1),
                                _buildDivider(),
                                _buildHeaderCell('Cedera', flex: 2),
                                _buildDivider(),
                                _buildHeaderCell('Awal', flex: 3),
                                _buildDivider(),
                                _buildHeaderCell('Lanjut', flex: 3),
                                _buildDivider(),
                                _buildHeaderCell('Aksi', flex: 3),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            color: AdminTheme.primary,
                            onRefresh: _loadAllData,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: _isLoading
                                  ? ListView(
                                      key: const ValueKey('loading'),
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: const [
                                        SizedBox(
                                          height: 260,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: AdminTheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : _penangananList.isEmpty
                                  ? ListView(
                                      key: const ValueKey('empty'),
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: [
                                        SizedBox(
                                          height: 260,
                                          child: Center(
                                            child: Text(
                                              "Tidak ada data",
                                              style: GoogleFonts.poppins(
                                                color: AdminTheme.ink,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Builder(
                                      key: const ValueKey('data'),
                                      builder: (context) {
                                        final paginatedList = getPaginatedList(_penangananList, _currentPage, _rowsPerPage);
                                        final startIndex = (_currentPage - 1) * _rowsPerPage;
                                        return ListView.builder(
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          itemCount: paginatedList.length,
                                          itemBuilder: (context, index) {
                                            final item = paginatedList[index];
                                            final globalIndex = startIndex + index;
                                            final namaCedera =
                                                item['cedera']?['nama_cedera'] ??
                                                '-';
                                            final awal =
                                                item['penanganan_awal'] ?? '-';
                                            final lanjutan =
                                                item['penanganan_lanjutan'] ?? '-';
                                            final rowColor = index.isEven
                                                ? Colors.white
                                                : AdminTheme.rowAlt;

                                            return Container(
                                              decoration: BoxDecoration(
                                                color: rowColor,
                                                border: Border(
                                                  bottom: BorderSide(color: AdminTheme.stroke),
                                                ),
                                              ),
                                              child: IntrinsicHeight(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.stretch,
                                                  children: [
                                                    _buildDataCell(
                                                      '${globalIndex + 1}',
                                                      flex: 1,
                                                      align: TextAlign.center,
                                                    ),
                                                    _buildDivider(),
                                                    _buildDataCell(
                                                      namaCedera,
                                                      flex: 2,
                                                      align: TextAlign.left,
                                                    ),
                                                    _buildDivider(),
                                                    _buildDataCell(
                                                      awal,
                                                      flex: 3,
                                                      align: TextAlign.left,
                                                    ),
                                                    _buildDivider(),
                                                    _buildDataCell(
                                                      lanjutan,
                                                      flex: 3,
                                                      align: TextAlign.left,
                                                    ),
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
                        ),
                        // Pagination controls
                        AdminPagination(
                          currentPage: _currentPage,
                          totalPages: calculateTotalPages(_penangananList.length, _rowsPerPage),
                          onPageChanged: (page) => setState(() => _currentPage = page),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: _rowHPad),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AdminTheme.ink,
          ),
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
        padding: const EdgeInsets.symmetric(
          vertical: _rowVPad,
          horizontal: _rowHPad,
        ),
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
                onTap: () => _deletePenanganan(item['id_penanganan']),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() => Container(width: 1, color: AdminTheme.stroke);

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

  Widget _buildGlow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildStatPill(String label, String value, {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
      filled: true,
      fillColor: AdminTheme.primarySoft,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AdminTheme.stroke),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AdminTheme.stroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AdminTheme.primary, width: 1.2),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
