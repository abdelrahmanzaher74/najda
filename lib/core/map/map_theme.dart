import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// بيقلب ألوان الخريطة لدرجات رمادي غامقة (للدارك مود).
const _darkTilesFilter = ColorFilter.matrix(<double>[
  -0.19134, -0.64368, -0.06498, 0, 241.5,
  -0.19134, -0.64368, -0.06498, 0, 241.5,
  -0.19134, -0.64368, -0.06498, 0, 241.5,
  0, 0, 0, 1, 0,
]);

/// طبقة صور الخريطة (OpenStreetMap) بتتحوّل للداكن مع الثيم.
class ThemedTileLayer extends StatelessWidget {
  const ThemedTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    final layer = TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.najda',
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? ColorFiltered(colorFilter: _darkTilesFilter, child: layer)
        : layer;
  }
}