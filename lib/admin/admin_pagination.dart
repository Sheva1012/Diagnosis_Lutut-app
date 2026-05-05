import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_theme.dart';

/// Widget pagination yang bisa dipakai di semua halaman admin.
/// Menampilkan tombol Previous, nomor halaman, dan Next.
class AdminPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const AdminPagination({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(top: BorderSide(color: AdminTheme.stroke)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tombol Previous
          _buildNavButton(
            icon: Icons.chevron_left_rounded,
            label: 'Prev',
            enabled: currentPage > 1,
            onTap: () => onPageChanged(currentPage - 1),
          ),
          const SizedBox(width: 8),

          // Nomor halaman
          ..._buildPageNumbers(),

          const SizedBox(width: 8),
          // Tombol Next
          _buildNavButton(
            icon: Icons.chevron_right_rounded,
            label: 'Next',
            enabled: currentPage < totalPages,
            onTap: () => onPageChanged(currentPage + 1),
            iconRight: true,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final List<Widget> pages = [];
    const int maxVisible = 5;

    int start = currentPage - (maxVisible ~/ 2);
    int end = currentPage + (maxVisible ~/ 2);

    if (start < 1) {
      start = 1;
      end = maxVisible.clamp(1, totalPages);
    }
    if (end > totalPages) {
      end = totalPages;
      start = (totalPages - maxVisible + 1).clamp(1, totalPages);
    }

    if (start > 1) {
      pages.add(_buildPageButton(1));
      if (start > 2) {
        pages.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text('...', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
          ),
        );
      }
    }

    for (int i = start; i <= end; i++) {
      pages.add(_buildPageButton(i));
    }

    if (end < totalPages) {
      if (end < totalPages - 1) {
        pages.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text('...', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500])),
          ),
        );
      }
      pages.add(_buildPageButton(totalPages));
    }

    return pages;
  }

  Widget _buildPageButton(int page) {
    final isActive = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: isActive ? null : () => onPageChanged(page),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AdminTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? AdminTheme.primary : AdminTheme.stroke,
            ),
          ),
          child: Text(
            '$page',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.white : AdminTheme.ink,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
    bool iconRight = false,
  }) {
    final color = enabled ? AdminTheme.primary : Colors.grey[400]!;
    final children = [
      if (!iconRight) Icon(icon, size: 18, color: color),
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      if (iconRight) Icon(icon, size: 18, color: color),
    ];

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: enabled ? AdminTheme.stroke : Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

/// Helper: hitung total halaman
int calculateTotalPages(int totalItems, int itemsPerPage) {
  if (totalItems <= 0) return 1;
  return (totalItems / itemsPerPage).ceil();
}

/// Helper: ambil data untuk halaman tertentu
List<T> getPaginatedList<T>(List<T> fullList, int currentPage, int itemsPerPage) {
  final startIndex = (currentPage - 1) * itemsPerPage;
  final endIndex = (startIndex + itemsPerPage).clamp(0, fullList.length);
  if (startIndex >= fullList.length) return [];
  return fullList.sublist(startIndex, endIndex);
}
