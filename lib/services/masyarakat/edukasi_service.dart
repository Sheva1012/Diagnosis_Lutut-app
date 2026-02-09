import 'package:flutter/material.dart';

class EdukasiService {
  
  /// Mengambil data edukasi (Disimulasikan seperti ambil dari database)
  Future<List<Map<String, dynamic>>> getEdukasiList() async {
    // Simulasi delay sedikit agar terasa natural
    await Future.delayed(const Duration(milliseconds: 300));

    return [
      {
        "title": "Apa itu Cedera Lutut?",
        "icon": Icons.info_rounded,
        "color": Colors.purple,
        "content": "Cedera lutut adalah kerusakan pada struktur lutut yang meliputi tulang, tulang rawan, ligamen, dan tendon. Cedera ini sering terjadi akibat olahraga, kecelakaan, atau tekanan berulang pada sendi lutut."
      },
      {
        "title": "Penyebab Cedera Lutut",
        "icon": Icons.help_rounded,
        "color": Colors.indigo,
        "content": "Penyebab umum meliputi:\n\n"
            "• Hentakan tiba-tiba atau berhenti mendadak saat berlari.\n"
            "• Pukulan atau benturan langsung ke lutut.\n"
            "• Mendarat dengan posisi kaki yang salah setelah melompat.\n"
            "• Penggunaan berlebihan (overuse) saat berolahraga."
      },
      {
        "title": "Faktor Risiko Cedera",
        "icon": Icons.warning_rounded,
        "color": Colors.orange,
        "content": "Beberapa faktor yang meningkatkan risiko cedera:\n\n"
            "• Kelebihan berat badan (Obesitas) memberikan tekanan ekstra pada lutut.\n"
            "• Kurangnya kelenturan atau kekuatan otot.\n"
            "• Riwayat cedera lutut sebelumnya.\n"
            "• Olahraga intensitas tinggi (basket, sepak bola, futsal)."
      },
      {
        "title": "Gejala Umum Cedera Lutut",
        "icon": Icons.medical_services_rounded,
        "color": Colors.blue,
        "content": "Tanda-tanda cedera lutut meliputi:\n\n"
            "• Nyeri hebat saat digerakkan.\n"
            "• Pembengkakan dan kemerahan di area lutut.\n"
            "• Lutut terasa kaku atau sulit diluruskan.\n"
            "• Terdengar bunyi 'pop' atau 'krak' saat cedera terjadi.\n"
            "• Lutut terasa tidak stabil atau 'goyang'."
      },
      {
        "title": "Pencegahan Cedera Lutut",
        "icon": Icons.shield_rounded,
        "color": Colors.green,
        "content": "Cara menjaga kesehatan lutut:\n\n"
            "• Lakukan pemanasan sebelum olahraga dan pendinginan setelahnya.\n"
            "• Gunakan sepatu yang sesuai dan nyaman.\n"
            "• Latih kekuatan otot paha (Quadriceps & Hamstring) untuk menopang lutut.\n"
            "• Jaga berat badan ideal."
      },
      {
        "title": "Kapan Harus ke Tenaga Medis",
        "icon": Icons.local_hospital_rounded,
        "color": Colors.red,
        "content": "Segera hubungi dokter jika:\n\n"
            "• Tidak bisa menumpu beban tubuh pada kaki yang sakit.\n"
            "• Terjadi perubahan bentuk (deformitas) pada lutut.\n"
            "• Nyeri sangat hebat dan bengkak parah.\n"
            "• Demam disertai kemerahan pada lutut (tanda infeksi)."
      },
    ];
  }
}