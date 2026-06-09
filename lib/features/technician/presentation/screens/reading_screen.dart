import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/keyboard_utils.dart';
import '../bloc/technician_service_bloc.dart';
import 'upload_proof_screen.dart';

class ReadingScreen extends StatefulWidget {
  final Map<String, dynamic> job;
  final bool isBefore;

  const ReadingScreen({super.key, required this.job, required this.isBefore});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  final TextEditingController ampController = TextEditingController();
  final TextEditingController voltController = TextEditingController();
  final TextEditingController flowController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final key = widget.isBefore ? "before" : "after";
    if (widget.job[key] != null) {
      ampController.text = widget.job[key]["ampere"] ?? "";
      voltController.text = widget.job[key]["voltage"] ?? "";
      flowController.text = widget.job[key]["flow"] ?? "";
    }
  }

  @override
  void dispose() {
    ampController.dispose();
    voltController.dispose();
    flowController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _saveReadings() {
    dismissKeyboard();
    if (ampController.text.trim().isEmpty ||
        voltController.text.trim().isEmpty ||
        flowController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all readings")),
      );
      return;
    }

    final now = DateTime.now().toIso8601String();
    final readings = {
      "ampere": ampController.text.trim(),
      "voltage": voltController.text.trim(),
      "flow": flowController.text.trim(),
      "dateTime": now,
    };

    if (widget.isBefore) {
      widget.job["beforeReading"] = readings;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReadingScreen(job: widget.job, isBefore: false),
        ),
      );
    } else {
      widget.job["afterReading"] = readings;
      widget.job["summary"] = descriptionController.text.trim();

      context.read<TechnicianServiceBloc>().add(
            SubmitReadingsRequested(
              jobId: widget.job["_id"],
              before: widget.job["beforeReading"],
              after: widget.job["afterReading"],
              summary: widget.job["summary"] ?? "",
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isBefore ? "Before Service Readings" : "After Service Readings";
    final deviceName = widget.job["device"]?["deviceId"] ?? "RO Device";
    final issue = widget.job["type"] ?? "No Issue";

    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        body: BlocConsumer<TechnicianServiceBloc, TechnicianServiceState>(
          listener: (context, state) {
            if (state is TechnicianServiceReadingsSaved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Readings Saved Successfully")),
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => UploadProofScreen(job: widget.job),
                ),
              );
            } else if (state is TechnicianServiceFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is TechnicianServiceLoading;

            return Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.blueGradient,
                          ),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(24.r),
                          ),
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Icon(Icons.arrow_back, color: Colors.white, size: 24.r),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Body inputs
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.all(16.r),
                          children: [
                            Text(
                              deviceName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Issue: $issue",
                              style: const TextStyle(color: AppColors.statusRed),
                            ),
                            SizedBox(height: 20.h),

                            // Input Card
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8.r,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  buildInput("Ampere", ampController),
                                  SizedBox(height: 12.h),
                                  buildInput("Voltage", voltController),
                                  SizedBox(height: 12.h),
                                  buildInput("Flow (L/Hr)", flowController),
                                  SizedBox(height: 12.h),
                                  if (!widget.isBefore)
                                    TextField(
                                      controller: descriptionController,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        labelText: "Service Comment",
                                        filled: true,
                                        fillColor: Colors.grey.shade100,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12.r),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30.h),

                            // Save Button
                            SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _saveReadings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  widget.isBefore ? "Save Initial Readings" : "Complete Service",
                                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

  Widget buildInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
