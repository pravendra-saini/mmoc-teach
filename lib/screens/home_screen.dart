import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/course_model.dart';
import '../widgets/course_card.dart';

import 'profile_screen.dart';
import 'wishlist_screen.dart';
import 'my_learning_screen.dart';
import 'notification_screen.dart';
import 'admin_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //------------------------
  // USER
  //------------------------

  final user = FirebaseAuth.instance.currentUser;

  String userName = "Student";

  //------------------------
  // SEARCH
  //------------------------

  String searchText = "";

  //------------------------
  // BOTTOM NAVIGATION
  //------------------------

  int currentIndex = 0;

  //------------------------
  // BANNER
  //------------------------

  int currentBanner = 0;

  final PageController pageController =
      PageController(viewportFraction: .92);

  final List<String> banners = [

    "assets/images/banner1.jpg",

    "assets/images/banner2.jpg",

    "assets/images/banner3.jpg",

  ];

  //------------------------
  // INIT
  //------------------------

  @override
  void initState() {
    super.initState();

    loadUser();

    Timer.periodic(
      const Duration(seconds: 4),
      (timer) {

        if (!pageController.hasClients) return;

        currentBanner++;

        if (currentBanner >= banners.length) {
          currentBanner = 0;
        }

        pageController.animateToPage(
          currentBanner,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  //------------------------
  // LOAD USER
  //------------------------

  Future<void> loadUser() async {

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if (!doc.exists) return;

    setState(() {
      userName = doc["name"] ?? "Student";
    });
  }

  //------------------------
  // GREETING
  //------------------------

  String greeting() {

    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    }

    if (hour < 17) {
      return "Good Afternoon";
    }

    return "Good Evening";
  }

  //------------------------
  // DISPOSE
  //------------------------

  @override
  void dispose() {

    pageController.dispose();

    super.dispose();
  }
    //==================================
  // BUILD
  //==================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF4F7FC),

      body: SafeArea(

        child: SingleChildScrollView(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              //==================================
              // HEADER
              //==================================

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),

                child: Row(

                  children: [

                    Expanded(

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Text(

                            greeting(),

                            style: TextStyle(

                              color: Colors.grey.shade700,

                              fontSize: 16,

                            ),

                          ),

                          const SizedBox(height: 5),

                          Text(

                            "$userName 👋",

                            style: const TextStyle(

                              fontSize: 28,

                              fontWeight: FontWeight.bold,

                            ),

                          ),

                        ],

                      ),

                    ),

                    if (user?.email ==
                        "pravendrasaini303@gmail.com")

                      IconButton(

                        onPressed: () {

                          Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder: (_) =>
                                  const AdminDashboard(),

                            ),

                          );

                        },

                        icon: const Icon(

                          Icons.admin_panel_settings,

                          color: Color(0xff1565C0),

                        ),

                      ),

                    IconButton(

                      onPressed: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                const NotificationScreen(),

                          ),

                        );

                      },

                      icon: const Icon(

                        Icons.notifications_none,

                        size: 28,

                      ),

                    ),

                    GestureDetector(

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                const ProfileScreen(),

                          ),

                        );

                      },

                      child: CircleAvatar(

                        radius: 24,

                        backgroundColor:
                            const Color(0xff1565C0),

                        child: Text(

                          userName.isNotEmpty
                              ? userName[0].toUpperCase()
                              : "S",

                          style: const TextStyle(

                            color: Colors.white,

                            fontWeight: FontWeight.bold,

                            fontSize: 20,

                          ),

                        ),

                      ),

                    ),

                  ],

                ),

              ),

              //==================================
              // SEARCH BAR
              //==================================

              Padding(

                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),

                child: TextField(

                  decoration: InputDecoration(

                    hintText: "Search Courses...",

                    prefixIcon:
                        const Icon(Icons.search),

                    filled: true,

                    fillColor: Colors.white,

                    border: OutlineInputBorder(

                      borderRadius:
                          BorderRadius.circular(18),

                      borderSide: BorderSide.none,

                    ),

                  ),

                  onChanged: (value) {

                    setState(() {

                      searchText =
                          value.toLowerCase();

                    });

                  },

                ),

              ),

              const SizedBox(height: 25),
                            //==================================
              // PREMIUM BANNER
              //==================================

              SizedBox(
                height: 220,

                child: PageView.builder(

                  controller: pageController,

                  itemCount: banners.length,

                  onPageChanged: (index) {

                    setState(() {

                      currentBanner = index;

                    });

                  },

                  itemBuilder: (context, index) {

                    return Padding(

                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                      ),

                      child: Container(

                        decoration: BoxDecoration(

                          borderRadius:
                              BorderRadius.circular(25),

                          boxShadow: [

                            BoxShadow(

                              color: Colors.black.withOpacity(.18),

                              blurRadius: 15,

                              offset: const Offset(0, 8),

                            ),

                          ],

                        ),

                        child: ClipRRect(

                          borderRadius:
                              BorderRadius.circular(25),

                          child: Stack(

                            fit: StackFit.expand,

                            children: [

                              Image.asset(

                                banners[index],

                                fit: BoxFit.cover,

                                alignment: Alignment.topCenter,

                              ),

                              Container(

                                decoration: BoxDecoration(

                                  gradient: LinearGradient(

                                    begin: Alignment.bottomCenter,

                                    end: Alignment.topCenter,

                                    colors: [

                                      Colors.black.withOpacity(.55),

                                      Colors.transparent,

                                    ],

                                  ),

                                ),

                              ),

                              Positioned(

                                left: 22,

                                bottom: 22,

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [

                                    const Text(

                                      "MMOC Teach",

                                      style: TextStyle(

                                        color: Colors.white,

                                        fontSize: 28,

                                        fontWeight: FontWeight.bold,

                                      ),

                                    ),

                                    const SizedBox(height: 5),

                                    const Text(

                                      "Learn Anywhere • Anytime",

                                      style: TextStyle(

                                        color: Colors.white,

                                        fontSize: 15,

                                      ),

                                    ),

                                    const SizedBox(height: 15),

                                    Container(

                                      padding:
                                          const EdgeInsets.symmetric(

                                        horizontal: 18,

                                        vertical: 10,

                                      ),

                                      decoration: BoxDecoration(

                                        color: Colors.orange,

                                        borderRadius:
                                            BorderRadius.circular(30),

                                      ),

                                      child: const Text(

                                        "Start Learning",

                                        style: TextStyle(

                                          color: Colors.white,

                                          fontWeight: FontWeight.bold,

                                        ),

                                      ),

                                    ),

                                  ],

                                ),

                              ),

                            ],

                          ),

                        ),

                      ),

                    );

                  },

                ),

              ),

              const SizedBox(height: 18),

              Row(

                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: List.generate(

                  banners.length,

                  (index) {

                    return AnimatedContainer(

                      duration:
                          const Duration(milliseconds: 300),

                      margin: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),

                      width:
                          currentBanner == index ? 26 : 8,

                      height: 8,

                      decoration: BoxDecoration(

                        color: currentBanner == index
                            ? const Color(0xff1565C0)
                            : Colors.grey.shade400,

                        borderRadius:
                            BorderRadius.circular(20),

                      ),

                    );

                  },

                ),

              ),

              const SizedBox(height: 30),
                            //==================================
              // CONTINUE LEARNING
              //==================================

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Continue Learning",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(

                  gradient: const LinearGradient(
                    colors: [
                      Color(0xff1565C0),
                      Color(0xff42A5F5),
                    ],
                  ),

                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(.25),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],

                ),

                child: Row(

                  children: [

                    ClipRRect(

                      borderRadius: BorderRadius.circular(15),

                      child: Image.asset(

                        "assets/images/flutter.jpg",

                        width: 90,
                        height: 90,

                        fit: BoxFit.cover,

                      ),

                    ),

                    const SizedBox(width: 18),

                    Expanded(

                      child: Column(

                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          const Text(

                            "Flutter Development",

                            style: TextStyle(

                              color: Colors.white,

                              fontSize: 20,

                              fontWeight: FontWeight.bold,

                            ),

                          ),

                          const SizedBox(height: 8),

                          const Text(

                            "65% Completed",

                            style: TextStyle(
                              color: Colors.white70,
                            ),

                          ),

                          const SizedBox(height: 12),

                          ClipRRect(

                            borderRadius:
                                BorderRadius.circular(20),

                            child: const LinearProgressIndicator(

                              value: .65,

                              minHeight: 8,

                              backgroundColor: Colors.white24,

                              color: Colors.orange,

                            ),

                          ),

                        ],

                      ),

                    ),

                  ],

                ),

              ),

              const SizedBox(height: 35),

              //==================================
              // CATEGORIES
              //==================================

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Categories",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(

                height: 110,

                child: ListView(

                  scrollDirection: Axis.horizontal,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),

                  children: [

                    categoryCard(
                      Icons.flutter_dash,
                      "Flutter",
                      Colors.blue,
                    ),

                    categoryCard(
                      Icons.language,
                      "Web",
                      Colors.deepPurple,
                    ),

                    categoryCard(
                      Icons.storage,
                      "Firebase",
                      Colors.orange,
                    ),

                    categoryCard(
                      Icons.computer,
                      "Python",
                      Colors.green,
                    ),

                    categoryCard(
                      Icons.smart_toy,
                      "AI",
                      Colors.red,
                    ),

                    categoryCard(
                      Icons.code,
                      "Java",
                      Colors.teal,
                    ),

                  ],

                ),

              ),

              const SizedBox(height: 35),
                            //==================================
              // FEATURED COURSES
              //==================================

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Featured Courses",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 320,

                child: StreamBuilder<QuerySnapshot>(

                  stream: FirebaseFirestore.instance
                      .collection("courses")
                      .snapshots(),

                  builder: (context, snapshot) {

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No Courses Found"),
                      );
                    }

                    final courses = snapshot.data!.docs;

                    return ListView.builder(

                      scrollDirection: Axis.horizontal,

                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),

                      itemCount: courses.length,

                      itemBuilder: (context, index) {

                        final data = courses[index].data()
                            as Map<String, dynamic>;

                        if (searchText.isNotEmpty &&
                            !(data["title"] ?? "")
                                .toString()
                                .toLowerCase()
                                .contains(searchText)) {
                          return const SizedBox();
                        }

                        return SizedBox(

                          width: 230,

                          child: CourseCard(

                            course: CourseModel(

                              title: data["title"] ?? "",

                              teacher: data["teacher"] ?? "",

                              duration: data["duration"] ?? "",

                              image: data["image"] ?? "",

                              rating: (data["rating"] ?? 0)
                                  .toDouble(),

                            ),

                          ),

                        );

                      },

                    );

                  },

                ),

              ),

              const SizedBox(height: 35),

              //==================================
              // YOUR ACHIEVEMENTS
              //==================================

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Your Achievements",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Row(

                  children: [

                    Expanded(
                      child: achievementCard(
                        Icons.workspace_premium,
                        "Certificates",
                        "02",
                        Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: achievementCard(
                        Icons.local_fire_department,
                        "Learning Streak",
                        "15 Days",
                        Colors.red,
                      ),
                    ),

                  ],

                ),

              ),

              const SizedBox(height: 35),
                            //==================================
              // TOP TEACHERS
              //==================================

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Top Teachers",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                height: 125,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [

                    teacherCard(
                      "Rahul Sir",
                      "Flutter",
                      Colors.blue,
                    ),

                    teacherCard(
                      "Aman Sir",
                      "Python",
                      Colors.green,
                    ),

                    teacherCard(
                      "Rohit Sir",
                      "Java",
                      Colors.deepPurple,
                    ),

                    teacherCard(
                      "Neha Ma'am",
                      "Firebase",
                      Colors.orange,
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 35),

              //==================================
              // STUDENT REVIEWS
              //==================================

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Student Reviews",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Icon(Icons.star,color: Colors.orange),
                        Icon(Icons.star,color: Colors.orange),
                        Icon(Icons.star,color: Colors.orange),
                        Icon(Icons.star,color: Colors.orange),
                        Icon(Icons.star,color: Colors.orange),
                      ],
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Amazing learning experience. Highly recommended!",
                      style: TextStyle(fontSize: 16),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "- MMOC Student",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 35),

              //==================================
              // LATEST NOTIFICATIONS
              //==================================

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Latest Notifications",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("notifications")
                    .orderBy("createdAt", descending: true)
                    .limit(3)
                    .snapshots(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {

                      final data =
                          docs[index].data()
                              as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.notifications,
                            color: Colors.blue,
                          ),
                          title: Text(data["title"] ?? ""),
                          subtitle: Text(data["message"] ?? ""),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 30),

            ],
          ),
        ),
      ),

      //==================================
      // BOTTOM NAVIGATION
      //==================================

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: currentIndex,

        type: BottomNavigationBarType.fixed,

        selectedItemColor: const Color(0xff1565C0),

        onTap: (index) {

          setState(() {

            currentIndex = index;

          });

          if (index == 1) {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const WishlistScreen(),
              ),
            );

          }

          if (index == 2) {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const MyLearningScreen(),
              ),
            );

          }

          if (index == 3) {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const ProfileScreen(),
              ),
            );

          }

        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Wishlist",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_fill),
            label: "Learning",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),

        ],

      ),

    );
  }

  Widget categoryCard(
      IconData icon,
      String title,
      Color color) {
    return Container(
      width: 95,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget teacherCard(
      String name,
      String subject,
      Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: color,
            child: Text(
              name[0],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subject,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget achievementCard(
      IconData icon,
      String title,
      String value,
      Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}