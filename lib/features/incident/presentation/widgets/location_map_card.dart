import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme.dart';
import '../../../../core/location/app_location.dart';
import '../../../../core/map/map_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// خريطة للعرض بس. الدبوس بيتحدد من الـ GPS الحقيقي،
/// ومفيش أي طريقة لتغيير الموقع بالضغط على الخريطة.
class LocationMapCard extends StatelessWidget {
  final AppLocation location;

  const LocationMapCard({super.key, required this.location});

  String _coord(double value, String positive, String negative) {
    return '${value.abs().toStringAsFixed(4)}° ${value >= 0 ? positive : negative}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final n = context.najda;
    final point = LatLng(location.latitude, location.longitude);
    final accuracy = location.accuracyMeters;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 260,
        child: Stack(
          children: [
            FlutterMap(
              key: ValueKey('${location.latitude}_${location.longitude}'),
              options: MapOptions(
                initialCenter: point,
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag |
                  InteractiveFlag.pinchZoom |
                  InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                const ThemedTileLayer(),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 46,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // كارت الإحداثيات
            PositionedDirectional(
              top: 10,
              start: 10,
              end: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: n.card.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.my_location,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.currentCoordinates.toUpperCase(),
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              color: n.textPrimary,
                            ),
                          ),
                          Text(
                            '${_coord(location.latitude, 'N', 'S')}, '
                                '${_coord(location.longitude, 'E', 'W')}'
                                '${accuracy == null ? '' : '  ·  ±${accuracy.round()} m'}',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: n.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.locationAuto,
                            style: textTheme.labelSmall
                                ?.copyWith(color: n.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // حقوق الخريطة (مطلوبة من OpenStreetMap)
            PositionedDirectional(
              bottom: 4,
              end: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: n.card.withValues(alpha: 0.8),
                child: Text(
                  l10n.mapCredit,
                  style: TextStyle(fontSize: 10, color: n.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}