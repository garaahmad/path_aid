import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path_aid/services/user_service.dart';
import 'package:path_aid/services/vehicle_service.dart';
import 'package:path_aid/services/transport_request_service.dart';

class RequestDetails extends StatefulWidget {
  final Map<String, dynamic> request;
  const RequestDetails({super.key, required this.request});

  @override
  State<RequestDetails> createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final patientName = request['patientName'] ?? 'Unknown';
    final patientId =
        request['patientId'] ??
        (request['id'] != null ? 'ID-${request['id']}' : 'N/A');
    final priority = request['priority'] ?? 'ROUTINE';
    final from = request['fromFacilityName'] ?? 'Unknown';
    final to = request['toFacilityName'] ?? 'Unknown';
    final date = request['transportTime'] != null
        ? request['transportTime'].toString().split('T')[0]
        : (request['scheduledTransferTime'] ?? 'غير محدد');
    final notes = request['notes'] ?? 'لا توجد ملاحظات إضافية من المرسل';

    Color priorityColor = Colors.green;
    String priorityText = 'منخفض';
    if (priority == 'MEDIUM') {
      priorityColor = Colors.orange;
      priorityText = 'متوسط';
    } else if (priority == 'HIGH') {
      priorityColor = Colors.red;
      priorityText = 'عالي';
    } else if (priority == 'CRITICAL') {
      priorityColor = Colors.purple;
      priorityText = 'حرج';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'تفاصيل الطلب',
              style: TextStyle(
                color: Color(0xFF1e293b),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1e293b)),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: IconButton(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF1e293b)),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 100,
                left: 16,
                right: 16,
                bottom: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'معرف الطلب: #${request['id']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748b),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'قيد الانتظار',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                        "https://lh3.googleusercontent.com/aida-public/AB6AXuBhBVKgewoCFxWdB75a1bpaMz1Bv1vuLRfoSdfIL1nCxzXWl3NmMLThPCj-NZPzw3dRHrbrDTBwi1261FQiYVInmn2881h8fQULvHUZzyT3va5nux5XQ_CjJhZu40GkW-g4FVqFuDIZGBFzgC8xStZ70qfhlQyQfQ4vcRPDgxzEfudsFL50kHXz8pFOcu_TdppsDirtqd3Tp_iPeONG4ginCB9xWf92gojdriD3DKcRHItn6boxZnL1nxzeJ2HtYJ0AbxuNw0yBWw",
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -5,
                                  right: -5,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF135bec),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.medical_services,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patientName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0f172a),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'رقم الملف الطبي: $patientId',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748b),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey[100]),
                        const SizedBox(height: 16),
                        _buildTimelineRow(from, to),
                        const SizedBox(height: 20),

                        Divider(color: Colors.grey[100]),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'تفاصيل إضافية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e293b),
                    ),
                  ),
                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildDetailBox(
                        Icons.calendar_today,
                        'تاريخ الطلب',
                        date,
                        Colors.grey,
                      ),
                      _buildDetailBox(
                        Icons.priority_high,
                        'الأولوية',
                        priorityText,
                        priorityColor,
                        isHighlight: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'ملاحظات المرسل (الطبيب)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1e293b),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Text(
                      notes,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF334155),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (request['status'] == 'PENDING')
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            _showRejectDialog();
                          },
                          icon: const Icon(Icons.block, size: 20),
                          label: const Text('رفض'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: BorderSide(color: Colors.red[200]!),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _assignVehicle();
                          },
                          icon: const Icon(Icons.medical_services, size: 20),
                          label: const Text('تعيين مركبة'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF135bec),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: const Color(
                              0xFF135bec,
                            ).withOpacity(0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    border: Border(top: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_outline, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'لا يمكن التعديل',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineRow(String from, String to) {
    return Container(
      padding: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey[200]!, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineItem(from, true),
          const SizedBox(height: 16),
          _buildTimelineItem(to, false),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String location, bool isStart) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isStart ? 'من' : 'إلى',
              style: TextStyle(fontSize: 12, color: const Color(0xFF64748b)),
            ),
            const SizedBox(height: 2),
            Text(
              location,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1e293b),
              ),
            ),
          ],
        ),
        Positioned(
          right: -17,
          top: 4,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isStart ? Colors.grey[300] : const Color(0xFF135bec),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailBox(
    IconData icon,
    String label,
    String value,
    Color iconColor, {
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isHighlight
                    ? iconColor.withOpacity(0.7)
                    : Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748b),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          isHighlight
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0f172a),
                  ),
                ),
        ],
      ),
    );
  }

  void _showRejectDialog() {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('هل أنت متأكد من رفض هذا الطلب؟ سيتم حذفه نهائياً.'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _rejectRequest();
            },
            child: const Text(
              'رفض وحذف',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rejectRequest() async {
    setState(() => _isLoading = true);
    try {
      await TransportRequestService.deleteTransportRequest(
        widget.request['id'],
      );
      if (mounted) {
        setState(() => _isLoading = false);
        MotionToast.success(
          title: const Text("تم الحذف"),
          description: const Text("تم رفض وحذف الطلب بنجاح"),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 2),
          toastAlignment: Alignment.topCenter,
          displaySideBar: false,
        ).show(context);
        Navigator.pop(context, true); // Return true to indicate change
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        MotionToast.error(
          title: const Text("خطأ"),
          description: Text("فشل حذف الطلب: $e"),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 2),
          toastAlignment: Alignment.topCenter,
          displaySideBar: false,
        ).show(context);
      }
    }
  }

  void _assignVehicle() {
    _showDriverSelectionDialog();
  }

  void _showDriverSelectionDialog() {
    Future<List<Map<String, dynamic>>> _driversFuture =
        UserService.getAvailableDriversForRequest(widget.request['id']);
    Map<String, dynamic>? selectedDriver;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('1. اختيار السائق'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _driversFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.isEmpty)
                    return const Center(child: Text('No drivers available'));

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final driver = snapshot.data![index];
                      final isSelected = selectedDriver == driver;
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(
                          "${driver['fName']} ${driver['lName'] ?? ''}",
                        ),
                        selected: isSelected,
                        selectedTileColor: const Color(
                          0xFF135bec,
                        ).withOpacity(0.1),
                        onTap: () {
                          setDialogState(() => selectedDriver = driver);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: selectedDriver == null
                    ? null
                    : () {
                        Navigator.pop(context);
                        _showVehicleSelectionDialog(selectedDriver!);
                      },
                child: const Text('التالي'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showVehicleSelectionDialog(Map<String, dynamic> driver) {
    Future<List<Map<String, dynamic>>> _vehiclesFuture = () async {
      try {
        final reqId = widget.request['id'];
        final results = await Future.wait([
          VehicleService.getAvailableVehiclesForRequest(reqId),
          VehicleService.getAllVehicles(),
        ]);

        final availableVehicles = results[0];
        final allVehicles = results[1];
        final allVehiclesMap = {
          for (var v in allVehicles) v['id'].toString(): v,
        };

        return availableVehicles.map((av) {
          final idStr = av['id'].toString();
          var fullDetails = allVehiclesMap[idStr];

          if (fullDetails == null) {
            try {
              fullDetails = allVehicles.firstWhere(
                (v) => v['code'] == av['code'],
                orElse: () => {},
              );
              if (fullDetails.isEmpty) fullDetails = null;
            } catch (_) {}
          }

          return {...av, 'capacity': fullDetails?['capacity'] ?? 0};
        }).toList();
      } catch (e) {
        throw e;
      }
    }();

    Map<String, dynamic>? selectedVehicle;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('2. اختيار المركبة'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _vehiclesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError)
                    return Center(child: Text('Error: ${snapshot.error}'));
                  if (!snapshot.hasData || snapshot.data!.isEmpty)
                    return const Center(child: Text('No vehicles available'));

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final vehicle = snapshot.data![index];
                      return ListTile(
                        leading: const Icon(Icons.directions_car),
                        title: Text(vehicle['code'] ?? 'Unknown'),
                        subtitle: Text('Capacity: ${vehicle['capacity']}'),
                        onTap: () {
                          selectedVehicle = vehicle;
                          setDialogState(() {});
                        },
                        selected: selectedVehicle == vehicle,
                        selectedTileColor: const Color(
                          0xFF135bec,
                        ).withOpacity(0.1),
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('رجوع'),
              ),
              ElevatedButton(
                onPressed: selectedVehicle == null
                    ? null
                    : () async {
                        Navigator.pop(context);
                        await _confirmAssignment(driver, selectedVehicle!);
                      },
                child: const Text('تأكيد'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmAssignment(
    Map<String, dynamic> driver,
    Map<String, dynamic> vehicle,
  ) async {
    setState(() => _isLoading = true);
    try {
      await TransportRequestService.assignAndUpdateStatus(
        requestId: widget.request['id'],
        driverId: driver['id'],
        vehicleId: vehicle['id'],
      );
      MotionToast.success(
        description: const Text("تم التخصيص بنجاح"),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topCenter,
        displaySideBar: false,
      ).show(context);
      Navigator.pop(context);
    } catch (e) {
      MotionToast.error(
        description: Text(e.toString()),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topCenter,
        displaySideBar: false,
      ).show(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
