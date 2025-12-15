import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path_aid/services/facility_service.dart';
import 'package:path_aid/services/vehicle_service.dart';
import 'package:path_aid/services/transport_request_service.dart';

class DispatcherHome extends StatefulWidget {
  final int initialTab;
  const DispatcherHome({super.key, this.initialTab = 0});

  @override
  State<DispatcherHome> createState() => _DispatcherHomeState();
}

class _DispatcherHomeState extends State<DispatcherHome> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _recentRequests = [];
  int _pendingCount = 0;
  int _inProgressCount = 0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await Future.wait([_fetchVehicles(), _fetchRequests()]);
  }

  Future<void> _fetchVehicles() async {
    try {
      final vehicles = await VehicleService.getAllVehicles();
      if (mounted) {
        setState(() {
          _vehicles = vehicles;
        });
      }
    } catch (e) {
      print('Error fetching vehicles: $e');
    }
  }

  Future<void> _fetchRequests() async {
    try {
      final requests = await TransportRequestService.getAllTransportRequests();
      final facilities = await FacilityService.getAllFacilities();
      final facilitiesMap = {for (var f in facilities) f['id']: f['name']};

      int pending = 0;
      int inProgress = 0;
      int completed = 0;

      final mappedRequests = requests.map((req) {
        final status = req['status'] ?? 'PENDING';
        if (status == 'PENDING')
          pending++;
        else if (status == 'IN_PROGRESS' ||
            status == 'ON_ROUTE' ||
            status == 'ASSIGNED')
          inProgress++;
        else if (status == 'COMPLETED')
          completed++;

        return {
          ...req,
          'status': status,
          'fromFacilityName':
              facilitiesMap[req['fromFacilityId']] ??
              'منشأة ${req['fromFacilityId']}',
          'toFacilityName':
              facilitiesMap[req['toFacilityId']] ??
              'منشأة ${req['toFacilityId']}',
        };
      }).toList();

      final recent = mappedRequests
          .where(
            (r) =>
                r['status'] != 'COMPLETED' &&
                r['status'] != 'CANCELLED' &&
                r['status'] != 'REJECTED',
          )
          .toList()
          .reversed
          .take(10)
          .toList();

      if (mounted) {
        setState(() {
          _recentRequests = recent;
          _pendingCount = pending;
          _inProgressCount = inProgress;
          _completedCount = completed;
        });
      }
    } catch (e) {
      print('Error fetching requests: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf6f6f8),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _currentIndex == 0
                      ? _buildDashboardBody()
                      : _currentIndex == 1
                      ? _buildVehicleManagementScreen()
                      : Container(),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNavigationBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFf6f6f8).withOpacity(0.95),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: NetworkImage(
                          "https://lh3.googleusercontent.com/aida-public/AB6AXuD24M-xSVDeT8SjVdb8VYVRuN4V0FVrTcOQ-3xpn8jQhNY5z108knD01AJszPjVZxIPQGjw4XShaF3lct5O9E5omFCTwpV1JnqJ7zKsqebWT7AqHpzri-a3CTilk_XYRCukb_FIACC82i1AnNjmi-KLnCtCfcai1u9Qw6Ig6AUNMuHP0WLdiqpdaqdOVHBh8yPC4WYt2jBeL2g7TiNwvtPIWPOHrS1C2_NBEzu0okzot2UR8whnqjQAmT6IZNLaKmKP2HSsYWoFUw",
                        ),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: const Color(0xFF135bec).withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFf6f6f8),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً بك 👋',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF64748b),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Text(
                    'المنسق',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1e293b),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              if (_currentIndex == 1) {
                _showAddVehicleDialog();
              } else {
                Navigator.pop(context);
              }
            },
            icon: Icon(_currentIndex == 1 ? Icons.add : Icons.logout),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardBody() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'لوحة التحكم',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e293b),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'نظرة عامة على عمليات النقل والأسطول',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF64748b),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatCard(
                    'طلبات معلقة',
                    _pendingCount.toString(),
                    Colors.orange,
                    Icons.pending_actions,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'قيد التنفيذ',
                    _inProgressCount.toString(),
                    const Color(0xFF135bec),
                    Icons.local_shipping,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'مكتملة',
                    _completedCount.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'مركبات متاحة',
                    _vehicles.length.toString(),
                    Colors.purple,
                    Icons.medical_services,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الطلبات الأخيرة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e293b),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/dispatcher/pending');
                    },
                    child: const Text('عرض الكل'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF135bec),
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentRequests.length,
              itemBuilder: (context, index) {
                return _buildRequestCard(_recentRequests[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748b),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF135bec) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? null : Border.all(color: Colors.grey[200]!),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF135bec).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    Color statusColor;
    String statusText;
    Color statusBg;

    String status = request['status'] ?? 'PENDING';
    if (status == 'PENDING') {
      statusText = 'قيد الانتظار';
      statusColor = Colors.orange[700]!;
      statusBg = Colors.orange[50]!;
    } else if (status == 'COMPLETED') {
      statusText = 'مكتمل';
      statusColor = Colors.green[700]!;
      statusBg = Colors.green[50]!;
    } else {
      statusText = 'جاري النقل';
      statusColor = const Color(0xFF135bec);
      statusBg = const Color(0xFF135bec).withOpacity(0.1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['patientName'] ?? 'غير معروف',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1e293b),
                        ),
                      ),
                      Text(
                        '#ID-${request['id']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF64748b),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.1)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimelineRow(
            request['fromFacilityName'],
            request['toFacilityName'],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/request_details',
                      arguments: request,
                    );
                  },
                  icon: const Icon(Icons.local_shipping_outlined, size: 18),
                  label: const Text('تفاصيل'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF135bec),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(String from, String to) {
    return Container(
      padding: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[200]!, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineItem(from, true),
          const SizedBox(height: 16),
          _buildTimelineItem(to, false),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String location, bool isStart) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isStart ? 'من' : 'إلى',
              style: TextStyle(fontSize: 12, color: const Color(0xFF64748b)),
            ),
            const SizedBox(height: 2),
            Text(
              location,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1e293b),
              ),
            ),
          ],
        ),
        Positioned(
          right: -17,
          top: 4,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isStart ? Colors.grey[300] : const Color(0xFF135bec),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(Icons.dashboard, 'الرئيسية', true, 0),
          _buildNavItem(
            Icons.assignment,
            'الطلبات',
            false,
            -1,
            onTap: () => Navigator.pushNamed(context, '/dispatcher/pending'),
          ),
          _buildNavItem(
            Icons.history,
            'السجل',
            false,
            -1,
            onTap: () => Navigator.pushNamed(
              context,
              '/dispatcher/pending',
              arguments: {'initialIndex': 1},
            ),
          ),
          _buildNavItem(
            Icons.domain,
            'المنشآت',
            false,
            -1,
            onTap: () => Navigator.pushNamed(context, '/dispatcher/facilities'),
          ),
          _buildNavItem(Icons.directions_car, 'المركبات', false, 1),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    int index, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            if (index != -1) {
              setState(() => _currentIndex = index);
              if (index == 1) _fetchVehicles();
            }
          },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? const Color(0xFF135bec)
                : const Color(0xFF64748b),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? const Color(0xFF135bec)
                  : const Color(0xFF64748b),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleManagementScreen() {
    return RefreshIndicator(
      onRefresh: _fetchVehicles,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _vehicles.length,
        itemBuilder: (context, index) =>
            _buildVehicleCardItem(_vehicles[index]),
      ),
    );
  }

  Widget _buildVehicleCardItem(Map<String, dynamic> vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF135bec).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.directions_car, color: Color(0xFF135bec)),
        ),
        title: Text(
          vehicle['code'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Capacity: ${vehicle['capacity']}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteVehicle(vehicle),
        ),
      ),
    );
  }

  void _showAddVehicleDialog() {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _codeController = TextEditingController();
    final TextEditingController _capacityController = TextEditingController();
    String _selectedStatus = 'ACTIVE';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة مركبة جديدة'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'رقم المركبة (الكود)',
                ),
                validator: (v) => v!.isEmpty ? 'مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'السعة (عدد الركاب)',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'مطلوب';
                  if (int.tryParse(v) == null) return 'يجب أن يكون رقم صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'الحالة'),
                items: [
                  DropdownMenuItem(child: Text('نشطة'), value: 'ACTIVE'),
                  DropdownMenuItem(
                    child: Text('تحت الصيانة'),
                    value: 'MAINTENANCE',
                  ),
                ],
                onChanged: (v) => _selectedStatus = v!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                _createVehicle(
                  code: _codeController.text,
                  capacity: int.parse(_capacityController.text),
                  status: _selectedStatus,
                );
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<void> _createVehicle({
    required String code,
    required int capacity,
    required String status,
  }) async {
    try {
      await VehicleService.createVehicle(
        code: code,
        capacity: capacity,
        status: status,
      );
      MotionToast.success(
        description: const Text("تم إضافة المركبة بنجاح"),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 1),
        toastAlignment: Alignment.topCenter,
      ).show(context);
      _fetchVehicles();
    } catch (e) {
      MotionToast.error(
        description: Text(e.toString()),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 1),
        toastAlignment: Alignment.topCenter,
      ).show(context);
    }
  }

  void _deleteVehicle(Map<String, dynamic> vehicle) async {
    try {
      await VehicleService.deleteVehicle(vehicle['id']);
      _fetchVehicles();
    } catch (e) {
      MotionToast.error(
        description: Text(e.toString()),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 1),
        toastAlignment: Alignment.topCenter,
      ).show(context);
    }
  }
}
