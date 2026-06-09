import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import '../../../../core/constants/app_colors.dart';
import '../bloc/customer_dashboard_bloc.dart';

class ChartData {
  final DateTime x;
  final double y;
  ChartData(this.x, this.y);
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
  String selectedMetricFlow = "Lt/Hr";
  String selectedMetricPressure = "Lt/Hr";
  bool isResetDone = false;
  bool showResetPopup = false;
  bool serviceJustCompleted = false;
  final Set<String> _localShownComplaintIds = {};

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
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
            final bool currentlyReset = showReset || isResetDone;
            if (!currentlyReset) {
              if (channel1 > 0 && channel1 <= 30 && channel2 > 0 && channel2 <= 30) {
                WidgetsBinding.instance.addPostFrameCallback((_) => showChannelAlert("Channel 1 and Channel 2 are BAD"));
              } else if (channel1 > 0 && channel1 <= 30) {
                WidgetsBinding.instance.addPostFrameCallback((_) => showChannelAlert("Channel 1 is BAD"));
              } else if (channel2 > 0 && channel2 <= 30) {
                WidgetsBinding.instance.addPostFrameCallback((_) => showChannelAlert("Channel 2 is BAD"));
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
            
            final double channel1 = isResetDone ? 0 : (latest["channel1"] ?? 0).toDouble();
            final double channel2 = isResetDone ? 0 : (latest["channel2"] ?? 0).toDouble();

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

              Map<String, double> dailyMap = {};
              for (var d in sortedHistory) {
                DateTime dt = DateTime.parse(d["recordedAt"]).toLocal();
                String date = "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
                double value = 0;

                if (selectedMetricFlow == "Ampere") {
                  value = (d["ampere"] ?? 0).toDouble();
                } else if (selectedMetricFlow == "Voltage") {
                  value = (d["voltage"] ?? 0).toDouble();
                } else {
                  value = (d["flowRate"] ?? 0).toDouble();
                }
                dailyMap[date] = value;
              }

              for (int i = 6; i >= 0; i--) {
                DateTime day = DateTime.now().subtract(Duration(days: i));
                String key = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
                tempFlow.add(dailyMap[key] ?? 0.0);
                tempLabels.add("${day.day}");
              }
            }

            final List<double> displayFlowData = isResetDone ? List.generate(7, (_) => 0.0) : tempFlow;
            final List<String> labels = tempLabels;

            // Prepare pressure chart data
            final pressureHistory = data["pressureHistory"] ?? [];
            List<ChartData> tempPressure = [];
            for (var d in pressureHistory) {
              DateTime time = DateTime.parse(d["recordedAt"]).toLocal();
              tempPressure.add(ChartData(time, (d["pressure"] ?? 0).toDouble()));
            }

            final List<ChartData> displayPressure = isResetDone ? [] : tempPressure;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CustomerDashboardBloc>().add(RefreshDashboard(deviceId: state.deviceId, userId: widget.userId));
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
                                  "Channel 1",
                                  channel1,
                                  selectedMetricPressure == "Voltage"
                                      ? 260
                                      : selectedMetricPressure == "Ampere"
                                          ? 20
                                          : 100,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: gaugeCard(
                                  "Channel 2",
                                  channel2,
                                  selectedMetricPressure == "Voltage"
                                      ? 260
                                      : selectedMetricPressure == "Ampere"
                                          ? 20
                                          : 100,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),

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
                                  final d = point.x as String;
                                  final y = point.y;
                                  int day = int.tryParse(d) ?? 1;

                                  String getSuffix(int d) {
                                    if (d >= 11 && d <= 13) return "th";
                                    switch (d % 10) {
                                      case 1:
                                        return "st";
                                      case 2:
                                        return "nd";
                                      case 3:
                                        return "rd";
                                      default:
                                        return "th";
                                    }
                                  }

                                  String monthName = [
                                    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                                    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
                                  ][DateTime.now().month - 1];

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
                                          "$day${getSuffix(day)} $monthName",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          "${(y ?? 0).toInt()} ${getUnit(selectedMetricFlow)}",
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
                              primaryXAxis: CategoryAxis(),
                              primaryYAxis: NumericAxis(
                                minimum: 0,
                                maximum: getDynamicMax(displayFlowData),
                                interval: (getDynamicMax(displayFlowData) / 5).clamp(1, double.infinity),
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
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
                              Text(
                                getFaultCount(displayPressure) > 0
                                    ? "⚠ ${getFaultCount(displayPressure)} Errors"
                                    : "All Good",
                                style: TextStyle(
                                  color: getFaultCount(displayPressure) > 0 ? AppColors.statusRed : AppColors.statusGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
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
                                lineType: TrackballLineType.vertical,
                                builder: (BuildContext context, TrackballDetails details) {
                                  final index = details.pointIndex ?? 0;
                                  if (index >= displayPressure.length) return const SizedBox();
                                  final ChartData pt = displayPressure[index];
                                  final DateTime dt = pt.x;
                                  final value = pt.y.toInt();

                                  String time = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                                  String status = value == 1 ? "ERROR" : "GOOD";

                                  return Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      color: value == 1 ? AppColors.statusRed : AppColors.statusBlue,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(time, style: const TextStyle(color: Colors.white)),
                                        SizedBox(height: 4.h),
                                        Text(
                                          status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              primaryXAxis: DateTimeAxis(
                                minimum: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0),
                                maximum: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59),
                                intervalType: DateTimeIntervalType.minutes,
                                interval: 30,
                                dateFormat: DateFormat.Hm(),
                                labelStyle: TextStyle(fontSize: 10.sp),
                              ),
                              primaryYAxis: NumericAxis(
                                minimum: 0,
                                maximum: 1,
                                interval: 1,
                                axisLabelFormatter: (AxisLabelRenderDetails args) {
                                  if (args.value == 0) {
                                    return ChartAxisLabel("G", const TextStyle(color: AppColors.statusBlue));
                                  } else {
                                    return ChartAxisLabel("E", const TextStyle(color: AppColors.statusRed));
                                  }
                                },
                              ),
                              series: <CartesianSeries<ChartData, DateTime>>[
                                LineSeries<ChartData, DateTime>(
                                  dataSource: displayPressure,
                                  xValueMapper: (data, _) => data.x,
                                  yValueMapper: (data, _) => data.y,
                                  pointColorMapper: (ChartData data, _) {
                                    return data.y == 1 ? AppColors.statusRed : AppColors.statusBlue;
                                  },
                                  color: AppColors.statusBlue,
                                  width: 2.5,
                                  markerSettings: MarkerSettings(
                                    isVisible: true,
                                    width: 8.r,
                                    height: 8.r,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 80.h),
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

  Widget gaugeCard(String title, double value, double max) {
    Color getGaugeColor(double v) {
      if (v <= 30) return AppColors.statusRed;
      if (v <= 70) return AppColors.statusOrange;
      return AppColors.statusGreen;
    }

    Color gaugeColor = getGaugeColor(value);

    String getStatus(double v) {
      if (v <= 30) return "BAD";
      if (v <= 70) return "OK";
      return "GOOD";
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
                  maximum: max,
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
                      value: value,
                      width: 10,
                      cornerStyle: gauges.CornerStyle.bothCurve,
                      color: gaugeColor,
                    ),
                    gauges.MarkerPointer(
                      value: value,
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
                          Text("SCORE", style: TextStyle(fontSize: 10.sp)),
                          Text(
                            value.toInt().toString(),
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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: gaugeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              getStatus(value),
              style: TextStyle(color: gaugeColor, fontWeight: FontWeight.bold, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  String getUnit(String metric) {
    if (metric == "Voltage") return "V";
    if (metric == "Ampere") return "A";
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
          "Ampere",
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
}
