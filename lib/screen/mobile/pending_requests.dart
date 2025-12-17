import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path_aid/services/vehicle_service.dart';
import 'package:path_aid/services/transport_request_service.dart';
import 'package:path_aid/services/facility_service.dart';
import 'package:path_aid/services/user_service.dart';

class PendingRequests extends StatefulWidget {
  final int initialIndex;
  const PendingRequests({super.key, this.initialIndex = 0});

  @override
  State<PendingRequests> createState() => _PendingRequestsState();
}

class _PendingRequestsState extends State<PendingRequests> {
  List<Map<String, dynamic>> pendingRequests = [];
  late int _selectedIndex;
  bool _isLoading = true;
  String? _error;
  Map<int, String> _facilitiesMap = {};

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final facilities = await FacilityService.getAllFacilities();
      _facilitiesMap = {for (var f in facilities) f['id']: f['name']};
      final facilitiesMapStringKeys = {
        for (var f in facilities) f['id'].toString(): f['name'],
      };

      final requests = await TransportRequestService.getAllTransportRequests();

      final mappedRequests = requests.map((req) {
        final dt = DateTime.parse(
          req['transportTime'] ?? DateTime.now().toString(),
        ).toLocal();
        final formattedTime =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

        return {
          ...req,
          'fromFacility':
              _facilitiesMap[req['fromFacilityId']] ??
              facilitiesMapStringKeys[req['fromFacilityId'].toString()] ??
              'منشأة #${req['fromFacilityId']}',
          'toFacility':
              _facilitiesMap[req['toFacilityId']] ??
              facilitiesMapStringKeys[req['toFacilityId'].toString()] ??
              'منشأة #${req['toFacilityId']}',
          'scheduledTransferTime': formattedTime,
          'requestedBy': req['requestedBy'] ?? 'النظام',
          'requestedByPhone': req['requestedByPhone'] ?? '-',
          'status': req['status'] ?? 'PENDING',
        };
      }).toList();

      setState(() {
        pendingRequests = mappedRequests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _fetchRequests();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredRequests = pendingRequests.where((
      request,
    ) {
      final status = request['status'] ?? 'PENDING';
      final isCompleted =
          status == 'COMPLETED' ||
          status == 'CANCELLED' ||
          status == 'REJECTED';

      if (_selectedIndex == 0) {
        if (isCompleted) return false;
      } else {
        if (!isCompleted) return false;
      }

      bool matchesSearch =
          _searchQuery.isEmpty ||
          request['patientName'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          request['fromFacility'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          request['toFacility'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      return matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Directionality(
          textDirection: TextDirection.rtl,
          child: Text(
            _selectedIndex == 0 ? 'الطلبات النشطة' : 'سجل الطلبات',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshRequests,
            tooltip: 'تحديث القائمة',
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white.withOpacity(0.1),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث باسم المريض أو المنشأة...',
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black, width: 2),
                  ),
                  hintStyle: TextStyle(color: Colors.black),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                ),
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.white.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.black),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      filteredRequests.isEmpty
                          ? 'لا توجد طلبات مطابقة للبحث'
                          : 'عرض ${filteredRequests.length} طلب',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'حدث خطأ أثناء جلب البيانات',
                            style: TextStyle(fontSize: 18, color: Colors.red),
                          ),
                          SizedBox(height: 8),
                          Text(_error!, style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _fetchRequests,
                            icon: Icon(Icons.refresh),
                            label: Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    )
                  : filteredRequests.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredRequests.length,
                      itemBuilder: (context, index) {
                        final request = filteredRequests[index];
                        return _buildRequestCard(request);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'الطلبات النشطة',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'المكتملة'),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    Color priorityColor = _getPriorityColor(request['priority']);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 24),
                ),
                SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request['patientName'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'العمر: ${request['patientAge']} سنة',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getPriorityText(request['priority']),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),
            _buildInfoRow(Icons.location_on, 'من:', request['fromFacility']),
            _buildInfoRow(Icons.location_on, 'إلى:', request['toFacility']),
            _buildInfoRow(
              Icons.schedule,
              'وقت النقل:',
              request['scheduledTransferTime'],
            ),
            _buildInfoRow(Icons.person, 'مقدم الطلب:', request['requestedBy']),

            if (request['notes'] != null && request['notes'].isNotEmpty)
              _buildInfoRow(Icons.note, 'ملاحظات:', request['notes']),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showRequestDetails(request);
                    },
                    icon: Icon(Icons.info, size: 18),
                    label: Text('تفاصيل'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 8),

                if (request['status'] == 'PENDING') ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showRejectDialog(request);
                      },
                      icon: Icon(Icons.cancel, size: 18, color: Colors.red),
                      label: Text('رفض', style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        side: BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _assignVehicle(request);
                      },
                      icon: Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        'موافقة',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ] else
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Text(
                        'الطلب معين / مكتمل',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          SizedBox(width: 8),
          Container(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
          SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'لا توجد طلبات معلقة'
                : 'لا توجد طلبات مطابقة للبحث',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 51, 148, 56),
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'جميع الطلبات تمت معالجتها'
                : 'جرب تغيير كلمات البحث',
            style: TextStyle(
              fontSize: 16,
              color: const Color.fromARGB(255, 117, 117, 117),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: Text('العودة للوحة التحكم'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(Map<String, dynamic> request) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 8),
            Text('رفض الطلب'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طلب: ${request['patientName']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('رقم الطلب: ${request['id']}'),
            SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                labelText: 'سبب الرفض *',
                border: OutlineInputBorder(),
                hintText: 'أدخل سبب رفض الطلب...',
              ),
              maxLines: 3,
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
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('يرجى إدخال سبب الرفض'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              _rejectRequest(request['id'], reasonController.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('تأكيد الرفض'),
          ),
        ],
      ),
    );
  }

  void _rejectRequest(dynamic requestId, String reason) {
    setState(() {
      pendingRequests.removeWhere((req) => req['id'] == requestId);
    });

    MotionToast.success(
      opacity: 0.9,
      width: MediaQuery.of(context).size.width,
      displaySideBar: false,
      title: Text("نجاح"),
      description: Text('تم رفض الطلب بنجاح'),
      animationType: AnimationType.slideInFromTop,
      enableAnimation: true,
      toastDuration: const Duration(seconds: 1),
      toastAlignment: Alignment.topCenter,
    ).show(context);
  }

  void _assignVehicle(Map<String, dynamic> request) {
    _showDriverSelectionDialog(request);
  }

  void _showDriverSelectionDialog(Map<String, dynamic> request) {
    Future<List<Map<String, dynamic>>> _driversFuture =
        UserService.getAvailableDriversForRequest(request['id']);

    Map<String, dynamic>? selectedDriver;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.person, color: Color(0xFF648aa3)),
                SizedBox(width: 8),
                Text('1. اختيار السائق'),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'طلب: ${request['patientName']}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'اختر السائق المناسب:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 16),

                  if (selectedDriver != null)
                    _buildSelectedDriverCard(selectedDriver!, () {
                      setDialogState(() {
                        selectedDriver = null;
                      });
                    })
                  else
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _driversFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'فشل تحميل السائقين: ${snapshot.error}',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('لا يوجد سائقين متاحين'));
                        }

                        final drivers = snapshot.data!;

                        return Container(
                          height: 200,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: drivers.length,
                            itemBuilder: (context, index) {
                              return _buildDriverOption(drivers[index], () {
                                setDialogState(() {
                                  selectedDriver = drivers[index];
                                });
                              });
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: selectedDriver == null
                    ? null
                    : () {
                        Navigator.pop(context);
                        _showVehicleSelectionDialog(request, selectedDriver!);
                      },
                child: Text(
                  'التالي (اختيار المركبة)',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF648aa3),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showVehicleSelectionDialog(
    Map<String, dynamic> request,
    Map<String, dynamic> selectedDriver,
  ) {
    Future<List<Map<String, dynamic>>> _vehiclesFuture =
        VehicleService.getAvailableVehiclesForRequest(request['id']);

    Map<String, dynamic>? selectedVehicle;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.local_shipping, color: Color(0xFF648aa3)),
                SizedBox(width: 8),
                Text('2. اختيار المركبة'),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'السائق: ${selectedDriver['fName']} ${selectedDriver['lName'] ?? ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF648aa3),
                    ),
                  ),
                  SizedBox(height: 12),

                  if (selectedVehicle != null)
                    _buildSelectedVehicleCard(selectedVehicle!, () {})
                  else
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _vehiclesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'فشل تحميل المركبات: ${snapshot.error}',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('لا توجد مركبات متاحة'));
                        }
                        final activeVehicles = snapshot.data!;

                        if (activeVehicles.isEmpty) {
                          return Center(
                            child: Text('لا توجد مركبات نشطة حالياً'),
                          );
                        }

                        return Container(
                          height: 250,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: activeVehicles.length,
                            itemBuilder: (context, index) {
                              return _buildVehicleOption(
                                activeVehicles[index],
                                () {
                                  setDialogState(() {
                                    selectedVehicle = activeVehicles[index];
                                  });
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('رجوع'),
              ),
              ElevatedButton(
                onPressed: selectedVehicle == null
                    ? null
                    : () {
                        _confirmAssignment(
                          request,
                          selectedDriver,
                          selectedVehicle!,
                        );
                        Navigator.pop(context);
                      },
                child: Text(
                  'تأكيد التخصيص',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDriverOption(Map<String, dynamic> driver, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFF648aa3),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
        title: Text(
          '${driver['fName']} ${driver['lName'] ?? ''}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (driver['age'] != null) Text('العمر: ${driver['age']} سنة'),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildVehicleOption(Map<String, dynamic> vehicle, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          child: Icon(Icons.local_shipping, color: Colors.white, size: 20),
        ),
        title: Text(
          vehicle['code'] ?? 'بدون كود',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'السعة: ${vehicle['capacity'] ?? 0} مقاعد',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            vehicle['currentArea'] ?? 'غير محدد',
            style: TextStyle(color: Colors.white, fontSize: 10),
          ),
          backgroundColor: Colors.green,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSelectedDriverCard(
    Map<String, dynamic> driver,
    VoidCallback onChange,
  ) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'السائق المختار',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                TextButton(onPressed: onChange, child: Text('تغيير')),
              ],
            ),
            SizedBox(height: 8),
            Text('الاسم: ${driver['fName']} ${driver['lName'] ?? ''}'),
            Text('الهاتف: ${driver['phoneNumber'] ?? 'غير محدد'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedVehicleCard(
    Map<String, dynamic> vehicle,
    VoidCallback onChange,
  ) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'المركبة المختارة',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                TextButton(onPressed: onChange, child: Text('تغيير')),
              ],
            ),
            SizedBox(height: 8),
            Text('رقم المركبة: ${vehicle['code']}'),
            Text('السعة: ${vehicle['capacity'] ?? 0} مقاعد'),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAssignment(
    Map<String, dynamic> request,
    Map<String, dynamic> driver,
    Map<String, dynamic> vehicle,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final int requestId = int.parse(request['id'].toString());
      final int driverId = int.parse(driver['id'].toString());
      final int vehicleId = int.parse(vehicle['id'].toString());

      await TransportRequestService.assignDriverVehicleAndUpdateStatus(
        requestId: requestId,
        driverId: driverId,
        vehicleId: vehicleId,
      );

      Navigator.pop(context);

      setState(() {
        final index = pendingRequests.indexWhere(
          (req) => req['id'].toString() == requestId.toString(),
        );
        if (index != -1) {
          pendingRequests[index]['status'] = 'ACCEPTED';
          pendingRequests[index]['assignedDriverId'] = driverId;
          pendingRequests[index]['assignedVehicleId'] = vehicleId;
        }
      });

      MotionToast.success(
        description: Text(
          'تم تعيين السائق ${driver['fName']} والمركبة ${vehicle['code']} للطلب بنجاح',
        ),
        displaySideBar: false,
      ).show(context);
    } catch (e) {
      Navigator.pop(context);

      MotionToast.error(
        description: Text(e.toString()),
        displaySideBar: false,
      ).show(context);
    }
  }

  int _parseId(dynamic id) {
    if (id == null) return 0;
    if (id is int) return id;
    if (id is String) return int.tryParse(id) ?? 0;
    if (id is double) return id.toInt();
    return 0;
  }

  Future<void> _updateRequestStatus(dynamic requestId, String status) async {
    try {
      print('🔄 محاولة تحديث حالة الطلب $requestId إلى $status');

      await TransportRequestService.updateTransportRequestStatus(
        requestId: requestId,
        status: status,
      );

      print('✅ تم تحديث حالة الطلب بنجاح');
    } catch (e) {
      print('❌ خطأ في تحديث الحالة: $e');

      if (status == 'ASSIGNED') {
        try {
          print('🔄 محاولة تحديث إلى IN_PROGRESS بدلاً من ASSIGNED');
          await TransportRequestService.updateTransportRequestStatus(
            requestId: requestId,
            status: 'IN_PROGRESS',
          );
          print('✅ تم تحديث الحالة إلى IN_PROGRESS');
        } catch (e2) {
          print('❌ فشل تحديث الحالة البديلة: $e2');
        }
      }
    }
  }

  void _refreshRequests() {
    _fetchRequests();

    MotionToast.success(
      displaySideBar: false,
      width: MediaQuery.of(context).size.width,
      description: Text(
        "تم تحديث قائمه الطلبات",
        style: TextStyle(color: Colors.white),
      ),
      title: Text("نجاح", style: TextStyle(color: Colors.white)),
      animationType: AnimationType.slideInFromLeft,
      toastAlignment: Alignment.topLeft,
    ).show(context);
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Color(0xFF648aa3)),
            SizedBox(width: 8),
            Text('تفاصيل الطلب'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('رقم الطلب:', request['id']),
              _buildDetailRow('اسم المريض:', request['patientName']),
              _buildDetailRow('العمر:', '${request['patientAge']} سنة'),
              _buildDetailRow('الحالة الصحية:', request['patientCondition']),
              _buildDetailRow('من:', request['fromFacility']),
              _buildDetailRow('إلى:', request['toFacility']),
              _buildDetailRow(
                'الأولوية:',
                _getPriorityText(request['priority']),
              ),
              _buildDetailRow('مقدم الطلب:', request['requestedBy']),
              _buildDetailRow('هاتف مقدم الطلب:', request['requestedByPhone']),
              _buildDetailRow('وقت النقل:', request['scheduledTransferTime']),

              if (request['notes'] != null && request['notes'].isNotEmpty)
                _buildDetailRow('ملاحظات:', request['notes']),

              if (request['assignedDriver'] != null &&
                  request['assignedVehicle'] != null) ...[
                SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات التخصيص',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildDetailRow(
                        'السائق:',
                        '${request['assignedDriver']['fName']} ${request['assignedDriver']['lName'] ?? ''}',
                      ),
                      _buildDetailRow(
                        'هاتف السائق:',
                        request['assignedDriver']['phoneNumber'] ?? '-',
                      ),
                      _buildDetailRow(
                        'المركبة:',
                        request['assignedVehicle']['code'] ?? 'بدون كود',
                      ),
                      _buildDetailRow(
                        'سعة المركبة:',
                        '${request['assignedVehicle']['capacity']} مقاعد',
                      ),
                      if (request['assignedAt'] != null)
                        _buildDetailRow('وقت التخصيص:', request['assignedAt']),
                    ],
                  ),
                ),
              ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'CRITICAL':
        return 'حرج جداً';
      case 'HIGH':
        return 'عالي';
      case 'MEDIUM':
        return 'متوسط';
      default:
        return 'عادي';
    }
  }
}
