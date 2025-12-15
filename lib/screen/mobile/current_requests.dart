import 'package:flutter/material.dart';
import 'package:path_aid/screen/mobile/driver_home.dart';
import 'package:path_aid/services/vehicle_service.dart';
import 'package:motion_toast/motion_toast.dart';

class CurrentRequests extends StatefulWidget {
  const CurrentRequests({super.key});

  static List<Map<String, dynamic>> queue = [
    {
      'id': 'REQ-002',
      'patientName': 'سارة أحمد',
      'fromFacility': 'مستشفى الشفاء',
      'toFacility': 'مستشفى القدس',
      'priority': 'HIGH',
      'status': 'مستلم',
      'estimatedTime': '15 دقيقة',
      'currentStep': 1,
      'totalSteps': 5,
    },
    {
      'id': 'REQ-003',
      'patientName': 'خالد عمر',
      'fromFacility': 'مستشفى الملك فهد',
      'toFacility': 'مستشفى العسكري',
      'priority': 'MEDIUM',
      'status': 'مستلم',
      'estimatedTime': '20 دقيقة',
      'currentStep': 1,
      'totalSteps': 5,
    },
    {
      'id': 'REQ-004',
      'patientName': 'فاطمة علي',
      'fromFacility': 'مستشفى التخصصي',
      'toFacility': 'مستشفى الحرس',
      'priority': 'LOW',
      'status': 'مستلم',
      'estimatedTime': '10 دقيقة',
      'currentStep': 1,
      'totalSteps': 5,
    },
  ];

  @override
  State<CurrentRequests> createState() => _CurrentRequestsState();
}

class _CurrentRequestsState extends State<CurrentRequests> {
  List<Map<String, dynamic>> _availableVehicles = [];
  bool _isVehiclesLoading = false;

  final List<String> statusSteps = [
    'مستلم',
    'في الطريق',
    'الوصول للمنشأة',
    'التحرك إلى الوجهة',
    'اتمام الرحلة',
  ];

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    setState(() {
      _isVehiclesLoading = true;
    });
    try {
      final vehicles = await VehicleService.getAllVehicles();
      setState(() {
        _availableVehicles = vehicles
            .where((v) => v['status'] == 'ACTIVE')
            .toList();
        _isVehiclesLoading = false;
      });
    } catch (e) {
      print("Error fetching vehicles: $e");
      setState(() {
        _isVehiclesLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الطلبات الحالية',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF012e47),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/Driver_BG.png"),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: CurrentRequests.queue.length,
            itemBuilder: (context, index) {
              final request = CurrentRequests.queue[index];
              return DriverRequestCard(
                request: request,
                statusSteps: statusSteps,
                onTap: () {
                  _showRequestDetails(request);
                },
                onStatusUpdate: (newStatus) {
                  _updateRequestStatus(request['id'], newStatus);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text('تفاصيل الطلب'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('رقم الطلب: ${request['id']}'),
                  SizedBox(height: 8),
                  Text('اسم المريض: ${request['patientName']}'),
                  SizedBox(height: 8),
                  Text('من: ${request['fromFacility']}'),
                  SizedBox(height: 8),
                  Text('إلى: ${request['toFacility']}'),
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 8),
                  Text('الأولوية: ${request['priority']}'),
                  SizedBox(height: 8),
                  Text('الحالة: ${request['status']}'),
                  SizedBox(height: 8),
                  Text('الوقت المقدر: ${request['estimatedTime']}'),
                  SizedBox(height: 8),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تقدم الرحلة:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        _buildProgressBar(request),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إغلاق'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showVehicleSelectionDialog(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر المركبة'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: _isVehiclesLoading
              ? Center(child: CircularProgressIndicator())
              : _availableVehicles.isEmpty
              ? Center(child: Text('لا توجد مركبات نشطة متاحة'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = _availableVehicles[index];
                    return ListTile(
                      leading: Icon(Icons.local_taxi, color: Color(0xFF012e47)),
                      title: Text(
                        vehicle['code'] ?? 'رمز غير معروف',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('السعة: ${vehicle['capacity']} مقاعد'),
                      trailing: request['vehicleName'] == vehicle['code']
                          ? Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          final reqIndex = CurrentRequests.queue.indexWhere(
                            (r) => r['id'] == request['id'],
                          );
                          if (reqIndex != -1) {
                            CurrentRequests.queue[reqIndex]['vehicleName'] =
                                vehicle['code'];
                          }
                        });
                        Navigator.pop(context);
                        _showRequestDetails(
                          CurrentRequests.queue.firstWhere(
                            (r) => r['id'] == request['id'],
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Map<String, dynamic> request) {
    int currentStep = request['currentStep'] ?? 1;
    int totalSteps = statusSteps.length;

    return Column(
      children: [
        LinearProgressIndicator(
          value: currentStep / totalSteps,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getStatusColor(request['status']),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '${currentStep} من ${totalSteps} - ${request['status']}',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _updateRequestStatus(String requestId, String newStatus) {
    setState(() {
      final requestIndex = CurrentRequests.queue.indexWhere(
        (req) => req['id'] == requestId,
      );
      if (requestIndex != -1) {
        if (newStatus == 'اتمام الرحلة') {
          CurrentRequests.queue[requestIndex]['status'] = newStatus;
          CurrentRequests.queue[requestIndex]['currentStep'] =
              statusSteps.length;

          MotionToast.success(
            toastDuration: const Duration(seconds: 1),
            opacity: 0.9,
            displaySideBar: false,
            animationDuration: const Duration(
              milliseconds: 3000,
            ), 
            title: Text("نجاح", style: TextStyle(color: Colors.white)),
            description: Text(
              'تم اتمام الرحلة بنجاح. سيتم إخفاء الطلب بعد 10 ثواني.',
              style: TextStyle(color: Colors.white),
            ),
            animationType: AnimationType.slideInFromTop,
            toastAlignment: Alignment.topCenter,
          ).show(context);

          Future.delayed(Duration(seconds: 10), () {
            if (mounted) {
              setState(() {
                CurrentRequests.queue.removeAt(requestIndex);
              });
            }
          });
        } else {
          int currentStep = statusSteps.indexOf(newStatus) + 1;
          CurrentRequests.queue[requestIndex]['status'] = newStatus;
          CurrentRequests.queue[requestIndex]['currentStep'] = currentStep;
        }
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مستلم':
        return Colors.blue;
      case 'في الطريق':
        return Colors.orange;
      case 'الوصول للمنشأة':
        return Colors.purple;
      case 'التحرك إلى الوجهة':
        return Colors.deepOrange;
      case 'اتمام الرحلة':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class DriverRequestCard extends StatelessWidget {
  final Map<String, dynamic> request;
  final List<String> statusSteps;
  final VoidCallback onTap;
  final Function(String) onStatusUpdate;

  const DriverRequestCard({
    super.key,
    required this.request,
    required this.statusSteps,
    required this.onTap,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
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
                      Text(
                        request['patientName'] ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0f172a),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        request['id'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748b),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildPriorityBadge(request['priority']),
              ],
            ),
            SizedBox(height: 12),
            Divider(color: Colors.grey[200]),
            SizedBox(height: 12),
            _buildLocationRow(
              Icons.local_hospital,
              'من',
              request['fromFacility'] ?? '',
            ),
            SizedBox(height: 8),
            _buildLocationRow(
              Icons.location_on,
              'إلى',
              request['toFacility'] ?? '',
            ),
            SizedBox(height: 12),
            Divider(color: Colors.grey[200]),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Color(0xFF64748b)),
                    SizedBox(width: 4),
                    Text(
                      request['estimatedTime'] ?? '',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748b)),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request['status'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(request['status']),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildProgressIndicator(),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showStatusUpdateDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF012e47),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'تحديث الحالة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, String label, String location) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Color(0xFF64748b)),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748b),
          ),
        ),
        Expanded(
          child: Text(
            location,
            style: TextStyle(fontSize: 14, color: Color(0xFF0f172a)),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBadge(String? priority) {
    Color color;
    String text;

    switch (priority) {
      case 'HIGH':
        color = Colors.red;
        text = 'عالية';
        break;
      case 'MEDIUM':
        color = Colors.orange;
        text = 'متوسطة';
        break;
      case 'LOW':
        color = Colors.green;
        text = 'منخفضة';
        break;
      default:
        color = Colors.grey;
        text = 'غير محدد';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    int currentStep = request['currentStep'] ?? 1;
    int totalSteps = statusSteps.length;
    double progress = currentStep / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التقدم: $currentStep من $totalSteps',
          style: TextStyle(fontSize: 12, color: Color(0xFF64748b)),
        ),
        SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getStatusColor(request['status']),
          ),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'مستلم':
        return Colors.blue;
      case 'في الطريق':
        return Colors.orange;
      case 'الوصول للمنشأة':
        return Colors.purple;
      case 'التحرك إلى الوجهة':
        return Colors.deepOrange;
      case 'اتمام الرحلة':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showStatusUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تحديث حالة الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statusSteps.map((status) {
            bool isCurrentStatus = status == request['status'];
            return ListTile(
              leading: Icon(
                isCurrentStatus ? Icons.check_circle : Icons.circle_outlined,
                color: isCurrentStatus ? Colors.green : Colors.grey,
              ),
              title: Text(status),
              onTap: () {
                Navigator.pop(context);
                onStatusUpdate(status);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
        ],
      ),
    );
  }
}
