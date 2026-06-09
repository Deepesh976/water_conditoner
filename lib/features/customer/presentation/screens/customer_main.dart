import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      CustomerDashboardPage(deviceId: widget.deviceId, userId: widget.userId),
      CustomerServicePage(deviceId: widget.deviceId, userId: widget.userId),
      CustomerHistoryPage(userId: widget.userId),
      CustomerProfilePage(userId: widget.userId, deviceId: widget.deviceId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Water Conditioner",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textWhite),
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) {
          setState(() {
            selectedIndex = i;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: "Service",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
