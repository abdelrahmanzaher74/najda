import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../app/theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/assigned_unit.dart';
import '../unit_style.dart';

/// خريطة المتابعة: موقعك + الوحدات المعيّنة (بألوان وأيقونات حسب النوع)
/// + نقطة "جاي منين" + خط الحركة.
class TrackingMap extends StatefulWidget {
  final LatLng incident;
  final List<AssignedUnit> units;

  const TrackingMap({super.key, required this.incident, required this.units});

  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap> {
  final _controller = MapController();

  /// أول موقع شفناه لكل وحدة (= "جاي منين")
  final Map<int, LatLng> _origins = {};

  bool _ready = false;
  int _fittedUnitCount = -1;

  @override
  void initState() {
    super.initState();
    _recordOrigins();
  }

  @override
  void didUpdateWidget(TrackingMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _recordOrigins();

    // لما عدد الوحدات يتغيّر نعيد ضبط الكاميرا عشان الكل يبان
    if (_ready && widget.units.length != _fittedUnitCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fit();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _recordOrigins() {
    for (final u in widget.units) {
      _origins.putIfAbsent(u.id, () => LatLng(u.latitude, u.longitude));
    }
  }

  void _fit() {
    _fittedUnitCount = widget.units.length;

    if (widget.units.isEmpty) {
      _controller.move(widget.incident, 16);
      return;
    }

    final points = [
      widget.incident,
      ...widget.units.map((u) => LatLng(u.latitude, u.longitude)),
    ];
    _controller.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.fromLTRB(56, 96, 56, 56),
        maxZoom: 17,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final lines = <Polyline>[];
    final originMarkers = <Marker>[];
    final unitMarkers = <Marker>[];

    for (final u in widget.units) {
      final color = unitColor(u.type);
      final current = LatLng(u.latitude, u.longitude);
      final origin = _origins[u.id];

      // مسار الحركة (من نقطة البداية للموقع الحالي)
      if (origin != null && origin != current) {
        lines.add(Polyline(points: [origin, current], strokeWidth: 3, color: color));
        originMarkers.add(
          Marker(
            point: origin,
            width: 14,
            height: 14,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        );
      }

      // خط خفيف ناحيتك (لحد ما يوصل)
      if (u.status != UnitStatus.arrived) {
        lines.add(
          Polyline(
            points: [current, widget.incident],
            strokeWidth: 2,
            color: color.withValues(alpha: 0.35),
          ),
        );
      }

      unitMarkers.add(
        Marker(
          point: current,
          width: 44,
          height: 44,
          child: _UnitPin(type: u.type),
        ),
      );
    }

    final typesPresent = widget.units.map((u) => u.type).toSet();

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: widget.incident,
                initialZoom: 15,
                onMapReady: () {
                  _ready = true;
                  _fit();
                },
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.drag |
                  InteractiveFlag.pinchZoom |
                  InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.najda',
                ),
                PolylineLayer(polylines: lines),
                MarkerLayer(markers: originMarkers),
                MarkerLayer(
                  markers: [
                    // موقعك
                    Marker(
                      point: widget.incident,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.foreground,
                        size: 46,
                      ),
                    ),
                    ...unitMarkers,
                  ],
                ),
              ],
            ),

            // مفتاح الألوان
            PositionedDirectional(
              top: 10,
              start: 10,
              end: 60,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _LegendChip(
                    icon: Icons.location_on,
                    color: AppColors.foreground,
                    label: l10n.yourLocation,
                  ),
                  for (final type in typesPresent)
                    _LegendChip(
                      icon: unitIcon(type),
                      color: unitColor(type),
                      label: unitTypeLabel(l10n, type),
                    ),
                ],
              ),
            ),

            // زر "عرض الجميع"
            PositionedDirectional(
              top: 10,
              end: 10,
              child: Material(
                color: Colors.white,
                shape: const CircleBorder(),
                elevation: 2,
                child: IconButton(
                  tooltip: l10n.showAll,
                  icon: const Icon(Icons.center_focus_strong),
                  onPressed: _fit,
                ),
              ),
            ),

            // حقوق الخريطة (مطلوبة من OpenStreetMap)
            PositionedDirectional(
              bottom: 4,
              end: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.white.withValues(alpha: 0.8),
                child: Text(
                  l10n.mapCredit,
                  style: const TextStyle(fontSize: 10, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitPin extends StatelessWidget {
  final ResponderType type;

  const _UnitPin({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: unitColor(type),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(unitIcon(type), size: 20, color: Colors.white),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _LegendChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground,
            ),
          ),
        ],
      ),
    );
  }
}