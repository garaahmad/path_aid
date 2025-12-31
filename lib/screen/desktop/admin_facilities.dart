import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import '../../services/facility_service.dart';

class AdminFacilities extends StatefulWidget {
  const AdminFacilities({super.key});

  @override
  State<AdminFacilities> createState() => _AdminFacilitiesState();
}

class _AdminFacilitiesState extends State<AdminFacilities> {
  List<Map<String, dynamic>> _facilities = [];
  bool _isLoading = false;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredFacilities = [];

  final _nameController = TextEditingController();
  String _selectedType = 'HOSPITAL';
  String _selectedArea = 'GAZA';
  String _selectedCity = 'GAZA';
  int? _editingFacilityId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    setState(() => _isLoading = true);
    try {
      final data = await FacilityService.getAllFacilities();
      setState(() {
        _facilities = data;
        _filterFacilities();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        MotionToast.error(
          description: Text('فشل تحميل المنشآت: $e'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 2),
          toastAlignment: Alignment.topCenter,
          displaySideBar: false,
        ).show(context);
      }
    }
  }

  void _filterFacilities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFacilities = _facilities.where((f) {
        final name = (f['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Form
          SizedBox(width: 380, child: _buildFacilityForm()),
          const SizedBox(width: 32),
          // Right Side: List
          Expanded(child: _buildFacilitiesList()),
        ],
      ),
    );
  }

  Widget _buildFacilityForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _editingFacilityId == null
                        ? Icons.add_business
                        : Icons.edit_note,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  _editingFacilityId == null ? 'إضافة منشأة' : 'تعديل المنشأة',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildTextField(
              _nameController,
              'اسم المنشأة',
              Icons.business_outlined,
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              'النوع',
              _selectedType,
              (val) => setState(() => _selectedType = val!),
              [
                const DropdownMenuItem(
                  value: 'HOSPITAL',
                  child: Text('مستشفى'),
                ),
                const DropdownMenuItem(value: 'CLINIC', child: Text('عيادة')),
                const DropdownMenuItem(value: 'LAB', child: Text('مختبر')),
              ],
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              'المنطقة',
              _selectedArea,
              (val) {
                setState(() {
                  _selectedArea = val!;
                  // Reset city to first available in area
                  _selectedCity = _getAvailableCities(val).first;
                });
              },
              [
                const DropdownMenuItem(value: 'NORTH', child: Text('الشمال')),
                const DropdownMenuItem(value: 'GAZA', child: Text('غزة')),
                const DropdownMenuItem(value: 'CENTER', child: Text('الوسطى')),
                const DropdownMenuItem(value: 'SOUTH', child: Text('الجنوب')),
              ],
              icon: Icons.map_outlined,
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              'المدينة',
              _selectedCity,
              (val) => setState(() => _selectedCity = val!),
              _getAvailableCities(_selectedArea).map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(FacilityService.getCityText(city)),
                );
              }).toList(),
              icon: Icons.location_city_outlined,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFacility,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _editingFacilityId == null
                            ? 'إنشاء منشأة'
                            : 'حفظ التغييرات',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (_editingFacilityId != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () => setState(() {
                    _editingFacilityId = null;
                    _nameController.clear();
                  }),
                  child: const Text('إلغاء التعديل'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<String> _getAvailableCities(String area) {
    switch (area) {
      case 'NORTH':
        return ['JABALIA', 'BEIT_LAHIA', 'BEIT_HANOUN'];
      case 'GAZA':
        return ['WEST_GAZA', 'CENTRAL_GAZA', 'EAST_GAZA', 'GAZA'];
      case 'CENTER':
        return ['NUSEIRAT', 'MAGHAZI', 'BUREIJ', 'DEIR_AL_BALAH', 'ZAWAIDA'];
      case 'SOUTH':
        return ['KHAN_YOUNIS', 'RAFAH'];
      default:
        return ['GAZA'];
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'أدخل $label',
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    ValueChanged<String?> onChanged,
    List<DropdownMenuItem<String>> items, {
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.blueAccent.withOpacity(0.5),
          ),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: const Color(0xFF94A3B8))
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF1F5F9)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFacilitiesList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              children: [
                const Text(
                  'قائمة المنشآت',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 300,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => _filterFacilities(),
                    decoration: const InputDecoration(
                      hintText: 'بحث عن منشأة...',
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFacilities.isEmpty
                ? const Center(child: Text('لا يوجد منشآت مطابقة'))
                : ListView.separated(
                    itemCount: _filteredFacilities.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final f = _filteredFacilities[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent.withOpacity(0.1),
                          child: const Icon(
                            Icons.business_outlined,
                            color: Colors.blueAccent,
                          ),
                        ),
                        title: Text(
                          f['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${FacilityService.getCityText(f['city'])} • ${FacilityService.getAreaText(f['area'])}',
                          style: TextStyle(color: Colors.blueGrey[600]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blue,
                                size: 20,
                              ),
                              onPressed: () => _editFacility(f),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () => _deleteFacility(f['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _editFacility(Map<String, dynamic> f) {
    setState(() {
      _editingFacilityId = f['id'];
      _nameController.text = f['name'] ?? '';
      _selectedType = f['type'] ?? 'HOSPITAL';
      _selectedArea = f['area'] ?? 'GAZA';
      _selectedCity = f['city'] ?? 'GAZA';
    });
  }

  Future<void> _submitFacility() async {
    if (_nameController.text.isEmpty) return;
    try {
      setState(() => _isSubmitting = true);
      if (_editingFacilityId == null) {
        await FacilityService.createFacility(
          name: _nameController.text,
          type: _selectedType,
          area: _selectedArea,
          city: _selectedCity,
        );
      } else {
        await FacilityService.updateFacility(
          facilityId: _editingFacilityId!,
          name: _nameController.text,
          type: _selectedType,
          area: _selectedArea,
          city: _selectedCity,
        );
      }
      _nameController.clear();
      _editingFacilityId = null;
      _loadFacilities();
      if (mounted) {
        MotionToast.success(
          description: const Text('تم حفظ المنشأة بنجاح'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 2),
          toastAlignment: Alignment.topCenter,
          displaySideBar: false,
        ).show(context);
      }
    } catch (e) {
      if (mounted) {
        MotionToast.error(
          description: Text('فشل الحفظ: $e'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 2),
          toastAlignment: Alignment.topCenter,
          displaySideBar: false,
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _deleteFacility(int id) async {
    try {
      await FacilityService.deleteFacility(id);
      _loadFacilities();
      if (mounted) {
        MotionToast.success(
          description: const Text('تم حذف المنشأة'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 2),
          toastAlignment: Alignment.topCenter,
          displaySideBar: false,
        ).show(context);
      }
    } catch (e) {
      if (mounted) {
        MotionToast.error(
          description: Text('فشل الحذف: $e'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 2),
          toastAlignment: Alignment.topCenter,
          displaySideBar: false,
        ).show(context);
      }
    }
  }
}
