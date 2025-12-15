import 'package:flutter/material.dart';
import 'package:path_aid/services/transport_request_service.dart';
import 'package:path_aid/services/facility_service.dart';

class SenderHome extends StatefulWidget {
  const SenderHome({super.key});

  @override
  State<SenderHome> createState() => _SenderHomeState();
}

class _SenderHomeState extends State<SenderHome> {
  List<Map<String, dynamic>> requests = [];
  Map<int, String> facilityNames = {};
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await Future.wait([_fetchFacilities(), _fetchRequests()]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchFacilities() async {
    try {
      final facilities = await FacilityService.getAllFacilities();
      setState(() {
        facilityNames = {for (var f in facilities) f['id']: f['name']};
      });
    } catch (e) {
      print('Error fetching facilities: $e');
    }
  }

  Future<void> _fetchRequests() async {
    try {
      final fetchedRequests =
          await TransportRequestService.getAllTransportRequests();
      setState(() {
        requests = fetchedRequests;
      });
    } catch (e) {
      print('Error fetching requests: $e');
    }
  }

  List<Map<String, dynamic>> _getFilteredRequests() {
    if (_selectedIndex == 0) {
      return requests.where((r) {
        final s = r['status'];
        return s != TransportRequestStatus.COMPLETED &&
            s != TransportRequestStatus.CANCELLED;
      }).toList();
    } else {
      return requests.where((r) {
        final s = r['status'];
        return s == TransportRequestStatus.COMPLETED ||
            s == TransportRequestStatus.CANCELLED;
      }).toList();
    }
  }

  String _getFacilityName(int? id) {
    if (id == null) return 'غير محدد';
    return facilityNames[id] ?? 'منشأة #$id';
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequests = _getFilteredRequests();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFFf8fafc),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedIndex == 0
                          ? 'الطلبات قيد التنفيذ'
                          : 'سجل الطلبات المكتملة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0f172a),
                      ),
                    ),
                  ),
                  if (_selectedIndex == 0)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFF2563eb).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.add, color: Color(0xFF2563eb)),
                        onPressed: () async {
                          await Navigator.pushNamed(context, '/doctor/create');
                          _loadData();
                        },
                        padding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: filteredRequests.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _selectedIndex == 0
                                        ? Icons.pending_actions
                                        : Icons.history,
                                    size: 64,
                                    color: Colors.grey[300],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    _selectedIndex == 0
                                        ? 'لا توجد طلبات نشطة حالياً'
                                        : 'لا يوجد سجل للطلبات المكتملة',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                                bottom: 16,
                              ),
                              itemCount: filteredRequests.length,
                              itemBuilder: (context, index) {
                                final request = filteredRequests[index];
                                return ModernRequestCard(
                                  request: request,
                                  getFacilityName: _getFacilityName,
                                  onTap: () => _showRequestDetails(request),
                                  onCancel: () => _cancelRequest(request),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: Color(0xFF2563eb),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined),
              activeIcon: Icon(Icons.local_shipping),
              label: 'قيد التنفيذ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_turned_in_outlined),
              activeIcon: Icon(Icons.assignment_turned_in),
              label: 'المكتملة',
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الطلب'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('رقم الطلب: ${request['id']}'),
              SizedBox(height: 8),
              Text('من: ${_getFacilityName(request['fromFacilityId'])}'),
              SizedBox(height: 8),
              Text('إلى: ${_getFacilityName(request['toFacilityId'])}'),
              SizedBox(height: 8),
              Text('اسم المريض: ${request['patientName'] ?? 'غير معروف'}'),
              SizedBox(height: 8),
              Text('الحالة: ${_getStatusText(request['status'])}'),
              SizedBox(height: 8),
              Text('ملاحظات: ${request['notes'] ?? ""}'),
            ],
          ),
        ),
        actions: [
          if (request['status'] == TransportRequestStatus.PENDING)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/doctor/create',
                  arguments: request,
                ).then((_) => _loadData());
              },
              child: Text('تعديل', style: TextStyle(color: Colors.blue)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelRequest(Map<String, dynamic> request) async {
    if (request['status'] != 'PENDING') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا يمكن حذف الطلب لأنه قيد التنفيذ أو تم قبوله'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إلغاء الطلب'),
        content: Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('نعم', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await TransportRequestService.deleteTransportRequest(request['id']);
        _loadData(); 
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم إلغاء الطلب بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل إلغاء الطلب: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case TransportRequestStatus.PENDING:
        return 'معلق';
      case TransportRequestStatus.ACCEPTED:
        return 'تمت الموافقة';
      case TransportRequestStatus.ON_THE_WAY:
        return 'في الطريق';
      case TransportRequestStatus.ARRIVED_AT_FACILITY:
        return 'وصل للمنشأة';
      case TransportRequestStatus.TRANSFERRED_TO_DESTINATION:
        return 'نُقل للوجهة';
      case TransportRequestStatus.COMPLETED:
        return 'مكتمل';
      case TransportRequestStatus.CANCELLED:
        return 'ملغى';
      default:
        return status ?? 'غير محدد';
    }
  }
}

class ModernRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final String Function(int?) getFacilityName;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const ModernRequestCard({
    required this.request,
    required this.getFacilityName,
    required this.onTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final status = request['status'] ?? TransportRequestStatus.PENDING;
    final isPending = status == TransportRequestStatus.PENDING;
    final isInProgress =
        status == TransportRequestStatus.ON_THE_WAY ||
        status == TransportRequestStatus.ARRIVED_AT_FACILITY ||
        status == TransportRequestStatus.TRANSFERRED_TO_DESTINATION;
    final isCancelled = status == TransportRequestStatus.CANCELLED;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isCancelled ? Color(0xFFf1f5f9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isInProgress)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: Color(0xFF2563eb),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getIconBackgroundColor(status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getPatientIcon(),
                              color: _getIconColor(status),
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request['patientName'] ?? 'غير معروف',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isCancelled
                                      ? Color(0xFF64748b)
                                      : Color(0xFF0f172a),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'ID: ${request['id']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isCancelled
                                      ? Color(0xFF94a3b8)
                                      : Color(0xFF64748b),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),

                  SizedBox(height: 12),
                  Divider(color: Colors.grey[100], height: 1),
                  SizedBox(height: 12),
                  Opacity(
                    opacity: isCancelled ? 0.6 : 1.0,
                    child: Row(
                      children: [
                        Icon(Icons.near_me, size: 18, color: Color(0xFF94a3b8)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  getFacilityName(request['fromFacilityId']),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF475569),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.arrow_back,
                                size: 16,
                                color: Color(0xFFcbd5e1),
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  getFacilityName(request['toFacilityId']),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF475569),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 8),
                  if (isInProgress) ...[
                    Divider(color: Colors.grey[50], height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Color(0xFF64748b),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'منذ 25 دقيقة',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748b),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF2563eb).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.local_shipping,
                                size: 16,
                                color: Color(0xFF2563eb),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'مركبة رقم 4',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2563eb),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xFF64748b),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'منذ 10 دقائق',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748b),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isPending) ...[
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: onCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFfef2f2),
                          foregroundColor: Color(0xFFdc2626),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cancel, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'إلغاء الطلب',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPatientIcon() {
    return Icons.person;
  }

  Color _getIconBackgroundColor(String status) {
    switch (status) {
      case TransportRequestStatus.PENDING:
        return Color(0xFFfef3c7);
      case TransportRequestStatus.ON_THE_WAY:
      case TransportRequestStatus.ARRIVED_AT_FACILITY:
      case TransportRequestStatus.TRANSFERRED_TO_DESTINATION:
        return Color(0xFFdbeafe);
      case TransportRequestStatus.ACCEPTED:
        return Color(0xFFdbeafe);
      case TransportRequestStatus.COMPLETED:
        return Color(0xFFdcfce7);
      case TransportRequestStatus.CANCELLED:
        return Color(0xFFe2e8f0);
      default:
        return Color(0xFFf1f5f9);
    }
  }

  Color _getIconColor(String status) {
    switch (status) {
      case TransportRequestStatus.PENDING:
        return Color(0xFFf59e0b);
      case TransportRequestStatus.ACCEPTED:
      case TransportRequestStatus.ON_THE_WAY:
      case TransportRequestStatus.ARRIVED_AT_FACILITY:
      case TransportRequestStatus.TRANSFERRED_TO_DESTINATION:
        return Color(0xFF2563eb);
      case TransportRequestStatus.COMPLETED:
        return Color(0xFF16a34a);
      case TransportRequestStatus.CANCELLED:
        return Color(0xFF64748b);
      default:
        return Color(0xFF94a3b8);
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;
    IconData? icon;
    bool showPulse = false;

    switch (status) {
      case TransportRequestStatus.PENDING:
        bgColor = const Color(0xFFfef3c7);
        textColor = const Color(0xFFf59e0b);
        text = 'معلق';
        icon = Icons.schedule;
        break;
      case TransportRequestStatus.ACCEPTED:
        bgColor = const Color(0xFFdbeafe);
        textColor = const Color(0xFF2563eb);
        text = 'تمت الموافقة';
        icon = Icons.thumb_up;
        break;
      case TransportRequestStatus.ON_THE_WAY:
        bgColor = const Color(0xFFe0e7ff);
        textColor = const Color(0xFF4338ca);
        text = 'في الطريق';
        showPulse = true;
        break;
      case TransportRequestStatus.ARRIVED_AT_FACILITY:
        bgColor = const Color(0xFFf3e8ff);
        textColor = const Color(0xFF7e22ce);
        text = 'وصل للمنشأة';
        icon = Icons.location_on;
        break;
      case TransportRequestStatus.TRANSFERRED_TO_DESTINATION:
        bgColor = const Color(0xFFfae8ff);
        textColor = const Color(0xFFa21caf);
        text = 'نُقل للوجهة';
        icon = Icons.directions_car;
        break;
      case TransportRequestStatus.COMPLETED:
        bgColor = const Color(0xFFdcfce7);
        textColor = const Color(0xFF16a34a);
        text = 'مكتمل';
        icon = Icons.check_circle;
        break;
      case TransportRequestStatus.CANCELLED:
        bgColor = const Color(0xFFe2e8f0);
        textColor = const Color(0xFF64748b);
        text = 'ملغى';
        icon = Icons.block;
        break;
      default:
        bgColor = const Color(0xFFf1f5f9);
        textColor = const Color(0xFF64748b);
        text = 'غير محدد';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: (status == 'ON_THE_WAY' || status == 'IN_PROGRESS')
            ? Border.all(color: const Color(0xFFbfdbfe))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPulse)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 6),
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
              ),
            )
          else if (icon != null)
            Icon(icon, size: 14, color: textColor),
          if (icon != null) const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
