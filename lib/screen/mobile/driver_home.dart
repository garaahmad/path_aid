import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path_aid/services/transport_request_service.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  int _selectedTab = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _myTasks = [];
  final String driverName = 'السائق';

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() => _isLoading = true);
    try {
      final allRequests =
          await TransportRequestService.getAllTransportRequests();
      if (mounted) {
        setState(() {
          _myTasks = allRequests.where((r) {
            final status = r['status'];
            return status != 'PENDING' && status != 'CANCELLED';
          }).toList();
          _myTasks.sort((a, b) {
            final isCompletedA = a['status'] == 'COMPLETED';
            final isCompletedB = b['status'] == 'COMPLETED';
            if (isCompletedA && !isCompletedB) return 1;
            if (!isCompletedA && isCompletedB) return -1;
            return 0;
          });

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching tasks: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        MotionToast.error(
          description: Text('فشل تحميل المهام: $e'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 1),
          toastAlignment: Alignment.topCenter,
        ).show(context);
      }
    }
  }

  Map<String, dynamic>? get _currentActiveTask {
    try {
      return _myTasks.firstWhere((t) => t['status'] != 'COMPLETED');
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    final displayedTasks = _selectedTab == 0
        ? _myTasks.where((t) => t['status'] != 'COMPLETED').toList()
        : _myTasks.where((t) => t['status'] == 'COMPLETED').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFf8fafc),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: _fetchTasks,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 100),
                            child: Column(
                              children: [
                                if (_selectedTab == 0 &&
                                    _currentActiveTask != null)
                                  _buildCurrentTask(_currentActiveTask!),

                                if (_selectedTab == 0 &&
                                    _currentActiveTask == null &&
                                    displayedTasks.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: Text(
                                      "لا توجد مهام نشطة حالياً",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),

                                if (displayedTasks.isNotEmpty &&
                                    (_selectedTab == 1 ||
                                        displayedTasks.length > 1))
                                  _buildTaskList(
                                    displayedTasks,
                                    _selectedTab == 0,
                                  ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF135bec), width: 2),
                  color: Colors.blue.shade50,
                ),
                child: const Icon(Icons.person, color: Color(0xFF135bec)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً، $driverName',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0f172a),
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => _fetchTasks(),
            icon: Icon(Icons.refresh, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTask(Map<String, dynamic> task) {
    final status = task['status'] ?? 'ACCEPTED';
    final isEmergency =
        task['priority'] == 'CRITICAL' || task['priority'] == 'HIGH';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'المهمة الحالية',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0f172a),
                ),
              ),
              if (isEmergency)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red[100]!),
                  ),
                  child: const Text(
                    'أولوية عالية',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[100]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المريض',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748b),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              task['patientName'] ?? 'غير معروف',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0f172a),
                              ),
                            ),
                            Text(
                              'العمر: ${task['patientAge'] ?? 0}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748b),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF135bec).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF135bec),
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTimeline(
                    'منشأة #${task['fromFacilityId']}',
                    'منشأة #${task['toFacilityId']}',
                  ),
                  const SizedBox(height: 20),
                  _buildStatusProgress(status),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(task),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getStatusColor(status),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getNextStatusButtonLabel(status),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(String from, String to) {
    return Container(
      padding: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[200]!, width: 2)),
      ),
      child: Column(
        children: [
          _buildTimelineItem(from, true),
          const SizedBox(height: 24),
          _buildTimelineItem(to, false),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String location, bool isStart) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isStart ? 'من (الانطلاق)' : 'إلى (الوجهة)',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748b)),
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0f172a),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: -5,
          top: 4,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isStart ? const Color(0xFF135bec) : Colors.grey[400],
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case TransportRequestStatus.ACCEPTED:
        return 'تم القبول';
      case TransportRequestStatus.ON_THE_WAY:
        return 'في الطريق';
      case TransportRequestStatus.ARRIVED_AT_FACILITY:
        return 'وصل للمنشأة';
      case TransportRequestStatus.TRANSFERRED_TO_DESTINATION:
        return 'نُقل للوجهة';
      case TransportRequestStatus.COMPLETED:
        return 'مكتمل';
      default:
        return status;
    }
  }

  String _getNextStatusButtonLabel(String status) {
    switch (status) {
      case TransportRequestStatus.ACCEPTED:
        return 'بدء الرحلة (في الطريق)';
      case TransportRequestStatus.ON_THE_WAY:
        return 'تأكيد الوصول للمنشأة';
      case TransportRequestStatus.ARRIVED_AT_FACILITY:
        return 'تأكيد النقل للوجهة';
      case TransportRequestStatus.TRANSFERRED_TO_DESTINATION:
        return 'إكمال المهمة';
      case TransportRequestStatus.COMPLETED:
        return 'المهمة مكتملة';
      default:
        return 'تحديث الحالة';
    }
  }

  int _getProgressFromStatus(String status) {
    switch (status) {
      case TransportRequestStatus.ACCEPTED:
        return 0;
      case TransportRequestStatus.ON_THE_WAY:
        return 1;
      case TransportRequestStatus.ARRIVED_AT_FACILITY:
        return 2;
      case TransportRequestStatus.TRANSFERRED_TO_DESTINATION:
        return 3;
      case TransportRequestStatus.COMPLETED:
        return 4;
      default:
        return 0;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case TransportRequestStatus.ACCEPTED:
        return const Color(0xFF135bec);
      case TransportRequestStatus.ON_THE_WAY:
        return const Color(0xFF2563EB);
      case TransportRequestStatus.ARRIVED_AT_FACILITY:
        return const Color(0xFFD97706);
      case TransportRequestStatus.TRANSFERRED_TO_DESTINATION:
        return const Color(0xFF7C3AED);
      case TransportRequestStatus.COMPLETED:
        return const Color(0xFF059669);
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusProgress(String currentStatus) {
    final progress = _getProgressFromStatus(currentStatus);
    final statusColor = _getStatusColor(currentStatus);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'حالة النقل: ',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748b)),
              ),
              Text(
                _getStatusLabel(currentStatus),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildProgressDot(
                Icons.check,
                0,
                progress,
                statusColor,
              ), 
              Expanded(child: _buildProgressLine(progress >= 1, statusColor)),
              _buildProgressDot(
                Icons.directions_car,
                1,
                progress,
                statusColor,
              ), 
              Expanded(child: _buildProgressLine(progress >= 2, statusColor)),
              _buildProgressDot(
                Icons.location_on,
                2,
                progress,
                statusColor,
              ), 
              Expanded(child: _buildProgressLine(progress >= 3, statusColor)),
              _buildProgressDot(
                Icons.flag,
                3,
                progress,
                statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDot(
    IconData icon,
    int stepIndex,
    int currentProgress,
    Color color,
  ) {
    bool isActive = currentProgress >= stepIndex;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 14,
        color: isActive ? Colors.white : Colors.grey[400],
      ),
    );
  }

  Widget _buildProgressLine(bool isActive, Color color) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isActive ? color : Colors.grey[300],
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks, bool excludeActive) {
    final list = excludeActive
        ? tasks.where((t) => t['id'] != _currentActiveTask?['id']).toList()
        : tasks;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedTab == 0 ? 'مهام أخرى' : 'المهام المكتملة',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0f172a),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...list.map((task) => _buildTaskCard(task)).toList(),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final status = task['status'] ?? 'UNKNOWN';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['patientName'] ?? 'غير معروف',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0f172a),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_getStatusLabel(status)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.pending_actions, 'المهام الحالية', 0),
            _buildNavItem(Icons.task_alt, 'المهام المكتملة', 1),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26,
              color: isSelected ? const Color(0xFF135bec) : Colors.grey[400],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF135bec) : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(Map<String, dynamic> task) async {
    final currentStatus = task['status'] ?? 'ACCEPTED';
    String? nextStatus;

    switch (currentStatus) {
      case TransportRequestStatus.ACCEPTED:
        nextStatus = TransportRequestStatus.ON_THE_WAY;
        break;
      case TransportRequestStatus.ON_THE_WAY:
        nextStatus = TransportRequestStatus.ARRIVED_AT_FACILITY;
        break;
      case TransportRequestStatus.ARRIVED_AT_FACILITY:
        nextStatus = TransportRequestStatus.TRANSFERRED_TO_DESTINATION;
        break;
      case TransportRequestStatus.TRANSFERRED_TO_DESTINATION:
        nextStatus = TransportRequestStatus.COMPLETED;
        break;
      case TransportRequestStatus.COMPLETED:
        return; 
      default:
        nextStatus = TransportRequestStatus.ON_THE_WAY;
    }

    try {
      await TransportRequestService.updateTransportRequestStatus(
        requestId: task['id'],
        status: nextStatus,
      );
      MotionToast.success(
        description: const Text('تم تحديث الحالة بنجاح'),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 1),
        toastAlignment: Alignment.topCenter,
      ).show(context);
      _fetchTasks();
    } catch (e) {
      MotionToast.error(
        description: Text('فشل الانتقال إلى $nextStatus: $e'),
        height: 100,
        width: 350,
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 1),
        toastAlignment: Alignment.topCenter,
      ).show(context);
    }
  }
}
