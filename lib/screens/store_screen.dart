import 'package:flutter/material.dart';
import 'package:flutter_application_1/widget/store_list.dart';
import 'package:flutter_application_1/widget/store_map.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';

// Custom Clipper for BottomNavigationBar with curved top edges
class CurvedTopClipper extends CustomClipper<Path> {
  MapController _mapController = MapController();

  @override
  Path getClip(Size size) {
    Path path = Path();

    // Start at the bottom left
    path.lineTo(0, 0);

    // Curve on the top-left
    path.quadraticBezierTo(size.width * 0.1, 0, size.width * 0.2, 0);

    // Line from top left to top right
    path.lineTo(size.width * 0.8, 0);

    // Curve on the top-right
    path.quadraticBezierTo(size.width * 0.9, 0, size.width, 0);

    // Line from top right to bottom right
    path.lineTo(size.width, size.height);

    // Line from bottom right to bottom left
    path.lineTo(0, size.height);

    // Close the path
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class StoreScreen extends StatefulWidget {
  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fetch data when the screen loads
    final storeProvider = Provider.of<StoreProvider>(context);
    if (storeProvider.stores.isEmpty) {
      storeProvider.fetchStores();
    }

    // Widgets for each tab
    List<Widget> _tabs = [
      // Home Tab
      Center(child: Text("Home Tab")),
      // Menu Tab
      Center(child: Text("Menu Tab")),
      // Store Tab
      Column(
        children: [
          Expanded(
            flex: 2,
            child: StoreMap(),
          ),
          Expanded(
            flex: 1,
            child: StoreList(),
          ),
        ],
      ),
      // Cart Tab
      Center(child: Text("Cart Tab")),
    ];

    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: ClipPath(
        clipper: CurvedTopClipper(),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.orange,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none, // Ensures the badge overflows the icon
                children: [
                  Icon(Icons.shopping_cart), // Cart icon
                  Positioned(
                    right:
                        -4, // Adjust the badge position closer to the top-right of the cart icon
                    top: -4, // Slightly above the cart icon
                    child: Container(
                      padding: EdgeInsets.all(
                          2), // Smaller padding for a smaller badge
                      decoration: BoxDecoration(
                        color: Colors.red, // Red background for the badge
                        borderRadius:
                            BorderRadius.circular(8), // Smaller radius
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12, // Smaller width
                        minHeight: 12, // Smaller height
                      ),
                      child: Text(
                        '2', // Notification value
                        style: TextStyle(
                          color: Colors.white, // White text color
                          fontSize: 8, // Smaller font size
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              label: 'Cart',
            ),
          ],
        ),
      ),
    );
  }
}
