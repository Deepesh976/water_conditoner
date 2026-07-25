import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../bloc/customer_report_bloc.dart';

class ReportDetailsScreen extends StatefulWidget {
  final String userId;
  final String reportDate;

  const ReportDetailsScreen({
    super.key,
    required this.userId,
    required this.reportDate,
  });

  @override
  State<ReportDetailsScreen> createState() =>
      _ReportDetailsScreenState();
}

class _ReportDetailsScreenState
    extends State<ReportDetailsScreen> {

  @override
  void initState() {
    super.initState();

    sl<CustomerReportBloc>().add(
      FetchReportDetailsRequested(
        userId: widget.userId,
        reportDate: widget.reportDate,
      ),
    );
  }

  String formatDate(String date) {
    final d = DateTime.parse(date);

    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];

    return "${d.day} ${months[d.month - 1]} ${d.year}";
  }

  String formatTime(String value) {
    final d = DateTime.parse(value).toLocal();

    final hour =
    d.hour > 12
        ? d.hour - 12
        : (d.hour == 0 ? 12 : d.hour);

    final minute =
    d.minute.toString().padLeft(2, "0");

    final amPm =
    d.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $amPm";
  }

  Widget buildInfoCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.bgGrey,

        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Daily Report",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        body: BlocBuilder<CustomerReportBloc, CustomerReportState>(
            bloc: sl<CustomerReportBloc>(),
            builder: (context, state) {

              if (state is CustomerReportLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is CustomerReportFailure) {
                return Center(
                  child: Text(state.message),
                );
              }

              if (state is CustomerReportDetailsLoaded) {

                final report = state.report;

                return SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [

                      buildInfoCard(
                        "Report Date",
                        formatDate(
                          report["reportDate"],
                        ),
                        Icons.calendar_month,
                        Colors.blue,
                      ),

                      buildInfoCard(
                        "Device ID",
                        report["deviceId"],
                        Icons.memory,
                        Colors.deepPurple,
                      ),

                      buildInfoCard(
                        "Device ON",
                        formatTime(
                          report["deviceOn"],
                        ),
                        Icons.power_settings_new,
                        Colors.green,
                      ),

                      buildInfoCard(
                        "Average Voltage",
                        "${report["averageVoltage"]} V",
                        Icons.bolt,
                        Colors.orange,
                      ),

                      buildInfoCard(
                        "Average Current 1",
                        "${report["averageCurrent1"]} A",
                        Icons.electric_bolt,
                        Colors.red,
                      ),

                      buildInfoCard(
                        "Average Current 2",
                        "${report["averageCurrent2"]} A",
                        Icons.electric_bolt,
                        Colors.teal,
                      ),

                      buildInfoCard(
                        "Average Lt/Hr",
                        "${report["averageFlowRate"]} Lt/Hr",
                        Icons.water_drop,
                        Colors.lightBlue,
                      ),

                      SizedBox(height: 30.h),
                    ],
                  ),
                );
              }          return const Center(
                child: Text(
                  "Report not found",
                ),
              );
            },
        ),
    );
  }
}