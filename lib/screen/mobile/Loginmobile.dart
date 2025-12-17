import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

class Loginmobile extends StatefulWidget {
  const Loginmobile({super.key});

  @override
  State<Loginmobile> createState() => _LoginmobileState();
}

class _LoginmobileState extends State<Loginmobile> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(
                width: 150,
                height: 150,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 2,
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Image.asset("assets/Logo.png", fit: BoxFit.cover),
              ),
              const SizedBox(height: 25),
              const Text(
                "PathAid",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "نظام نقل المرضى المتكامل",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF757575),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 50),
              Align(
                alignment: Alignment.centerRight,
                child: const Text(
                  "اسم المستخدم",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: "اسم المستخدم أو البريد الإلكتروني",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  hintTextDirection: TextDirection.rtl,
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1E60F7)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: const Text(
                  "كلمة المرور",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: "أدخل كلمة المرور",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  hintTextDirection: TextDirection.rtl,
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  prefixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1E60F7)),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    "نسيت كلمة المرور؟",
                    style: TextStyle(
                      color: Color(0xFF1E60F7),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E60F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: const Color(0x401E60F7),
                  ),
                  child: const Text(
                    "تسجيل الدخول",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "ليس لديك حساب؟",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "اتصل بالإدارة",
                        style: TextStyle(
                          color: Color(0xFF1E60F7),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username == "Doctor" && password == "Doctor") {
      Navigator.pushNamed(context, '/doctor');
    } else if (username == "Driver" && password == "Driver") {
      Navigator.pushNamed(context, '/driver');
    } else if (username == "Dis" && password == "Dis") {
      Navigator.pushNamed(context, '/dispatcher');
    } else if (username == "Admin" && password == "Admin") {
      Navigator.pushNamed(context, '/admin');
    } else {
      MotionToast.error(
        description: const Text(
          'اسم المستخدم أو كلمة المرور غير صحيحة',
          style: TextStyle(color: Colors.white),
        ),
        animationType: AnimationType.slideInFromTop,
        toastDuration: const Duration(seconds: 1),
        toastAlignment: Alignment.topCenter,

        width: 300,
        height: 50,
        dismissable: true,
        displaySideBar: false,
      ).show(context);
    }
  }
}
