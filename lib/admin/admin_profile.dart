import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/admin/profile_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'admin_theme.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  final service = ProfileService();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final FocusNode usernameFocusNode = FocusNode();

  String joined = "";
  String foto = "";
  String initialUsername = "";
  String initialNama = "";
  String initialNoHp = "";

  File? imageFile;
  bool isLoading = false;
  bool isEditMode = false;
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    usernameController.addListener(_onFormChanged);
    namaController.addListener(_onFormChanged);
    noHpController.addListener(_onFormChanged);
    loadData();
  }

  void _onFormChanged() {
    if (!mounted) return;

    final changed =
        usernameController.text.trim() != initialUsername.trim() ||
        namaController.text.trim() != initialNama.trim() ||
        noHpController.text.trim() != initialNoHp.trim() ||
        imageFile != null;

    if (changed != hasChanges) {
      setState(() {
        hasChanges = changed;
      });
    }
  }

  void _enterEditMode() {
    setState(() => isEditMode = true);
    Future.delayed(Duration.zero, () {
      if (mounted) {
        usernameFocusNode.requestFocus();
      }
    });
  }

  void _cancelEdit() {
    setState(() {
      isEditMode = false;
      imageFile = null;
      usernameController.text = initialUsername;
      namaController.text = initialNama;
      noHpController.text = initialNoHp;
      hasChanges = false;
    });
  }

  Future<void> loadData() async {
    final data = await service.getProfile();

    if (!mounted) return;

    setState(() {
      usernameController.text = data['username']!;
      namaController.text = data['nama_lengkap']!;
      emailController.text = data['email']!;
      noHpController.text = data['no_hp']!;
      joined = data['joined_at']!;
      foto = data['foto']!;
      initialUsername = data['username']!;
      initialNama = data['nama_lengkap']!;
      initialNoHp = data['no_hp']!;
      hasChanges = false;
      isEditMode = false;
      imageFile = null;
    });
  }

  @override
  void dispose() {
    usernameController.removeListener(_onFormChanged);
    namaController.removeListener(_onFormChanged);
    noHpController.removeListener(_onFormChanged);
    usernameController.dispose();
    namaController.dispose();
    emailController.dispose();
    noHpController.dispose();
    usernameFocusNode.dispose();
    super.dispose();
  }

  void pickImage() async {
    if (!isEditMode) {
      _showImagePopup();
      return;
    }

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: picked.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 80,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Sesuaikan Foto',
            toolbarColor: AdminTheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Sesuaikan Foto',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        imageFile = File(croppedFile.path);
        _onFormChanged();
        setState(() {});
      }
    }
  }

  void _showImagePopup() {
    final imageProvider = imageFile != null
        ? FileImage(imageFile!) as ImageProvider
        : (foto.isNotEmpty ? NetworkImage(foto) : null);

    if (imageProvider == null) {
      Fluttertoast.showToast(
          msg: "Belum ada foto profil",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image(image: imageProvider, fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveProfile() async {
    if (usernameController.text.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "Username tidak boleh kosong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
      return;
    }

    if (namaController.text.trim().isEmpty) {
      Fluttertoast.showToast(
          msg: "Nama lengkap tidak boleh kosong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
      return;
    }

    if (!hasChanges) {
      Fluttertoast.showToast(
          msg: "Belum ada perubahan yang disimpan",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
      return;
    }

    setState(() => isLoading = true);

    try {
      await service.updateProfile(
        username: usernameController.text.trim(),
        nama: namaController.text.trim(),
        noHp: noHpController.text.trim(),
        imageFile: imageFile,
      );

      if (!mounted) return;

      setState(() => isLoading = false);
      Fluttertoast.showToast(
          msg: "Profil berhasil diperbarui",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );

      await loadData();
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      Fluttertoast.showToast(
          msg: "Gagal simpan profil: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = hasChanges
        ? const Color(0xFFED6C02)
        : const Color(0xFF2E7D32);
    final statusBgColor = hasChanges
        ? const Color(0xFFFFF3E0)
        : const Color(0xFFE8F5E9);
    final statusIcon = hasChanges ? Icons.edit_note : Icons.verified;
    final statusText = hasChanges
        ? "Perubahan belum disimpan"
        : "Profil tersimpan";

    // Mengganti LayoutBuilder dengan MediaQuery agar tidak konflik dengan Spacer
    final bool compact = MediaQuery.of(context).size.height < 700;
    final double gap = compact ? 10.0 : 12.0;

    InputDecoration buildInputDecoration(String label, IconData icon) {
      return InputDecoration(
        isDense: true,
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AdminTheme.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFF4EB),
                    Color(0xFFFFF7F0),
                    Color(0xFFFFFBF7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          Positioned(
            top: -70,
            right: -30,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: AdminTheme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            top: 250,
            left: -55,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: AdminTheme.accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
            ),
          ),

          /// 🔵 HEADER GRADIENT
          Container(
            height: 215,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AdminTheme.primaryDark,
                  AdminTheme.primary,
                  AdminTheme.accent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// 🔥 CONTENT BISA DI-PULL UNTUK REFRESH & SCROLLABLE SAAT KEYBOARD MUNCUL
          SafeArea(
            child: RefreshIndicator(
              onRefresh: loadData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false, // Penting agar otomatis mengisi layar & menahan overflow
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                      child: Column(
                        children: [
                          /// 🔙 APPBAR CUSTOM (Tombol refresh sudah dihapus)
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Profil Admin",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          /// 🔥 AVATAR FLOATING
                          GestureDetector(
                            onTap: pickImage,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 49,
                                  backgroundColor: Colors.white,
                                  backgroundImage: imageFile != null
                                      ? FileImage(imageFile!)
                                      : (foto.isNotEmpty ? NetworkImage(foto) : null),
                                  child: foto.isEmpty && imageFile == null
                                      ? const Icon(Icons.person, size: 42)
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: AdminTheme.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(color: Colors.black26, blurRadius: 4),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            usernameController.text.isEmpty
                                ? "Admin"
                                : usernameController.text,
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          if (namaController.text.isNotEmpty)
                            Text(
                              namaController.text,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),

                          const SizedBox(height: 6),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 16, color: statusColor),
                                const SizedBox(width: 6),
                                Text(
                                  statusText,
                                  style: GoogleFonts.poppins(
                                    color: statusColor,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// 🔥 CARD FORM (Dibuat otomatis memanjang ke bawah dengan Expanded)
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: compact ? 8 : 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AdminTheme.primarySoft,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          size: 16,
                                          color: AdminTheme.primaryDark,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            isEditMode
                                                ? "Mode edit aktif. Email tetap tidak bisa diubah."
                                                : "Tekan Edit Profil untuk mulai mengubah data.",
                                            style: GoogleFonts.poppins(
                                              fontSize: compact ? 11 : 12,
                                              color: AdminTheme.primaryDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: gap),

                                  TextField(
                                    controller: usernameController,
                                    focusNode: usernameFocusNode,
                                    enabled: isEditMode,
                                    textInputAction: TextInputAction.next,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                    ),
                                    decoration: buildInputDecoration(
                                      "Username",
                                      Icons.alternate_email,
                                    ),
                                  ),

                                  SizedBox(height: gap),

                                  TextField(
                                    controller: namaController,
                                    enabled: isEditMode,
                                    textInputAction: TextInputAction.next,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                    ),
                                    decoration: buildInputDecoration(
                                      "Nama Lengkap",
                                      Icons.person,
                                    ),
                                  ),

                                  SizedBox(height: gap),

                                  TextField(
                                    controller: emailController,
                                    enabled: false,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                    ),
                                    decoration: buildInputDecoration(
                                      "Email",
                                      Icons.email,
                                    ),
                                  ),

                                  SizedBox(height: gap),

                                  TextField(
                                    controller: noHpController,
                                    enabled: isEditMode,
                                    keyboardType: TextInputType.phone,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black87,
                                    ),
                                    decoration: buildInputDecoration(
                                      "No HP",
                                      Icons.phone,
                                    ),
                                  ),

                                  SizedBox(height: compact ? 8 : 10),

                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Bergabung sejak: $joined",
                                      style: GoogleFonts.poppins(
                                        fontSize: compact ? 11 : 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                  const Spacer(),

                                  isLoading
                                      ? const CircularProgressIndicator(color: AdminTheme.primary)
                                      : !isEditMode
                                      ? SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: _enterEditMode,
                                            icon: const Icon(Icons.edit),
                                            label: const Text("Edit Profil"),
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                  12,
                                                ),
                                              ),
                                              backgroundColor: AdminTheme.primary,
                                            ),
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    onPressed: _cancelEdit,
                                                    style: OutlinedButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                          12,
                                                        ),
                                                      ),
                                                    ),
                                                    child: const Text("Batal"),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: ElevatedButton.icon(
                                                    onPressed: hasChanges
                                                        ? saveProfile
                                                        : null,
                                                    icon: const Icon(Icons.save),
                                                    label: const Text("Simpan"),
                                                    style: ElevatedButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                          12,
                                                        ),
                                                      ),
                                                      backgroundColor: AdminTheme.primary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              hasChanges
                                                  ? "Perubahan terdeteksi. Tekan Simpan."
                                                  : "Belum ada perubahan.",
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}