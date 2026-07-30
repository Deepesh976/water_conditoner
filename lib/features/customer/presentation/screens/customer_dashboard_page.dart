import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import '../../../../core/constants/app_colors.dart';
import '../bloc/customer_dashboard_bloc.dart';
import 'all_alerts_screen.dart';
import '../../../../injection_container.dart';
import '../bloc/customer_alert_bloc.dart';
import 'dart:async';

class ChartData {
  final DateTime x;
  final double y;
  final int alert;

  ChartData(
      this.x,
      this.y,
      this.alert,
      );
}

class FlowChartData {
  final String x;
  final double y;
  FlowChartData(this.x, this.y);
}

class CustomerDashboardPage extends StatefulWidget {
  final String deviceId;
  final String userId;

  const CustomerDashboardPage({
    super.key,
    required this.deviceId,
    required this.userId,
  });

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  Timer? _refreshTimer;
  String selectedMetricFlow = "Lt/Hr";
  String selectedMetricPressure = "Lt/Hr";
  bool isResetDone = false;
  bool showResetPopup = false;
  bool serviceJustCompleted = false;
  int? selectedAlert;
  final Set<String> _localShownComplaintIds = {};

  @override
  void initState() {
    super.initState();

    // Load latest values immediately
    _loadDashboardData();

    // Refresh once after ESP boots (10–15 sec)
    Future.delayed(const Duration(seconds: 15), () {
      if (!mounted) return;

      context.read<CustomerDashboardBloc>().add(
        RefreshDashboard(
          deviceId: widget.deviceId,
          userId: widget.userId,
        ),
      );
    });

    // Refresh every 3 minutes 5 second
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 185),
          (_) {
        if (!mounted) return;

        context.read<CustomerDashboardBloc>().add(
          RefreshDashboard(
            deviceId: widget.deviceId,
            userId: widget.userId,
          ),
        );
      },
    );
  }

  void _loadDashboardData() {
    context.read<CustomerDashboardBloc>().add(LoadDashboard(userId: widget.userId));
  }

  void _showResetPopupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Service Completed", style: TextStyle(fontSize: 18.sp)),
        content: Text(
          "Device has been reset",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isResetDone = true;
                  serviceJustCompleted = true;
                });
              },
              child: const Text("OK"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResetPopup(bool showReset, double channel1, double channel2, double flowRate) async {
    final prefs = await SharedPreferences.getInstance();
    final String resetKey = 'reset_popup_shown_${widget.deviceId}';

    if (showReset) {
      final bool alreadyShown = prefs.getBool(resetKey) ?? false;
      if (!alreadyShown && !showResetPopup) {
        await prefs.setBool(resetKey, true);
        setState(() {
          showResetPopup = true;
          isResetDone = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showResetPopupDialog();
        });
      } else {
        if (!isResetDone) {
          setState(() {
            isResetDone = true;
          });
        }
      }
    } else {
      await prefs.setBool(resetKey, false);
      if (isResetDone || showResetPopup || serviceJustCompleted) {
        setState(() {
          isResetDone = false;
          showResetPopup = false;
          serviceJustCompleted = false;
        });
      }
    }

    if (serviceJustCompleted && (channel1 > 0 || channel2 > 0 || flowRate > 0)) {
      await prefs.setBool(resetKey, false);
      setState(() {
        isResetDone = false;
        showResetPopup = false;
        serviceJustCompleted = false;
      });
    }
  }

  Future<void> _checkCompletedComplaints(List<dynamic> complaints) async {
    if (complaints.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final List<String> shownIds = prefs.getStringList('shown_completed_complaints_${widget.userId}') ?? [];

    final List<String> allCompletedIds = [];
    Map<String, dynamic>? latestCompletedComplaint;

    for (var complaint in complaints) {
      if (complaint is! Map) continue;
      final String? id = complaint['_id']?.toString();
      final String? status = complaint['status']?.toString();

      if (id != null && status == 'Completed') {
        allCompletedIds.add(id);
        if (latestCompletedComplaint == null) {
          // The list is sorted latest first, so the first completed complaint is the latest.
          latestCompletedComplaint = complaint.cast<String, dynamic>();
        }
      }
    }

    if (latestCompletedComplaint != null) {
      final String latestId = latestCompletedComplaint['_id'].toString();

      if (!shownIds.contains(latestId) && !_localShownComplaintIds.contains(latestId)) {
        _localShownComplaintIds.add(latestId);

        // Mark all completed complaints in the fetched history as shown.
        for (var id in allCompletedIds) {
          if (!shownIds.contains(id)) {
            shownIds.add(id);
          }
        }
        await prefs.setStringList('shown_completed_complaints_${widget.userId}', shownIds);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showComplaintResolvedDialog(latestCompletedComplaint!);
        });
      }
    }
  }

  void _showComplaintResolvedDialog(Map<String, dynamic> complaint) {
    final before = complaint['beforeReading'] ?? {};
    final after = complaint['afterReading'] ?? {};
    final type = complaint['type'] ?? 'Service';
    final description = complaint['description'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.statusGreen,
                  size: 60.r,
                ),
              ),
              SizedBox(height: 16.h),
              Center(
                child: Text(
                  "Issue Resolved!",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Center(
                child: Text(
                  "Your water conditioner data has been fixed by the technician.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Divider(height: 1.h, color: Colors.grey.shade300),
              SizedBox(height: 16.h),
              Text(
                "Service Details",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text("• Type: $type", style: TextStyle(fontSize: 13.sp)),
              if (description.isNotEmpty)
                Text("• Description: $description", style: TextStyle(fontSize: 13.sp)),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "BEFORE",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.statusRed,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text("Flow: ${before['flow'] ?? '--'} L/hr", style: TextStyle(fontSize: 12.sp)),
                        Text("Ampere: ${before['ampere'] ?? '--'} A", style: TextStyle(fontSize: 12.sp)),
                        Text("Voltage: ${before['voltage'] ?? '--'} V", style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AFTER",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.statusGreen,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text("Flow: ${after['flow'] ?? '--'} L/hr", style: TextStyle(fontSize: 12.sp)),
                        Text("Ampere: ${after['ampere'] ?? '--'} A", style: TextStyle(fontSize: 12.sp)),
                        Text("Voltage: ${after['voltage'] ?? '--'} V", style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 44.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Great, Thanks!",
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showChannelAlert(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, color: AppColors.statusRed, size: 50.r),
              SizedBox(height: 10.h),
              Text(
                "ALERT",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: BlocConsumer<CustomerDashboardBloc, CustomerDashboardState>(
        listener: (context, state) {
          if (state is CustomerDashboardLoaded) {
            final data = state.analysisData;
            final latest = data["latest"] ?? {};
            final channel1 = (latest["channel1"] ?? 0).toDouble();
            final channel2 = (latest["channel2"] ?? 0).toDouble();
            final flowRate = (latest["flowRate"] ?? 0).toDouble();
            final showReset = data["showResetPopup"] ?? false;

            _handleResetPopup(showReset, channel1, channel2, flowRate);

            // Channel Bad Alerts (only if not reset)
// Channel Bad Alerts (only if not reset)
            final bool currentlyReset = showReset || isResetDone;

            if (!currentlyReset) {

              final channel1Settings = state.conditionerSettings?["channel1"];
              final channel2Settings = state.conditionerSettings?["channel2"];

              double channel1Health = 100;
              double channel2Health = 100;

              if (channel1Settings != null) {
                final min =
                (channel1Settings["minCurrent"] as num? ?? 0).toDouble();

                final max =
                (channel1Settings["maxCurrent"] as num? ?? 100).toDouble();

                if (max > min) {
                  channel1Health =
                      ((((channel1 - min) / (max - min)) * 100)
                          .clamp(0.0, 100.0))
                          .toDouble();
                }
              }

              if (channel2Settings != null) {
                final min =
                (channel2Settings["minCurrent"] as num? ?? 0).toDouble();

                final max =
                (channel2Settings["maxCurrent"] as num? ?? 100).toDouble();

                if (max > min) {
                  channel2Health =
                      ((((channel2 - min) / (max - min)) * 100)
                          .clamp(0.0, 100.0))
                          .toDouble();
                }
              }

              final bool channel1Bad = channel1Health <= 30;
              final bool channel2Bad = channel2Health <= 30;

              if (channel1Bad && channel2Bad) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showChannelAlert("Channel 1 and Channel 2 are BAD");
                });
              } else if (channel1Bad) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showChannelAlert("Channel 1 is BAD");
                });
              } else if (channel2Bad) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  showChannelAlert("Channel 2 is BAD");
                });
              }
            }
            _checkCompletedComplaints(state.complaints);
          }
        },
        builder: (context, state) {
          if (state is CustomerDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CustomerDashboardFailure) {
            return RefreshIndicator(
              onRefresh: () async => _loadDashboardData(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 200.h),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.sp, color: AppColors.statusRed),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is CustomerDashboardLoaded) {
            final data = state.analysisData;
            final latest = data["latest"] ?? {};

            final double channel1 =
            isResetDone ? 0.0 : (latest["channel1"] ?? 0).toDouble();

            final double channel2 =
            isResetDone ? 0.0 : (latest["channel2"] ?? 0).toDouble();

            // Prepare flow chart data (last 7 days)
            final flowHistory = data["flowHistory"] ?? [];
            List<double> tempFlow = [];
            List<String> tempLabels = [];

            if (flowHistory == null || flowHistory.isEmpty) {
              tempFlow = List.generate(7, (_) => 0.0);
              tempLabels = List.generate(7, (i) {
                DateTime day = DateTime.now().subtract(Duration(days: 6 - i));
                return "${day.day}";
              });
            } else {
              List sortedHistory = List.from(flowHistory);
              sortedHistory.sort((a, b) => DateTime.parse(a["recordedAt"]).compareTo(DateTime.parse(b["recordedAt"])));

              Map<String, List<double>> dailyValues = {};

              for (var d in sortedHistory) {
                DateTime dt = DateTime.parse(d["recordedAt"]).toLocal();

                String date =
                    "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

                double value = 0;

                if (selectedMetricFlow == "Voltage") {
                  value = (d["voltage"] ?? 0).toDouble();
                } else {
                  value = (d["flowRate"] ?? 0).toDouble();
                }

                if (!dailyValues.containsKey(date)) {
                  dailyValues[date] = [];
                }

                dailyValues[date]!.add(value);
              }

// Calculate average for each day
              Map<String, double> dailyMap = {};

              dailyValues.forEach((date, values) {
                if (values.isNotEmpty) {
                  double sum = values.reduce((a, b) => a + b);
                  dailyMap[date] = sum / values.length;
                } else {
                  dailyMap[date] = 0;
                }
              });

              for (int i = 6; i >= 0; i--) {
                DateTime day = DateTime.now().subtract(Duration(days: i));
                String key = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                tempFlow.add(dailyMap[key] ?? 0.0);
                tempLabels.add(
                  DateFormat("d MMM").format(day),
                );
              }
            }

            final List<double> displayFlowData = isResetDone ? List.generate(7, (_) => 0.0) : tempFlow;
            final List<String> labels = tempLabels;

// Prepare pressure chart data (ONLY TODAY + NEW FIELD)
            final pressureHistory = data["alertHistory"] ?? [];

            List<ChartData> tempPressure = [];

// 🔥 Get today's start time
            DateTime now = DateTime.now();
            DateTime startOfDay = DateTime(now.year, now.month, now.day);

            for (var d in pressureHistory) {
              DateTime time = DateTime.parse(d["recordedAt"]).toLocal();

              // 🔥 ONLY TODAY DATA (0–24 hrs)
              if (time.isAfter(startOfDay)) {
                tempPressure.add(
                  ChartData(
                    time,
                    ((d["alert"] ?? 0) > 0) ? 1.0 : 0.0,
                    d["alert"] ?? 0,
                  ),
                );
              }
            }

            final List<ChartData> displayPressure = isResetDone
                ? []
                : selectedAlert == null
                ? tempPressure
                : tempPressure
                .where((e) => e.alert == selectedAlert)
                .toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CustomerDashboardBloc>().add(RefreshDashboard(deviceId: widget.deviceId, userId: widget.userId));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Column(
                  children: [
                    // Device info chip
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.devices, size: 16.r, color: AppColors.primaryBlue),
                          SizedBox(width: 6.w),
                          Text(
                            "Device ID: ${state.deviceName}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Gauge Cards Section
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Conditioner Service Status",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              Expanded(
                                child: gaugeCard(
                                  title: "Channel 1",
                                  current: channel1,
                                  settings: state.conditionerSettings?["channel1"],
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: gaugeCard(
                                  title: "Channel 2",
                                  current: channel2,
                                  settings: state.conditionerSettings?["channel2"],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 0.5.h),

                    // Flow Rate Section
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Flow Rate",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              buildMetricDropdown(selectedMetricFlow, (val) {
                                setState(() {
                                  selectedMetricFlow = val;
                                });
                              }),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            height: 200.h,
                            child: SfCartesianChart(
                              plotAreaBorderWidth: 0,
                              trackballBehavior: TrackballBehavior(
                                enable: true,
                                activationMode: ActivationMode.singleTap,
                                tooltipDisplayMode: TrackballDisplayMode.floatAllPoints,
                                lineType: TrackballLineType.vertical,
                                builder: (BuildContext context, TrackballDetails details) {
                                  final point = details.point!;
                                  final date = point.x.toString();
                                  final y = point.y;

                                  return Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          date,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          "${(y ?? 0).toStringAsFixed(1)} ${getUnit(selectedMetricFlow)}",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              primaryXAxis: CategoryAxis(
                                majorGridLines: const MajorGridLines(
                                  width: 0,
                                ),
                                axisLine: const AxisLine(
                                  width: 0,
                                ),
                                majorTickLines: const MajorTickLines(
                                  size: 0,
                                ),
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              series: <CartesianSeries<FlowChartData, String>>[
                                ColumnSeries<FlowChartData, String>(
                                  animationDuration: 800,
                                  dataSource: List.generate(
                                    displayFlowData.length,
                                    (i) => FlowChartData(
                                      labels[i],
                                      displayFlowData[i],
                                    ),
                                  ),
                                  xValueMapper: (data, _) => data.x,
                                  yValueMapper: (data, _) => data.y,
                                  borderRadius: BorderRadius.circular(8.r),
                                  gradient: const LinearGradient(
                                    colors: AppColors.chartsPurpleGradient,
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Low Water Pressure Section
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Low Water Pressure",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: getFaultCount(displayPressure) > 0
                                      ? Colors.red.withOpacity(.1)
                                      : Colors.green.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      getFaultCount(displayPressure) > 0
                                          ? Icons.warning_amber_rounded
                                          : Icons.check_circle,
                                      size: 18,
                                      color: getFaultCount(displayPressure) > 0
                                          ? Colors.red
                                          : Colors.green,
                                    ),

                                    SizedBox(width: 5),

                                    Text(
                                      getFaultCount(displayPressure) > 0
                                          ? "${getFaultCount(displayPressure)} Errors"
                                          : "All Good",
                                      style: TextStyle(
                                        color: getFaultCount(displayPressure) > 0
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            height: 260.h,
                            child: SfCartesianChart(
                              backgroundColor: Colors.transparent,
                              plotAreaBorderWidth: 0,
                              margin: EdgeInsets.only(right: 12.w),

                              trackballBehavior: TrackballBehavior(
                                enable: true,
                                activationMode: ActivationMode.singleTap,
                                tooltipDisplayMode: TrackballDisplayMode.nearestPoint,
                                lineType: TrackballLineType.none,
                                builder: (BuildContext context, TrackballDetails details) {
                                  final index = details.pointIndex ?? 0;

                                  if (index >= displayPressure.length) {
                                    return const SizedBox();
                                  }

                                  final ChartData pt = displayPressure[index];

                                  return Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      color: pt.alert == 0
                                          ? Colors.blue
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          pt.alert == 0
                                              ? "GOOD"
                                              : "Alert ${pt.alert}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat("HH:mm").format(pt.x),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              primaryXAxis: DateTimeAxis(
                                minimum: DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  0,
                                ),
                                maximum: DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  23,
                                  59,
                                ),
                                intervalType: DateTimeIntervalType.hours,
                                interval: 3,

                                majorGridLines: const MajorGridLines(
                                  width: 0,
                                ),

                                majorTickLines: const MajorTickLines(
                                  size: 4,
                                  width: 1,
                                ),

                                axisLine: AxisLine(
                                  width: 2,
                                  color: Colors.grey.shade600,
                                ),

                                dateFormat: DateFormat("HH:mm"),

                                labelStyle: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.black87,
                                ),
                              ),

                              primaryYAxis: NumericAxis(
                                minimum: 0,
                                maximum: 1,
                                interval: 1,

                                majorGridLines: MajorGridLines(
                                  width: 0,
                                ),

                                axisLine: AxisLine(
                                  width: 2,
                                  color: Colors.grey.shade400,
                                ),

                                axisLabelFormatter: (args) {
                                  if (args.value == 0) {
                                    return ChartAxisLabel(
                                      "G",
                                      TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                      ),
                                    );
                                  }

                                  return ChartAxisLabel(
                                    "E",
                                    TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.sp,
                                    ),
                                  );
                                },
                              ),

                              series: <CartesianSeries<ChartData, DateTime>>[
                                ColumnSeries<ChartData, DateTime>(
                                  dataSource: displayPressure,
                                  xValueMapper: (data, _) => data.x,
                                  yValueMapper: (data, _) => data.y,

                                  width: 0.006,
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.zero,
                                  enableTooltip: false,
                                ),

                                ScatterSeries<ChartData, DateTime>(
                                  dataSource: displayPressure,

                                  xValueMapper: (data, _) => data.x,
                                  yValueMapper: (data, _) => data.y,

                                  pointColorMapper: (data, _) =>
                                  data.alert == 0
                                      ? Colors.blue
                                      : Colors.red,

                                  opacity: 1,

                                  markerSettings: const MarkerSettings(
                                    isVisible: true,
                                    width: 10,
                                    height: 10,
                                    shape: DataMarkerType.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10.h),

                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 3.5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 8,
                            children: [
                              legendItem(1, "Max Voltage"),
                              legendItem(2, "Min Voltage"),
                              legendItem(3, "LPS Trip"),
                              legendItem(4, "Over Amp C1"),
                              legendItem(5, "Under Amp C1"),
                              legendItem(6, "Over Amp C2"),
                              legendItem(7, "Under Amp C2"),
                              legendItem(8, "Service Mode"),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Show All Alerts",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider(
                                      create: (_) => sl<CustomerAlertBloc>()
                                        ..add(
                                          FetchCustomerAlertsRequested(
                                            userId: widget.userId,
                                          ),
                                        ),
                                      child: AllAlertsScreen(
                                        userId: widget.userId,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text("Uninitialized"));
        },
      ),
    );
  }

  Widget gaugeCard({
    required String title,
    required double current,
    required Map<String, dynamic>? settings,
  }) {
    double minCurrent =
    (settings?["minCurrent"] ?? 0).toDouble();

    double maxCurrent =
    (settings?["maxCurrent"] ?? 100).toDouble();
    print("==========");
    print("Title: $title");
    print("Current: $current");
    print("Settings: $settings");
    print("Min: $minCurrent");
    print("Max: $maxCurrent");
    print("==========");


    double health = 0;

    if (maxCurrent > minCurrent) {
      health =
          ((current - minCurrent) /
              (maxCurrent - minCurrent)) *
              100;

      health = health.clamp(0, 100);
    }

    print("Health = $health");

    Color gaugeColor;

    String status;

    if (health <= 30) {
      gaugeColor = AppColors.statusRed;
      status = "Bad";
    } else if (health <= 70) {
      gaugeColor = AppColors.statusOrange;
      status = "Normal";
    } else {
      gaugeColor = AppColors.statusGreen;
      status = "Good";
    }

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 120.h,
            child: gauges.SfRadialGauge(
              axes: [
                gauges.RadialAxis(
                  minimum: 0,
                  maximum: 100,
                  startAngle: 135,
                  endAngle: 45,
                  showLabels: false,
                  showTicks: false,
                  axisLineStyle: const gauges.AxisLineStyle(
                    thickness: 10,
                    color: Color(0xFFE0E0E0),
                  ),
                  pointers: [
                    gauges.RangePointer(
                      value: health,
                      width: 10,
                      cornerStyle: gauges.CornerStyle.bothCurve,
                      color: gaugeColor,
                    ),
                    gauges.MarkerPointer(
                      value: health,
                      markerType: gauges.MarkerType.circle,
                      color: Colors.white,
                      borderColor: gaugeColor,
                      borderWidth: 3,
                      markerWidth: 14.r,
                      markerHeight: 14.r,
                    ),
                  ],
                  annotations: [
                    gauges.GaugeAnnotation(
                      widget: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            health.toInt().toString(),
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: gaugeColor,
                            ),
                          ),
                          Text("/100", style: TextStyle(fontSize: 10.sp)),
                        ],
                      ),
                      angle: 90,
                      positionFactor: 0.1,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            "Current",
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey,
            ),
          ),

          SizedBox(height: 2.h),

          Text(
            "${current.toStringAsFixed(1)} A",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: gaugeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              status,
              style: TextStyle(color: gaugeColor, fontWeight: FontWeight.bold, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  String getUnit(String metric) {
    if (metric == "Voltage") return "V";
    return "L/hr";
  }

  double getDynamicMax(List<double> data) {
    if (data.isEmpty) return 100;
    double maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal <= 0) return 100;
    double withHeadroom = maxVal * 1.2;
    return (withHeadroom / 5).ceil() * 5;
  }

  int getFaultCount(List<ChartData> faults) {
    if (isResetDone) return 0;
    return faults.where((d) => d.y == 1).length;
  }

  String getAlertName(int alert) {
    switch (alert) {
      case 1:
        return "Max Voltage Fault";

      case 2:
        return "Min Voltage Fault";

      case 3:
        return "LPS Trip";

      case 4:
        return "Over Ampere Trip Current 1";

      case 5:
        return "Under Ampere Trip Current 1";

      case 6:
        return "Over Ampere Trip Current 2";

      case 7:
        return "Under Ampere Trip Current 2";

      case 8:
        return "Service Mode";

      default:
        return "Unknown Alert";
    }
  }

  Widget legendItem(int number, String title) {
    final bool isSelected = selectedAlert == number;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedAlert == number) {
            selectedAlert = null;
          } else {
            selectedAlert = number;
          }
        });
      },

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),

        decoration: BoxDecoration(
          color: isSelected
              ? Colors.red.withOpacity(.15)
              : Colors.grey.shade100,

          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: isSelected
                ? Colors.red
                : Colors.transparent,
            width: 1.5,
          ),
        ),

        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),

              child: Center(
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 6),

            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMetricDropdown(String selectedValue, Function(String) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down),
        style: TextStyle(
          fontSize: 13.sp,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        items: [
          "Voltage",
          "Lt/Hr",
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (val) {
          onChanged(val!);
          context.read<CustomerDashboardBloc>().add(RefreshDashboard(deviceId: widget.deviceId, userId: widget.userId));
        },
      ),
    );
  }
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
