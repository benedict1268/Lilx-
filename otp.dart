import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'users.dart'; // Users list screen after login
import 'package:fluttertoast/fluttertoast.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;

  OTPScreen({required this.verificationId});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController otpController = TextEditingController();

  void verifyOTP() async {
    String otp = otpController.text.trim();

    if (otp.isEmpty) {
      Fluttertoast.showToast(msg: "Enter OTP");
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

// ✅ Add user to Firestore if not exists
final user = FirebaseAuth.instance.currentUser;
final userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
userRef.set({
  'phone': user.phoneNumber,
}, SetOptions(merge: true));

Fluttertoast.showToast(msg: "Login Successful");

// Navigate to Users list
Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (context) => UsersScreen()),
);
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid OTP or error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter OTP')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: InputDecoration(labelText: 'OTP'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: verifyOTP,
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}