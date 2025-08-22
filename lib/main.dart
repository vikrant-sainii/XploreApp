import 'package:flutter/material.dart';
import 'package:xplore_app/screen1.dart';
import './BackendIntegrate/events_view_model.dart';
import './BackendIntegrate/auth_view_model.dart';
import './BackendIntegrate/user_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // Wrap your app with MultiProvider to provide view models
    MultiProvider(
      providers: [
        // Authentication View Model
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        
        // Events View Model
        ChangeNotifierProvider(create: (_) => EventsViewModel()),
        
        // User View Model
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        
        // If you want to use the enhanced auth view model instead:
        // ChangeNotifierProvider(create: (_) => EnhancedAuthViewModel()),
      ],
      child: MaterialApp(
        home: Screen1(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}