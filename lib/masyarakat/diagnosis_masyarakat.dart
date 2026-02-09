import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/masyarakat/diagnosis_service.dart';
import 'hasil_diagnosis_masyarakat.dart';

class DiagnosisMasyarakat extends StatefulWidget {
  const DiagnosisMasyarakat({super.key});

  @override
  State<DiagnosisMasyarakat> createState() => _DiagnosisMasyarakatState();
}

class _DiagnosisMasyarakatState extends State<DiagnosisMasyarakat> {
  final DiagnosisService _service = DiagnosisService();

  List<Map<String, dynamic>> _questions = []; // Data Gejala
  List<Map<String, dynamic>> _aturanPakar = []; // Data Aturan CF Pakar
  bool _isLoading = true;
  int _currentIndex = 0;

  // Jawaban User: Key = ID Gejala, Value = Nilai CF User
  final Map<int, double> _answers = {};
  final Map<int, String> _answerLabels = {};

  final List<Map<String, dynamic>> _options = [
    {"label": "Sangat Yakin", "value": 1.0},
    {"label": "Yakin", "value": 0.8},
    {"label": "Cukup Yakin", "value": 0.6},
    {"label": "Kurang Yakin", "value": 0.4},
    {"label": "Tidak Tahu / Ragu", "value": 0.2},
    {"label": "Tidak", "value": 0.0},
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      // 1. Ambil Gejala (Pertanyaan)
      final gejalaData = await _service.getPertanyaanGejala();
      // 2. Ambil Aturan Pakar (Bobot & Penanganan)
      final aturanData = await _service.getAturanPakar();

      if (mounted) {
        setState(() {
          _questions = gejalaData;
          _aturanPakar = aturanData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // PERBAIKAN: Matikan loading jika error agar tidak stuck
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _nextQuestion() {
    // Ambil ID Gejala dari pertanyaan saat ini
    final currentIdGejala = _questions[_currentIndex]['id_gejala'];

    if (_answers[currentIdGejala] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan pilih tingkat keyakinan Anda"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _calculateAndFinish();
    }
  }

  // === ALGORITMA CERTAINTY FACTOR ===
  Future<void> _calculateAndFinish() async {
    setState(() => _isLoading = true);

    try {
      // Map untuk menyimpan CF Combine per Cedera
      // Key: id_cedera, Value: Nilai CF Sementara
      Map<int, double> hasilCF = {};
      Map<int, Map<String, dynamic>> infoCedera = {}; // Simpan nama & detail

      // Loop semua aturan pakar
      for (var aturan in _aturanPakar) {
        int idGejala = aturan['id_gejala'];
        int idCedera = aturan['id_cedera'];
        double cfPakar = (aturan['bobot_cf_pakar'] as num).toDouble();

        // Simpan info cedera (jika belum ada) agar bisa diambil nanti
        if (!infoCedera.containsKey(idCedera)) {
          infoCedera[idCedera] = aturan['cedera'];
        }

        // Cek apakah User menjawab gejala ini?
        if (_answers.containsKey(idGejala)) {
          double cfUser = _answers[idGejala]!;

          // RUMUS 1: CF(H, E) = CF(User) * CF(Pakar)
          double cfGejala = cfUser * cfPakar;

          // Jika CF Gejala > 0, Lakukan Kombinasi Sequential
          if (cfGejala > 0) {
            double cfOld = hasilCF[idCedera] ?? 0.0;

            // RUMUS 2: CF Combine = CF_old + CF_gejala * (1 - CF_old)
            double cfCombine = cfOld + cfGejala * (1 - cfOld);

            hasilCF[idCedera] = cfCombine;
          }
        }
      }

      // Cari Nilai Tertinggi
      if (hasilCF.isEmpty) {
        throw Exception(
          "Gejala yang Anda masukkan tidak cocok dengan cedera manapun.",
        );
      }

      // Urutkan dari yang terbesar
      var sortedKeys = hasilCF.keys.toList(growable: false)
        ..sort((k1, k2) => hasilCF[k2]!.compareTo(hasilCF[k1]!));

      int idPemenang = sortedKeys.first;
      double nilaiFinal = hasilCF[idPemenang]!;
      double persentase = nilaiFinal * 100;
      String tingkatKepastian = _getTingkatKepastian(nilaiFinal);

      // Siapkan data detail untuk disimpan
      List<Map<String, dynamic>> detailJawaban = [];
      _answers.forEach((key, value) {
        detailJawaban.add({
          'id_gejala': key,
          'cf_user': value,
          'label': _answerLabels[key],
        });
      });

      // Simpan ke Database
      await _service.saveDiagnosis(
        idCedera: idPemenang,
        nilaiCfFinal: nilaiFinal,
        persentase: persentase,
        tingkatKepastian: tingkatKepastian,
        detailJawaban: detailJawaban,
      );

      // --- LOGIKA MENGAMBIL DATA PENANGANAN (AWAL & LANJUT) ---
      final dataCedera = infoCedera[idPemenang] ?? {};
      
      // Ambil list penanganan dari relasi tabel
      final listPenanganan = dataCedera['penanganan'] as List<dynamic>?;

      String pAwal = "- Belum ada data penanganan awal.";
      String pLanjut = "- Belum ada data penanganan lanjut.";

      if (listPenanganan != null && listPenanganan.isNotEmpty) {
        // Ambil data pertama dari list
        // PERBAIKAN: Menggunakan key 'penanganan_lanjutan' sesuai DB Anda
        pAwal = listPenanganan[0]['penanganan_awal'] ?? "-";
        pLanjut = listPenanganan[0]['penanganan_lanjutan'] ?? "-";
      }
      // ---------------------------------------------------------

      if (!mounted) return;

      // NAVIGASI KE HALAMAN HASIL
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HasilDiagnosisMasyarakat(
            namaCedera: dataCedera['nama_cedera'] ?? 'Tidak Diketahui',
            penangananAwal: pAwal,      // Kirim Penanganan Awal
            penangananLanjut: pLanjut,  // Kirim Penanganan Lanjut
            persentase: persentase,
            nilaiCf: nilaiFinal,
            tingkatKepastian: tingkatKepastian,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        // PERBAIKAN: Matikan loading jika error
        setState(() => _isLoading = false);
        
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text("Informasi"),
            content: Text("Terjadi kesalahan: ${e.toString().replaceAll("Exception:", "")}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  String _getTingkatKepastian(double cf) {
    if (cf >= 0.8) return "Sangat Pasti";
    if (cf >= 0.6) return "Hampir Pasti";
    if (cf >= 0.4) return "Kemungkinan Besar";
    if (cf >= 0.2) return "Mungkin";
    return "Tidak Tahu";
  }

  @override
  Widget build(BuildContext context) {
    double progress = _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length;
    
    String questionText = "Memuat...";
    int currentIdGejala = 0;

    if (_questions.isNotEmpty) {
      currentIdGejala = _questions[_currentIndex]['id_gejala'];
      // Gunakan kolom 'pertanyaan', jika null fallback ke 'nama_gejala'
      questionText = _questions[_currentIndex]['pertanyaan'] ?? 
                     "Apakah Anda mengalami ${_questions[_currentIndex]['nama_gejala']}?";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Mulai Diagnosis",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blue.shade500,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Info Progress
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Pertanyaan ${_currentIndex + 1} dari ${_questions.length}",
                      style: GoogleFonts.poppins(color: Colors.grey.shade700),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFF9747FF),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // KOTAK PERTANYAAN
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black87, width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Text(
                      questionText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2D3142),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // LIST OPSI JAWABAN
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _options.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final option = _options[index];
                        // Menggunakan ID GEJALA sebagai key
                        final isSelected = _answers[currentIdGejala] == option['value'];

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _answers[currentIdGejala] = option['value'];
                              _answerLabels[currentIdGejala] = option['label'];
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFF3E8FF) : Colors.grey.shade50,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF9747FF) : Colors.transparent,
                                width: 1.5
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? const Color(0xFF9747FF) : Colors.grey.shade400,
                                      width: 2
                                    ),
                                    color: isSelected ? const Color(0xFF9747FF) : Colors.transparent,
                                  ),
                                  child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  option['label'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    color: Colors.black87
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // TOMBOL SELANJUTNYA
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE0C6FD),
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentIndex == _questions.length - 1 ? "Selesai & Lihat Hasil" : "Selanjutnya",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}