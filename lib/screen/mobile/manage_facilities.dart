import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path_aid/services/facility_service.dart';

class ManageFacilities extends StatefulWidget {
  const ManageFacilities({super.key});

  @override
  State<ManageFacilities> createState() => _ManageFacilitiesState();
}

class _ManageFacilitiesState extends State<ManageFacilities> {
  List<Map<String, dynamic>> _facilities = [];
  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchFacilities();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _fetchFacilities({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final facilities = await FacilityService.getAllFacilities();
      if (mounted) {
        setState(() {
          _facilities = facilities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _fetchFacilities(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredFacilities = _facilities.where((
      facility,
    ) {
      final query = _searchQuery.toLowerCase();

      final name = (facility['name'] ?? '').toString().toLowerCase();
      final address = (facility['address'] ?? '').toString().toLowerCase();
      final contactPerson = (facility['contactPerson'] ?? '')
          .toString()
          .toLowerCase();
      final city = _getCityText(facility['city']).toLowerCase();

      return _searchQuery.isEmpty ||
          name.contains(query) ||
          address.contains(query) ||
          contactPerson.contains(query) ||
          city.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إدارة المنشآت الصحية',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: _showAddFacilityDialog,
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن المنشأة (الاسم، المدينة...)',
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
                  fillColor: Colors.white,
                ),
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.black),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isLoading
                          ? 'جاري التحميل...'
                          : _error != null
                          ? 'حدث خطأ'
                          : filteredFacilities.isEmpty
                          ? 'لا توجد منشآت مطابقة للبحث'
                          : 'عرض ${filteredFacilities.length} منشأة ',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(filteredFacilities)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<Map<String, dynamic>> filteredFacilities) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.black));
    }
    if (_error != null) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 80, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'فشل تحميل البيانات',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _fetchFacilities,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (filteredFacilities.isEmpty && _searchQuery.isEmpty) {
      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: _buildEmptyState(),
          ),
        ),
      );
    }
    if (filteredFacilities.isEmpty) {
      return Center(
        child: Text(
          'لا توجد منشآت مطابقة للبحث',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Color(0xFF648aa3),
      backgroundColor: Colors.white,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        physics: AlwaysScrollableScrollPhysics(),
        itemCount: filteredFacilities.length,
        itemBuilder: (context, index) {
          final facility = filteredFacilities[index];
          return _buildFacilityCard(facility);
        },
      ),
    );
  }

  Widget _buildFacilityCard(Map<String, dynamic> facility) {
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
                    color: Color(0xFF012e47),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    facility['type'] == 'HOSPITAL'
                        ? Icons.local_hospital
                        : Icons.medical_services,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility['name'] ?? 'اسم غير متوفر',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _getFacilityTypeText(facility['type']),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildFacilityInfoRow(
              Icons.location_on,
              _getCityText(facility['city']),
            ),
            _buildFacilityInfoRow(
              Icons.map,
              'المنطقة: ${_getAreaText(facility['area'])}',
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showFacilityDetails(facility),
                    icon: Icon(Icons.info, size: 18),
                    label: Text('تفاصيل'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: IconButton(
                    onPressed: () => _deactivateFacility(facility),
                    icon: Icon(Icons.delete, color: Colors.red),
                    tooltip: 'حذف المنشأة',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacilityInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey[600])),
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
          Icon(Icons.business, size: 80, color: Colors.white),
          SizedBox(height: 16),
          Text(
            'لا توجد منشآت مسجلة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'يمكنك إضافة منشآت جديدة باستخدام زر الإضافة',
            style: TextStyle(fontSize: 16, color: Colors.white),
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

  void _showAddFacilityDialog() {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _nameController = TextEditingController();

    String _selectedType = 'HOSPITAL';
    String _selectedArea = 'NORTH';
    String? _selectedCity;
    List<String> _cities = [];
    bool _isLoadingCities = false;

    Future<void> _fetchCities(String area, StateSetter setDialogState) async {
      setDialogState(() {
        _isLoadingCities = true;
        _cities = [];
        _selectedCity = null;
      });

      try {
        final cities = await FacilityService.getAreaCities(area);
        if (context.mounted) {
          setDialogState(() {
            _cities = cities;
            if (_cities.isNotEmpty) {
              _selectedCity = _cities.first;
            }
            _isLoadingCities = false;
          });
        }
      } catch (e) {
        if (context.mounted) {
          setDialogState(() {
            _isLoadingCities = false;
          });
          MotionToast.error(
            title: Text("خطأ", style: TextStyle(color: Colors.white)),
            description: Text("فشل تحميل المدن"),
            animationType: AnimationType.slideInFromTop,
            toastDuration: const Duration(seconds: 1),
            toastAlignment: Alignment.topCenter,
          ).show(context);
        }
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          if (_cities.isEmpty && !_isLoadingCities) {
            _fetchCities(_selectedArea, setDialogState);
          }

          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.add_business, color: Color(0xFF648aa3)),
                SizedBox(width: 8),
                Text('طلب إضافة منشأة جديدة'),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم المنشأة *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) => value!.isEmpty ? 'مطلوب' : null,
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'نوع المنشأة *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'HOSPITAL',
                          child: Text('مستشفى'),
                        ),
                        DropdownMenuItem(value: 'CLINIC', child: Text('عيادة')),
                        DropdownMenuItem(
                          value: 'EMERGENCY_CENTER',
                          child: Text('مركز طوارئ'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() => _selectedType = value!);
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedArea,
                      decoration: InputDecoration(
                        labelText: 'المنطقة *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map),
                      ),
                      items: [
                        DropdownMenuItem(value: 'NORTH', child: Text('الشمال')),
                        DropdownMenuItem(value: 'GAZA', child: Text('غزة')),
                        DropdownMenuItem(
                          value: 'CENTER',
                          child: Text('الوسطى'),
                        ),
                        DropdownMenuItem(value: 'SOUTH', child: Text('الجنوب')),
                      ],
                      onChanged: (newValue) {
                        setDialogState(() {
                          _selectedArea = newValue!;
                          _fetchCities(_selectedArea, setDialogState);
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _isLoadingCities
                        ? Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<String>(
                            key: ValueKey(
                              _selectedArea,
                            ), 
                            value: _selectedCity,
                            decoration: InputDecoration(
                              labelText: 'المدينة *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_city),
                            ),
                            items: _cities.map((city) {
                              return DropdownMenuItem<String>(
                                value: city,
                                child: Text(_getCityText(city)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setDialogState(() {
                                _selectedCity = value!;
                              });
                            },
                          ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _sendFacilityRequest(
                      name: _nameController.text,
                      type: _selectedType,
                      area: _selectedArea,
                      city: _selectedCity!,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF648aa3),
                ),
                child: Text('إضافة', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _sendFacilityRequest({
    required String name,
    required String type,
    required String area,
    required String city,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      await FacilityService.createFacility(
        name: name,
        type: type,
        area: area,
        city: city,
      );

      Navigator.pop(context);

      MotionToast.success(
        title: Text("نجاح", style: TextStyle(color: Colors.white)),
        description: Text(
          "تم إنشاء المنشأة $name بنجاح",
          style: TextStyle(color: Colors.white),
        ),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 1),
        toastAlignment: Alignment.topCenter,
        displaySideBar: false,
      ).show(context);

      _fetchFacilities();
    } catch (e) {
      Navigator.pop(context);

      MotionToast.error(
        title: Text("خطأ", style: TextStyle(color: Colors.white)),
        description: Text(e.toString()),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 1),
        toastAlignment: Alignment.topCenter,
      ).show(context);
    }
  }

  void _showFacilityDetails(Map<String, dynamic> facility) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Color(0xFF012e47)),
            SizedBox(width: 8),
            Text('تفاصيل المنشأة'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('الاسم:', facility['name'] ?? 'غير متوفر'),
              _buildDetailRow('النوع:', _getFacilityTypeText(facility['type'])),
              _buildDetailRow('العنوان:', _getCityText(facility['city'])),
              _buildDetailRow('المنطقة:', _getAreaText(facility['area'])),
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

  void _deactivateFacility(Map<String, dynamic> facility) {
    final mainContext = context;
    showDialog(
      context: mainContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.delete_forever, color: Colors.red),
              SizedBox(width: 8),
              Text('تأكيد الحذف'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'هل أنت متأكد من حذف هذه المنشأة؟ هذا الإجراء لا يمكن التراجع عنه.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('المنشأة: ${facility['name']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                showDialog(
                  context: mainContext,
                  barrierDismissible: false,
                  builder: (context) =>
                      Center(child: CircularProgressIndicator()),
                );

                try {
                  if (facility['id'] == null) {
                    throw Exception("لا يمكن حذف منشأة بدون معرف (ID)");
                  }
                  await FacilityService.deleteFacility(facility['id']);
                  Navigator.pop(mainContext);
                  MotionToast.success(
                    title: Text("نجاح", style: TextStyle(color: Colors.white)),
                    description: Text(
                      "تم حذف المنشأة بنجاح",
                      style: TextStyle(color: Colors.white),
                    ),
                    displaySideBar: false,
                    animationType: AnimationType.slideInFromTop,
                    toastDuration: const Duration(seconds: 1),
                    toastAlignment: Alignment.topCenter,
                  ).show(mainContext);

                  _fetchFacilities();
                } catch (e) {
                  Navigator.pop(mainContext);

                  MotionToast.error(
                    title: Text("خطأ"),
                    description: Text(e.toString()),
                    animationType: AnimationType.slideInFromTop,
                    toastDuration: const Duration(seconds: 1),
                    toastAlignment: Alignment.topCenter,
                  ).show(mainContext);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getFacilityTypeText(String? type) {
    switch (type) {
      case 'HOSPITAL':
        return 'مستشفى';
      case 'CLINIC':
        return 'عيادة';
      case 'EMERGENCY_CENTER':
        return 'مركز طوارئ';
      default:
        return type ?? 'غير محدد';
    }
  }

  String _getAreaText(String? area) {
    switch (area) {
      case 'NORTH':
        return 'الشمال';
      case 'GAZA':
        return 'غزة';
      case 'CENTER':
        return 'المركز';
      case 'SOUTH':
        return 'الجنوب';
      default:
        return area ?? 'غير محدد';
    }
  }

  String _getCityText(String? city) {
    switch (city) {
      case 'BEIT_HANOUN':
        return 'بيت حانون';
      case 'BEIT_LAHIA':
        return 'بيت لاهيا';
      case 'NUSEIRAT':
        return 'النصيرات';
      case 'DEIR_AL_BALAH':
        return 'دير البلح';
      case 'MAGHAZI':
        return 'المغازي';
      case 'BUREIJ':
        return 'البريج';
      case 'ZAWAIDA':
        return 'الزوايدة';
      case 'WEST_GAZA':
        return 'غرب غزة';
      case 'CENTRAL_GAZA':
        return 'وسط غزة';
      case 'EAST_GAZA':
        return 'شرق غزة';
      case 'KHAN_YOUNIS':
        return 'خانيونس';
      case 'RAFAH':
        return 'رفح';
      case 'JABALIA':
        return 'جباليا';
      case 'GAZA':
        return 'غزة';
      case 'BEIT_HANIOUN':
        return 'بيت حانون';
      default:
        return city ?? 'غير محدد';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
