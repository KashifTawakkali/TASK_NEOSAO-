import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';

class StoreMap extends StatefulWidget {
  @override
  _StoreMapState createState() => _StoreMapState();
}

class _StoreMapState extends State<StoreMap> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  // Function to calculate and move the map to fit all stores
  void _fitBoundsToAllStores(List<LatLng> storeLocations) {
    if (storeLocations.isEmpty) return;

    double minLat = storeLocations[0].latitude;
    double maxLat = storeLocations[0].latitude;
    double minLon = storeLocations[0].longitude;
    double maxLon = storeLocations[0].longitude;

    // Calculate bounds
    for (var location in storeLocations) {
      if (location.latitude < minLat) minLat = location.latitude;
      if (location.latitude > maxLat) maxLat = location.latitude;
      if (location.longitude < minLon) minLon = location.longitude;
      if (location.longitude > maxLon) maxLon = location.longitude;
    }

    final center = LatLng((minLat + maxLat) / 2, (minLon + maxLon) / 2);
    final zoom = _calculateZoom(storeLocations);

    _mapController.move(center, zoom);
  }

  // Calculate appropriate zoom level based on bounds
  double _calculateZoom(List<LatLng> storeLocations) {
    final maxDistance = _getMaxDistance(storeLocations);
    if (maxDistance <= 0.1) return 14.0; // Close zoom for small distance
    if (maxDistance <= 1.0) return 12.0;
    return 10.0; // Default zoom level
  }

  // Calculate max distance between any two points
  double _getMaxDistance(List<LatLng> storeLocations) {
    final distance = Distance(); // Use Distance class from latlong2
    double maxDistance = 0.0;
    for (int i = 0; i < storeLocations.length; i++) {
      for (int j = i + 1; j < storeLocations.length; j++) {
        final dist = distance.as(
            LengthUnit.Kilometer, storeLocations[i], storeLocations[j]);
        if (dist > maxDistance) maxDistance = dist;
      }
    }
    return maxDistance;
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);

    if (storeProvider.stores.isEmpty) {
      return const Center(
        child: Text('No stores available'),
      );
    }

    // Extract shop locations
    final storeLocations = storeProvider.stores.map((store) {
      return LatLng(
        double.parse(store.latitude),
        double.parse(store.longitude),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Locations'),
        backgroundColor: Colors.orange,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: storeLocations.isNotEmpty
              ? storeLocations.first // Set the center to the first store
              : LatLng(0, 0), // Default center if no stores
          initialZoom:
              storeLocations.isNotEmpty ? _calculateZoom(storeLocations) : 1.0,
          onMapReady: () {
            // Fit all shops within view when the map is ready
            _fitBoundsToAllStores(storeLocations);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: storeProvider.stores.map((store) {
              final isSelected = store == storeProvider.selectedStore;
              return Marker(
                point: LatLng(
                  double.parse(store.latitude),
                  double.parse(store.longitude),
                ),
                width: 40.0,
                height: 40.0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      storeProvider.selectStore(store); // Corrected method
                    });
                    // Zoom in to the selected shop
                    _mapController.move(
                      LatLng(
                        double.parse(store.latitude),
                        double.parse(store.longitude),
                      ),
                      16.0, // Zoom level for shop focus
                    );
                  },
                  child: Icon(
                    Icons.location_on,
                    color: isSelected ? Colors.orange : Colors.red,
                    size: isSelected ? 40.0 : 30.0,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
