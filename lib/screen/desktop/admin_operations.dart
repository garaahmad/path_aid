import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../services/transport_request_service.dart';
import 'package:motion_toast/motion_toast.dart';

class AdminOperations extends StatefulWidget {
  const AdminOperations({super.key});

  @override
  State<AdminOperations> createState() => _AdminOperationsState();
}

class _AdminOperationsState extends State<AdminOperations> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allRequests = [];
  int _completedCount = 0;
  int _pendingCount = 0;
  int _rejectedCount = 0;
  int _totalCount = 0;
  double _successRate = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final requests = await TransportRequestService.getAllTransportRequests();

      int completed = 0;
      int pending = 0;
      int rejected = 0;

      for (var req in requests) {
        String status = req['status'] ?? 'PENDING';
        if (status == TransportRequestStatus.COMPLETED) {
          completed++;
        } else if (status == TransportRequestStatus.CANCELLED) {
          rejected++;
        } else {
          pending++;
        }
      }

      if (mounted) {
        setState(() {
          _allRequests = requests;
          _completedCount = completed;
          _pendingCount = pending;
          _rejectedCount = rejected;
          _totalCount = requests.length;
          _successRate = _totalCount > 0 ? (completed / _totalCount) * 100 : 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        MotionToast.error(
          description: Text('فشل تحميل البيانات: $e'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 2),
          toastAlignment: Alignment.topCenter,
          displaySideBar: false,
        ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري جلب البيانات من السيرفر...'),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'نظرة عامة على العمليات والنتائج',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                tooltip: 'تحديث البيانات',
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              children: [
                // Left side: Statistics Chart
                Expanded(flex: 1, child: _buildAchievementChart()),
                const SizedBox(width: 32),
                // Right side: Statistics Cards & Details
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildStatCard(
                            'العمليات المكتملة',
                            _completedCount.toString(),
                            Icons.check_circle_rounded,
                            const Color(0xFF10B981),
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            'قيد الانتظار',
                            _pendingCount.toString(),
                            Icons.pending_actions_rounded,
                            const Color(0xFFFB923C),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatCard(
                            'المرفوضة',
                            _rejectedCount.toString(),
                            Icons.cancel_rounded,
                            const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 16),
                          _buildStatCard(
                            'إجمالي العمليات',
                            _totalCount.toString(),
                            Icons.analytics_rounded,
                            const Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildRecentOperationsList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementChart() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'توزيع حالة العمليات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'نسبة النجاح مقابل المعلق والمرفوض',
            style: TextStyle(fontSize: 14, color: const Color(0xFF64748B)),
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 250,
            width: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(250, 250),
                  painter: DonutChartPainter(
                    completed: _completedCount,
                    pending: _pendingCount,
                    rejected: _rejectedCount,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_successRate.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        letterSpacing: -2,
                      ),
                    ),
                    Text(
                      'نسبة النجاح',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          _buildLegendItem(
            'عمليات مكتملة',
            const Color(0xFF10B981),
            _completedCount.toString(),
          ),
          _buildLegendItem(
            'عمليات قيد الانتظار',
            const Color(0xFFFB923C),
            _pendingCount.toString(),
          ),
          _buildLegendItem(
            'عمليات مرفوضة',
            const Color(0xFFEF4444),
            _rejectedCount.toString(),
          ),
          const Divider(height: 32),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.query_stats, color: Colors.blueAccent, size: 16),
              SizedBox(width: 8),
              Text(
                'تم تحديث البيانات من الخادم الآن',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOperationsList() {
    final recentRequests = _allRequests.reversed.take(6).toList();

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'أحدث العمليات',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('عرض الكل')),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: recentRequests.isEmpty
                  ? const Center(child: Text('لا توجد عمليات حالياً'))
                  : ListView.separated(
                      itemCount: recentRequests.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final req = recentRequests[index];
                        final status = req['status'] ?? 'PENDING';
                        final isCompleted =
                            status == TransportRequestStatus.COMPLETED;

                        return InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCompleted
                                        ? Icons.check_circle_outline
                                        : Icons.location_on_outlined,
                                    size: 20,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'نقل ${req['patientName'] ?? 'مريض'}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                          fontSize: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.priority_high,
                                            size: 14,
                                            color: _getPriorityColor(
                                              req['priority'],
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'أولوية: ${req['priority'] ?? 'عادية'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Color(0xFF94A3B8),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatTime(req['transportTime']),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusBgColor(status),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    TransportRequestStatus.getArabicStatus(
                                      status,
                                    ),
                                    style: TextStyle(
                                      color: _getStatusTextColor(status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'HIGH':
        return Colors.red;
      case 'URGENT':
        return Colors.redAccent;
      case 'NORMAL':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return '--:--';
    try {
      final dt = DateTime.parse(timeStr).toLocal();
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timeStr;
    }
  }

  Color _getStatusBgColor(String status) {
    if (status == TransportRequestStatus.COMPLETED)
      return const Color(0xFFDCFCE7);
    if (status == TransportRequestStatus.CANCELLED)
      return const Color(0xFFFEE2E2);
    return const Color(0xFFFEF3C7);
  }

  Color _getStatusTextColor(String status) {
    if (status == TransportRequestStatus.COMPLETED)
      return const Color(0xFF166534);
    if (status == TransportRequestStatus.CANCELLED)
      return const Color(0xFF991B1B);
    return const Color(0xFF92400E);
  }
}

class DonutChartPainter extends CustomPainter {
  final int completed;
  final int pending;
  final int rejected;

  DonutChartPainter({
    required this.completed,
    required this.pending,
    required this.rejected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double total = (completed + pending + rejected).toDouble();
    if (total == 0) {
      final Paint bgPaint = Paint()
        ..color = Colors.grey.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 32.0;
      canvas.drawCircle(
        Offset(size.width / 2, size.width / 2),
        (size.width / 2) - 16,
        bgPaint,
      );
      return;
    }

    final double center = size.width / 2;
    final double radius = size.width / 2;
    final double strokeWidth = 32.0;
    final Rect rect = Rect.fromCircle(
      center: Offset(center, center),
      radius: radius - (strokeWidth / 2),
    );

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -math.pi / 2;

    // Completed Segment
    paint.color = const Color(0xFF10B981);
    final double completedAngle = (completed / total) * 2 * math.pi;
    if (completedAngle > 0) {
      canvas.drawArc(rect, startAngle, completedAngle, false, paint);
      startAngle += completedAngle;
    }

    // Pending Segment
    paint.color = const Color(0xFFFB923C);
    final double pendingAngle = (pending / total) * 2 * math.pi;
    if (pendingAngle > 0) {
      canvas.drawArc(rect, startAngle, pendingAngle, false, paint);
      startAngle += pendingAngle;
    }

    // Rejected Segment
    paint.color = const Color(0xFFEF4444);
    final double rejectedAngle = (rejected / total) * 2 * math.pi;
    if (rejectedAngle > 0) {
      canvas.drawArc(rect, startAngle, rejectedAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
