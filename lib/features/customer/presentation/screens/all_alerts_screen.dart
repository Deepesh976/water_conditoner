import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart';
import '../bloc/customer_alert_bloc.dart';

class AllAlertsScreen extends StatefulWidget {
  final String userId;

  const AllAlertsScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AllAlertsScreen> createState() =>
      _AllAlertsScreenState();
}

class _AllAlertsScreenState
    extends State<AllAlertsScreen> {

  late final CustomerAlertBloc _alertBloc;

  @override
  void initState() {
    super.initState();

    _alertBloc = sl<CustomerAlertBloc>();

    _alertBloc.add(
      FetchCustomerAlertsRequested(
        userId: widget.userId,
      ),
    );
  }

  @override
  void dispose() {
    _alertBloc.close();
    super.dispose();
  }

  Color getAlertColor(int alert) {
    switch (alert) {
      case 3:
      case 5:
      case 7:
        return Colors.red;

      case 4:
      case 6:
        return Colors.orange;

      default:
        return Colors.red;
    }
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
            "All Alerts",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        body: BlocBuilder<CustomerAlertBloc, CustomerAlertState>(
            bloc: _alertBloc,
            builder: (context, state) {

              if (state is CustomerAlertLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is CustomerAlertFailure) {
                return Center(
                  child: Text(state.message),
                );
              }

              if (state is CustomerAlertLoaded) {

                final alerts = state.alerts;

                if (alerts.isEmpty) {
                  return Center(
                    child: Text(
                      "No Alerts Found",
                      style: TextStyle(
                        fontSize: 18.sp,
                      ),
                    ),
                  );
                }

                alerts.sort(
                      (a, b) => DateTime.parse(
                    b["recordedAt"],
                  ).compareTo(
                    DateTime.parse(
                      a["recordedAt"],
                    ),
                  ),
                );

                return ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: alerts.length,
                    itemBuilder: (context, index) {

                      final alert = alerts[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 18.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 18.h,
                          ),
                          child: Column(
                            children: [

                              //================ DATE =================

                              Row(
                                children: [

                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: AppColors.primaryBlue,
                                    size: 20.sp,
                                  ),

                                  SizedBox(width: 14.w),

                                  Text(
                                    "Date",
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    DateFormat("dd MMM yyyy").format(
                                      DateTime.parse(
                                        alert["recordedAt"],
                                      ).toLocal(),
                                    ),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 12.h),

                              Divider(
                                thickness: .8,
                                color: Colors.grey.shade300,
                              ),

                              SizedBox(height: 12.h),

                              //================ TIME =================

                              Row(
                                children: [

                                  Icon(
                                    Icons.access_time_outlined,
                                    color: AppColors.primaryBlue,
                                    size: 20.sp,
                                  ),

                                  SizedBox(width: 14.w),

                                  Text(
                                    "Time",
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    DateFormat("hh:mm:ss a").format(
                                      DateTime.parse(
                                        alert["recordedAt"],
                                      ).toLocal(),
                                    ),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 12.h),

                              Divider(
                                thickness: .8,
                                color: Colors.grey.shade300,
                              ),

                              SizedBox(height: 12.h),

                              //================ ALERT NAME =================

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Icon(
                                    Icons.notifications_none_rounded,
                                    color: AppColors.primaryBlue,
                                    size: 20.sp,
                                  ),

                                  SizedBox(width: 14.w),

                                  Text(
                                    "Alert Name",
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  SizedBox(width: 12.w),

                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        alert["alertName"],
                                        textAlign: TextAlign.end,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: getAlertColor(
                                            alert["alertNumber"],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                );
              }

              return const Center(
                child: Text(
                  "No Alerts Found",
                ),
              );
            },
        ),
    );
  }
}