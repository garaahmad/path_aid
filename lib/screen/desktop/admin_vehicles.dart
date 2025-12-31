import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import '../../services/vehicle_service.dart';

class AdminVehicles extends StatefulWidget {
  const AdminVehicles({super.key});

  @override
  State<AdminVehicles> createState() => _AdminVehiclesState();
}

class _AdminVehiclesState extends State<AdminVehicles> {
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = false;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredVehicles = [];

  final _codeController = TextEditingController();
  final _capacityController = TextEditingController();
  int? _editingVehicleId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() => _isLoading = true);
    try {
      final data = await VehicleService.getAllVehicles();
      setState(() {
        _vehicles = data;
        _filterVehicles();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        MotionToast.error(
          description: Text('فشل تحميل المركبات: $e'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 2),
          toastAlignment: Alignment.topCenter,
          displaySideBar: false,
        ).show(context);
      }
    }
  }

  void _filterVehicles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredVehicles = _vehicles.where((v) {
        final code = (v['code'] ?? '').toString().toLowerCase();
        return code.contains(query);
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
          SizedBox(width: 380, child: _buildVehicleForm()),
          const SizedBox(width: 32),
          // Right Side: List
          Expanded(child: _buildVehiclesList()),
        ],
      ),
    );
  }

  Widget _buildVehicleForm() {
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
                    _editingVehicleId == null
                        ? Icons.add_road_rounded
                        : Icons.edit_note_rounded,
                    color: Colors.blueAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  _editingVehicleId == null ? 'إضافة مركبة' : 'تعديل مركبة',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildTextField(_codeController, 'كود المركبة', Icons.tag),
            const SizedBox(height: 20),
            _buildTextField(
              _capacityController,
              'السعة',
              Icons.people_outline,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitVehicle,
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
                        _editingVehicleId == null
                            ? 'إضافة مركبة'
                            : 'حفظ التغييرات',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (_editingVehicleId != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () => setState(() {
                    _editingVehicleId = null;
                    _codeController.clear();
                    _capacityController.clear();
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

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
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

  Widget _buildVehiclesList() {
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
                  'قائمة المركبات',
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
                    onChanged: (val) => _filterVehicles(),
                    decoration: const InputDecoration(
                      hintText: 'بحث عن مركبة...',
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
                : _filteredVehicles.isEmpty
                ? const Center(child: Text('لا يوجد مركبات مطابقة'))
                : ListView.separated(
                    itemCount: _filteredVehicles.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final v = _filteredVehicles[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: Colors.orange.withOpacity(0.1),
                          child: const Icon(
                            Icons.local_shipping,
                            color: Colors.orange,
                          ),
                        ),
                        title: Text(
                          v['code'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('السعة: ${v['capacity']} أشخاص'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: VehicleService.getStatusColor(
                                  v['status'],
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                VehicleService.getStatusText(v['status']),
                                style: TextStyle(
                                  color: VehicleService.getStatusColor(
                                    v['status'],
                                  ),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blue,
                                size: 20,
                              ),
                              onPressed: () => _editVehicle(v),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () => _deleteVehicle(v['id']),
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

  void _editVehicle(Map<String, dynamic> v) {
    setState(() {
      _editingVehicleId = v['id'];
      _codeController.text = v['code'] ?? '';
      _capacityController.text = v['capacity']?.toString() ?? '';
    });
  }

  Future<void> _submitVehicle() async {
    if (_codeController.text.isEmpty || _capacityController.text.isEmpty)
      return;
    try {
      setState(() => _isSubmitting = true);
      if (_editingVehicleId == null) {
        await VehicleService.createVehicle(
          code: _codeController.text,
          capacity: int.parse(_capacityController.text),
          status: 'ACTIVE',
        );
      } else {
        await VehicleService.updateVehicle(
          vehicleId: _editingVehicleId!,
          code: _codeController.text,
          capacity: int.parse(_capacityController.text),
          status: 'ACTIVE',
        );
      }
      _codeController.clear();
      _capacityController.clear();
      _editingVehicleId = null;
      _loadVehicles();
      if (mounted) {
        MotionToast.success(
          description: const Text('تم حفظ المركبة بنجاح'),
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

  Future<void> _deleteVehicle(int id) async {
    try {
      await VehicleService.deleteVehicle(id);
      _loadVehicles();
      if (mounted) {
        MotionToast.success(
          description: const Text('تم حذف المركبة'),
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
