import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../../domain/usecases/technician_usecases.dart';
import 'installation_upload_screen.dart';

class ConditionerSettingsScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const ConditionerSettingsScreen({
    Key? key,
    required this.job,
  }) : super(key: key);

  @override
  State<ConditionerSettingsScreen> createState() =>
      _ConditionerSettingsScreenState();
}

class _ConditionerSettingsScreenState
    extends State<ConditionerSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final SaveConditionerSettingsUsecase
  saveConditionerSettingsUsecase;

  final TextEditingController ch1MinController =
  TextEditingController();

  final TextEditingController ch1MaxController =
  TextEditingController();

  final TextEditingController ch2MinController =
  TextEditingController();

  final TextEditingController ch2MaxController =
  TextEditingController();

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    saveConditionerSettingsUsecase =
        di.sl<SaveConditionerSettingsUsecase>();
  }

  @override
  void dispose() {
    ch1MinController.dispose();
    ch1MaxController.dispose();
    ch2MinController.dispose();
    ch2MaxController.dispose();
    super.dispose();
  }

  Widget buildInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Required";
        }

        if (double.tryParse(value) == null) {
          return "Invalid value";
        }

        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: AppColors.primaryBlue,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildSectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget buildChannelCard({
    required String title,
    required TextEditingController minController,
    required TextEditingController maxController,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          buildSectionTitle(
            title,
            Icons.tune,
          ),

          SizedBox(height: 18.h),

          buildInput(
            label: "Minimum Current (A)",
            icon: Icons.arrow_downward,
            controller: minController,
          ),

          SizedBox(height: 16.h),

          buildInput(
            label: "Maximum Current (A)",
            icon: Icons.arrow_upward,
            controller: maxController,
          ),
        ],
      ),
    );
  }

  Future<void> saveSettings() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final ch1Min =
    double.parse(ch1MinController.text);

    final ch1Max =
    double.parse(ch1MaxController.text);

    final ch2Min =
    double.parse(ch2MinController.text);

    final ch2Max =
    double.parse(ch2MaxController.text);

    if (ch1Min >= ch1Max) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Channel 1 maximum current must be greater than minimum current.",
          ),
        ),
      );
      return;
    }

    if (ch2Min >= ch2Max) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Channel 2 maximum current must be greater than minimum current.",
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });    try {
      await saveConditionerSettingsUsecase.call(
        deviceId: widget.job["deviceId"],
        channel1Min: ch1Min,
        channel1Max: ch1Max,
        channel2Min: ch2Min,
        channel2Max: ch2Max,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InstallationUploadScreen(
            job: widget.job,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceId =
        widget.job["deviceId"] ?? "N/A";

    return Scaffold(
        backgroundColor: Colors.grey.shade100,

        body: SafeArea(
            child: Form(
                key: _formKey,

                child: Column(
                  children: [

                  /// ================= HEADER =================

                  Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    18.h,
                    20.w,
                    28.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xff1E88E5),
                        Color(0xff1565C0),
                      ],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30.r),
                    ),
                  ),

                  child: Row(
                    children: [

                      GestureDetector(
                        onTap: () => Navigator.pop(context),

                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(width: 18.w),

                      Text(
                        "Conditioner Settings",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 21.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(18.r),

                      child: Column(
                        children: [

                        /// ================= DEVICE CARD =================

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

                        child: Row(
                          children: [

                            CircleAvatar(
                              radius: 28.r,
                              backgroundColor:
                              Colors.blue.shade50,

                              child: Icon(
                                Icons.memory,
                                size: 30.r,
                                color: Colors.blue,
                              ),
                            ),

                            SizedBox(width: 16.w),

                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,

                              children: [

                                Text(
                                  "Device ID",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13.sp,
                                  ),
                                ),

                                SizedBox(height: 5.h),

                                Text(
                                  deviceId,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 22.h),

                      buildChannelCard(
                        title: "Channel 1",
                        minController: ch1MinController,
                        maxController: ch1MaxController,
                      ),

                      buildChannelCard(
                        title: "Channel 2",
                        minController: ch2MinController,
                        maxController: ch2MaxController,
                      ),                      /// ================= INFO CARD =================

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18.r),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius:
                          BorderRadius.circular(18.r),
                          border: Border.all(
                            color: Colors.blue.shade100,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 24.sp,
                            ),

                            SizedBox(width: 12.w),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [

                                  Text(
                                    "Conditioner Current Settings",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                    ),
                                  ),

                                  SizedBox(height: 8.h),

                                  Text(
                                    "Enter the minimum and maximum operating current measured during installation. These values will be used to calculate the Conditioner Service Status shown to the customer.",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13.sp,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 28.h),

                      Row(
                        children: [

                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isSaving
                                  ? null
                                  : () {

                                ch1MinController.clear();
                                ch1MaxController.clear();
                                ch2MinController.clear();
                                ch2MaxController.clear();

                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text("Reset"),

                              style: OutlinedButton.styleFrom(
                                minimumSize:
                                Size(double.infinity, 55.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(14.r),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(width: 14.w),

                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 55.h,
                              child: ElevatedButton.icon(
                                onPressed:
                                isSaving
                                    ? null
                                    : saveSettings,

                                icon: isSaving
                                    ? SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child:
                                  const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Icon(
                                  Icons.save_alt_rounded,
                                  color: Colors.white,
                                ),

                                label: Text(
                                  isSaving
                                      ? "Saving..."
                                      : "Save & Continue",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight:
                                    FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),

                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Colors.blue,
                                  elevation: 0,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        14.r),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                ),
                  ],
                ),
            ),
        ),
    );
  }
}