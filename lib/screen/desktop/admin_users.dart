import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import '../../services/user_service.dart';

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
  final _facilityIdController = TextEditingController();

  String _selectedRole = 'DRIVER';
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  // For editing
  int? _editingUserId;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _facilityIdController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await UserService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        MotionToast.error(
          description: Text('فشل تحميل المستخدمين: ${e.toString()}'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 1),
          toastAlignment: Alignment.topCenter,
          displaySideBar: false,
        ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 24),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildUserForm()),
                SizedBox(width: 24),
                Expanded(flex: 2, child: _buildUsersList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.people, size: 32, color: Color(0xFF1A237E)),
        SizedBox(width: 12),
        Text(
          'إدارة المستخدمين',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
      ],
    );
  }

  Widget _buildUserForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _editingUserId == null ? 'إضافة مستخدم جديد' : 'تعديل المستخدم',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),

              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الأول',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الأخير',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: _editingUserId == null
                      ? 'كلمة المرور'
                      : 'كلمة المرور (اتركها فارغة للإبقاء)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'العمر',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.cake),
                ),
              ),
              SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'الدور',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.work),
                ),
                items: [
                  DropdownMenuItem(value: 'DRIVER', child: Text('سائق')),
                  DropdownMenuItem(value: 'SENDER', child: Text('مرسل')),
                  DropdownMenuItem(value: 'DISPATCHER', child: Text('موزع')),
                  DropdownMenuItem(value: 'ADMIN', child: Text('مدير')),
                ],
                onChanged: (value) => setState(() => _selectedRole = value!),
              ),
              SizedBox(height: 16),

              TextField(
                controller: _facilityIdController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'معرف المنشأة (اختياري)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitUser,
                      icon: _isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              _editingUserId == null ? Icons.add : Icons.save,
                            ),
                      label: Text(
                        _editingUserId == null
                            ? 'إضافة مستخدم'
                            : 'حفظ التعديلات',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  if (_editingUserId != null) ...[
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _cancelEdit,
                      child: Text('إلغاء'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        minimumSize: Size(80, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'قائمة المستخدمين',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Chip(
                  label: Text('${_users.length} مستخدم'),
                  backgroundColor: Color(0xFF1A237E),
                  labelStyle: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _loadUsers,
                  tooltip: 'تحديث',
                ),
              ],
            ),
            SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'لا يوجد مستخدمين',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: DataTable(
                        columns: [
                          DataColumn(
                            label: Text(
                              'الاسم',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'البريد',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'الهاتف',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'الدور',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'الإجراءات',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: _users.map((user) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text('${user['fName']} ${user['lName']}'),
                              ),
                              DataCell(Text(user['email'] ?? '')),
                              DataCell(Text(user['phoneNumber'] ?? '')),
                              DataCell(
                                Chip(
                                  label: Text(
                                    _getRoleDisplayName(user['role']),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  backgroundColor: _getRoleColor(user['role']),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _editUser(user),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _deleteUser(user['id']),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
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
    // Validation
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _ageController.text.isEmpty) {
      MotionToast.error(
        description: Text('يرجى ملء جميع الحقول المطلوبة'),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 1),
        toastAlignment: Alignment.topCenter,
        displaySideBar: false,
      ).show(context);
      return;
    }

    if (_editingUserId == null && _passwordController.text.isEmpty) {
      MotionToast.error(
        description: Text('كلمة المرور مطلوبة للمستخدمين الجدد'),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 1),
        toastAlignment: Alignment.topCenter,
        displaySideBar: false,
      ).show(context);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userData = {
        'fName': _firstNameController.text,
        'lName': _lastNameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'age': int.parse(_ageController.text),
        'role': _selectedRole,
      };

      // Add password only if provided
      if (_passwordController.text.isNotEmpty) {
        userData['password'] = _passwordController.text;
      }

      // Add facilityId if provided
      if (_facilityIdController.text.isNotEmpty) {
        userData['facilityId'] = int.parse(_facilityIdController.text);
      }

      if (_editingUserId == null) {
        // Create new user
        await UserService.createUser(userData);
        if (mounted) {
          MotionToast.success(
            description: Text('تم إضافة المستخدم بنجاح'),
            animationType: AnimationType.slideInFromTop,
            toastDuration: const Duration(seconds: 1),
            toastAlignment: Alignment.topCenter,
            displaySideBar: false,
          ).show(context);
        }
      } else {
        // Update existing user
        await UserService.updateUser(_editingUserId!, userData);
        if (mounted) {
          MotionToast.success(
            description: Text('تم تحديث المستخدم بنجاح'),
            animationType: AnimationType.slideInFromTop,
            toastDuration: const Duration(seconds: 1),
            toastAlignment: Alignment.topCenter,
            displaySideBar: false,
          ).show(context);
        }
      }

      _clearForm();
      await _loadUsers();
    } catch (e) {
      if (mounted) {
        MotionToast.error(
          description: Text('فشل حفظ المستخدم: ${e.toString()}'),
          animationType: AnimationType.slideInFromTop,
          toastDuration: const Duration(seconds: 1),
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

  void _editUser(Map<String, dynamic> user) {
    setState(() {
      _editingUserId = user['id'];
      _firstNameController.text = user['fName'] ?? '';
      _lastNameController.text = user['lName'] ?? '';
      _emailController.text = user['email'] ?? '';
      _phoneController.text = user['phoneNumber'] ?? '';
      _ageController.text = user['age']?.toString() ?? '';
      _selectedRole = user['role'] ?? 'DRIVER';
      _facilityIdController.text = user['facilityId']?.toString() ?? '';
      _passwordController.clear(); // Don't show existing password
    });
  }

  void _cancelEdit() {
    _clearForm();
  }

  void _clearForm() {
    setState(() {
      _editingUserId = null;
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _phoneController.clear();
      _ageController.clear();
      _facilityIdController.clear();
      _selectedRole = 'DRIVER';
    });
  }

  void _deleteUser(int userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف هذا المستخدم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await UserService.deleteUser(userId);
                if (mounted) {
                  MotionToast.success(
                    description: Text('تم حذف المستخدم بنجاح'),
                    animationType: AnimationType.slideInFromTop,
                    toastDuration: const Duration(seconds: 1),
                    toastAlignment: Alignment.topCenter,
                    displaySideBar: false,
                  ).show(context);
                }
                await _loadUsers();
              } catch (e) {
                if (mounted) {
                  MotionToast.error(
                    description: Text('فشل حذف المستخدم: ${e.toString()}'),
                    animationType: AnimationType.slideInFromTop,
                    toastDuration: const Duration(seconds: 1),
                    toastAlignment: Alignment.topCenter,
                    displaySideBar: false,
                  ).show(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }
}
