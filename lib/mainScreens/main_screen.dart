import 'package:drivers_app/tabPages/earning_tab.dart';
import 'package:drivers_app/tabPages/profile_tab.dart';
import 'package:drivers_app/tabPages/ratings_tab.dart';
import 'package:flutter/material.dart';

import '../tabPages/home_tab.dart';
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin{
  TabController? tabController;
  int selectedIndex=0;
  onItemClicked(int index){
    setState(() {
      selectedIndex=index;
      tabController!.index=selectedIndex;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController= TabController(length: 4, vsync: this);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: const [
           HomeTabPage(),
           RatingsTabPage(),
           EarningsTabPage(),
           ProfileTabPage()
        ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: "Ratings"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: "Earnings"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              label: "Profile"
          )
        ],
        unselectedItemColor: Colors.white54,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.green,
        type: BottomNavigationBarType.fixed,
        unselectedLabelStyle: const TextStyle(
          fontSize: 14
        ),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
    );
  }
}
