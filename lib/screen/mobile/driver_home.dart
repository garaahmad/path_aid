import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path_aid/services/transport_request_service.dart';
import 'package:path_aid/services/facility_service.dart';

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
      final results = await Future.wait([
        TransportRequestService.getAllTransportRequests(),
        FacilityService.getAllFacilities(),
      ]);

      final allRequests = (results[0] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final facilities = (results[1] as List<dynamic>)
          .cast<Map<String, dynamic>>();
      final facilitiesMap = {
        for (var f in facilities) f['id'].toString(): f['name'],
      };

      if (mounted) {
        setState(() {
          _myTasks = allRequests
              .where((r) {
                final status = r['status'];
                return status != 'PENDING' && status != 'CANCELLED';
              })
              .map((r) {
                return {
                  ...r,
                  'fromFacilityName':
                      facilitiesMap[r['fromFacilityId'].toString()] ??
                      'منشأة #${r['fromFacilityId']}',
                  'toFacilityName':
                      facilitiesMap[r['toFacilityId'].toString()] ??
                      'منشأة #${r['toFacilityId']}',
                };
              })
              .toList();

          // Sort prioritization: Active statuses > ACCEPTED > COMPLETED
          _myTasks.sort((a, b) {
            int score(String status) {
              switch (status) {
                case TransportRequestStatus.ON_THE_WAY:
                case TransportRequestStatus.ARRIVED_AT_FACILITY:
                case TransportRequestStatus.TRANSFERRED_TO_DESTINATION:
                  return 3; // Highest priority (Active)
                case TransportRequestStatus.ACCEPTED:
                  return 2; // Waiting to start
                case TransportRequestStatus.PENDING:
                  return 1;
                case TransportRequestStatus.COMPLETED:
                case TransportRequestStatus.CANCELLED:
                default:
                  return 0; // Completed or inactive
              }
            }

            return score(b['status']).compareTo(score(a['status']));
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
          toastDuration: const Duration(seconds: 2),
          toastAlignment: Alignment.topCenter,
          displaySideBar: false,
        ).show(context);
      }
    }
  }

  Map<String, dynamic>? get _currentActiveTask {
    try {
      // Priority 1: Missions in progress (ON_THE_WAY, ARRIVED, TRANSFERRED)
      // Priority 2: Accepted missions (waiting to start)
      final inProgress = _myTasks.firstWhere(
        (t) =>
            t['status'] == TransportRequestStatus.ON_THE_WAY ||
            t['status'] == TransportRequestStatus.ARRIVED_AT_FACILITY ||
            t['status'] == TransportRequestStatus.TRANSFERRED_TO_DESTINATION,
        orElse: () => {},
      );

      if (inProgress.isNotEmpty) return inProgress;

      final accepted = _myTasks.firstWhere(
        (t) => t['status'] == TransportRequestStatus.ACCEPTED,
        orElse: () => {},
      );

      if (accepted.isNotEmpty) return accepted;

      return null;
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
                                        displayedTasks.length > 1 ||
                                        _currentActiveTask == null))
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المهمة الحالية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e293b),
            ),
          ),
          const SizedBox(height: 12),
          _buildTaskCard(task, isProminent: true),
        ],
      ),
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks, bool excludeActive) {
    final activeId = _currentActiveTask?['id'];
    final list = excludeActive
        ? tasks.where((t) => t['id'] != activeId).toList()
        : tasks;

    if (list.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedTab == 0 ? 'مهام أخرى' : 'المهام المكتملة',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e293b),
            ),
          ),
          const SizedBox(height: 12),
          ...list
              .map((task) => _buildTaskCard(task, isProminent: false))
              .toList(),
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
        return 'وصول للمنشأة';
      case TransportRequestStatus.ARRIVED_AT_FACILITY:
        return 'نقل للوجهة';
      case TransportRequestStatus.TRANSFERRED_TO_DESTINATION:
        return 'إنهاء المهمة (مكتمل)';
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
      case TransportRequestStatus.COMPLETED:
        return 3;
      default:
        return 0;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case TransportRequestStatus.ACCEPTED:
        return const Color(0xFF135bec); // Blue
      case TransportRequestStatus.ON_THE_WAY:
        return const Color(0xFFF59E0B); // Orange - Distinct from Blue
      case TransportRequestStatus.ARRIVED_AT_FACILITY:
        return const Color(0xFFD97706);
      case TransportRequestStatus.TRANSFERRED_TO_DESTINATION:
        return const Color(0xFF7C3AED);
      case TransportRequestStatus.COMPLETED:
        return const Color(0xFF059669); // Green
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusProgress(String currentStatus) {
    final progress = _getProgressFromStatus(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
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
              _buildStepItem(
                'مقبول',
                Icons.check_circle_outline,
                0,
                progress,
                const Color(0xFF135bec),
              ),
              _buildConnector(0, progress, const Color(0xFF135bec)),
              _buildStepItem(
                'في الطريق',
                Icons.directions_car,
                1,
                progress,
                const Color(0xFFF59E0B),
              ),
              _buildConnector(1, progress, const Color(0xFFD97706)),
              _buildStepItem(
                'وصل',
                Icons.location_on,
                2,
                progress,
                const Color(0xFFD97706),
              ),
              _buildConnector(2, progress, const Color(0xFF7C3AED)),
              _buildStepItem(
                'نُقل',
                Icons.flag,
                3,
                progress,
                const Color(0xFF7C3AED),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(
    String label,
    IconData icon,
    int stepIndex,
    int currentProgress,
    Color activeColor,
  ) {
    final bool isCompleted = currentProgress >= stepIndex;
    final bool isCurrent = currentProgress == stepIndex;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted ? activeColor : Colors.grey[100],
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? activeColor : Colors.grey[300]!,
              width: 2,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            size: 16,
            color: isCompleted ? Colors.white : Colors.grey[400],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCompleted || isCurrent
                ? FontWeight.bold
                : FontWeight.normal,
            color: isCompleted || isCurrent
                ? activeColor
                : const Color(0xFF94a3b8),
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(int stepIndex, int currentProgress, Color color) {
    final bool isActive = currentProgress > stepIndex;
    return Expanded(
      child: Container(
        height: 3,
        margin: const EdgeInsets.fromLTRB(
          4,
          0,
          4,
          20,
        ), // Lift slightly to align with dots
        decoration: BoxDecoration(
          color: isActive ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(1.5),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, {bool isProminent = true}) {
    final status = task['status'] ?? 'UNKNOWN';

    if (!isProminent) {
      // Minimal card for 'Other Tasks'
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['patientName'] ?? 'غير معروف',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0f172a),
                  ),
                ),
                Text(
                  _getStatusLabel(status),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      );
    }

    // Full detailed card for 'Current Mission'
    final isCompleted = status == 'COMPLETED';
    final priority = task['priority'] ?? 'MEDIUM';

    Color priorityColor = Colors.green;
    String priorityText = 'أولوية منخفضة';
    if (priority == 'MEDIUM') {
      priorityColor = Colors.orange;
      priorityText = 'أولوية متوسطة';
    } else if (priority == 'HIGH') {
      priorityColor = Colors.red;
      priorityText = 'أولوية عالية';
    } else if (priority == 'CRITICAL') {
      priorityColor = Colors.purple;
      priorityText = 'أولوية حرجة';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: priorityColor.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          priorityText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ),
                      const Text(
                        'المريض',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748b),
                        ),
                      ),
                      Text(
                        task['patientName'] ?? 'غير معروف',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0f172a),
                        ),
                      ),
                      Text(
                        'العمر: ${task['patientAge'] ?? 0}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748b),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Colors.blue, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTimeline(
              task['fromFacilityName'] ?? 'منشأة #${task['fromFacilityId']}',
              task['toFacilityName'] ?? 'منشأة #${task['toFacilityId']}',
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ملاحظات المريض:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748b),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task['notes'] != null && task['notes'].toString().isNotEmpty
                        ? task['notes']
                        : 'لا توجد ملاحظات إضافية',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
            if (!isCompleted) ...[
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
                      // Dynamic Icon based on next action
                      Icon(
                        status ==
                                TransportRequestStatus
                                    .TRANSFERRED_TO_DESTINATION
                            ? Icons.check_circle
                            : Icons.arrow_back, // RTL forward
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
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
        nextStatus = TransportRequestStatus.COMPLETED;
    }

    try {
      await TransportRequestService.updateTransportRequestStatus(
        requestId: task['id'],
        status: nextStatus,
      );
      MotionToast.success(
        description: const Text('تم تحديث الحالة بنجاح'),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topCenter,
        displaySideBar: false,
      ).show(context);
      _fetchTasks();
    } catch (e) {
      MotionToast.error(
        description: Text('فشل الانتقال إلى $nextStatus: $e'),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topCenter,
        displaySideBar: false,
      ).show(context);
    }
  }
}
