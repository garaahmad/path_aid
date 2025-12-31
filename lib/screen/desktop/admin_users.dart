import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import '../../services/user_service.dart';
import '../../services/facility_service.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedRole = 'DRIVER';
  int? _selectedFacilityId;
  List<Map<String, dynamic>> _facilities = [];
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  final _searchController = TextEditingController();

  // For editing
  int? _editingUserId;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    try {
      final facilities = await FacilityService.getAllFacilities();
      setState(() => _facilities = facilities);
    } catch (e) {
      debugPrint('Error loading facilities: $e');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final users = await UserService.getAllUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _filterUsers();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        MotionToast.error(
          description: Text('فشل تحميل المستخدمين: ${e.toString()}'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 2),
          toastAlignment: Alignment.topCenter,
          displaySideBar: false,
        ).show(context);
      }
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = List.from(_users);
      } else {
        _filteredUsers = _users.where((user) {
          final fullName = '${user['fName']} ${user['lName']}'.toLowerCase();
          final email = (user['email'] ?? '').toLowerCase();
          final phone = (user['phoneNumber'] ?? '').toLowerCase();
          return fullName.contains(query) ||
              email.contains(query) ||
              phone.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Form
          SizedBox(width: 380, child: _buildUserForm()),
          const SizedBox(width: 32),
          // Right Side: List
          Expanded(child: _buildUsersList()),
        ],
      ),
    );
  }

  Widget _buildUserForm() {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
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
                      _editingUserId == null ? Icons.person_add : Icons.edit,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _editingUserId == null
                        ? 'إضافة مستخدم'
                        : 'تعديل بيانات المستخدم',
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
                _firstNameController,
                'الاسم الأول',
                Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                _lastNameController,
                'الاسم الأخير',
                Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                _emailController,
                'البريد الإلكتروني',
                Icons.alternate_email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                _passwordController,
                _editingUserId == null
                    ? 'كلمة المرور'
                    : 'كلمة المرور الجديدة (اختياري)',
                Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                _phoneController,
                'رقم الهاتف',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                _ageController,
                'العمر',
                Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildDropdownField(),
              const SizedBox(height: 20),
              _buildFacilityDropdownField(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitUser,
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
                          _editingUserId == null
                              ? 'إنشاء حساب جديد'
                              : 'حفظ التغييرات',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              if (_editingUserId != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    onPressed: _cancelEdit,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('إلغاء التعديل'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
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
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: 'أدخل $label',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.blueAccent,
                width: 1.5,
              ),
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

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نوع الحساب (الدور)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          onChanged: (value) => setState(() => _selectedRole = value!),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.shield_outlined,
              size: 20,
              color: Color(0xFF94A3B8),
            ),
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
          items: const [
            DropdownMenuItem(value: 'DRIVER', child: Text('سائق')),
            DropdownMenuItem(value: 'SENDER', child: Text('مرسل')),
            DropdownMenuItem(value: 'DISPATCHER', child: Text('موزع')),
            DropdownMenuItem(value: 'ADMIN', child: Text('مدير')),
          ],
        ),
      ],
    );
  }

  Widget _buildFacilityDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المنشأة التابع لها',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedFacilityId,
          hint: const Text('اختر المنشأة'),
          onChanged: (value) => setState(() => _selectedFacilityId = value),
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.business_outlined,
              size: 20,
              color: Color(0xFF94A3B8),
            ),
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
          items: _facilities.map((f) {
            return DropdownMenuItem<int>(
              value: f['id'],
              child: Text(f['name'] ?? 'منشأة غير معروفة'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildUsersList() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Toolbar
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              children: [
                const Text(
                  'قائمة المستخدمين في النظام',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_users.length} مستخدم',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
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
                    onChanged: (value) => _filterUsers(),
                    decoration: const InputDecoration(
                      hintText: 'بحث عن مستخدم...',
                      hintStyle: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                      ),
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
                const SizedBox(width: 12),
                _buildToolbarButton(Icons.refresh, 'تحديث', _loadUsers),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Header
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'المستخدم',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'البريد الإلكتروني',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'رقم الهاتف',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'الدور / الصلاحية',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'خيارات',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Body
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: _filteredUsers.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _buildUserRow(user);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    return InkWell(
      onTap: () => _editUser(user),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _getRoleColor(
                      user['role'],
                    ).withOpacity(0.1),
                    child: Text(
                      (user['fName']?[0] ?? '').toUpperCase(),
                      style: TextStyle(
                        color: _getRoleColor(user['role']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user['fName']} ${user['lName']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'ID: #${user['id']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                user['email'] ?? '',
                style: const TextStyle(color: Color(0xFF475569)),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                user['phoneNumber'] ?? '',
                style: const TextStyle(color: Color(0xFF475569)),
              ),
            ),
            Expanded(flex: 2, child: _buildRoleBadge(user['role'])),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  _buildIconButton(
                    Icons.edit_outlined,
                    Colors.blue,
                    () => _editUser(user),
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    Icons.delete_outline,
                    Colors.red,
                    () => _deleteUser(user['id']),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final color = _getRoleColor(role);
    return UnconstrainedBox(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _getRoleDisplayName(role),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 80, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 24),
          const Text(
            'لا يوجد مستخدمين مسجلين حالياً',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'يمكنك إضافة مستخدم جديد من النموذج الجانبي',
            style: TextStyle(color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'DRIVER':
        return 'سائق';
      case 'SENDER':
        return 'مرسل';
      case 'DISPATCHER':
        return 'موزع';
      case 'ADMIN':
        return 'مدير';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'SENDER':
        return Colors.blue;
      case 'DRIVER':
        return Colors.green;
      case 'DISPATCHER':
        return Colors.orange;
      case 'ADMIN':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _submitUser() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _ageController.text.isEmpty) {
      MotionToast.error(
        description: const Text('يرجى ملء جميع الحقول المطلوبة'),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topCenter,
        displaySideBar: false,
      ).show(context);
      return;
    }

    if (_editingUserId == null && _passwordController.text.isEmpty) {
      MotionToast.error(
        description: const Text('كلمة المرور مطلوبة للمستخدمين الجدد'),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 2),
        toastAlignment: Alignment.topCenter,
        displaySideBar: false,
      ).show(context);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final Map<String, dynamic> userData = {
        'fName': _firstNameController.text,
        'lName': _lastNameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'age': int.parse(_ageController.text),
        'role': _selectedRole,
      };

      if (_passwordController.text.isNotEmpty) {
        userData['password'] = _passwordController.text;
      }

      if (_selectedFacilityId != null) {
        userData['facilityId'] = _selectedFacilityId;
      }

      if (_editingUserId == null) {
        await UserService.createUser(userData);
        if (mounted) {
          MotionToast.success(
            description: const Text('تم إضافة المستخدم بنجاح'),
            animationType: AnimationType.slideInFromTop,
            toastDuration: const Duration(seconds: 2),
            toastAlignment: Alignment.topCenter,
            displaySideBar: false,
          ).show(context);
        }
      } else {
        await UserService.updateUser(_editingUserId!, userData);
        if (mounted) {
          MotionToast.success(
            description: const Text('تم تحديث بيانات المستخدم بنجاح'),
            animationType: AnimationType.slideInFromTop,
            toastDuration: const Duration(seconds: 2),
            toastAlignment: Alignment.topCenter,
            displaySideBar: false,
          ).show(context);
        }
      }

      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _ageController.clear();
      _passwordController.clear();
      setState(() {
        _editingUserId = null;
        _isSubmitting = false;
        _selectedFacilityId = null;
      });
      _loadUsers();
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        final cleanError = e.toString().replaceAll('Exception: ', '');
        MotionToast.error(
          description: Text('فشل العملية: $cleanError'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 2),
          toastAlignment: Alignment.topCenter,
          displaySideBar: false,
        ).show(context);
      }
    }
  }

  void _editUser(Map<String, dynamic> user) {
    setState(() {
      _editingUserId = user['id'];
      _firstNameController.text = user['fName'] ?? '';
      _lastNameController.text = user['lName'] ?? '';
      _emailController.text = user['email'] ?? '';
      _phoneController.text = user['phoneNumber'] ?? '';
      _ageController.text = user['age']?.toString() ?? '';
      _selectedRole = user['role'] ?? 'DRIVER';
      _selectedFacilityId = user['facilityId'];
      _passwordController.clear();
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingUserId = null;
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _ageController.clear();
      _passwordController.clear();
      _selectedRole = 'DRIVER';
      _selectedFacilityId = null;
    });
  }

  void _deleteUser(int userId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المستخدم'),
        content: const Text(
          'هل أنت متأكد من حذف هذا المستخدم؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await UserService.deleteUser(userId);
                if (mounted) {
                  // Update local list immediately for instant UI response
                  setState(() {
                    _users.removeWhere((u) => u['id'] == userId);
                    _filterUsers();
                  });

                  MotionToast.success(
                    description: const Text('تم حذف المستخدم بنجاح'),
                    animationType: AnimationType.slideInFromTop,
                    toastDuration: const Duration(seconds: 2),
                    toastAlignment: Alignment.topCenter,
                    displaySideBar: false,
                  ).show(context);
                }
                // Refresh from server silently to sync up
                _loadUsers(silent: true);
              } catch (e) {
                if (mounted) {
                  final cleanError = e.toString().replaceAll('Exception: ', '');
                  MotionToast.error(
                    description: Text('فشل الحذف: $cleanError'),
                    animationType: AnimationType.slideInFromTop,
                    toastDuration: const Duration(seconds: 2),
                    toastAlignment: Alignment.topCenter,
                    displaySideBar: false,
                  ).show(context);
                  // Refresh list in case of partial failure
                  _loadUsers(silent: true);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
