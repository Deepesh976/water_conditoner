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
// import 'reports_details_screen.dart';
import 'customer_reports_screen.dart';

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
  //==========================================================
  // PROFILE
  //==========================================================

  bool isEditing = false;
  bool isChanged = false;

  //==========================================================
  // PASSWORD
  //==========================================================

  bool hideNewPassword = true;
  bool hideConfirmPassword = true;

  bool passwordsMatch = false;
  bool showPasswordValidation = false;

  //==========================================================
  // CONTROLLERS
  //==========================================================

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

  //==========================================================
  // INIT
  //==========================================================

  @override
  void initState() {
    super.initState();

    _loadProfile();

    newPasswordController.addListener(_validatePasswords);
    confirmPasswordController.addListener(_validatePasswords);
  }

  //==========================================================
  // PASSWORD VALIDATION
  //==========================================================

  void _validatePasswords() {
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    setState(() {
      showPasswordValidation =
          newPass.isNotEmpty && confirmPass.isNotEmpty;

      passwordsMatch =
          showPasswordValidation &&
              newPass == confirmPass;
    });
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
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SizedBox(height: 20.h),

                    // Personal info container
                    _buildPersonalInformationCard(data),

                    SizedBox(height: 16.h),

                    _buildAddressCard(data),

                    SizedBox(height: 16.h),

                    _buildReportsCard(),

                    SizedBox(height: 16.h),

                    // Change Password Container
                    _buildChangePasswordCard(),

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
                    SizedBox(height: 12.h),
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
  Widget _buildPersonalInformationCard(
      Map<String, dynamic> data,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [

          //----------------------------------------------------
          // HEADER
          //----------------------------------------------------

          Row(
            children: [

              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: const Color(0xffEEF5FF),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.primaryBlue,
                  size: 22.sp,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Text(
                  "Personal Information",
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              SizedBox(
                height: 34.h,
                child: OutlinedButton.icon(

                  onPressed: () {

                    setState(() {

                      isEditing = !isEditing;

                      if (!isEditing) {
                        cancelEdit(data);
                      }

                    });

                  },

                  style: OutlinedButton.styleFrom(

                    foregroundColor: AppColors.primaryBlue,

                    side: BorderSide(
                      color: AppColors.primaryBlue,
                      width: 1.2,
                    ),

                    backgroundColor: Colors.white,

                    elevation: 0,

                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(8.r),
                    ),
                  ),

                  icon: Icon(
                    isEditing
                        ? Icons.close_rounded
                        : Icons.edit_outlined,
                    size: 16.sp,
                  ),

                  label: Text(
                    isEditing
                        ? "Cancel"
                        : "Edit",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

            ],
          ),

          SizedBox(height: 20.h),

          buildProfileTile(
            icon: Icons.person,
            title: "Full Name",
            controller: nameController,
          ),

          Divider(
            color: Colors.grey.shade200,
            height: 28.h,
          ),

          buildProfileTile(
            icon: Icons.phone,
            title: "Phone Number",
            controller: phoneController,
            editable: false,
          ),

          Divider(
            color: Colors.grey.shade200,
            height: 28.h,
          ),

          buildProfileTile(
            icon: Icons.email,
            title: "Email Address",
            controller: emailController,
            editable: false,
          ),

          if (isEditing)

            Padding(
              padding: EdgeInsets.only(top: 22.h),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: isChanged
                      ? _saveProfileData
                      : null,
                  child: const Text(
                    "Save Changes",
                  ),
                ),
              ),
            ),

        ],
      ),
    );
  }

  Widget _buildAddressCard(
      Map<String, dynamic> data,
      ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [

          buildSectionHeader(

            icon: Icons.location_on,

            title: "Address",

            editing: isEditing,

            onPressed: () {

              setState(() {

                isEditing = !isEditing;

                if (!isEditing) {
                  cancelEdit(data);
                }

              });

            },

          ),

          SizedBox(height: 20.h),

          buildProfileTile(
            icon: Icons.home_outlined,
            title: "Flat / House No",
            controller: flatController,
          ),

          Divider(
            color: Colors.grey.shade200,
            height: 28.h,
          ),

          buildProfileTile(
            icon: Icons.location_city,
            title: "Area / Street",
            controller: areaController,
          ),

          Divider(
            color: Colors.grey.shade200,
            height: 28.h,
          ),

          buildProfileTile(
            icon: Icons.map_outlined,
            title: "District",
            controller: districtController,
          ),

          Divider(
            color: Colors.grey.shade200,
            height: 28.h,
          ),

          buildProfileTile(
            icon: Icons.public,
            title: "State",
            controller: stateController,
          ),

          Divider(
            color: Colors.grey.shade200,
            height: 28.h,
          ),

          buildProfileTile(
            icon: Icons.markunread_mailbox_outlined,
            title: "Postal Code",
            controller: postalController,
          ),

          if (isEditing)

            Padding(
              padding: EdgeInsets.only(top: 22.h),
              child: SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed:
                  isChanged
                      ? _saveProfileData
                      : null,
                  child: const Text(
                    "Save Address",
                  ),
                ),
              ),
            ),

        ],
      ),
    );
  }

  Widget _buildReportsCard() {

    return InkWell(

      borderRadius: BorderRadius.circular(18.r),

      onTap: () {

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (_) => CustomerReportsScreen(

              userId: widget.userId,

            ),

          ),

        );

      },

      child: Container(

        margin: EdgeInsets.symmetric(horizontal: 16.w),

        padding: EdgeInsets.symmetric(
          horizontal: 18.w,
          vertical: 16.h,
        ),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(18.r),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withOpacity(.05),

              blurRadius: 12,

              offset: const Offset(0,4),

            ),

          ],

        ),

        child: Row(

          children: [

            Container(

              width: 44.w,

              height: 44.w,

              decoration: BoxDecoration(

                color: Colors.purple.shade50,

                borderRadius:
                BorderRadius.circular(12.r),

              ),

              child: Icon(

                Icons.description_outlined,

                color: Colors.purple,

                size: 22.sp,

              ),

            ),

            SizedBox(width: 14.w),

            Expanded(

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(

                    "Reports",

                    style: TextStyle(

                      fontSize: 16.sp,

                      fontWeight: FontWeight.w700,

                    ),

                  ),

                  SizedBox(height: 3.h),

                  Text(

                    "View Daily Device Reports",

                    style: TextStyle(

                      fontSize: 12.sp,

                      color: Colors.grey.shade600,

                    ),

                  ),

                ],

              ),

            ),

            Icon(

              Icons.chevron_right_rounded,

              size: 28.sp,

              color: Colors.grey,

            ),

          ],

        ),

      ),

    );

  }

  Widget _buildChangePasswordCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [

          Row(
            children: [

              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: Colors.green,
                  size: 22.sp,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    Text(
                      "Update your account password",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),

                  ],
                ),
              ),

            ],
          ),

          SizedBox(height: 20.h),

          TextField(
            controller: newPasswordController,
            obscureText: hideNewPassword,

            decoration: InputDecoration(

              prefixIcon: const Icon(Icons.lock_outline),

              hintText: "New Password",

              suffixIcon: IconButton(

                icon: Icon(

                  hideNewPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,

                ),

                onPressed: () {

                  setState(() {

                    hideNewPassword =
                    !hideNewPassword;

                  });

                },

              ),

              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(14.r),
              ),

            ),
          ),

          SizedBox(height: 14.h),

          TextField(
            controller: confirmPasswordController,

            obscureText: hideConfirmPassword,

            decoration: InputDecoration(

              prefixIcon: const Icon(Icons.lock_outline),

              hintText: "Confirm Password",

              suffixIcon: IconButton(

                icon: Icon(

                  hideConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,

                ),

                onPressed: () {

                  setState(() {

                    hideConfirmPassword =
                    !hideConfirmPassword;

                  });

                },

              ),

              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(14.r),
              ),

            ),
          ),

          SizedBox(height: 10.h),

          AnimatedSwitcher(

            duration: const Duration(milliseconds: 250),

            child: !showPasswordValidation

                ? const SizedBox()

                : Row(

              key: ValueKey(passwordsMatch),

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                Icon(

                  passwordsMatch
                      ? Icons.check_circle
                      : Icons.cancel,

                  size: 18,

                  color: passwordsMatch
                      ? Colors.green
                      : Colors.red,

                ),

                SizedBox(width: 6.w),

                Text(

                  passwordsMatch
                      ? "Passwords Match"
                      : "Passwords Do Not Match",

                  style: TextStyle(

                    color: passwordsMatch
                        ? Colors.green
                        : Colors.red,

                    fontWeight: FontWeight.w600,

                  ),

                ),

              ],

            ),

          ),
          SizedBox(height: 20.h),

          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14.r),
                ),
              ),
              child: const Text(
                "Update Password",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget buildSectionHeader({
    required IconData icon,
    required String title,
    required bool editing,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [

        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: const Color(0xffEEF5FF),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 22.sp,
          ),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),

        SizedBox(
          height: 34.h,
          child: OutlinedButton.icon(
            onPressed: onPressed,

            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: BorderSide(
                color: AppColors.primaryBlue,
                width: 1.2,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 12.w,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(8.r),
              ),
            ),

            icon: Icon(
              editing
                  ? Icons.close_rounded
                  : Icons.edit_outlined,
              size: 16.sp,
            ),

            label: Text(
              editing
                  ? "Cancel"
                  : "Edit",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

      ],
    );
  }

  Widget buildProfileTile({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    bool editable = true,
  }) {
    final bool canEdit = editable && isEditing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //------------------------------------------------
        // ICON
        //------------------------------------------------

        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(
            icon,
            color: AppColors.primaryBlue,
            size: 20.sp,
          ),
        ),

        SizedBox(width: 14.w),

        //------------------------------------------------
        // TEXT
        //------------------------------------------------

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 10.sp,
                  letterSpacing: 0.8,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 8.h),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),

                child: canEdit
                    ? TextField(
                  key: ValueKey(title),

                  controller: controller,

                  onChanged: (_) => onFieldChanged(),

                  decoration: InputDecoration(
                    isDense: true,

                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 15.h,
                    ),

                    filled: true,
                    fillColor: const Color(0xffFAFBFD),

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14.r),
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14.r),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14.r),
                      borderSide: BorderSide(
                        color: AppColors.primaryBlue,
                        width: 2,
                      ),
                    ),
                  ),
                )
                    : Padding(
                  key: ValueKey("${title}_text"),
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    controller.text.isEmpty
                        ? "-"
                        : controller.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff202124),
                      height: 1.35,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ],
    );
  }
}