import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../../../../core/constants/app_colors.dart';
import 'customer_dashboard_page.dart';
import 'customer_history_page.dart';
import 'customer_profile_page.dart';
import 'customer_service_page.dart';

class CustomerMain extends StatefulWidget {
  final String userName;
  final String deviceId;
  final String userId;

  const CustomerMain({
    super.key,
    required this.userName,
    required this.deviceId,
    required this.userId,
  });

  @override
  State<CustomerMain> createState() => _CustomerMainState();
}

class _CustomerMainState extends State<CustomerMain> {
  int selectedIndex = 0;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      CustomerDashboardPage(
        deviceId: widget.deviceId,
        userId: widget.userId,
      ),
      CustomerServicePage(
        deviceId: widget.deviceId,
        userId: widget.userId,
      ),
      CustomerHistoryPage(
        userId: widget.userId,
      ),
      CustomerProfilePage(
        userId: widget.userId,
        deviceId: widget.deviceId,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Water Conditioner",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textWhite,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),

      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 18.h,
        ),
        decoration: const BoxDecoration(
          color: Colors.blue, // Light grey background
        ),
        child: SafeArea(
          top: false,
          child: GNav(
            selectedIndex: selectedIndex,
            onTabChange: (index) {
              setState(() {
                selectedIndex = index;
              });
            },

            gap: 8,

            padding: EdgeInsets.symmetric(
              horizontal: 18.w,
              vertical: 14.h,
            ),

            backgroundColor: Colors.transparent,

            color: Colors.white,
            activeColor: AppColors.primaryBlue,

            // Selected tab background
            tabBackgroundColor: Colors.white,

            tabs: const [
              GButton(
                icon: Icons.dashboard_rounded,
                text: 'Dashboard',
              ),
              GButton(
                icon: Icons.build_rounded,
                text: 'Service',
              ),
              GButton(
                icon: Icons.history,
                text: 'History',
              ),
              GButton(
                icon: Icons.person,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}