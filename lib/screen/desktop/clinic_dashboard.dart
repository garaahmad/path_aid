import 'package:flutter/material.dart';
import 'package:path_aid/services/transport_request_service.dart';

class ClinicDashboardDesktop extends StatefulWidget {
  final List<Map<String, dynamic>> requests;
  final Map<int, String> facilityNames;
  final VoidCallback onRefresh;
  final Function(Map<String, dynamic>) onCreateRequest;
  final Function(Map<String, dynamic>) onViewDetails;

  const ClinicDashboardDesktop({
    super.key,
    required this.requests,
    required this.facilityNames,
    required this.onRefresh,
    required this.onCreateRequest,
    required this.onViewDetails,
  });

  @override
  State<ClinicDashboardDesktop> createState() => _ClinicDashboardDesktopState();
}

class _ClinicDashboardDesktopState extends State<ClinicDashboardDesktop> {
  int _selectedSidebarIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        body: Row(
          children: [
            // Sidebar
            _buildSidebar(),

            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Dashboard Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Promo Banner
                          _buildPromoBanner(),

                          const SizedBox(height: 32),

                          // Stats Row
                          _buildStatsRow(),

                          const SizedBox(height: 48),

                          // Recent Requests Table
                          _buildRecentRequestsSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      color: const Color(0xFF2C333D),
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Image.asset(
                  'assets/Logo.png',
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.medical_services,
                    color: Colors.cyan,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'PathAid',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),

          // Navigation Items
          _buildSidebarItem(0, Icons.home, 'Home'),
          _buildSidebarItem(1, Icons.person_outline, 'My Requests'),
          _buildSidebarItem(2, Icons.edit_note, 'Create New Request'),
          _buildSidebarItem(3, Icons.description_outlined, 'Reports'),
          _buildSidebarItem(4, Icons.settings_outlined, 'Settings'),

          const Spacer(),
          // Optional footer or profile could go here
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String label) {
    final isSelected = _selectedSidebarIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSidebarIndex = index;
        });
        if (index == 2) {
          widget.onCreateRequest({});
        }
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            // Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 6,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF00E5FF)
                    : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF00E5FF)
                  : const Color(0xFF94A3B8),
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
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      color: const Color(0xFF1F2937),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          const Text(
            'Clinic Dashboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          // Profile Info
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              backgroundColor: Color(0xFF6B7280),
              radius: 18,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Clinic A - Al-Nada Hospital',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Administrator',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3A7BD5).withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern/circles for texture
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'مدى الركني؟',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Need a transport',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => widget.onCreateRequest({}),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8A00),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Create New Request',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final pendingCount = widget.requests
        .where((r) => r['status'] == TransportRequestStatus.PENDING)
        .length;
    final completedCount = widget.requests
        .where((r) => r['status'] == TransportRequestStatus.COMPLETED)
        .length;
    final inProgressCount = widget.requests
        .where(
          (r) =>
              r['status'] == TransportRequestStatus.ON_THE_WAY ||
              r['status'] == TransportRequestStatus.ARRIVED_AT_FACILITY ||
              r['status'] ==
                  TransportRequestStatus.TRANSFERRED_TO_DESTINATION ||
              r['status'] == TransportRequestStatus.ACCEPTED,
        )
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Pending Requests', pendingCount.toString()),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard(
            'Completed This Month',
            completedCount.toString(),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard('Completed This Month', '3'),
        ), // Dummy as per image
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard('In Progress', inProgressCount.toString()),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2C333D),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Requests',
          style: TextStyle(
            color: Color(0xFF2C333D),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Table Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Request ID',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Date',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Patient Name',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Actions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Table Rows
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.requests.take(5).length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final request = widget.requests[index];
                  return _buildRequestRow(request);
                },
              ),
              if (widget.requests.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No requests found'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestRow(Map<String, dynamic> request) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('#${request['id']}')),
          Expanded(flex: 2, child: Text(_formatDate(request['transportTime']))),
          Expanded(flex: 3, child: Text(request['patientName'] ?? 'Unknown')),
          Expanded(flex: 2, child: _buildStatusChip(request['status'])),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () => widget.onViewDetails(request),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563eb),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label = TransportRequestStatus.getArabicStatus(status);

    switch (status) {
      case TransportRequestStatus.PENDING:
        color = Colors.amber;
        break;
      case TransportRequestStatus.COMPLETED:
        color = Colors.green;
        break;
      case TransportRequestStatus.CANCELLED:
        color = Colors.redAccent;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
