import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  Widget build(BuildContext context) {
    final status = job["status"] ?? "Pending";
    final statusColor = getStatusColor(status);

    final deviceName = job["device"]?["deviceId"] ?? "RO Device";
    final issue = job["type"] ?? "No Issue";
    final description = job["description"] ?? "No description";

    final user = job["user"] ?? {};
    final customerName = user["name"] ?? "Unknown";

    final fullAddress = [
      user["flatNo"],
      user["area"],
      user["district"],
      user["state"],
      user["postalCode"]
    ]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(", ");

    final location = fullAddress.isNotEmpty ? fullAddress : "Address not available";

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: SafeArea(
        child: Column(
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 30.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.blueGradient,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28.r),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 24.r),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "Service Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    // Main Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(18.r),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10.r,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                deviceName,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 14.h),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Issue: $issue",
                                style: TextStyle(
                                  color: AppColors.statusRed,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                "Description: $description",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 18.h),
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.grey, size: 20.r),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  customerName,
                                  style: TextStyle(fontSize: 15.sp),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on, color: Colors.grey, size: 20.r),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  location,
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Start Service Button
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                        child: Text(
                          "Start Service",
                          style: TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
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
