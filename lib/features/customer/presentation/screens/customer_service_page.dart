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
  String issueType = "Low Pressure";
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
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  title: const Text("Success"),
                  content: const Text("Service request submitted"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          image = null;
                          isCaptured = false;
                          descriptionController.clear();
                        });
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
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
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: DropdownButton<String>(
                            value: issueType,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                value: "Low Pressure",
                                child: Text("Low Pressure"),
                              ),
                              DropdownMenuItem(
                                value: "Leakage",
                                child: Text("Leakage"),
                              ),
                              DropdownMenuItem(
                                value: "No Water",
                                child: Text("No Water"),
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
