import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart'; // 1. IMPORT INI
import '../services/masyarakat/profile_service.dart';

class EditProfilMasyarakat extends StatefulWidget {
  final String currentName;
  final String currentPhone;
  final String currentEmail;
  final String currentPhotoUrl;

  const EditProfilMasyarakat({
    super.key,
    required this.currentName,
    required this.currentPhone,
    required this.currentEmail,
    this.currentPhotoUrl = '',
  });

  @override
  State<EditProfilMasyarakat> createState() => _EditProfilMasyarakatState();
}

class _EditProfilMasyarakatState extends State<EditProfilMasyarakat> {
  static const Color _bg = Color(0xFFF2F6FF);
  static const Color _ink = Color(0xFF1F2A44);
  static const Color _primary = Color(0xFF2F6FDB);
  static const Color _soft = Color(0xFFE7F0FF);
  static const Color _muted = Color(0xFF6B7A99);
  static const Color _border = Color(0xFFD6E2F3);

  final ProfileService _service = ProfileService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _hpController;
  late TextEditingController _emailController;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.currentName == '-' ? '' : widget.currentName);
    _hpController = TextEditingController(text: widget.currentPhone == '-' ? '' : widget.currentPhone);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  // --- LOGIKA GAMBAR BARU (PICK -> CROP) ---

  // 1. Fungsi Pilih Gambar (Hanya Memilih)
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Ambil kualitas penuh dulu sebelum di-crop
      );
      
      if (pickedFile != null) {
        // JANGAN LANGSUNG SET STATE, TAPI CROP DULU
        _cropImage(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Error pick image: $e");
    }
  }

  // 2. Fungsi Crop Gambar (WA/IG Style)
  Future<void> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        // Kunci Rasio jadi Persegi (1:1) karena ini Foto Profil
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        // Pengaturan Tampilan Cropper
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Foto',
            toolbarColor: _primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true, // Kunci agar tetap persegi
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Potong Foto',
            aspectRatioLockEnabled: true, // Kunci agar tetap persegi
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        // Jika user selesai memotong, baru simpan ke state
        setState(() {
          _selectedImage = File(croppedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error cropping: $e");
    }
  }

  // ... (Fungsi _viewPhoto, _showImageOptions, _saveProfile, build TETAP SAMA) ...
  // ... Paste sisa kode di bawah ini ...

  void _viewPhoto() {
    ImageProvider? imageToView;
    if (_selectedImage != null) {
      imageToView = FileImage(_selectedImage!);
    } else if (widget.currentPhotoUrl.isNotEmpty) {
      imageToView = NetworkImage(widget.currentPhotoUrl);
    }

    if (imageToView == null) {
      Fluttertoast.showToast(
          msg: "Belum ada foto profil",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
          body: Center(child: InteractiveViewer(child: Image(image: imageToView!))),
        ),
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle), child: Icon(Icons.visibility, color: Colors.blue.shade600)),
                title: Text("Lihat Foto", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                onTap: () { Navigator.pop(context); _viewPhoto(); },
              ),
              ListTile(
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle), child: Icon(Icons.photo_library, color: Colors.green.shade600)),
                title: Text("Ubah Foto", style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                onTap: () { Navigator.pop(context); _pickImage(); }, // Panggil _pickImage yang baru
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _service.updateUserProfile(
        namaLengap: _namaController.text.trim(),
        noTelepon: _hpController.text.trim(),
        imageFile: _selectedImage,
      );
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Profil berhasil diperbarui!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) Fluttertoast.showToast(
          msg: "Terjadi kesalahan",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;
    if (_selectedImage != null) {
      avatarImage = FileImage(_selectedImage!);
    } else if (widget.currentPhotoUrl.isNotEmpty) {
      avatarImage = NetworkImage(widget.currentPhotoUrl);
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text("Edit Profil", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: _ink,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5F8FF),
              Color(0xFFEAF1FF),
              Color(0xFFF9FBFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: GestureDetector(
                  onTap: _showImageOptions,
                  onLongPress: _showImageOptions,
                  child: Stack(
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: _soft,
                          shape: BoxShape.circle,
                          border: Border.all(color: _border, width: 2),
                          image: avatarImage != null ? DecorationImage(image: avatarImage, fit: BoxFit.cover) : null,
                        ),
                        child: avatarImage == null ? Icon(Icons.person, size: 50, color: _primary) : null,
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(child: Text("Ketuk foto untuk opsi lainnya", style: GoogleFonts.poppins(fontSize: 12, color: _muted))),
              const SizedBox(height: 30),
              _buildLabel("Nama Lengkap"),
              TextFormField(
                controller: _namaController,
                decoration: _inputDecoration("Masukkan nama lengkap"),
                style: GoogleFonts.poppins(),
                validator: (v) => (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              _buildLabel("Nomor HP"),
              TextFormField(
                controller: _hpController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Masukkan nomor HP"),
                style: GoogleFonts.poppins(),
                validator: (v) => (v == null || v.isEmpty) ? 'Nomor HP tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              _buildLabel("Email"),
              TextFormField(
                controller: _emailController,
                readOnly: true,
                style: GoogleFonts.poppins(color: _muted),
                decoration: _inputDecoration("Email").copyWith(filled: true, fillColor: _soft, suffixIcon: const Icon(Icons.lock, size: 18, color: Colors.grey)),
              ),
              const SizedBox(height: 8),
              Text("*Email tidak dapat diubah.", style: GoogleFonts.poppins(fontSize: 11, color: _muted, fontStyle: FontStyle.italic)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text("Simpan Perubahan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(foregroundColor: _muted, side: BorderSide(color: _border), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text("Batal", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(text, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: _ink)));
  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: _muted, fontSize: 14), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primary)));
}