import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';

class StoreList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);

    return ListView.builder(
      itemCount: storeProvider.stores.length,
      itemBuilder: (context, index) {
        final store = storeProvider.stores[index];

        // Calculate distance from current location (mocked here, replace with actual logic)
        double distance = store.distance;

        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12.0),
            leading: Icon(
              Icons.store,
              color: Colors.orange,
              size: 40.0,
            ),
            title: Text(
              store.storeLocation,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(store.storeAddress),
                Text('Days: ${store.dayOfWeek}'),
                Text('Time: ${store.startTime} - ${store.endTime}'),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${distance.toStringAsFixed(2)} km',
                  style: TextStyle(fontSize: 12.0),
                ),
              ],
            ),
            onTap: () {
              storeProvider.selectStore(store);

              // Get the selected store's latitude and longitude
              final storeLocation = LatLng(
                double.parse(store.latitude),
                double.parse(store.longitude),
              );

              // Get the map controller and move the camera to the store location
              final mapController =
                  Provider.of<GoogleMapController>(context, listen: false);
              mapController.moveCamera(
                CameraUpdate.newLatLngZoom(
                    storeLocation, 16.0), // Adjust the zoom level
              );
            },
          ),
        );
      },
    );
  }
}
