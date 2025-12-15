import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart'; // تأكد من استيراد المكتبة
import 'package:path_aid/components.dart';

class Logindesktop extends StatefulWidget {
  const Logindesktop({super.key});

  @override
  State<Logindesktop> createState() => _LogindesktopState();
}

class _LogindesktopState extends State<Logindesktop> {
  // تم تصحيح اسم المتغير ليكون متسقًا
  String username = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/backgroundIMG_login.png"),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            // إضافة SingleChildScrollView لمنع تجاوز الشاشة
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 100),
                  child: Column(
                    children: [
                      Image.asset("assets/Logo.png", width: 300),
                      SansBold(text: "PathAid", size: 60),
                      Sans(
                        text: "هنا نظام لادارة عمليات النقل بواسطة الاسعاف",
                        size: 20,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(40.0), // زيادة الهوامش الداخلية
                  width: 500, // تصغير العرض لشكل أفضل
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          0.2,
                        ), // تقليل قتامة الظل
                        offset: Offset(0, 5), // تعديل اتجاه الظل
                        blurRadius: 10.0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Input(
                        label: "Username",
                        hint: "Username",
                        maxLine: 1,
                        onChanged: (value) {
                          setState(() {
                            username = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      Input(
                        label: "Password",
                        hint: "Password",
                        maxLine: 1,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                      ),
                      SizedBox(height: 30),
                      MaterialButton(
                        onPressed: () {
                          // استخدام المتغير المصحح
                          if (username == "Doctor" && password == "Doctor") {
                            Navigator.pushNamed(context, '/doctor');
                          } else if (username == "Driver" &&
                              password == "Driver") {
                            Navigator.pushNamed(context, '/driver');
                          } else if (username == "Dis" && password == "Dis") {
                            Navigator.pushNamed(context, '/dispatcher');
                          } else if (username == "Admin" &&
                              password == "Admin") {
                            Navigator.pushNamed(context, '/admin');
                          } else {
                            MotionToast.error(
                              title: Text("خطأ في تسجيل الدخول"),
                              description: Text(
                                'اسم المستخدم أو كلمة المرور غير صحيحة',
                                style: TextStyle(color: Colors.white),
                              ),
                              animationType: AnimationType.slideInFromTop,
                              toastDuration: const Duration(seconds: 1),
                              toastAlignment: Alignment.topCenter,
                              displaySideBar: false,
                            ).show(context);
                          }
                        },
                        color: const Color.fromARGB(255, 98, 247, 235),
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
