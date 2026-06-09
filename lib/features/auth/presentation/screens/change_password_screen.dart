import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/keyboard_utils.dart';
import '../../../customer/presentation/screens/customer_main.dart';
import '../../../technician/presentation/screens/technician_main.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String userId;
  final String role;
  final String userName;
  final String deviceId;

  const ChangePasswordScreen({
    super.key,
    required this.userId,
    required this.role,
    required this.userName,
    required this.deviceId,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  bool showNewPassword = false;
  bool showConfirmPassword = false;

  @override
  void dispose() {
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  void showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        title: const Text("Success"),
        content: const Text("Password Updated Successfully"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => widget.role == "Technician"
                      ? TechnicianMain(technicianId: widget.userId)
                      : CustomerMain(
                          userName: widget.userName,
                          deviceId: widget.deviceId,
                          userId: widget.userId,
                        ),
                ),
              );
            },
            child: const Text("Continue"),
          ),
        ],
      ),
    );
  }

  void _submitChangePassword() {
    dismissKeyboard();
    if (newPassController.text.isEmpty || confirmPassController.text.isEmpty) {
      showError("Please fill all fields");
      return;
    }

    if (newPassController.text != confirmPassController.text) {
      showError("Passwords do not match");
      return;
    }

    context.read<AuthBloc>().add(
          ChangePasswordRequested(
            userId: widget.userId,
            newPassword: newPassController.text,
            confirmPassword: confirmPassController.text,
            role: widget.role,
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
              showError(state.error);
            } else if (state is AuthPasswordChangedSuccess) {
              showSuccess();
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          children: [
                            SizedBox(height: 30.h),
                            Container(
                              padding: EdgeInsets.all(18.r),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: AppColors.blueGradient,
                                ),
                              ),
                              child: Icon(
                                Icons.lock,
                                size: 40.r,
                                color: AppColors.textWhite,
                              ),
                            ),
                            SizedBox(height: 15.h),
                            Text(
                              "Change Password",
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 5.h),
                            const Text(
                              "Secure your account",
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                            SizedBox(height: 30.h),
                            Container(
                              padding: EdgeInsets.all(20.r),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 15.r,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // New Password Field
                                  TextField(
                                    controller: newPassController,
                                    obscureText: !showNewPassword,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.lock),
                                      hintText: "New Password",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          showNewPassword ? Icons.visibility : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            showNewPassword = !showNewPassword;
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
                                  SizedBox(height: 15.h),

                                  // Confirm Password Field
                                  TextField(
                                    controller: confirmPassController,
                                    obscureText: !showConfirmPassword,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      hintText: "Confirm Password",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            showConfirmPassword = !showConfirmPassword;
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

                                  // Submit Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 55.h,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _submitChangePassword,
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
                                          child: isLoading
                                              ? const CircularProgressIndicator(
                                                  color: AppColors.textWhite,
                                                )
                                              : Text(
                                                  "UPDATE PASSWORD",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.sp,
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
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
