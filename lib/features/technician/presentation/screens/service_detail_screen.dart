import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import 'reading_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final Map<String, dynamic> job;

  const ServiceDetailScreen({
    super.key,
    required this.job,
  });

  Color getStatusColor(String status) {
    switch (status) {
      case "Accepted":
        return AppColors.statusGreen;
      case "Pending":
        return AppColors.statusOrange;
      case "In Progress":
        return AppColors.statusBlue;
      case "Completed":
        return AppColors.statusGreen;
      default:
        return AppColors.statusGrey;
    }
  }

  Future<void> _openGoogleMaps(BuildContext context) async {
    final user = job["user"] ?? {};

    // Use coordinates if available
    if (user["latitude"] != null && user["longitude"] != null) {
      final url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${user["latitude"]},${user["longitude"]}",
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        return;
      }
    }

    // Otherwise use address
    final address = [
      user["flatNo"],
      user["area"],
      user["district"],
      user["state"],
      user["postalCode"],
    ]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(", ");

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location not available"),
        ),
      );
      return;
    }

    final url = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Widget buildTile(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 22.r,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = job["status"] ?? "Pending";
    final statusColor = getStatusColor(status);

    final user = job["user"] ?? {};

    final customerName =
        user["name"] ?? "Unknown Customer";

    final phone =
        user["phone"] ?? "N/A";

    final deviceId =
        job["device"]?["deviceId"] ?? "N/A";

    final issue =
        job["type"] ?? "No Issue";

    final description =
        job["description"] ?? "-";

    final address = [
      user["flatNo"],
      user["area"],
      user["district"],
      user["state"],
      user["postalCode"],
    ]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(", ");

    return Scaffold(
        backgroundColor: AppColors.bgGrey,
        body: SafeArea(
            child: Column(
              children: [
              //================ HEADER =================

              Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                16.w,
                20.h,
                16.w,
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
                      onTap: () =>
                          Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24.r,
                      ),
                    ),
                  ),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Service Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        "Customer Service Request",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.sp,
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
                        children: [//================ DEVICE INFORMATION =================

                      Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10.r,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Device Information",
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 18.h),

                          buildTile(
                            Icons.memory_rounded,
                            "Device ID",
                            deviceId,
                          ),

                          SizedBox(height: 14.h),

                          buildTile(
                            Icons.build_circle_outlined,
                            "Issue Type",
                            issue,
                          ),

                          SizedBox(height: 14.h),

                          buildTile(
                            Icons.description_outlined,
                            "Description",
                            description,
                          ),

                          SizedBox(height: 14.h),

                          Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: statusColor,
                                size: 22.r,
                              ),

                              SizedBox(width: 12.w),

                              Text(
                                "Status",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12.sp,
                                ),
                              ),

                              const Spacer(),

                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(.12),
                                  borderRadius:
                                  BorderRadius.circular(30.r),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 18.h),

//================ CUSTOMER DETAILS =================

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10.r,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                        Text(
                        "Customer Details",
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 18.h),

                      buildTile(
                        Icons.person,
                        "Customer Name",
                        customerName,
                      ),

                      SizedBox(height: 14.h),

                      buildTile(
                        Icons.phone,
                        "Phone Number",
                        phone,
                      ),

                      SizedBox(height: 14.h),

                      buildTile(
                        Icons.location_on,
                        "Address",
                        address.isEmpty
                            ? "Address not available"
                            : address,
                      ),

                      SizedBox(height: 22.h),      //================ GOOGLE MAP BUTTON =================

                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton.icon(
                              onPressed: () => _openGoogleMaps(context),
                              icon: const Icon(
                                Icons.map_outlined,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Show on Google Maps",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(14.r),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 14.h),

                          //================ START SERVICE BUTTON =================

                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                job["status"] = "In Progress";

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReadingScreen(
                                      job: job,
                                      isBefore: true,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.location_searching,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Reached Location",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
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