import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_sidebar.dart';
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
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
      builder: (_) => AlertDialog(
        title: const Text("Detail Pengguna"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detail("Nama", item['nama_lengkap'] ?? '-'),
            _detail("Email", item['email'] ?? '-'),
            _detail("Username", item['username'] ?? '-'),
            _detail("Role", item['role'] ?? '-'),
            _detail("Terdaftar", date),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  Widget _detail(String t, String v) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          v,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );

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
      builder: (_) => AlertDialog(
        title: const Text("Tambah Admin Baru"),
        content: SingleChildScrollView(
          child: Column(
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nama.text.isEmpty ||
                  email.text.isEmpty ||
                  password.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mohon isi semua data wajib')),
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Gagal tambah: $e")));
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final nama = TextEditingController(text: item['nama_lengkap']);
    final email = TextEditingController(text: item['email']);
    final username = TextEditingController(text: item['username'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Admin"),
        content: SingleChildScrollView(
          child: Column(
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Gagal update: $e")));
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _delete(String idUser) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Pengguna"),
        content: const Text("Yakin ingin menghapus pengguna ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await _penggunaService.deletePengguna(idUser);
                await _loadData();
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Gagal hapus: $e")));
              }
            },
            child: const Text("Hapus"),
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
    decoration: InputDecoration(
      labelText: l,
      border: const OutlineInputBorder(),
    ),
  );

  SizedBox _gap() => const SizedBox(height: 14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        title: const Text(
          'Data Pengguna',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      drawer: const AdminSidebar(activePage: 'pengguna'),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // search + add
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filter,
                    decoration: const InputDecoration(
                      hintText: 'Cari pengguna...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
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
                    onPressed: _showAddDialog,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // table
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _tableHeader(),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _penggunaList.isEmpty
                        ? const Center(child: Text("Tidak ada data"))
                        : ListView.builder(
                            itemCount: _penggunaList.length,
                            itemBuilder: (_, i) {
                              final item = _penggunaList[i];
                              final role = item['role'] ?? '-';
                              final isAdmin = role == 'Admin';

                              return Container(
                                decoration: BoxDecoration(
                                  color: isAdmin
                                      ? Colors.blue[50]
                                      : Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      _cell("${i + 1}", 1, TextAlign.center),
                                      _cell(
                                        item['nama_lengkap'] ?? '-',
                                        3,
                                        TextAlign.left,
                                      ),
                                      _cell(
                                        item['email'] ?? '-',
                                        4,
                                        TextAlign.left,
                                      ),
                                      _cell(role, 2, TextAlign.center),
                                      Expanded(
                                        flex: 3,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _icon(
                                                Icons.visibility,
                                                Colors.blue,
                                                () => _showDetail(item),
                                              ),
                                              if (isAdmin)
                                                _icon(
                                                  Icons.edit,
                                                  Colors.orange,
                                                  () => _showEditDialog(item),
                                                ),
                                              _icon(
                                                Icons.delete,
                                                Colors.red,
                                                () => _delete(item['id_user']),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _icon(IconData i, Color c, VoidCallback fn) => IconButton(
    icon: Icon(i, color: c, size: 18),
    onPressed: fn,
  );

  Widget _cell(String t, int f, TextAlign a) => Expanded(
    flex: f,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      child: Text(
        t,
        textAlign: a,
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );

  Widget _tableHeader() => Container(
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
    ),
    child: Row(
      children: [
        _header("No", 1),
        _header("Nama", 3),
        _header("Email", 4),
        _header("Role", 2),
        _header("Aksi", 3),
      ],
    ),
  );

  Widget _header(String t, int f) => Expanded(
    flex: f,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        t,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
