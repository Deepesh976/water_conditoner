import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/technician_history_bloc.dart';

class TechnicianHistoryPage extends StatefulWidget {
  final String technicianId;

  const TechnicianHistoryPage({super.key, required this.technicianId});

  @override
  State<TechnicianHistoryPage> createState() => _TechnicianHistoryPageState();
}

class _TechnicianHistoryPageState extends State<TechnicianHistoryPage> {
  int expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    context.read<TechnicianHistoryBloc>().add(FetchTechnicianHistoryRequested(technicianId: widget.technicianId));
  }

  String formatDate(String? date) {
    if (date == null) return "N/A";
    try {
      final utc = DateTime.parse(date);
      final ist = utc.add(const Duration(hours: 5, minutes: 30));
      return DateFormat("dd MMM yyyy, hh:mm a").format(ist);
    } catch (_) {
      return date;
    }
  }

  Color getStatusColor(String? status) {
    switch (status) {
      case "Completed":
        return AppColors.statusGreen;
      case "Pending":
        return AppColors.statusOrange;
      default:
        return AppColors.statusBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: BlocBuilder<TechnicianHistoryBloc, TechnicianHistoryState>(
        builder: (context, state) {
          if (state is TechnicianHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TechnicianHistoryFailure) {
            return RefreshIndicator(
              onRefresh: () async => _loadHistory(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 200.h),
                  Center(
                    child: Text(
                      state.error,
                      style: TextStyle(fontSize: 16.sp, color: AppColors.statusRed),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is TechnicianHistoryLoaded) {
            final history = state.history;

            return Column(
              children: [
                // Header
                Container(
                  height: 110.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.blueGradient,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(25.r)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "History",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "Your completed services",
                        style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _loadHistory(),
                    child: history.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 150.h),
                              const Center(child: Text("No history found")),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.all(12.r),
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              final item = history[index];
                              final isExpanded = expandedIndex == index;
                              final color = getStatusColor(item["status"]);

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    expandedIndex = isExpanded ? -1 : index;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: EdgeInsets.only(bottom: 14.h),
                                  padding: EdgeInsets.all(16.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBg,
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8.r,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10.r),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(Icons.build, color: color, size: 20.r),
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item["device"]?["deviceId"] ?? "No ID",
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  item["type"] ?? "No Issue",
                                                  style: TextStyle(color: AppColors.statusRed, fontSize: 13.sp),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  item["createdAt"] != null
                                                      ? item["createdAt"].toString().substring(0, 10)
                                                      : "",
                                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                item["status"] ?? "",
                                                style: TextStyle(
                                                  color: color,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.sp,
                                                ),
                                              ),
                                              Icon(
                                                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                size: 20.r,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      AnimatedSize(
                                        duration: const Duration(milliseconds: 300),
                                        child: isExpanded
                                            ? Column(
                                                children: [
                                                  SizedBox(height: 12.h),
                                                  const Divider(),
                                                  buildRow(Icons.person, "Customer", item["user"]?["name"]),
                                                  buildRow(Icons.calendar_today, "Requested", formatDate(item["createdAt"])),
                                                  buildRow(Icons.check_circle, "Completed", formatDate(item["completedAt"])),
                                                ],
                                              )
                                            : const SizedBox(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text("Uninitialized"));
        },
      ),
    );
  }

  Widget buildRow(IconData icon, String title, dynamic value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 16.r, color: AppColors.textSecondary),
          SizedBox(width: 8.w),
          Text("$title: ", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp)),
          Expanded(
            child: Text(
              value?.toString() ?? "N/A",
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }
}
