import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path_aid/services/vehicle_service.dart';
import 'package:path_aid/services/user_service.dart';
import 'package:path_aid/services/transport_request_service.dart';

class AssignVehicle extends StatefulWidget {
  const AssignVehicle({super.key});

  @override
  State<AssignVehicle> createState() => _AssignVehicleState();
}

class _AssignVehicleState extends State<AssignVehicle> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await TransportRequestService.getAllTransportRequests();
      if (mounted) {
        setState(() {
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        MotionToast.error(
          description: Text('فشل تحميل الطلبات: $e'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 1),
          toastAlignment: Alignment.topCenter,
        ).show(context);
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredRequests() {
    if (_selectedIndex == 0) {
      return _requests.where((r) {
        final s = r['status'];
        return s != TransportRequestStatus.COMPLETED &&
            s != TransportRequestStatus.CANCELLED;
      }).toList();
    } else {
      return _requests.where((r) {
        final s = r['status'];
        return s == TransportRequestStatus.COMPLETED ||
            s == TransportRequestStatus.CANCELLED;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredRequests();

    return Scaffold(
      backgroundColor: const Color(0xFFf8fafc),
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'الطلبات النشطة' : 'سجل الطلبات'),
        backgroundColor: const Color(0xFF135bec),
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _fetchRequests, icon: Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : filtered.isEmpty
          ? Center(
              child: Text(
                _selectedIndex == 0
                    ? 'لا توجد طلبات نشطة'
                    : 'لا يوجد سجل طلبات',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final req = filtered[index];
                return _buildRequestCard(req);
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'الطلبات النشطة',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'المكتملة'),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> req) {
    final isPending = req['status'] == TransportRequestStatus.PENDING;
    final statusText = TransportRequestStatus.getArabicStatus(req['status']);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المريض: ${req['patientName'] ?? 'غير معروف'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPending ? Colors.orange[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: isPending ? Colors.orange[800] : Colors.blue[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('من: ${req['fromFacilityName'] ?? req['fromFacilityId']}'),
            Text('إلى: ${req['toFacilityName'] ?? req['toFacilityId']}'),
            Text('الأولوية: ${_getPriorityText(req['priority'])}'),
            const SizedBox(height: 12),
            if (isPending)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAssignmentDialog(req),
                  icon: const Icon(Icons.assignment),
                  label: const Text('تعيين مركبة وسائق'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF135bec),
                    foregroundColor: Colors.white,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'تم التعيين',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAssignmentDialog(Map<String, dynamic> request) async {
    showDialog(
      context: context,
      builder: (ctx) =>
          AssignmentDialog(request: request, onSuccess: _fetchRequests),
    );
  }

  String _getPriorityText(String? p) {
    if (p == 'CRITICAL') return 'حرج';
    if (p == 'HIGH') return 'عالي';
    if (p == 'MEDIUM') return 'متوسط';
    return 'منخفض';
  }
}

class AssignmentDialog extends StatefulWidget {
  final Map<String, dynamic> request;
  final VoidCallback onSuccess;

  const AssignmentDialog({
    super.key,
    required this.request,
    required this.onSuccess,
  });

  @override
  State<AssignmentDialog> createState() => _AssignmentDialogState();
}

class _AssignmentDialogState extends State<AssignmentDialog> {
  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _drivers = [];
  Map<String, dynamic>? _selectedVehicle;
  Map<String, dynamic>? _selectedDriver;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchOptions();
  }

  Future<void> _fetchOptions() async {
    try {
      final reqId = widget.request['id'];
      final results = await Future.wait([
        VehicleService.getAvailableVehiclesForRequest(reqId),
        VehicleService.getAllVehicles(),
        UserService.getAvailableDriversForRequest(reqId),
      ]);

      final availableVehicles = results[0] as List<Map<String, dynamic>>;
      final allVehicles = results[1] as List<Map<String, dynamic>>;
      final drivers = results[2] as List<Map<String, dynamic>>;

      final allVehiclesMap = {for (var v in allVehicles) v['id'].toString(): v};
      final enrichedVehicles = availableVehicles.map((av) {
        final idStr = av['id'].toString();
        var fullDetails = allVehiclesMap[idStr];
        if (fullDetails == null) {
          try {
            fullDetails = allVehicles.firstWhere(
              (v) => v['code'] == av['code'],
              orElse: () => {},
            );
            if (fullDetails!.isEmpty) fullDetails = null;
          } catch (_) {}
        }

        return {...av, 'capacity': fullDetails?['capacity'] ?? 0};
      }).toList();

      if (mounted) {
        setState(() {
          _vehicles = enrichedVehicles;
          _drivers = drivers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        MotionToast.error(
          description: Text('فشل تحميل الخيارات: $e'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 1),
          toastAlignment: Alignment.topCenter,
        ).show(context);
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedVehicle == null || _selectedDriver == null) return;

    setState(() => _isSubmitting = true);
    try {
      await TransportRequestService.assignAndUpdateStatus(
        requestId: widget.request['id'],
        driverId: _selectedDriver!['id'],
        vehicleId: _selectedVehicle!['id'],
        status: TransportRequestStatus.ACCEPTED,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        MotionToast.success(
          description: const Text('تم التعيين بنجاح'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 1),
          toastAlignment: Alignment.topCenter,
        ).show(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        MotionToast.error(
          description: Text('فشل التعيين: $e'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 1),
          toastAlignment: Alignment.topCenter,
        ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تعيين مركبة وسائق'),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: 'المركبة'),
                    items: _vehicles.map((v) {
                      return DropdownMenuItem(
                        value: v,
                        child: Text('${v['code']} (سعة: ${v['capacity']})'),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _selectedVehicle = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: 'السائق'),
                    items: _drivers.map((d) {
                      return DropdownMenuItem(
                        value: d,
                        child: Text('${d['fName']} ${d['lName']}'),
                      );
                    }).toList(),
                    onChanged: (d) => setState(() => _selectedDriver = d),
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
          onPressed:
              (_isSubmitting ||
                  _selectedVehicle == null ||
                  _selectedDriver == null)
              ? null
              : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('تأكيد'),
        ),
      ],
    );
  }
}
