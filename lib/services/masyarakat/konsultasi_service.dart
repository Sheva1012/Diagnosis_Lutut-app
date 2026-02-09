import 'package:url_launcher/url_launcher.dart';

class KonsultasiService {
  
  // Data Link (Sesuai Request Anda)
  final String _waUrl = "https://wa.me/c/6281216338862";
  final String _igUrl = "https://www.instagram.com/kmc_physiotherapy?utm_source=ig_web_button_share_sheet&igsh=ZDNlZDc0MzIxNw==";
  final String _phone = "+6281216338862"; // Format bersih untuk tel:
  final String _mapsUrl = "https://maps.app.goo.gl/AVPDSZJmkAKSMFUA7";

  /// Membuka Link Umum (WA, IG, Maps)
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // 1. WhatsApp
  Future<void> openWhatsApp() async {
    await _launchURL(_waUrl);
  }

  // 2. Instagram
  Future<void> openInstagram() async {
    await _launchURL(_igUrl);
  }

  // 3. Telepon Klinik
  Future<void> callClinic() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: _phone);
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch phone call');
    }
  }

  // 4. Lokasi (Maps)
  Future<void> openMaps() async {
    await _launchURL(_mapsUrl);
  }
}