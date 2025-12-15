import 'package:flutter/material.dart';
import 'admin_users.dart';
import 'admin_facilities.dart';
import 'admin_vehicles.dart';
import 'admin_maintenance.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    AdminUsers(),
    AdminFacilities(),
    AdminVehicles(),
    AdminMaintenance(),
  ];

  static final List<String> _tabTitles = <String>[
    'إدارة المستخدمين',
    'طلبات المنشآت',
    'طلبات المركبات',
    'طلبات الصيانة',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _tabTitles[_selectedIndex],
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/',
              (route) => false,
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            elevation: 4,
            backgroundColor: Colors.white,
            groupAlignment: -0.5,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('المستخدمين'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business_outlined),
                selectedIcon: Icon(Icons.business),
                label: Text('المنشآت'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_shipping_outlined),
                selectedIcon: Icon(Icons.local_shipping),
                label: Text('المركبات'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.build_outlined),
                selectedIcon: Icon(Icons.build),
                label: Text('الصيانة'),
              ),
            ],
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue[50]!, Colors.grey[100]!],
                ),
              ),
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
        ],
      ),

      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'المستخدمين',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business),
                  label: 'المنشآت',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_shipping),
                  label: 'المركبات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.build),
                  label: 'الصيانة',
                ),

              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Color(0xFF1A237E),
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }

  void _showNotifications() {
  }
}
