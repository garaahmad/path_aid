import 'package:flutter/material.dart';
import 'package:path_aid/components.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path_aid/services/facility_service.dart';
import 'package:flutter/services.dart';
import 'package:path_aid/services/transport_request_service.dart';

class CreateRequest extends StatefulWidget {
  final Map<String, dynamic>? requestToEdit;
  const CreateRequest({super.key, this.requestToEdit});

  @override
  State<CreateRequest> createState() => _CreateRequestState();
}

class _CreateRequestState extends State<CreateRequest> {
  final TextEditingController _fromFacilityController = TextEditingController();
  final TextEditingController _toFacilityController = TextEditingController();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientAgeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String _selectedPriority = 'MEDIUM';
  final List<String> _priorities = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];

  List<Map<String, dynamic>> _facilities = [];
  bool _isLoadingFacilities = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchFacilities();
    if (widget.requestToEdit != null) {
      _loadRequestData();
    }
  }

  void _loadRequestData() {
    final request = widget.requestToEdit!;
    _fromFacilityController.text = request['fromFacilityId'].toString();
    _toFacilityController.text = request['toFacilityId'].toString();
    _patientNameController.text = request['patientName'] ?? '';
    _patientAgeController.text = request['patientAge'].toString();
    _notesController.text = request['notes'] ?? '';
    _selectedPriority = request['priority'] ?? 'MEDIUM';

    if (request['transportTime'] != null) {
      final dateTime = DateTime.parse(request['transportTime']).toLocal();
      _selectedDate = dateTime;
      _selectedTime = TimeOfDay.fromDateTime(dateTime);
      _dateController.text =
          "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
      _timeController.text =
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
  }

  Future<void> _fetchFacilities() async {
    try {
      final facilities = await FacilityService.getAllFacilities();
      setState(() {
        _facilities = facilities;
        _isLoadingFacilities = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFacilities = false;
      });
      print('فشل في جلب المنشآت: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _submitRequest() async {
    if (_fromFacilityController.text.isEmpty ||
        _toFacilityController.text.isEmpty ||
        _patientNameController.text.isEmpty ||
        _patientAgeController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      MotionToast.error(
        displaySideBar: false,
        title: const Text("خطأ", style: TextStyle(color: Colors.white)),
        description: const Text(
          "يرجى ملء جميع الحقول الإلزامية بما في ذلك التاريخ والوقت",
          style: TextStyle(color: Colors.white),
        ),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topCenter,
      ).show(context);
      return;
    } else if (_fromFacilityController.text == _toFacilityController.text) {
      MotionToast.error(
        displaySideBar: false,
        title: const Text("خطأ", style: TextStyle(color: Colors.white)),
        description: const Text(
          "لا يمكن انشاء طلب نقل الى نفس المسشفى",
          style: TextStyle(color: Colors.white),
        ),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topCenter,
      ).show(context);
      return;
    } else if (int.parse(_patientAgeController.text) >= 100) {
      MotionToast.error(
        displaySideBar: false,
        title: const Text("خطأ", style: TextStyle(color: Colors.white)),
        description: const Text(
          "يرجى إدخال عمر صحي",
          style: TextStyle(color: Colors.white),
        ),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topCenter,
      ).show(context);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final DateTime transportDate = _selectedDate!;
      final TimeOfDay transportTime = _selectedTime!;
      final DateTime transportDateTime = DateTime(
        transportDate.year,
        transportDate.month,
        transportDate.day,
        transportTime.hour,
        transportTime.minute,
      );

      if (widget.requestToEdit != null) {
        await TransportRequestService.updateTransportRequest(
          id: widget.requestToEdit!['id'],
          fromFacilityId: int.parse(_fromFacilityController.text),
          toFacilityId: int.parse(_toFacilityController.text),
          priority: _selectedPriority,
          patientName: _patientNameController.text,
          patientAge: int.parse(_patientAgeController.text),
          transportTime: transportDateTime,
          notes: _notesController.text,
        );
      } else {
        await TransportRequestService.createTransportRequest(
          fromFacilityId: int.parse(_fromFacilityController.text),
          toFacilityId: int.parse(_toFacilityController.text),
          priority: _selectedPriority,
          patientName: _patientNameController.text,
          patientAge: int.parse(_patientAgeController.text),
          transportTime: transportDateTime,
          notes: _notesController.text,
        );
      }

      if (!mounted) return;

      MotionToast.success(
        displaySideBar: false,
        title: const Text("نجاح", style: TextStyle(color: Colors.white)),
        description: Text(
          widget.requestToEdit != null
              ? "تم تعديل الطلب بنجاح"
              : "تم إنشاء الطلب بنجاح",
          style: const TextStyle(color: Colors.white),
        ),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topCenter,
      ).show(context);

      Future.delayed(Duration(milliseconds: 1500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      if (!mounted) return;
      MotionToast.error(
        displaySideBar: false,
        title: const Text("فشل", style: TextStyle(color: Colors.white)),
        description: Text(
          e.toString().replaceAll('Exception: ', ''),
          style: const TextStyle(color: Colors.white),
        ),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topCenter,
      ).show(context);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _clearFields() {
    _fromFacilityController.clear();
    _toFacilityController.clear();
    _patientNameController.clear();
    _patientAgeController.clear();
    _notesController.clear();
    _dateController.clear();
    _timeController.clear();
    setState(() {
      _selectedPriority = 'MEDIUM';
      _selectedDate = null;
      _selectedTime = null;
    });

    MotionToast.info(
      displaySideBar: false,
      title: const Text("تنظيف الحقول", style: TextStyle(color: Colors.white)),
      description: const Text(
        "تم تنظيف جميع الحقول",
        style: TextStyle(color: Colors.white),
      ),
      animationType: AnimationType.slideInFromTop,
      toastDuration: const Duration(seconds: 2),
      toastAlignment: Alignment.topCenter,
    ).show(context);
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'LOW':
        return 'منخفض';
      case 'MEDIUM':
        return 'متوسط';
      case 'HIGH':
        return 'عالي';
      case 'CRITICAL':
        return 'حرج';
      default:
        return priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.requestToEdit != null
              ? 'تعديل طلب النقل'
              : 'إنشاء طلب نقل جديد',
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: MediaQuery.of(context).size.height,

          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _isLoadingFacilities
                              ? CircularProgressIndicator()
                              : DropdownButtonFormField<String>(
                                  value: _fromFacilityController.text.isEmpty
                                      ? null
                                      : _fromFacilityController.text,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: 'المنشأة المصدر *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  items: _facilities.map((facility) {
                                    return DropdownMenuItem<String>(
                                      value: facility['id'].toString(),
                                      child: Text(facility['name']),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _fromFacilityController.text = newValue!;
                                    });
                                  },
                                ),
                          SizedBox(height: 20),
                          _isLoadingFacilities
                              ? CircularProgressIndicator()
                              : DropdownButtonFormField<String>(
                                  value: _toFacilityController.text.isEmpty
                                      ? null
                                      : _toFacilityController.text,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    labelText: 'المنشأة الهدف *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  items: _facilities.map((facility) {
                                    return DropdownMenuItem<String>(
                                      value: facility['id'].toString(),
                                      child: Text(facility['name']),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _toFacilityController.text = newValue!;
                                    });
                                  },
                                ),
                          SizedBox(height: 20),
                          Input(
                            label: "اسم المريض *",
                            hint: "أدخل اسم المريض",
                            controller: _patientNameController,
                            maxLine: 1,
                          ),
                          SizedBox(height: 20),
                          Input(
                            label: "عمر المريض *",
                            hint: "أدخل عمر المريض",
                            controller: _patientAgeController,
                            maxLine: 1,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: _selectedPriority,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'أولوية النقل *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items: _priorities.map((priority) {
                              return DropdownMenuItem<String>(
                                value: priority,
                                child: Row(
                                  children: [
                                    _getPriorityIcon(priority),
                                    SizedBox(width: 10),
                                    Text(_getPriorityText(priority)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedPriority = newValue!;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _dateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'تاريخ النقل *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: Icon(Icons.calendar_today),
                                    suffixIcon: Icon(Icons.arrow_drop_down),
                                  ),
                                  onTap: _selectDate,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'يرجى اختيار التاريخ';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: TextFormField(
                                  controller: _timeController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    labelText: 'وقت النقل *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: Icon(Icons.access_time),
                                    suffixIcon: Icon(Icons.arrow_drop_down),
                                  ),
                                  onTap: _selectTime,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'يرجى اختيار الوقت';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Input(
                            label: "ملاحظات",
                            hint: "أدخل أي ملاحظات إضافية",
                            maxLine: 3,
                            controller: _notesController,
                          ),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: MaterialButton(
                                  onPressed: _submitRequest,
                                  color: Colors.green,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: _isSubmitting
                                      ? CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          widget.requestToEdit != null
                                              ? "حفظ التعديلات"
                                              : "تأكيد الطلب",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: MaterialButton(
                                  onPressed: _clearFields,
                                  color: Colors.grey.shade600,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "تنظيف الحقول",
                                    style: TextStyle(
                                      color: Colors.white,
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getPriorityIcon(String priority) {
    switch (priority) {
      case 'LOW':
        return Icon(Icons.arrow_downward, color: Colors.green);
      case 'MEDIUM':
        return Icon(Icons.remove, color: Colors.orange);
      case 'HIGH':
        return Icon(Icons.arrow_upward, color: Colors.red);
      case 'CRITICAL':
        return Icon(Icons.warning, color: Colors.purple);
      default:
        return Icon(Icons.help, color: Colors.grey);
    }
  }

  @override
  void dispose() {
    _fromFacilityController.dispose();
    _toFacilityController.dispose();
    _patientNameController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}
