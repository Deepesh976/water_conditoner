import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/keyboard_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../bloc/technician_profile_bloc.dart';

class TechnicianProfilePage extends StatefulWidget {
  final String technicianId;

  const TechnicianProfilePage({super.key, required this.technicianId});

  @override
  State<TechnicianProfilePage> createState() => _TechnicianProfilePageState();
}

class _TechnicianProfilePageState extends State<TechnicianProfilePage> {
  bool isEditing = false;
  bool isChanged = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final flatController = TextEditingController();
  final areaController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final postalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    flatController.dispose();
    areaController.dispose();
    districtController.dispose();
    stateController.dispose();
    postalController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    context.read<TechnicianProfileBloc>().add(LoadTechnicianProfileRequested(technicianId: widget.technicianId));
  }

  void onFieldChanged() {
    if (!isChanged) {
      setState(() {
        isChanged = true;
      });
    }
  }

  void _populateFields(Map<String, dynamic> data) {
    nameController.text = data["name"] ?? "";
    emailController.text = data["email"] ?? "";
    phoneController.text = data["phone"] ?? "";
    flatController.text = data["flatNo"] ?? "";
    areaController.text = data["area"] ?? "";
    districtController.text = data["district"] ?? "";
    stateController.text = data["state"] ?? "";
    postalController.text = data["postalCode"] ?? "";
  }

  void _saveProfile() {
    dismissKeyboard();
    context.read<TechnicianProfileBloc>().add(
          UpdateTechnicianProfileRequested(
            technicianId: widget.technicianId,
            profileData: {
              "name": nameController.text.trim(),
              "email": emailController.text.trim(),
              "phone": phoneController.text.trim(),
              "flatNo": flatController.text.trim(),
              "area": areaController.text.trim(),
              "district": districtController.text.trim(),
              "state": stateController.text.trim(),
              "postalCode": postalController.text.trim(),
            },
          ),
        );
  }

  void changePasswordDialog() {
    final newPass = TextEditingController();
    final confirmPass = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Change Password", style: TextStyle(fontSize: 18.sp)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            TextField(
              controller: confirmPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (newPass.text.trim().isEmpty || confirmPass.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields")),
                );
                return;
              }
              if (newPass.text != confirmPass.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Passwords do not match")),
                );
                return;
              }

              context.read<AuthBloc>().add(
                    ChangePasswordRequested(
                      userId: widget.technicianId,
                      newPassword: newPass.text.trim(),
                      confirmPassword: confirmPass.text.trim(),
                      role: "Technician",
                    ),
                  );
              Navigator.pop(ctx);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _logout() {
    context.read<AuthBloc>().add(const LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: MultiBlocListener(
        listeners: [
          BlocListener<TechnicianProfileBloc, TechnicianProfileState>(
            listener: (context, state) {
              if (state is TechnicianProfileUpdateSuccess) {
                setState(() {
                  isEditing = false;
                  isChanged = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile Updated ✅")),
                );
                _loadProfile();
              } else if (state is TechnicianProfileFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              } else if (state is AuthPasswordChangedSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Password Updated. Logging out... ✅")),
                );
                _logout();
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: AppColors.bgGrey,
          body: BlocBuilder<TechnicianProfileBloc, TechnicianProfileState>(
            builder: (context, state) {
              if (state is TechnicianProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              Map<String, dynamic> data = {};
              bool isAvailable = false;
              if (state is TechnicianProfileLoaded) {
                data = state.profileData;
                isAvailable = state.isAvailable;

                if (!isEditing && !isChanged) {
                  _populateFields(data);
                }
              }

              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 40.h),
                child: Column(
                  children: [
                    // Header Banner
                    Container(
                      height: 90.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.blueGradient,
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(30.r),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 20.w,
                            top: 15.h,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Profile",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "Manage your account",
                                  style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 16.w,
                            top: 25.h,
                            child: GestureDetector(
                              onTap: () {
                                if (isEditing) {
                                  _saveProfile();
                                } else {
                                  setState(() => isEditing = true);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isEditing ? Icons.check : Icons.edit,
                                  color: Colors.white,
                                  size: 20.r,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Availability Switch Container
                    Container(
                      margin: EdgeInsets.all(16.r),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Availability",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isAvailable ? "Available" : "Offline",
                                style: TextStyle(
                                  color: isAvailable ? AppColors.statusGreen : AppColors.statusRed,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isAvailable,
                            activeColor: AppColors.statusGreen,
                            inactiveThumbColor: AppColors.statusRed,
                            onChanged: (value) {
                              context.read<TechnicianProfileBloc>().add(
                                    ToggleAvailabilityRequested(
                                      technicianId: widget.technicianId,
                                      availability: value,
                                    ),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Profile Header card
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10.r),
                        ],
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40.r,
                            backgroundColor: AppColors.primaryBlue,
                            child: Text(
                              nameController.text.isNotEmpty ? nameController.text[0] : "T",
                              style: TextStyle(fontSize: 28.sp, color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          TextField(
                            controller: nameController,
                            enabled: isEditing,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(border: InputBorder.none),
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "ID: ${widget.technicianId}",
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Contact Info
                    buildSection("Contact Info", [
                      buildFieldItem(Icons.phone, "Phone", phoneController),
                      buildFieldItem(Icons.email, "Email", emailController),
                    ]),
                    SizedBox(height: 20.h),

                    // Address Info
                    buildSection("Address", [
                      buildFieldItem(Icons.home, "Flat No", flatController),
                      buildFieldItem(Icons.location_city, "Area", areaController),
                      buildFieldItem(Icons.map, "District", districtController),
                      buildFieldItem(Icons.public, "State", stateController),
                      buildFieldItem(Icons.pin_drop, "Postal Code", postalController),
                    ]),
                    SizedBox(height: 20.h),

                    // Change Password
                    ElevatedButton(
                      onPressed: changePasswordDialog,
                      child: const Text("Change Password"),
                    ),
                    SizedBox(height: 20.h),

                    // Logout
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusRed),
                          child: Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildSection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6.r),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          SizedBox(height: 10.h),
          ...children,
        ],
      ),
    );
  }

  Widget buildFieldItem(
    IconData icon,
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 24.r),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                    SizedBox(height: 4.h),
                    isEditing
                        ? TextField(
                            controller: controller,
                            onChanged: (_) => onFieldChanged(),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                            ),
                          )
                        : Text(
                            controller.text.isEmpty ? "Not Available" : controller.text,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }
}
