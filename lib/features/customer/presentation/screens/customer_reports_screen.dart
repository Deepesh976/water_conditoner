import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../bloc/customer_report_bloc.dart';
import 'report_details_screen.dart';

class CustomerReportsScreen extends StatefulWidget {
  final String userId;

  const CustomerReportsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<CustomerReportsScreen> createState() =>
      _CustomerReportsScreenState();
}

class _CustomerReportsScreenState
    extends State<CustomerReportsScreen> {

  @override
  void initState() {
    super.initState();

    sl<CustomerReportBloc>().add(
      FetchReportsRequested(
        userId: widget.userId,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Daily Reports",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocBuilder<CustomerReportBloc, CustomerReportState>(
            bloc: sl<CustomerReportBloc>(),
            builder: (context, state) {          if (state is CustomerReportLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            debugPrint("========== REPORT STATE ==========");
            debugPrint(state.runtimeType.toString());


            if (state is CustomerReportFailure) {
              return Center(
                child: Text(state.message),
              );
            }

            if (state is CustomerReportsLoaded) {
              final reports = state.reports;

              if (reports.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 70.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "No Reports Available",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];

                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.only(
                      bottom: 14.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        16.r,
                      ),
                    ),
                    child: InkWell(
                      borderRadius:
                      BorderRadius.circular(
                        16.r,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReportDetailsScreen(
                                  userId: widget.userId,
                                  reportDate:
                                  report["reportDate"],
                                ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Row(
                          children: [
                            Container(
                              width: 52.w,
                              height: 52.w,
                              decoration: BoxDecoration(
                                color: Colors
                                    .blue.shade50,
                                shape:
                                BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.insert_drive_file,
                                color: Colors.blue,
                                size: 28.sp,
                              ),
                            ),

                            SizedBox(width: 16.w),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    formatDate(
                                      report[
                                      "reportDate"],
                                    ),
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),

                                  SizedBox(
                                      height: 6.h),

                                  Text(
                                    "Device ID : ${report["deviceId"]}",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors
                                          .grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Icon(
                              Icons
                                  .keyboard_arrow_right_rounded,
                              size: 30.sp,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }          return const SizedBox();
            },
        ),
    );
  }
}