//lib/features/profile/presentation/widget/item_profile_widget.dart
import 'package:flutter/material.dart';

class ItemProfileWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool showDivider; // Untuk menyembunyikan garis di item terakhir

  const ItemProfileWidget({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Ikon di sebelah kiri (Biru Outline)
                Icon(
                  icon,
                  color: const Color(0xFF3B82F6), // Warna biru utama
                  size: 24,
                ),
                const SizedBox(width: 16),

                // Teks Judul
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937), // Warna teks hampir hitam
                    ),
                  ),
                ),

                // Panah ke kanan
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
            // Garis pemisah (Divider) jika showDivider true
            if (showDivider) ...[
              const SizedBox(height: 12),
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFF3F4F6), // Abu-abu sangat muda
              ),
            ],
          ],
        ),
      ),
    );
  }
}
