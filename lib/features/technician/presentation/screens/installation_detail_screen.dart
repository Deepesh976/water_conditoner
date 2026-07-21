import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import 'installation_work_screen.dart';

class InstallationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> job;

  const InstallationDetailScreen({
    super.key,
    required this.job,
  });

  Future<void> _openGoogleMaps(BuildContext context) async {
    final user = job["user"] ?? {};

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
        const SnackBar(content: Text("Address not available")),
      );
      return;
    }

    final Uri uri = Uri(
      scheme: "https",
      host: "www.google.com",
      path: "/maps/search/",
      queryParameters: {
        "api": "1",
        "query": address,
      },
    );

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to open Google Maps")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = job["user"] ?? {};

    final deviceId = job["deviceId"] ?? "N/A";

    final status = job["technicianStatus"] ?? "Pending";

    final customerName = user["name"] ?? "-";
    final phone = user["phone"] ?? "-";

    final fullAddress = [
      user["flatNo"],
      user["area"],
      user["district"],
      user["state"],
      user["postalCode"],
    ]
        .where((e) => e != null && e.toString().trim().isNotEmpty)
        .join(", ");

    final address = fullAddress.isNotEmpty
        ? fullAddress
        : (job["location"] ?? "Address not available");

    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: SafeArea(
        child: Column(
          children: [
            //-------------------------------------------------------
            // HEADER
            //-------------------------------------------------------

            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                16.w,
                20.h,
                16.w,
                30.h,
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
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24.r,
                      ),
                    ),
                  ),

                  Text(
                    "Installation Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                EdgeInsets.all(16.r),
                child: Column(
                  children: [

                    //-------------------------------------------------------
                    // DEVICE CARD
                    //-------------------------------------------------------

                    Container(
                      width: double.infinity,
                      padding:
                      EdgeInsets.all(18.r),
                      decoration:
                      BoxDecoration(
                        color:
                        AppColors.cardBg,
                        borderRadius:
                        BorderRadius.circular(
                            18.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(
                                0.05),
                            blurRadius: 10.r,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [

                          Text(
                            "Device Information",
                            style: TextStyle(
                              fontWeight:
                              FontWeight
                                  .bold,
                              fontSize: 16.sp,
                            ),
                          ),

                          SizedBox(height: 18.h),

                          buildTile(
                            Icons.memory,
                            "Device ID",
                            deviceId,
                          ),

                          SizedBox(height: 14.h),

                          buildTile(
                            Icons.verified,
                            "Status",
                            status,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 18.h),

                    //-------------------------------------------------------
                    // CUSTOMER CARD
                    //-------------------------------------------------------

                    Container(
                      width: double.infinity,
                      padding:
                      EdgeInsets.all(18.r),
                      decoration:
                      BoxDecoration(
                        color:
                        AppColors.cardBg,
                        borderRadius:
                        BorderRadius.circular(
                            18.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(
                                0.05),
                            blurRadius: 10.r,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [

                          Text(
                            "Customer Details",
                            style: TextStyle(
                              fontWeight:
                              FontWeight
                                  .bold,
                              fontSize: 16.sp,
                            ),
                          ),

                          SizedBox(height: 18.h),

                          buildTile(
                            Icons.person,
                            "Customer",
                            customerName,
                          ),

                          SizedBox(height: 14.h),

                          buildTile(
                            Icons.phone,
                            "Phone",
                            phone,
                          ),

                          SizedBox(height: 14.h),

                          buildTile(
                            Icons.location_on,
                            "Address",
                            address,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30.h),

                    //-------------------------------------------------------
                    // GOOGLE MAP
                    //-------------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.map,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Show on Google Maps",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.green,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                                14.r),
                          ),
                        ),
                        onPressed: () => _openGoogleMaps(context),
                      ),
                    ),

                    SizedBox(height: 14.h),

                    //-------------------------------------------------------
                    // REACHED LOCATION
                    //-------------------------------------------------------

                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: ElevatedButton(
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors.primaryBlue,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                                14.r),
                          ),
                        ),
                        onPressed: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  InstallationWorkScreen(
                                    job: job,
                                  ),
                            ),
                          );

                        },
                        child: Text(
                          "Reached Location",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
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

  Widget buildTile(
      IconData icon,
      String title,
      String value,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.grey,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                value,
                style: const TextStyle(
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}