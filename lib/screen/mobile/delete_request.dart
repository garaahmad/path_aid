import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path_aid/services/transport_request_service.dart';

class DeleteRequest extends StatefulWidget {
  const DeleteRequest({super.key});

  @override
  State<DeleteRequest> createState() => _DeleteRequestState();
}

class _DeleteRequestState extends State<DeleteRequest> {
  List<Map<String, dynamic>> requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final fetchedRequests =
          await TransportRequestService.getAllTransportRequests();
      setState(() {
        requests = fetchedRequests;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching requests: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _deleteRequest(int id, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد من حذف طلب ${requests[index]['patientName'] ?? 'هذا المريض'}؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performDelete(id);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(int id) async {
    try {
      await TransportRequestService.deleteTransportRequest(id);

      setState(() {
        requests.removeWhere((r) => r['id'] == id);
      });

      if (!mounted) return;

      MotionToast.success(
        width: MediaQuery.of(context).size.width,
        animationDuration: const Duration(seconds: 2),
        toastDuration: const Duration(seconds: 1),
        displaySideBar: false,
        displayBorder: false,
        title: Text("نجاح", style: TextStyle(color: Colors.white)),
        description: Text(
          'تم حذف الطلب بنجاح',
          style: TextStyle(color: Colors.white),
        ),
        animationType: AnimationType.slideInFromTop,
        toastAlignment: Alignment.topCenter,
      ).show(context);
    } catch (e) {
      if (!mounted) return;
      MotionToast.error(
        width: MediaQuery.of(context).size.width,
        animationDuration: const Duration(seconds: 2),
        toastDuration: const Duration(seconds: 1),
        displaySideBar: false,
        displayBorder: false,
        title: Text("فشل", style: TextStyle(color: Colors.white)),
        description: Text(
          e.toString().replaceAll('Exception: ', ''),
          style: TextStyle(color: Colors.white),
        ),
        animationType: AnimationType.slideInFromTop,
        toastAlignment: Alignment.topCenter,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('حذف طلبات النقل'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : requests.isEmpty
          ? Center(
              child: Text(
                'لا توجد طلبات للحذف',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(request['patientName'] ?? 'غير معروف'),
                    subtitle: Text(
                      'العمر: ${request['patientAge'] ?? 0} - ${request['priority'] ?? "غير محدد"}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteRequest(request['id'], index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
