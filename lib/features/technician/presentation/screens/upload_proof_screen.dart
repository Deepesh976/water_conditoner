import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/technician_service_bloc.dart';

class UploadProofScreen extends StatefulWidget {
  final Map job;

  const UploadProofScreen({super.key, required this.job});

  @override
  State<UploadProofScreen> createState() => _UploadProofScreenState();
}

class _UploadProofScreenState extends State<UploadProofScreen> {
  File? deviceImage;
  File? selfieImage;
  final ImagePicker picker = ImagePicker();

  Future<File> compressImage(File file) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path + "_compressed.jpg",
      quality: 50,
    );
    return File(result!.path);
  }

  Future<void> pickImage(bool isDevice) async {
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (picked != null) {
      final compressed = await compressImage(File(picked.path));
      setState(() {
        if (isDevice) {
          deviceImage = compressed;
        } else {
          selfieImage = compressed;
        }
      });
    }
  }

  void _submitService() {
    if (deviceImage == null || selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload both images")),
      );
      return;
    }

    final deviceId = widget.job["device"]?["_id"] ?? widget.job["device"];

    context.read<TechnicianServiceBloc>().add(
          UploadProofRequested(
            jobId: widget.job["_id"],
            deviceImagePath: deviceImage!.path,
            selfieImagePath: selfieImage!.path,
            deviceId: deviceId,
            before: widget.job["beforeReading"],
            after: widget.job["afterReading"],
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: BlocConsumer<TechnicianServiceBloc, TechnicianServiceState>(
        listener: (context, state) {
          if (state is TechnicianServiceProofUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ Service Completed")),
            );
            Navigator.popUntil(context, (route) => route.isFirst);
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
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.blueGradient,
                        ),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "Upload Proof",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(16.r),
                        children: [
                          buildImageCard(
                            title: "Device Image",
                            image: deviceImage,
                            onTap: () => pickImage(true),
                          ),
                          SizedBox(height: 20.h),
                          buildImageCard(
                            title: "Technician Selfie",
                            image: selfieImage,
                            onTap: () => pickImage(false),
                          ),
                          SizedBox(height: 30.h),
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submitService,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.statusGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                "Submit Service",
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
    );
  }

  Widget buildImageCard({
    required String title,
    required File? image,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8.r),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
              IconButton(
                onPressed: onTap,
                icon: Icon(Icons.camera_alt, color: AppColors.primaryBlue, size: 24.r),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: onTap, // 🔥 THIS IS THE MAGIC
            child: Container(
              height: 150.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: image != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(image, fit: BoxFit.cover),
              )
                  : const Center(child: Text("No Image Selected")),
            ),
          ),
        ],
      ),
    );
  }
}
