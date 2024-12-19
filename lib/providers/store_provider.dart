import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/store.dart';
import '../utils/constants.dart';

class StoreProvider with ChangeNotifier {
  List<Store> _stores = [];
  List<LatLng> _storeLocations = [];
  Store? _selectedStore;

  List<Store> get stores => _stores;
  List<LatLng> get storeLocations => _storeLocations;
  Store? get selectedStore => _selectedStore;

  // Fetch stores and update the state
  Future<void> fetchStores() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] as List;

        // Map the data to store model and update _stores
        _stores = data
            .map((item) {
              try {
                return Store.fromJson(item); // Ensure valid data mapping
              } catch (e) {
                print('Error parsing store data: $e');
                return null; // Handle invalid data gracefully
              }
            })
            .whereType<Store>()
            .toList(); // Filter out any null values

        // Update store locations list
        _storeLocations = _stores.map((store) {
          try {
            return LatLng(
              double.parse(store.latitude),
              double.parse(store.longitude),
            );
          } catch (e) {
            print('Error parsing location: $e');
            return LatLng(0.0, 0.0); // Handle invalid coordinates
          }
        }).toList();

        // Notify listeners about changes in store data
        notifyListeners();
      } else {
        throw Exception('Failed to fetch stores');
      }
    } catch (error) {
      print('Error fetching stores: $error');
      // Optionally handle error (show UI message or retry logic)
    }
  }

  // Select a store and notify listeners
  void selectStore(Store store) {
    _selectedStore = store;
    notifyListeners();
  }

  // Update the selected store to null (for deselecting)
  void deselectStore() {
    _selectedStore = null;
    notifyListeners();
  }

  // Fit map to show all store locations
  void fitBoundsToStoreLocations(MapController mapController) {
    if (_storeLocations.isNotEmpty) {
      double minLat = _storeLocations[0].latitude;
      double maxLat = _storeLocations[0].latitude;
      double minLon = _storeLocations[0].longitude;
      double maxLon = _storeLocations[0].longitude;

      // Loop through each store location to find bounds
      for (var location in _storeLocations) {
        if (location.latitude < minLat) minLat = location.latitude;
        if (location.latitude > maxLat) maxLat = location.latitude;
        if (location.longitude < minLon) minLon = location.longitude;
        if (location.longitude > maxLon) maxLon = location.longitude;
      }

      final center = LatLng((minLat + maxLat) / 2, (minLon + maxLon) / 2);
      final zoom = _calculateZoom(_storeLocations);

      mapController.move(center, zoom); // Move map to fit the bounds
    }
  }

  // Calculate the appropriate zoom level based on store locations
  double _calculateZoom(List<LatLng> locations) {
    double maxDistance = _getMaxDistance(locations);
    if (maxDistance <= 0.1) return 14.0; // Close zoom for small distance
    if (maxDistance <= 1.0) return 12.0;
    return 10.0; // Default zoom level
  }

  // Get the max distance between store locations
  double _getMaxDistance(List<LatLng> locations) {
    final Distance distance = Distance();
    double maxDistance = 0.0;
    for (int i = 0; i < locations.length; i++) {
      for (int j = i + 1; j < locations.length; j++) {
        final dist =
            distance.as(LengthUnit.Kilometer, locations[i], locations[j]);
        if (dist > maxDistance) maxDistance = dist;
      }
    }
    return maxDistance;
  }
}
