import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_sidebar.dart';
import 'admin_theme.dart';
import 'admin_pagination.dart';
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

  // Pagination
  int _currentPage = 1;
  final int _rowsPerPage = 15;

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
          _currentPage = 1;
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
                      child: const Icon(Icons.monitor_heart_outlined, color: AdminTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Detail Gejala",
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
                        _buildDetailCard("Kode Gejala", item['kode_gejala'] ?? '-', Icons.qr_code),
                        _buildDetailCard("Nama Gejala", item['nama_gejala'] ?? '-', Icons.sick_outlined),
                        _buildDetailCard("Pertanyaan", item['pertanyaan'] ?? '-', Icons.help_outline_rounded),
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

  // --- 2. Dialog Form ---
  void _showFormDialog({Map<String, dynamic>? item}) {
    final isEdit = item != null;
    final TextEditingController kodeController = TextEditingController(text: item?['kode_gejala'] ?? '');
    final TextEditingController namaController = TextEditingController(text: item?['nama_gejala'] ?? '');
    final TextEditingController tanyaController = TextEditingController(text: item?['pertanyaan'] ?? '');

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
                      child: Icon(isEdit ? Icons.edit_document : Icons.add_circle_outline, color: AdminTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isEdit ? 'Edit Gejala' : 'Tambah Gejala',
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
                        TextField(
                          controller: kodeController,
                          style: GoogleFonts.poppins(fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Kode Gejala',
                            labelStyle: GoogleFonts.poppins(fontSize: 12),
                            filled: true,
                            fillColor: AdminTheme.primarySoft,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AdminTheme.stroke)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AdminTheme.stroke)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminTheme.primary, width: 1.2)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: namaController,
                          style: GoogleFonts.poppins(fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Nama Gejala',
                            labelStyle: GoogleFonts.poppins(fontSize: 12),
                            filled: true,
                            fillColor: AdminTheme.primarySoft,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AdminTheme.stroke)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AdminTheme.stroke)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminTheme.primary, width: 1.2)),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: tanyaController,
                          style: GoogleFonts.poppins(fontSize: 13),
                          decoration: InputDecoration(
                            labelText: 'Pertanyaan',
                            labelStyle: GoogleFonts.poppins(fontSize: 12),
                            filled: true,
                            fillColor: AdminTheme.primarySoft,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AdminTheme.stroke)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AdminTheme.stroke)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminTheme.primary, width: 1.2)),
                          ),
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
  }

  // --- 3. Hapus Data ---
  void _deleteGejala(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Gejala', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Yakin hapus data ini?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await _gejalaService.deleteGejala(id);
              _loadData();
            },
            child: Text('Hapus', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalData = _gejalaList.length;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Data Gejala', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AdminTheme.appBarGradient),
        ),
        leading: IconButton(icon: const Icon(Icons.menu, color: Colors.white), onPressed: () => _scaffoldKey.currentState?.openDrawer()),
      ),
      drawer: const AdminSidebar(activePage: 'gejala'),
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
                          'Data Gejala',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kelola daftar gejala dan pertanyaan untuk diagnosis.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStatPill('Tampil', '$totalData', icon: Icons.monitor_heart_outlined),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.health_and_safety_outlined, color: Colors.white, size: 36),
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
                      onChanged: _filterGejala,
                      style: GoogleFonts.poppins(fontSize: 13, color: AdminTheme.ink),
                      decoration: InputDecoration(
                        hintText: 'Cari gejala...',
                        hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                        prefixIcon: const Icon(Icons.search, color: AdminTheme.primary),
                        filled: true,
                        fillColor: AdminTheme.primarySoft,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _showFormDialog,
                    icon: const Icon(Icons.add),
                    label: Text(
                      'Tambah',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [AdminTheme.headerLight, AdminTheme.headerDark],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          _buildHeaderCell('No', flex: 2),
                          _buildDivider(),
                          _buildHeaderCell('Kode', flex: 3),
                          _buildDivider(),
                          _buildHeaderCell('Nama Gejala', flex: 5),
                          _buildDivider(),
                          _buildHeaderCell('Pertanyaan', flex: 5),
                          _buildDivider(),
                          _buildHeaderCell('Aksi', flex: 4),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: AdminTheme.primary,
                      onRefresh: _loadData,
                      child: _isLoading
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [
                                SizedBox(
                                  height: 260,
                                  child: Center(
                                    child: CircularProgressIndicator(color: AdminTheme.primary),
                                  ),
                                ),
                              ],
                            )
                          : _gejalaList.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: const [
                                    SizedBox(
                                      height: 260,
                                      child: Center(child: Text("Tidak ada data")),
                                    ),
                                  ],
                                )
                              : Builder(
                                  builder: (context) {
                                    final paginatedList = getPaginatedList(_gejalaList, _currentPage, _rowsPerPage);
                                    final startIndex = (_currentPage - 1) * _rowsPerPage;
                                    return ListView.builder(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      itemCount: paginatedList.length,
                                      itemBuilder: (context, index) {
                                        final item = paginatedList[index];
                                        final globalIndex = startIndex + index;
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
                                                _buildDataCell('${globalIndex + 1}', flex: 2, align: TextAlign.center),
                                                _buildDivider(),
                                                _buildDataCell(item['kode_gejala'] ?? '-', flex: 3, align: TextAlign.center, isBold: true),
                                                _buildDivider(),
                                                _buildDataCell(item['nama_gejala'] ?? '-', flex: 5, align: TextAlign.left),
                                                _buildDivider(),
                                                _buildDataCell(item['pertanyaan'] ?? '-', flex: 5, align: TextAlign.left),
                                                _buildDivider(),
                                                _buildActionCell(item, flex: 4),
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
                  AdminPagination(
                    currentPage: _currentPage,
                    totalPages: calculateTotalPages(_gejalaList.length, _rowsPerPage),
                    onPageChanged: (page) => setState(() => _currentPage = page),
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
        child: Text(
          text, 
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12, color: AdminTheme.ink), 
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        alignment: align == TextAlign.center ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text, 
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AdminTheme.ink
          ), 
          textAlign: align, 
          maxLines: 2,
          overflow: TextOverflow.ellipsis 
        ),
      ),
    );
  }

  Widget _buildActionCell(Map<String, dynamic> item, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        alignment: Alignment.center,
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
                onTap: () => _deleteGejala(item['id_gejala']),
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
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}