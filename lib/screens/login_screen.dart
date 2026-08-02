import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_dashboard.dart';
import 'admin_login_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // Hidden Admin Tap Counter
  int adminTapCount = 0;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> loginUser() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter email and password"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final user = await AuthService().login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
    });

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful"),
        ),
      );
final doc = await FirebaseFirestore.instance
    .collection("users")
    .doc(user.uid)
    .get();

print("UID: ${user.uid}");
print("Document Exists: ${doc.exists}");
print("Data: ${doc.data()}");

final data = doc.data();

if (data != null && data["role"] == "admin") {
  print("ADMIN LOGIN");

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const AdminDashboard(),
    ),
  );
} else {
  print("STUDENT LOGIN");

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const HomeScreen(),
    ),
  );
}
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid Email or Password"),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              const SizedBox(height: 40),

             GestureDetector(
  onTap: () {
    adminTapCount++;

    if (adminTapCount >= 5) {
      adminTapCount = 0;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminLoginScreen(),
        ),
      );
    }
  },
  child: const CircleAvatar(
    radius: 50,
    backgroundColor: Color(0xff1565C0),
    child: Icon(
      Icons.school,
      color: Colors.white,
      size: 55,
    ),
  ),
),

              const SizedBox(height: 20),

              const Text(
                "MMOC Teach",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Welcome Back 👋",
                style: TextStyle(fontSize: 22),
              ),

              const SizedBox(height: 35),

              CustomTextField(
                controller: emailController,
                hintText: "Email",
                icon: Icons.email,
              ),

              const SizedBox(height: 20),

              CustomTextField(
                controller: passwordController,
                hintText: "Password",
                icon: Icons.lock,
                obscureText: true,
              ),

              const SizedBox(height: 30),

              isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      text: "Login",
                      onPressed: loginUser,
                    ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Forgot Password feature coming soon."),
                    ),
                  );
                },
                child: const Text("Forgot Password?"),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(" Sign Up"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}