import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_sidebar.dart';
import 'admin_theme.dart';
import 'admin_pagination.dart';
import '../services/admin/pengguna_service.dart';

class AdminKelolaPengguna extends StatefulWidget {
  const AdminKelolaPengguna({Key? key}) : super(key: key);

  @override
  State<AdminKelolaPengguna> createState() => _AdminKelolaPenggunaState();
}

class _AdminKelolaPenggunaState extends State<AdminKelolaPengguna> {
  final PenggunaService _penggunaService = PenggunaService();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Map<String, dynamic>> _penggunaList = [];
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
      final data = await _penggunaService.getAllPengguna();
      if (mounted) {
        setState(() {
          _penggunaList = data;
          _isLoading = false;
          _currentPage = 1;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Error: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      setState(() => _isLoading = false);
    }
  }

  void _filter(String value) async {
    if (value.isEmpty) {
      _loadData();
    } else {
      setState(() => _isLoading = true);
      final result = await _penggunaService.searchPengguna(value);
      setState(() {
        _penggunaList = result;
        _isLoading = false;
        _currentPage = 1;
      });
    }
  }

  void _showDetail(Map<String, dynamic> item) {
    String date = '-';
    if (item['created_at'] != null) {
      final dt = DateTime.parse(item['created_at']);
      date = "${dt.day}/${dt.month}/${dt.year}";
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
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
                    child: const Icon(Icons.person_outline, color: AdminTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Detail Pengguna",
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
                      _buildDetailCard("Nama", item['nama_lengkap'] ?? '-', Icons.badge_outlined),
                      _buildDetailCard("Email", item['email'] ?? '-', Icons.email_outlined),
                      _buildDetailCard("Username", item['username'] ?? '-', Icons.account_circle_outlined),
                      _buildDetailCard("Role", item['role'] ?? '-', Icons.admin_panel_settings_outlined),
                      _buildDetailCard("Terdaftar", date, Icons.calendar_month_outlined),
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
      ),
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

  void _showAddDialog() {
    final nama = TextEditingController();
    final email = TextEditingController();
    final username = TextEditingController();
    final password = TextEditingController();

    nama.clear();
    email.clear();
    password.clear();
    username.clear();

    showDialog(
      context: context,
      builder: (_) => Dialog(
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
                    child: const Icon(Icons.person_add_alt_1_outlined, color: AdminTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Tambah Admin",
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
                      _input(nama, "Nama Lengkap"),
                      _gap(),
                      _input(username, "Username (Opsional)"),
                      _gap(),
                      _input(email, "Email"),
                      _gap(),
                      _input(password, "Password", ob: true),
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
                        if (nama.text.isEmpty ||
                            email.text.isEmpty ||
                            password.text.isEmpty) {
                          Fluttertoast.showToast(
          msg: 'Mohon isi semua data wajib',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
                          return;
                        }

                        Navigator.pop(context);
                        setState(() => _isLoading = true);

                        try {
                          await _penggunaService.addPengguna(
                            email: email.text,
                            password: password.text,
                            namaLengkap: nama.text,
                            role: 'Admin',
                            username: username.text,
                          );
                          await _loadData();
                        } catch (e) {
                          Fluttertoast.showToast(
          msg: "Gagal tambah: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
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
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final nama = TextEditingController(text: item['nama_lengkap']);
    final email = TextEditingController(text: item['email']);
    final username = TextEditingController(text: item['username'] ?? '');

    showDialog(
      context: context,
      builder: (_) => Dialog(
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
                    child: const Icon(Icons.edit_document, color: AdminTheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Edit Admin",
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
                      _input(nama, "Nama Lengkap"),
                      _gap(),
                      _input(
                        email,
                        "Email",
                        keyboard: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                      ),
                      _gap(),
                      _input(username, "Username"),
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
                        Navigator.pop(context);
                        setState(() => _isLoading = true);
                        try {
                          await _penggunaService.updatePengguna(
                            userId: item['id_user'],
                            namaLengkap: nama.text,
                            email: email.text,
                            username: username.text,
                          );
                          await _loadData();
                        } catch (e) {
                          Fluttertoast.showToast(
          msg: "Gagal update: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
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
      ),
    );
  }

  void _delete(String idUser) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text("Hapus Pengguna", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text("Yakin ingin menghapus pengguna ini?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.danger),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await _penggunaService.deletePengguna(idUser);
                await _loadData();
              } catch (e) {
                Fluttertoast.showToast(
          msg: "Gagal hapus: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
              }
            },
            child: Text("Hapus", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String l, {
    bool ob = false,
    TextInputType keyboard = TextInputType.text,
    List<String>? autofillHints,
  }) => TextField(
    controller: c,
    obscureText: ob,
    keyboardType: keyboard,
    autofillHints: autofillHints,
    style: GoogleFonts.poppins(fontSize: 13),
    decoration: InputDecoration(
      labelText: l,
      labelStyle: GoogleFonts.poppins(fontSize: 12),
      filled: true,
      fillColor: AdminTheme.primarySoft,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AdminTheme.stroke)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AdminTheme.stroke)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AdminTheme.primary, width: 1.2)),
    ),
  );

  SizedBox _gap() => const SizedBox(height: 14);

  @override
  Widget build(BuildContext context) {
    final totalData = _penggunaList.length;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Data Pengguna',
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
      drawer: const AdminSidebar(activePage: 'pengguna'),
      backgroundColor: AdminTheme.bg,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AdminTheme.primaryDark, AdminTheme.primary]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: AdminTheme.primaryDark.withOpacity(0.28), blurRadius: 18, offset: const Offset(0, 10))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Data Pengguna', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text('Kelola akun admin dan pengguna pada sistem.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.9))),
                        const SizedBox(height: 12),
                        _buildStatPill('Tampil', '$totalData', icon: Icons.people_alt_rounded),
                      ],
                    ),
                  ),
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), shape: BoxShape.circle), child: const Icon(Icons.person_outline, color: Colors.white, size: 36)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AdminTheme.stroke), boxShadow: [BoxShadow(color: AdminTheme.ink.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 6))]),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filter,
                      style: GoogleFonts.poppins(fontSize: 13, color: AdminTheme.ink),
                      decoration: InputDecoration(
                        hintText: 'Cari pengguna...',
                        hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                        prefixIcon: const Icon(Icons.search, color: AdminTheme.primary),
                        filled: true,
                        fillColor: AdminTheme.primarySoft,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primary, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), shape: const StadiumBorder()),
                    onPressed: _showAddDialog,
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
                  _tableHeader(),
                  Expanded(
                    child: RefreshIndicator(
                      color: AdminTheme.primary,
                      onRefresh: _loadData,
                      child: _isLoading
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: const [SizedBox(height: 260, child: Center(child: CircularProgressIndicator(color: AdminTheme.primary)))],
                            )
                          : _penggunaList.isEmpty
                              ? ListView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  children: const [SizedBox(height: 260, child: Center(child: Text("Tidak ada data")))],
                                )
                              : Builder(
                                  builder: (context) {
                                    final paginatedList = getPaginatedList(_penggunaList, _currentPage, _rowsPerPage);
                                    final startIndex = (_currentPage - 1) * _rowsPerPage;
                                    return ListView.builder(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      itemCount: paginatedList.length,
                                      itemBuilder: (_, i) {
                                        final item = paginatedList[i];
                                        final globalIndex = startIndex + i;
                                        final role = item['role'] ?? '-';
                                        final isAdmin = role == 'Admin';
                                        final bgColor = i.isEven ? Colors.white : AdminTheme.rowAlt;
                                        final roleBackground = isAdmin ? AdminTheme.primaryDark : const Color(0xFF4A90D9);
                                        final roleTextColor = Colors.white;

                                        return Container(
                                          decoration: BoxDecoration(
                                            color: bgColor,
                                            border: const Border(
                                              bottom: BorderSide(color: AdminTheme.stroke),
                                            ),
                                          ),
                                          child: IntrinsicHeight(
                                            child: Row(
                                              children: [
                                                _cell("${globalIndex + 1}", 1, TextAlign.center),
                                                _buildDivider(),
                                                _cell(item['nama_lengkap'] ?? '-', 3, TextAlign.left),
                                                _buildDivider(),
                                                _cell(item['email'] ?? '-', 4, TextAlign.left),
                                                _buildDivider(),
                                                _roleCell(role, 2, backgroundColor: roleBackground, textColor: roleTextColor),
                                                _buildDivider(),
                                                Expanded(
                                                  flex: 3,
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        _icon(Icons.visibility, AdminTheme.primary, () => _showDetail(item)),
                                                        const SizedBox(width: 6),
                                                        if (isAdmin) _icon(Icons.edit, AdminTheme.accent, () => _showEditDialog(item)),
                                                        if (isAdmin) const SizedBox(width: 6),
                                                        _icon(Icons.delete, AdminTheme.danger, () => _delete(item['id_user'])),
                                                      ],
                                                    ),
                                                  ),
                                                ),
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
                    totalPages: calculateTotalPages(_penggunaList.length, _rowsPerPage),
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

  Widget _icon(IconData i, Color c, VoidCallback fn) {
    return Tooltip(
      message: 'Aksi',
      child: Material(
        color: c.withOpacity(0.14),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: fn,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(i, size: 18, color: c),
          ),
        ),
      ),
    );
  }

  Widget _cell(String t, int f, TextAlign a) => Expanded(
    flex: f,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Text(
        t,
        textAlign: a,
        style: GoogleFonts.poppins(fontSize: 12, color: AdminTheme.ink),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );

  Widget _roleCell(
    String t,
    int f, {
    required Color backgroundColor,
    required Color textColor,
  }) =>
      Expanded(
        flex: f,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                t,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );

  Widget _tableHeader() => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [AdminTheme.headerLight, AdminTheme.headerDark]),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: IntrinsicHeight(
      child: Row(
        children: [
          _header("No", 1),
          _buildDivider(),
          _header("Nama", 3),
          _buildDivider(),
          _header("Email", 4),
          _buildDivider(),
          _header("Role", 2),
          _buildDivider(),
          _header("Aksi", 3),
        ],
      ),
    ),
  );

  Widget _buildDivider() => Container(width: 1, color: AdminTheme.stroke);

  Widget _header(String t, int f) => Expanded(
    flex: f,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Text(
        t,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AdminTheme.ink),
      ),
    ),
  );

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
}
