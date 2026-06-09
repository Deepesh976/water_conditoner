import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/customer_history_bloc.dart';

class CustomerHistoryPage extends StatefulWidget {
  final String userId;

  const CustomerHistoryPage({super.key, required this.userId});

  @override
  State<CustomerHistoryPage> createState() => _CustomerHistoryPageState();
}

class _CustomerHistoryPageState extends State<CustomerHistoryPage> {
  String selectedFilter = "All";
  int expandedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    context.read<CustomerHistoryBloc>().add(FetchHistoryRequested(userId: widget.userId));
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Completed":
      case "Resolved":
        return AppColors.statusGreen;
      case "Pending":
        return AppColors.statusOrange;
      default:
        return AppColors.statusGrey;
    }
  }

  String formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return "${dt.day}/${dt.month}/${dt.year}";
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGrey,
      body: BlocBuilder<CustomerHistoryBloc, CustomerHistoryState>(
        builder: (context, state) {
          if (state is CustomerHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CustomerHistoryFailure) {
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
          } else if (state is CustomerHistoryLoaded) {
            final services = state.complaints;
            final filteredServices = selectedFilter == "All"
                ? services
                : services.where((s) => s["status"] == selectedFilter).toList();

            return Column(
              children: [
                // Filter ChoiceChips
                Padding(
                  padding: EdgeInsets.all(12.r),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ["All", "Completed", "Pending", "Resolved"]
                          .map(
                            (filter) => Padding(
                              padding: EdgeInsets.only(right: 8.w),
                              child: ChoiceChip(
                                label: Text(filter, style: TextStyle(fontSize: 13.sp)),
                                selected: selectedFilter == filter,
                                onSelected: (_) {
                                  setState(() {
                                    selectedFilter = filter;
                                    expandedIndex = -1;
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),

                // History List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _loadHistory(),
                    child: filteredServices.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 150.h),
                              const Center(child: Text("No service history")),
                            ],
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16.r),
                            itemCount: filteredServices.length,
                            itemBuilder: (context, index) {
                              final service = filteredServices[index];
                              final isExpanded = expandedIndex == index;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    expandedIndex = isExpanded ? -1 : index;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: EdgeInsets.only(bottom: 14.h),
                                  padding: EdgeInsets.all(14.r),
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBg,
                                    borderRadius: BorderRadius.circular(14.r),
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
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              service["issueType"] ?? "Service",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15.sp,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 10.w,
                                              vertical: 5.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: getStatusColor(service["status"] ?? "").withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20.r),
                                            ),
                                            child: Text(
                                              service["status"] ?? "Pending",
                                              style: TextStyle(
                                                color: getStatusColor(service["status"] ?? ""),
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6.h),
                                      Text(
                                        formatDate(service["createdAt"] ?? ""),
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                      if (isExpanded) ...[
                                        SizedBox(height: 12.h),
                                        const Divider(),
                                        SizedBox(height: 8.h),
                                        Text(
                                          service["description"] ?? "",
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                      ],
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
}
