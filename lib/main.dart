import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/store_screen.dart';
import 'package:provider/provider.dart';
import 'providers/store_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => StoreProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StoreScreen(),
      ),
    ),
  );
}
