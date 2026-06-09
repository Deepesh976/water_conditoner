import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/keyboard_utils.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../bloc/customer_profile_bloc.dart';

class CustomerProfilePage extends StatefulWidget {
  final String userId;
  final String deviceId;

  const CustomerProfilePage({
    super.key,
    required this.userId,
    required this.deviceId,
  });

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  bool isEditing = false;
  bool isChanged = false;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final flatController = TextEditingController();
  final areaController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final postalController = TextEditingController();

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    flatController.dispose();
    areaController.dispose();
    districtController.dispose();
    stateController.dispose();
    postalController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _loadProfile() {
    context.read<CustomerProfileBloc>().add(LoadProfileRequested(userId: widget.userId));
  }

  void onFieldChanged() {
    if (!isChanged) {
      setState(() {
        isChanged = true;
      });
    }
  }

  void cancelEdit(Map<String, dynamic> data) {
    setState(() {
      isEditing = false;
      isChanged = false;
    });
    _populateFields(data);
  }

  void _populateFields(Map<String, dynamic> data) {
    nameController.text = data["name"] ?? "";
    phoneController.text = data["phone"] ?? "";
    emailController.text = data["email"] ?? "";
    flatController.text = data["flatNo"] ?? "";
    areaController.text = data["area"] ?? "";
    districtController.text = data["district"] ?? "";
    stateController.text = data["state"] ?? "";
    postalController.text = data["postalCode"] ?? "";
  }

  void _saveProfileData() {
    dismissKeyboard();
    context.read<CustomerProfileBloc>().add(
          UpdateProfileRequested(
            userId: widget.userId,
            profileData: {
              "name": nameController.text.trim(),
              "phone": phoneController.text.trim(),
              "email": emailController.text.trim(),
              "flatNo": flatController.text.trim(),
              "area": areaController.text.trim(),
              "district": districtController.text.trim(),
              "state": stateController.text.trim(),
              "postalCode": postalController.text.trim(),
            },
          ),
        );
  }

  void _changePassword() {
    dismissKeyboard();
    if (newPasswordController.text.trim().isEmpty || confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    // Trigger password change through AuthBloc
    context.read<AuthBloc>().add(
          ChangePasswordRequested(
            userId: widget.userId,
            newPassword: newPasswordController.text.trim(),
            confirmPassword: confirmPasswordController.text.trim(),
            role: "Customer",
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
          BlocListener<CustomerProfileBloc, CustomerProfileState>(
            listener: (context, state) {
              if (state is CustomerProfileUpdateSuccess) {
                setState(() {
                  isEditing = false;
                  isChanged = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile updated successfully ✅")),
                );
                _loadProfile();
              } else if (state is CustomerProfileFailure) {
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
                  const SnackBar(content: Text("Password updated. Logging out... ✅")),
                );
                newPasswordController.clear();
                confirmPasswordController.clear();
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
          body: BlocBuilder<CustomerProfileBloc, CustomerProfileState>(
            builder: (context, state) {
              if (state is CustomerProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              Map<String, dynamic> data = {};
              if (state is CustomerProfileLoaded) {
                data = state.profileData;
                // Populate controllers if not editing
                if (!isEditing && !isChanged) {
                  _populateFields(data);
                }
              }

              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 40.h),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),

                    // Personal info container
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          sectionTitle("Personal Information"),
                          buildField("Full Name", nameController),
                          buildField("Phone Number", phoneController),
                          buildField("Email Address", emailController),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Address Info Container
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          sectionTitle("Address"),
                          buildField("Flat / House No", flatController),
                          buildField("Area / Street", areaController),
                          buildField("District", districtController),
                          buildField("State", stateController),
                          buildField("Postal Code", postalController),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Change Password Container
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          sectionTitle("Change Password"),
                          buildField(
                            "New Password",
                            newPasswordController,
                            isPassword: true,
                          ),
                          buildField(
                            "Confirm Password",
                            confirmPasswordController,
                            isPassword: true,
                          ),
                          SizedBox(height: 10.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _changePassword,
                              child: const Text("Update Password"),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Save / Cancel profile edits
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: !isEditing
                          ? SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    isEditing = true;
                                  });
                                },
                                child: const Text("Edit Profile"),
                              ),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => cancelEdit(data),
                                    child: const Text("Cancel"),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: isChanged ? _saveProfileData : null,
                                    child: const Text("Save"),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    SizedBox(height: 20.h),

                    // Logout Button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.statusRed,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            "Logout",
                            style: TextStyle(color: AppColors.textWhite, fontSize: 16.sp),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 80.h),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        enabled: isEditing || isPassword,
        onChanged: (_) => onFieldChanged(),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: isEditing || isPassword ? Colors.white : Colors.blue.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
