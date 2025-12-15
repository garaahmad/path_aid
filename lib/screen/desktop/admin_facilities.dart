import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

class AdminFacilities extends StatefulWidget {
  const AdminFacilities({super.key});

  @override
  State<AdminFacilities> createState() => _AdminFacilitiesState();
}

class _AdminFacilitiesState extends State<AdminFacilities> {
  final List<Map<String, dynamic>> _facilityRequests = [
    {
      'id': 'REQ-FAC-001',
      'name': 'مستشفى الأمل',
      'type': 'مستشفى',
      'area': 'غزة',
      'requester': 'منسق 1',
      'date': '2024-01-15',
      'status': 'معلق',
    },
    {
      'id': 'REQ-FAC-002',
      'name': 'عيادة الشفاء',
      'type': 'عيادة',
      'area': 'الشمال',
      'requester': 'منسق 2',
      'date': '2024-01-16',
      'status': 'معلق',
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.business, size: 32, color: Color(0xFF1A237E)),
        SizedBox(width: 12),
        Text(
          'طلبات إضافة المنشآت',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        Spacer(),
        Chip(
          label: Text('${_facilityRequests.length} طلب'),
          backgroundColor: Color(0xFF1A237E),
          labelStyle: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildRequestsList() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemCount: _facilityRequests.length,
        itemBuilder: (context, index) {
          final request = _facilityRequests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    return Card(
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
                Icon(Icons.business, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  request['name'],
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildDetailRow('النوع:', request['type']),
            _buildDetailRow('المنطقة:', request['area']),
            _buildDetailRow('مقدم الطلب:', request['requester']),
            _buildDetailRow('التاريخ:', request['date']),
            Spacer(),
            Row(
              children: [
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
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _handleApproval(String requestId, bool isApproved) {
    setState(() {
      _facilityRequests.removeWhere((req) => req['id'] == requestId);
    });
    MotionToast.success(
      description: Text(isApproved ? 'تمت الموافقة على الطلب' : 'تم رفض الطلب'),
      animationType: AnimationType.slideInFromTop,
      toastDuration: const Duration(seconds: 1),
      toastAlignment: Alignment.topCenter,
      displaySideBar: false,
    ).show(context);
  }
}
