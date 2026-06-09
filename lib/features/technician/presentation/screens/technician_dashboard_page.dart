import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/technician_dashboard_bloc.dart';
import 'service_detail_screen.dart';

class TechnicianDashboardPage extends StatefulWidget {
  final String technicianId;

  const TechnicianDashboardPage({super.key, required this.technicianId});

  @override
  State<TechnicianDashboardPage> createState() => _TechnicianDashboardPageState();
}

class _TechnicianDashboardPageState extends State<TechnicianDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  void _loadJobs() {
    context.read<TechnicianDashboardBloc>().add(FetchJobsRequested(technicianId: widget.technicianId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: BlocConsumer<TechnicianDashboardBloc, TechnicianDashboardState>(
        listener: (context, state) {
          if (state is TechnicianDashboardFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is TechnicianDashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TechnicianDashboardLoaded) {
            return Scaffold(
              backgroundColor: AppColors.bgGrey,
              body: Column(
                children: [
                  // Blue Header banner
                  Container(
                    padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.blueGradient,
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(30.r),
                      ),
                    ),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          "Water Conditioner",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        const Text(
                          "Technician Dashboard",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => _loadJobs(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.all(16.r),
                        children: [
                          Text(
                            "Work Summary",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          Row(
                            children: [
                              Expanded(
                                child: SummaryCard(
                                  "${state.todayCount}",
                                  "Today",
                                  Icons.today,
                                  Colors.purple,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: SummaryCard(
                                  "${state.pendingCount}",
                                  "Pending",
                                  Icons.assignment_late,
                                  AppColors.statusOrange,
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: SummaryCard(
                                  "${state.completedCount}",
                                  "Completed",
                                  Icons.check_circle,
                                  AppColors.statusGreen,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.h),

                          Text(
                            "Assigned Jobs",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12.h),

                          if (state.activeJobs.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 40.h),
                              child: const Center(child: Text("No jobs assigned")),
                            )
                          else
                            ...state.activeJobs.map((e) => JobCard(
                                  job: e,
                                  technicianId: widget.technicianId,
                                  refresh: _loadJobs,
                                )).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text("Uninitialized"));
        },
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const SummaryCard(this.value, this.label, this.icon, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10.r),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.r),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final String technicianId;
  final VoidCallback refresh;

  const JobCard({
    super.key,
    required this.job,
    required this.technicianId,
    required this.refresh,
  });

  Color getColor() {
    switch (job["status"]) {
      case "Pending":
        return AppColors.statusOrange;
      case "Assigned":
      case "Accepted":
        return AppColors.statusBlue;
      case "Rejected":
        return AppColors.statusRed;
      case "Completed":
        return AppColors.statusGreen;
      default:
        return AppColors.statusGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor();

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: job["status"] == "Accepted"
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ServiceDetailScreen(job: job),
                ),
              ).then((_) {
                refresh();
              });
            }
          : null,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8.r),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.build, color: color, size: 24.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job["device"]?["deviceId"] ?? "No Device",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    job["type"] ?? "",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.sp),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    job["user"] != null
                        ? "${job["user"]["area"] ?? ""}, ${job["user"]["district"] ?? ""}"
                        : "No Location",
                    style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                  ),
                  if (job["assignedDate"] != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12.r, color: AppColors.textSecondary),
                        SizedBox(width: 6.w),
                        Text(
                          job["assignedDate"],
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                  if (job["assignedTimeSlot"] != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 12.r, color: AppColors.textSecondary),
                        SizedBox(width: 6.w),
                        Text(
                          job["assignedTimeSlot"],
                          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],

                  if (job["status"] == "Assigned") ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusGreen,
                            ),
                            onPressed: () {
                              context.read<TechnicianDashboardBloc>().add(
                                    RespondJobRequested(
                                      jobId: job["_id"],
                                      action: "accept",
                                      technicianId: technicianId,
                                    ),
                                  );
                            },
                            child: const Text(
                              "Accept",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusRed,
                            ),
                            onPressed: () {
                              context.read<TechnicianDashboardBloc>().add(
                                    RespondJobRequested(
                                      jobId: job["_id"],
                                      action: "reject",
                                      technicianId: technicianId,
                                    ),
                                  );
                            },
                            child: const Text(
                              "Reject",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (job["status"] == "Accepted") ...[
                    SizedBox(height: 8.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ServiceDetailScreen(job: job),
                          ),
                        ).then((_) {
                          refresh();
                        });
                      },
                      child: const Text(
                        "Click Me",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
