import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/dashboard_screen.dart';
import 'screens/user/blood donation request/blood_request_Form_screen.dart'; 
import 'screens/user/blood donation request/blood_request_management_screen.dart';
import 'screens/user/blood donation request/edit_blood_request_screen.dart';
import 'screens/user/blood campaign/create_campaign_screen.dart';
import 'screens/user/blood campaign/edit_campaign_screen.dart';
import 'controller/Donor_Matching_Controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('Starting app initialization...');
    
    // Initialize Firebase only once
    if (Firebase.apps.isEmpty) {
      print('Initializing Firebase...');
      await Firebase.initializeApp(
        name: "kavindu",
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized successfully');
    } else {
      print('Firebase already initialized, using existing instance');
      Firebase.app(); // Get the existing instance
    }
    
    // Initialize GetX controller
    Get.put(DonorMatchingController());
    
    runApp(MyApp());
  } catch (e, stackTrace) {
    print('Error during initialization:');
    print('Error: $e');
    print('Stack trace: $stackTrace');
    // You might want to show an error screen here
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Blood Bank App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => DashboardScreen()),
        GetPage(name: '/blood-request-form', page: () => BloodRequestForm()),
        GetPage(name: '/blood-request-management', page: () => BloodRequestManagementScreen()),
        GetPage(name: '/edit-blood-request', page: () => EditBloodRequestScreen()),
        GetPage(name: '/create-campaign', page: () => CreateCampaignScreen()),
        GetPage(name: '/edit-campaign', page: () => EditCampaignScreen()),
      ],
    );
  }
}
