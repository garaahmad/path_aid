import 'package:flutter/material.dart';
import 'package:path_aid/screen/desktop/logindesktop.dart';
import 'package:path_aid/screen/mobile/Loginmobile.dart';
import 'package:path_aid/screen/mobile/create_request.dart';
import 'package:path_aid/screen/mobile/current_requests.dart';
import 'package:path_aid/screen/mobile/delete_request.dart';
import 'package:path_aid/screen/mobile/dispatcher_home.dart';
import 'package:path_aid/screen/mobile/driver_home.dart';
import 'package:path_aid/screen/mobile/manage_facilities.dart';
import 'package:path_aid/screen/mobile/pending_requests.dart';
import 'package:path_aid/screen/mobile/request_details.dart';
import 'package:path_aid/screen/mobile/sender_home.dart';
import 'package:path_aid/screen/desktop/admin_home.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1700) {
                return Logindesktop();
              } else {
                return Loginmobile();
              }
            },
          ),
        );

      case "/doctor":
        return MaterialPageRoute(builder: (_) => SenderHome());

      case "/doctor/create":
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CreateRequest(requestToEdit: args),
        );

      case "/doctor/delete":
        return MaterialPageRoute(builder: (_) => DeleteRequest());

      case "/driver":
        return MaterialPageRoute(builder: (_) => DriverHome());

      case "/driver/current":
        return MaterialPageRoute(builder: (_) => CurrentRequests());

      case "/dispatcher":
        return MaterialPageRoute(builder: (_) => DispatcherHome());

      case "/dispatcher/pending":
        final args = settings.arguments as Map<String, dynamic>?;
        final idx = args?['initialIndex'] ?? 0;
        return MaterialPageRoute(
          builder: (_) => PendingRequests(initialIndex: idx),
        );

      case "/dispatcher/facilities":
        return MaterialPageRoute(builder: (_) => ManageFacilities());

      case "/admin":
        return MaterialPageRoute(builder: (_) => AdminHome());

      case "/request_details":
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (_) => RequestDetails(request: args));

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'الصفحة غير موجودة!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'مسار: ${settings.name}',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
