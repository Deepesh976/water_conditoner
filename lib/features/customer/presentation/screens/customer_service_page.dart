import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/keyboard_utils.dart';
import '../bloc/customer_service_bloc.dart';

class CustomerServicePage extends StatefulWidget {
  final String deviceId;
  final String userId;

  const CustomerServicePage({
    super.key,
    required this.deviceId,
    required this.userId,
  });

  @override
  State<CustomerServicePage> createState() => _CustomerServicePageState();
}

class _CustomerServicePageState extends State<CustomerServicePage> {
  File? image;
  final picker = ImagePicker();
  String issueType = "Power Issue";
  final descriptionController = TextEditingController();
  bool isCaptured = false;

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
  }

  Future<File> compressImage(File file) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path + "_compressed.jpg",
      quality: 50,
    );
    return File(result!.path);
  }

  Future<void> openCamera() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      final compressed = await compressImage(File(pickedFile.path));
      setState(() {
        image = compressed;
        isCaptured = true;
      });
    }
  }

  void _submitRequest() {
    dismissKeyboard();
    if (image == null || descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    context.read<CustomerServiceBloc>().add(
          SubmitComplaintRequested(
            userId: widget.userId,
            deviceId: widget.deviceId,
            description: descriptionController.text.trim(),
            issueType: issueType,
            imagePath: image!.path,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        body: BlocConsumer<CustomerServiceBloc, CustomerServiceState>(
          listener: (context, state) {
            if (state is CustomerServiceSuccess) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) {
                  return Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 28.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          Container(
                            width: 90.w,
                            height: 90.w,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 62.sp,
                            ),
                          ),

                          SizedBox(height: 24.h),

                          Text(
                            "Request Submitted",
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          SizedBox(height: 12.h),

                          Text(
                            "Your service request has been submitted successfully.\nOur technician will contact you shortly.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),

                          SizedBox(height: 28.h),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);

                                setState(() {
                                  image = null;
                                  isCaptured = false;
                                  issueType = "Power Issue";
                                  descriptionController.clear();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xFF1976D2),
                                padding: EdgeInsets.symmetric(vertical: 15.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              child: Text(
                                "Done",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is CustomerServiceFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is CustomerServiceLoading;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Column(
                    children: [
                      Text(
                        "Request Service",
                        style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20.h),

                      // Capture Button
                      GestureDetector(
                        onTap: openCamera,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, color: AppColors.textWhite, size: 20.r),
                              SizedBox(width: 10.w),
                              Text(
                                "Capture Issue",
                                style: TextStyle(color: AppColors.textWhite, fontSize: 16.sp),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Image Preview
                      if (image != null)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          height: 200.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.r),
                            image: DecorationImage(
                              image: FileImage(image!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      if (isCaptured) ...[
                        SizedBox(height: 20.h),

                        // Dropdown Selector
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: DropdownButtonFormField<String>(
                            value: issueType,
                            isExpanded: true,
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF4FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.report_problem_rounded,
                                color: Color(0xFF1976D2),
                              ),
                              labelText: "Issue Type",
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15.sp,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.r),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18.r),
                                borderSide: const BorderSide(
                                  color: Color(0xFF1976D2),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
                            ),
                            borderRadius: BorderRadius.circular(18.r),
                            dropdownColor: Colors.white,
                            elevation: 8,
                            items: [
                              DropdownMenuItem(
                                value: "Power Issue",
                                child: Row(
                                  children: [
                                    const SizedBox(width: 14),
                                    const Text(
                                      "Power Issue",
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Water Quality Issue",
                                child: Row(
                                  children: [
                                    const SizedBox(width: 14),
                                    const Text(
                                      "Water Quality Issue",
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Leakage Issue",
                                child: Row(
                                  children: [
                                    const SizedBox(width: 14),
                                    const Text(
                                      "Leakage Issue",
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                issueType = value!;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 15.h),

                        // Description TextField
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: TextField(
                            controller: descriptionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: "Describe the issue...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Submit Button
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20.w),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submitRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusGreen,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              "Submit Request",
                              style: TextStyle(fontSize: 16.sp, color: AppColors.textWhite),
                            ),
                          ),
                        ),
                      ],
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
}
