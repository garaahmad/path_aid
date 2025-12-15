import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

class AdminVehicles extends StatefulWidget {
  const AdminVehicles({super.key});

  @override
  State<AdminVehicles> createState() => _AdminVehiclesState();
}

class _AdminVehiclesState extends State<AdminVehicles> {
  List<Map<String, dynamic>> _vehicleRequests = [
    {
      'id': 'REQ-VEH-001',
      'code': 'AMB-004',
      'type': 'إسعاف مجهز',
      'capacity': '4',
      'requester': 'منسق 1',
      'date': '2024-01-15',
      'status': 'معلق',
      'specifications': 'مجهز بأجهزة إنعاش',
    },
    {
      'id': 'REQ-VEH-002',
      'code': 'AMB-005',
      'type': 'إسعاف عادي',
      'capacity': '3',
      'requester': 'منسق 2',
      'date': '2024-01-16',
      'status': 'معلق',
      'specifications': 'إسعاف أساسي',
    },
    {
      'id': 'REQ-VEH-003',
      'code': 'AMB-005',
      'type': 'إسعاف عادي',
      'capacity': '3',
      'requester': 'منسق 2',
      'date': '2024-01-16',
      'status': 'معلق',
      'specifications': 'إسعاف أساسي',
    },
    {
      'id': 'REQ-VEH-004',
      'code': 'AMB-005',
      'type': 'إسعاف عادي',
      'capacity': '3',
      'requester': 'منسق 2',
      'date': '2024-01-16',
      'status': 'معلق',
      'specifications': 'إسعاف أساسي',
    },
    {
      'id': 'REQ-VEH-005',
      'code': 'AMB-005',
      'type': 'إسعاف عادي',
      'capacity': '3',
      'requester': 'منسق 2',
      'date': '2024-01-16',
      'status': 'معلق',
      'specifications': 'إسعاف أساسي',
    },
    {
      'id': 'REQ-VEH-006',
      'code': 'AMB-005',
      'type': 'إسعاف عادي',
      'capacity': '3',
      'requester': 'منسق 2',
      'date': '2024-01-16',
      'status': 'معلق',
      'specifications': 'إسعاف أساسي',
    },
    {
      'id': 'REQ-VEH-007',
      'code': 'AMB-005',
      'type': 'إسعاف عادي',
      'capacity': '3',
      'requester': 'منسق 2',
      'date': '2024-01-16',
      'status': 'معلق',
      'specifications': 'إسعاف أساسي',
    },
    {
      'id': 'REQ-VEH-008',
      'code': 'AMB-005',
      'type': 'إسعاف عادي',
      'capacity': '3',
      'requester': 'منسق 2',
      'date': '2024-01-16',
      'status': 'معلق',
      'specifications': 'إسعاف أساسي',
    },
    {
      'id': 'REQ-VEH-009',
      'code': 'AMB-005',
      'type': 'إسعاف عادي',
      'capacity': '3',
      'requester': 'منسق 2',
      'date': '2024-01-16',
      'status': 'معلق',
      'specifications': 'إسعاف أساسي',
    },
    {
      'id': 'REQ-VEH-010',
      'code': 'AMB-005',
      'type': 'إسعاف عادي',
      'capacity': '3',
      'requester': 'منسق 2',
      'date': '2024-01-16',
      'status': 'معلق',
      'specifications': 'إسعاف أساسي',
    },
    {
      'id': 'REQ-VEH-011',
      'code': 'AMB-005',
      'type': 'إسعاف عادي',
      'capacity': '3',
      'requester': 'منسق 2',
      'date': '2024-01-16',
      'status': 'معلق',
      'specifications': 'إسعاف أساسي',
    },
    {
      'id': 'REQ-VEH-012',
      'code': 'AMB-005',
      'type': 'إسعاف عادي',
      'capacity': '3',
      'requester': 'منسق 2',
      'date': '2024-01-16',
      'status': 'معلق',
      'specifications': 'إسعاف أساسي',
    },
    {
      'id': 'REQ-VEH-013',
      'code': 'AMB-005',
      'type': 'إسعاف عادي',
      'capacity': '3',
      'requester': 'منسق 2',
      'date': '2024-01-16',
      'status': 'معلق',
      'specifications': 'إسعاف أساسي',
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Icon(Icons.local_shipping, size: 32, color: Color(0xFF1A237E)),
          SizedBox(width: 12),
          Text(
            'طلبات إضافة المركبات',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          Spacer(),
          Chip(
            label: Text('${_vehicleRequests.length} طلب'),
            backgroundColor: Color(0xFF1A237E),
            labelStyle: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: _vehicleRequests.length,
      itemBuilder: (context, index) {
        final request = _vehicleRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8),
                  Text(
                    request['code'],
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildDetailRow('النوع:', request['type']),
              _buildDetailRow('السعة:', '${request['capacity']} أشخاص'),
              _buildDetailRow('المواصفات:', request['specifications']),
              _buildDetailRow('مقدم الطلب:', request['requester']),
              _buildDetailRow('التاريخ:', request['date']),
              Spacer(),
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _handleApproval(String requestId, bool isApproved) {
    setState(() {
      _vehicleRequests.removeWhere((req) => req['id'] == requestId);
    });
    MotionToast.success(
      description: Text(isApproved ? 'تمت الموافقة على الطلب' : 'تم رفض الطلب'),
      animationType: AnimationType.slideInFromTop,
      toastDuration: const Duration(seconds: 1),
      toastAlignment: Alignment.topCenter,
    ).show(context);
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل طلب المركبة'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRowDialog('رقم الطلب:', request['id']),
              _buildDetailRowDialog('كود المركبة:', request['code']),
              _buildDetailRowDialog('نوع المركبة:', request['type']),
              _buildDetailRowDialog('السعة:', '${request['capacity']} أشخاص'),
              _buildDetailRowDialog('المواصفات:', request['specifications']),
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
}
