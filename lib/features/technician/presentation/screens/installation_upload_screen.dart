import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/technician_service_bloc.dart';

class InstallationUploadScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const InstallationUploadScreen({
    super.key,
    required this.job,
  });

  @override
  State<InstallationUploadScreen> createState() =>
      _InstallationUploadScreenState();
}

class _InstallationUploadScreenState
    extends State<InstallationUploadScreen> {

  File? installationImage;

  final ImagePicker picker = ImagePicker();

  Future<File> compressImage(File file) async {
    final result =
    await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      "${file.absolute.path}_compressed.jpg",
      quality: 50,
    );

    return File(result!.path);
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (picked != null) {
      final compressed =
      await compressImage(File(picked.path));

      setState(() {
        installationImage = compressed;
      });
    }
  }

  void submitInstallation() {
    if (installationImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please capture installation image"),
        ),
      );
      return;
    }

    final reading =
        widget.job["installationReading"] ?? {};

    final comment =
        widget.job["installationComment"] ?? "";

    context.read<TechnicianServiceBloc>().add(
      CompleteInstallationRequested(
        deviceId: widget.job["_id"],
        imagePath: installationImage!.path,
        ampere:
        reading["ampere"]?.toString() ?? "",
        voltage:
        reading["voltage"]?.toString() ?? "",
        flowRate:
        reading["flowRate"]?.toString() ?? "",
        comment: comment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final deviceId =
        widget.job["deviceId"] ?? "N/A";

    return BlocConsumer<
        TechnicianServiceBloc,
        TechnicianServiceState>(
        listener: (context, state) {

          if (state is InstallationCompleted) {

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Installation Completed Successfully",
                ),
              ),
            );

            Navigator.popUntil(
              context,
                  (route) => route.isFirst,
            );
          }

          if (state is TechnicianServiceFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
              ),
            );
          }
        },

        builder: (context, state) {

          final loading =
          state is TechnicianServiceLoading;

          return Scaffold(
        backgroundColor: AppColors.bgGrey,

        body: SafeArea(
            child: Column(
              children: [

              /// ================= HEADER =================

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
                            "Installation Proof",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
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
                            AppColors.primaryBlue.withOpacity(.1),
                            child: Icon(
                              Icons.devices,
                              color: AppColors.primaryBlue,
                              size: 28.r,
                            ),
                          ),

                          SizedBox(width: 15.w),

                          Expanded(
                            child: Column(
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

                                SizedBox(height: 4.h),

                                Text(
                                  deviceId,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 20.h),

                  /// ================= IMAGE CARD =================

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
                              Icons.camera_alt,
                              color: AppColors.primaryBlue,
                            ),

                            SizedBox(width: 8.w),

                            Text(
                              "Installation Photo",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 18.h),

                        GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            height: 230.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius:
                              BorderRadius.circular(16.r),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),

                            child: installationImage == null

                                ? Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [

                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: 65.r,
                                  color: Colors.grey,
                                ),

                                SizedBox(height: 15.h),

                                Text(
                                  "Tap to Capture Image",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 8.h),

                                Padding(
                                  padding:
                                  EdgeInsets.symmetric(
                                      horizontal: 20.w),
                                  child: Text(
                                    "Capture a clear photo of the installed water conditioner.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ],
                            )

                                : ClipRRect(
                              borderRadius:
                              BorderRadius.circular(16.r),
                              child: Image.file(
                                installationImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ),

                        if (installationImage != null) ...[

                          SizedBox(height: 18.h),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius:
                              BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.green.shade300,
                              ),
                            ),
                            child: Row(
                              children: [

                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),

                                SizedBox(width: 10.w),

                                Expanded(
                                  child: loading
                                      ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : Text(
                                    "Installation image captured successfully.",
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h),
                          /// ================= COMPLETE BUTTON =================

                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton.icon(
                              onPressed: loading
                                  ? null
                                  : submitInstallation,
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Complete Installation",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.statusGreen,
                                elevation: 2,
                                shadowColor:
                                AppColors.statusGreen.withOpacity(.35),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(16.r),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 25.h),
                        ],
                    ),
                ),
            ),
              ],
            ),
        ),
          );
        },
    );
  }
}