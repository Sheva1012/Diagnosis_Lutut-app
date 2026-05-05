import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class HasilDiagnosisMasyarakat extends StatefulWidget {
  final String namaCedera;
  final String penangananAwal; // Parameter Baru
  final String penangananLanjut; // Parameter Baru
  final double persentase;
  final double nilaiCf;
  final String tingkatKepastian;

  const HasilDiagnosisMasyarakat({
    super.key,
    required this.namaCedera,
    required this.penangananAwal,
    required this.penangananLanjut,
    required this.persentase,
    required this.nilaiCf,
    required this.tingkatKepastian,
  });

  @override
  State<HasilDiagnosisMasyarakat> createState() =>
      _HasilDiagnosisMasyarakatState();
}

class _HasilDiagnosisMasyarakatState extends State<HasilDiagnosisMasyarakat> {
  static const Color _bg = Color(0xFFF2F6FF);
  static const Color _ink = Color(0xFF1F2A44);
  static const Color _primary = Color(0xFF2F6FDB);
  static const Color _soft = Color(0xFFE7F0FF);
  static const Color _muted = Color(0xFF6B7A99);
  static const Color _border = Color(0xFFD6E2F3);

  String? _videoAssetPath;
  VideoPlayerController? _previewController;
  bool _isPreviewLoading = false;
  String? _videoErrorMessage;

  static const Map<String, String> _imageByCederaKeyword = {
    'acl': 'assets/images/ACL.jpg',
    'pcl': 'assets/images/PCL.jpg',
    'mcl': 'assets/images/MCL.jpg',
    'lcl': 'assets/images/LCL.jpg',
    'meniscus': 'assets/images/MENISCUS.jpg',
    'meniskus': 'assets/images/MENISCUS.jpg',
  };

  static const Map<String, String> _videoByCederaKeyword = {
    'acl': 'assets/videos/acl_rehab.mp4',
    'pcl': 'assets/videos/pcl_rehab.mp4',
    'mcl': 'assets/videos/mcl_rehab.mp4',
    'lcl': 'assets/videos/lcl_rehab.mp4',
    'meniskus': 'assets/videos/meniscus_rehab.mp4',
    'meniscus': 'assets/videos/meniscus_rehab.mp4',
  };

  @override
  void initState() {
    super.initState();
    _initializeVideoForCedera();
  }

  @override
  void didUpdateWidget(covariant HasilDiagnosisMasyarakat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.namaCedera != widget.namaCedera) {
      _initializeVideoForCedera();
    }
  }

  @override
  void dispose() {
    _previewController?.dispose();
    super.dispose();
  }

  String? _resolveVideoAsset(String namaCedera) {
    final normalizedNamaCedera = namaCedera.toLowerCase();

    for (final entry in _videoByCederaKeyword.entries) {
      if (normalizedNamaCedera.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  String? _resolveCederaImageAsset(String namaCedera) {
    final normalized = namaCedera.toLowerCase();

    for (final entry in _imageByCederaKeyword.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  Widget _buildHeaderImage(String? imageAsset) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: imageAsset == null
          ? Icon(
              Icons.health_and_safety_outlined,
              size: 54,
              color: _primary,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                width: 112,
                height: 112,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.health_and_safety_outlined,
                    size: 54,
                    color: _primary,
                  );
                },
              ),
            ),
    );
  }

  void _initializeVideoForCedera() async {
    _previewController?.dispose();
    _previewController = null;
    _videoErrorMessage = null;

    final assetPath = _resolveVideoAsset(widget.namaCedera);
    if (!mounted) return;
    setState(() {
      _videoAssetPath = assetPath;
      _isPreviewLoading = assetPath != null;
    });

    if (assetPath == null) {
      return;
    }

    final controller = VideoPlayerController.asset(assetPath);
    _previewController = controller;

    try {
      await controller.initialize();
      await controller.pause();
      await controller.seekTo(Duration.zero);

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _isPreviewLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _isPreviewLoading = false;
        _videoErrorMessage =
            'Video latihan untuk ${widget.namaCedera} belum tersedia.';
      });
    }
  }

  Widget _buildVideoLatihanCard() {
    if (_videoAssetPath == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _ink.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _soft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.ondemand_video_rounded,
                  color: _primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Video Latihan Rehabilitasi',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Panduan latihan untuk ${widget.namaCedera}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: _muted,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _openVideoPopup,
            borderRadius: BorderRadius.circular(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: _previewController?.value.isInitialized == true
                    ? _previewController!.value.aspectRatio
                    : 16 / 9,
                child: _buildVideoPreviewBody(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPreviewBody() {
    if (_isPreviewLoading) {
      return Container(
        color: Colors.black.withOpacity(0.06),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_videoErrorMessage != null) {
      return Container(
        color: Colors.grey.shade100,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Text(
          _videoErrorMessage!,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    final controller = _previewController;
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.grey.shade100,
        child: Icon(
          Icons.video_library_outlined,
          color: Colors.grey.shade500,
          size: 36,
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        VideoPlayer(controller),
        Container(color: Colors.black.withOpacity(0.16)),
        const Center(
          child: Icon(
            Icons.play_circle_fill_rounded,
            size: 62,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  void _openVideoPopup() {
    final assetPath = _videoAssetPath;
    if (assetPath == null) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _VideoPopupPlayer(
          assetPath: assetPath,
          namaCedera: widget.namaCedera,
        );
      },
    );
  }

  // Helper untuk memecah text jadi list poin
  List<String> _parsePoin(String text) {
    if (text.trim().isEmpty || text == '-') return [];
    return text.split('\n').where((e) => e.trim().isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final listAwal = _parsePoin(widget.penangananAwal);
    final listLanjut = _parsePoin(widget.penangananLanjut);
    final headerImageAsset = _resolveCederaImageAsset(widget.namaCedera);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: Text(
          "Hasil Diagnosis",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: _ink,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
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
          child: Column(
            children: [
            // ================= KARTU HASIL =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_soft, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: [
                  _buildHeaderImage(headerImageAsset),
                  const SizedBox(height: 12),
                  Text(
                    "Kemungkinan Cedera",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: _muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.namaCedera,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Badge Persentase
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${widget.tingkatKepastian} (${widget.persentase.toStringAsFixed(0)}%)",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Judul Section
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Saran Penanganan",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _ink,
                ),
              ),
            ),
            const SizedBox(height: 12),

            _buildVideoLatihanCard(),
            if (_videoAssetPath != null) const SizedBox(height: 16),

            // ================= 1. PENANGANAN AWAL =================
            _buildPenangananCard(
              title: "Penanganan Awal (Pertolongan Pertama)",
              icon: Icons.medical_services_outlined,
              colorTheme: Colors.green,
              items: listAwal,
              emptyText: "Tidak ada penanganan awal khusus.",
            ),

            const SizedBox(height: 16),

            // ================= 2. PENANGANAN LANJUT =================
            _buildPenangananCard(
              title: "Penanganan Lanjut / Medis",
              icon: Icons.local_hospital_outlined,
              colorTheme: Colors.orange,
              items: listLanjut,
              emptyText:
                  "Segera konsultasikan ke dokter untuk penanganan lebih lanjut.",
            ),

            const SizedBox(height: 30),

            // ================= DISCLAIMER =================
            Text(
              "Catatan: Hasil ini hanya prediksi sistem pakar. Segera hubungi dokter spesialis ortopedi untuk diagnosis medis yang akurat.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: _muted,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Selesai",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper untuk Kartu Penanganan
  Widget _buildPenangananCard({
    required String title,
    required IconData icon,
    required Color colorTheme,
    required List<String> items,
    required String emptyText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: _ink.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorTheme.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: colorTheme, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            Text(
              emptyText,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: _muted,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(Icons.circle, size: 6, color: colorTheme),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: _ink,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }
}

class _VideoPopupPlayer extends StatefulWidget {
  final String assetPath;
  final String namaCedera;

  const _VideoPopupPlayer({required this.assetPath, required this.namaCedera});

  @override
  State<_VideoPopupPlayer> createState() => _VideoPopupPlayerState();
}

class _VideoPopupPlayerState extends State<_VideoPopupPlayer> {
  static const MethodChannel _galChannel = MethodChannel('gal');

  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _isDownloading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoChanged);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeController() async {
    final controller = VideoPlayerController.asset(widget.assetPath);
    _controller = controller;
    controller.addListener(_onVideoChanged);

    try {
      await controller.initialize();
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Video latihan untuk ${widget.namaCedera} belum tersedia.';
      });
    }
  }

  void _onVideoChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _togglePlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void _seekRelative(int seconds) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final duration = controller.value.duration;
    var target = controller.value.position + Duration(seconds: seconds);

    if (target < Duration.zero) {
      target = Duration.zero;
    }
    if (target > duration) {
      target = duration;
    }

    controller.seekTo(target);
  }

  Future<void> _downloadVideo() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final byteData = await rootBundle.load(widget.assetPath);
      final bytes = byteData.buffer.asUint8List();
      final tempDirectory = await getTemporaryDirectory();
      final safeCederaName = widget.namaCedera.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]+'),
        '_',
      );
      final fileName =
          '${safeCederaName}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final savedFile = File('${tempDirectory.path}/$fileName');

      await savedFile.writeAsBytes(bytes, flush: true);
      await _galChannel.invokeMethod<void>('putVideo', {
        'path': savedFile.path,
        'album': 'Knee Check',
      });

      if (!mounted) return;
      setState(() {
        _isDownloading = false;
      });

      Fluttertoast.showToast(
          msg: 'Video berhasil disimpan ke galeri.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
      });
      if (e is MissingPluginException) {
        Fluttertoast.showToast(
          msg: 'Plugin galeri belum aktif. Coba tutup aplikasi lalu jalankan ulang.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );
        return;
      }
      Fluttertoast.showToast(
          msg: 'Gagal menyimpan ke galeri: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }

    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF101418),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 260,
                child: Center(child: CircularProgressIndicator()),
              )
            : _errorMessage != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tutup'),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Video ${widget.namaCedera}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (controller != null && controller.value.isInitialized)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  const SizedBox(height: 10),
                  if (controller != null && controller.value.isInitialized)
                    VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: const Color(0xFF2F6FDB),
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (controller != null && controller.value.isInitialized)
                    Row(
                      children: [
                        Text(
                          _formatDuration(controller.value.position),
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDuration(controller.value.duration),
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  if (controller != null && controller.value.isInitialized)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => _seekRelative(-5),
                          icon: const Icon(
                            Icons.replay_5_rounded,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: _togglePlayback,
                          iconSize: 36,
                          icon: Icon(
                            controller.value.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_filled_rounded,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _seekRelative(5),
                          icon: const Icon(
                            Icons.forward_5_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isDownloading ? null : _downloadVideo,
                      icon: _isDownloading
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.download_rounded),
                      label: Text(
                        _isDownloading ? 'Mengunduh...' : 'Unduh Video',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F6FDB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
