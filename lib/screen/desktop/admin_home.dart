import 'package:flutter/material.dart';
import 'admin_users.dart';
import 'admin_facilities.dart';
import 'admin_vehicles.dart';
import 'admin_operations.dart';

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
    AdminOperations(),
  ];

  static final List<String> _tabTitles = <String>[
    'إدارة المستخدمين',
    'إدارة المنشآت',
    'إدارة المركبات',
    'إحصائيات العمليات',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Row(
          children: [
            // Sidebar for Desktop
            if (MediaQuery.of(context).size.width >= 1000) _buildSidebar(),

            // Main Content Area
            Expanded(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(-5, 0),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                        ),
                        child: _widgetOptions.elementAt(_selectedIndex),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: MediaQuery.of(context).size.width < 1000
            ? _buildBottomBar()
            : null,
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: const Color(0xFF0F172A), // More dark
      child: Column(
        children: [
          const SizedBox(height: 48),
          // Logo & Branding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/Logo.png',
                    height: 32,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.shield, color: Colors.blueAccent),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'PathAid Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),

          // Menu Items
          _buildSidebarItem(0, Icons.people_alt_rounded, 'المستخدمين'),
          _buildSidebarItem(1, Icons.business_rounded, 'المنشآت'),
          _buildSidebarItem(2, Icons.local_shipping_rounded, 'المركبات'),
          _buildSidebarItem(3, Icons.analytics_rounded, 'العمليات'),

          const Spacer(),
          // Profile/Settings or Logout at bottom
          _buildSidebarItem(
            99,
            Icons.logout_rounded,
            'تسجيل الخروج',
            isLogout: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    int index,
    IconData icon,
    String label, {
    bool isLogout = false,
  }) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          if (isLogout) {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          } else {
            _onItemTapped(index);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.blueAccent.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.blueAccent : const Color(0xFF94A3B8),
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      color: const Color(0xFFF8FAFC),
      child: Row(
        children: [
          Text(
            _tabTitles[_selectedIndex],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Color(0xFF64748B),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          Container(height: 40, width: 1, color: const Color(0xFFE2E8F0)),
          const SizedBox(width: 16),
          const CircleAvatar(
            backgroundColor: Color(0xFFE2E8F0),
            child: Icon(Icons.person, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 12),
          if (MediaQuery.of(context).size.width > 600)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'المدير العام',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'admin@pathaid.com',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'المستخدمين'),
        BottomNavigationBarItem(icon: Icon(Icons.business), label: 'المنشآت'),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping),
          label: 'المركبات',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.build), label: 'الصيانة'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: const Color(0xFF94A3B8),
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 20,
    );
  }
}
