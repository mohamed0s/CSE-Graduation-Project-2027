import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auth', style: TextStyle(fontSize: 18.sp)),
      ),
      body: Center(
        child: Text('Auth Feature', style: TextStyle(fontSize: 24.sp)),
      ),
    );
  }
}
