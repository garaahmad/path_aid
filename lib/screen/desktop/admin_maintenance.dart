import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

class AdminMaintenance extends StatefulWidget {
  const AdminMaintenance({super.key});

  @override
  State<AdminMaintenance> createState() => _AdminMaintenanceState();
}

class _AdminMaintenanceState extends State<AdminMaintenance> {
  final List<Map<String, dynamic>> _maintenanceRequests = [
    {
      'id': 'REQ-MAINT-001',
      'vehicleCode': 'AMB-002',
      'reason': 'صيانة دورية للمحرك',
      'requester': 'منسق 2',
      'date': '2024-01-15',
      'status': 'معلق',
      'priority': 'عالية',
      'estimatedCost': '500 ₪',
    },
    {
      'id': 'REQ-MAINT-002',
      'vehicleCode': 'AMB-001',
      'reason': 'تغيير إطارات',
      'requester': 'منسق 1',
      'date': '2024-01-16',
      'status': 'معلق',
      'priority': 'متوسطة',
      'estimatedCost': '300 ₪',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 24),
          Expanded(child: _buildRequestsList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.build, size: 32, color: Color(0xFF1A237E)),
        SizedBox(width: 12),
        Text(
          'طلبات الصيانة',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        Spacer(),
        Chip(
          label: Text('${_maintenanceRequests.length} طلب'),
          backgroundColor: Color(0xFF1A237E),
          labelStyle: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildRequestsList() {
    return ListView.builder(
      itemCount: _maintenanceRequests.length,
      itemBuilder: (context, index) {
        final request = _maintenanceRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    Color priorityColor = _getPriorityColor(request['priority']);

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'طلب صيانة - ${request['vehicleCode']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(
                    request['priority'],
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: priorityColor,
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('المركبة:', request['vehicleCode']),
                      _buildDetailRow('سبب الصيانة:', request['reason']),
                      _buildDetailRow(
                        'التكلفة المقدرة:',
                        request['estimatedCost'],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('مقدم الطلب:', request['requester']),
                      _buildDetailRow('التاريخ:', request['date']),
                      _buildDetailRow('الحالة:', request['status']),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRequestDetails(request),
                    icon: Icon(Icons.info_outline, size: 18),
                    label: Text('تفاصيل'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _scheduleMaintenance(request),
                    icon: Icon(Icons.calendar_today, size: 18),
                    label: Text('جدولة'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.purple,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleApproval(request['id'], false),
                    icon: Icon(Icons.close, size: 18),
                    label: Text('رفض'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleApproval(request['id'], true),
                    icon: Icon(Icons.check, size: 18),
                    label: Text('موافقة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'عالية':
        return Colors.red;
      case 'متوسطة':
        return Colors.orange;
      case 'منخفضة':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _handleApproval(String requestId, bool isApproved) {
    setState(() {
      _maintenanceRequests.removeWhere((req) => req['id'] == requestId);
    });
    MotionToast.success(
      description: Text(
        isApproved ? 'تمت الموافقة على طلب الصيانة' : 'تم رفض طلب الصيانة',
      ),
      animationType: AnimationType.slideInFromTop,
      toastDuration: const Duration(seconds: 1),
      toastAlignment: Alignment.topCenter,
    ).show(context);
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل طلب الصيانة'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRowDialog('رقم الطلب:', request['id']),
              _buildDetailRowDialog('كود المركبة:', request['vehicleCode']),
              _buildDetailRowDialog('سبب الصيانة:', request['reason']),
              _buildDetailRowDialog('الأولوية:', request['priority']),
              _buildDetailRowDialog(
                'التكلفة المقدرة:',
                request['estimatedCost'],
              ),
              _buildDetailRowDialog('مقدم الطلب:', request['requester']),
              _buildDetailRowDialog('التاريخ:', request['date']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowDialog(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _scheduleMaintenance(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('جدولة الصيانة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('حدد موعد الصيانة للمركبة ${request['vehicleCode']}'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'التاريخ والوقت',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'مكان الصيانة',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              MotionToast.success(
                description: Text('تم جدولة الصيانة بنجاح'),
                animationType: AnimationType.slideInFromTop,
                toastDuration: const Duration(seconds: 1),
                toastAlignment: Alignment.topCenter,
              ).show(context);
            },
            child: Text('تأكيد الجدولة'),
          ),
        ],
      ),
    );
  }
}
