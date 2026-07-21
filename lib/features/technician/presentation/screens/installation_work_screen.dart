import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import 'installation_upload_screen.dart';

class InstallationWorkScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const InstallationWorkScreen({
    super.key,
    required this.job,
  });

  @override
  State<InstallationWorkScreen> createState() =>
      _InstallationWorkScreenState();
}

class _InstallationWorkScreenState
    extends State<InstallationWorkScreen> {
  final TextEditingController ampController =
  TextEditingController();

  final TextEditingController voltageController =
  TextEditingController();

  final TextEditingController flowController =
  TextEditingController();

  final TextEditingController commentController =
  TextEditingController();

  @override
  void dispose() {
    ampController.dispose();
    voltageController.dispose();
    flowController.dispose();
    commentController.dispose();
    super.dispose();
  }

  void _next() {
    if (ampController.text.trim().isEmpty ||
        voltageController.text.trim().isEmpty ||
        flowController.text.trim().isEmpty ||
        commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    widget.job["installationReading"] = {
      "ampere": ampController.text.trim(),
      "voltage": voltageController.text.trim(),
      "flowRate": flowController.text.trim(),
    };

    widget.job["installationComment"] =
        commentController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InstallationUploadScreen(
          job: widget.job,
        ),
      ),
    );
  }

  Widget buildInput(
      String label,
      IconData icon,
      TextEditingController controller,
      ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: AppColors.primaryBlue,
        ),
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 14.sp,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(
          vertical: 18.h,
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceId =
        widget.job["deviceId"] ?? "N/A";

    return Scaffold(
        backgroundColor: AppColors.bgGrey,
        body: SafeArea(
            child: Column(
              children: [

              /// HEADER
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    18.w,
                    18.h,
                    18.w,
                    28.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.blueGradient,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28.r),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Installation Work",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

            Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [

                    /// DEVICE CARD
                    Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(18.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                          18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28.r,
                          backgroundColor:
                          AppColors.primaryBlue
                              .withOpacity(.1),
                          child: Icon(
                            Icons.devices,
                            color:
                            AppColors.primaryBlue,
                            size: 28.r,
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              "Device ID",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              deviceId,
                              style: TextStyle(
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 18.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// READING CARD
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(18.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(
                          18.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                    Row(
                    children: [
                    Icon(
                    Icons.analytics,
                      color:
                      AppColors.primaryBlue,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      "Installation Reading",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  buildInput(
                    "Voltage",
                    Icons.flash_on,
                    voltageController,
                  ),

                  SizedBox(height: 15.h),

                  buildInput(
                    "Ampere",
                    Icons.electrical_services,
                    ampController,
                  ),

                  SizedBox(height: 15.h),

                  buildInput(
                    "Flow Rate (L/Hr)",
                    Icons.water_drop,
                    flowController,
                  ),

                  SizedBox(height: 20.h),
                        /// COMMENT CARD
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(18.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit_note,
                                    color: AppColors.primaryBlue,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "Technician Comment",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 16.h),

                              TextField(
                                controller: commentController,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  hintText:
                                  "Enter installation remarks...",
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(14.r),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30.h),

                        /// CONTINUE BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 55.h,
                          child: ElevatedButton.icon(
                            onPressed: _next,
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                            label: Text(
                              "Continue",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              AppColors.primaryBlue,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(14.r),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                    ],
                  ),
                ),
            ),
              ],
            ),
        ),
    );
  }
}