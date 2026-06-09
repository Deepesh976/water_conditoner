import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/keyboard_utils.dart';
import '../../../customer/presentation/screens/customer_main.dart';
import '../../../technician/presentation/screens/technician_main.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'change_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String selectedRole = "Customer";
  bool isPasswordVisible = false;

  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: AppColors.statusRed, size: 50.r),
                SizedBox(height: 15.h),
                Text(
                  "Login Failed",
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel"),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _submitLogin();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusBlue,
                        ),
                        child: const Text("Retry"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitLogin() {
    dismissKeyboard();
    if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter phone and password")),
      );
      return;
    }

    context.read<AuthBloc>().add(
          LoginRequested(
            phone: phoneController.text,
            password: passwordController.text,
            role: selectedRole,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              showErrorDialog(state.error);
            } else if (state is Authenticated) {
              final data = state.responseData;
              final isFirstLogin = data["isFirstLogin"] ?? false;
              final deviceId = data["device"] != null ? data["device"]["_id"] ?? "" : "";
              final userId = state.role == "Technician"
                  ? (data["technician"] != null ? data["technician"]["_id"] ?? "" : "")
                  : (data["user"] != null ? data["user"]["_id"] ?? "" : "");

              if (isFirstLogin) {
                final userName = state.role == "Technician"
                    ? (data["technician"]?["name"] ?? "")
                    : (data["user"]?["name"] ?? "");

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChangePasswordScreen(
                      userId: userId,
                      role: state.role,
                      userName: userName,
                      deviceId: deviceId,
                    ),
                  ),
                );
              } else {
                if (state.role == "Technician") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TechnicianMain(technicianId: userId),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerMain(
                        userName: data["user"]?["name"] ?? "",
                        deviceId: deviceId,
                        userId: userId,
                      ),
                    ),
                  );
                }
              }
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Stack(
              children: [
                // Background Gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.backgroundGradient,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),

                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.bgPath,
                    fit: BoxFit.cover,
                  ),
                ),

                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 40.h),
                        Image.asset(
                          AppAssets.logoPath,
                          height: 90.h,
                          width: 300.w,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          "WATER CONDITIONER",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        const Text(
                          "Pure Water. Better Life.",
                          style: TextStyle(color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 40.h),

                        // Login Card
                        Container(
                          margin: EdgeInsets.all(16.r),
                          padding: EdgeInsets.all(20.r),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20.r,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Welcome Back",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              const Text(
                                "Sign in to continue",
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                              SizedBox(height: 20.h),

                              // Role Selector
                              Row(
                                children: [
                                  Expanded(child: roleBox("Customer")),
                                  SizedBox(width: 10.w),
                                  Expanded(child: roleBox("Technician")),
                                ],
                              ),
                              SizedBox(height: 20.h),

                              // Phone Field
                              TextField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.phone),
                                  hintText: "Phone Number",
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              SizedBox(height: 15.h),

                              // Password Field
                              TextField(
                                controller: passwordController,
                                obscureText: !isPasswordVisible,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock),
                                  hintText: "Password",
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              SizedBox(height: 25.h),

                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 55.h,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _submitLogin,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: AppColors.blueGradient,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(14.r),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textWhite,
                                        ),
                                      ),
                                    ),
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
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget roleBox(String role) {
    final isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: AppColors.blueGradient,
                )
              : null,
          color: isSelected ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Center(
          child: Text(
            role,
            style: TextStyle(
              color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}
