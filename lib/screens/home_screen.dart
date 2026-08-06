import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/course_model.dart';
import '../widgets/course_card.dart';

import 'login_screen.dart';
import 'profile_screen.dart';
import 'wishlist_screen.dart';
import 'my_learning_screen.dart';
import 'admin_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentIndex = 0;

  String searchText = "";

  String userName = "Student";

  final PageController pageController = PageController();

  int currentBanner = 0;

  final List<String> banners = [

    "assets/images/banner1.jpg",

    "assets/images/banner2.jpg",

    "assets/images/banner3.jpg",

  ];

  @override
  void initState() {
    super.initState();

    loadUser();

    Timer.periodic(
      const Duration(seconds: 3),
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

  Future<void> loadUser() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data();

    setState(() {

      userName = data?["name"] ?? "Student";

    });
  }

  @override
  void dispose() {

    pageController.dispose();

    super.dispose();
  }

  //==============================
  // PART 2 
  //==============================

    @override
  Widget build(BuildContext context) {

    final hour = DateTime.now().hour;

    String greeting = "Good Evening";

    if (hour < 12) {
      greeting = "Good Morning";
    } else if (hour < 17) {
      greeting = "Good Afternoon";
    }

    return Scaffold(

      backgroundColor: const Color(0xffF4F7FC),

      appBar: AppBar(

        automaticallyImplyLeading: false,

        elevation: 0,

        toolbarHeight: 90,

        backgroundColor: const Color(0xff1565C0),

        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              greeting,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              "$userName 👋",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),

          ],
        ),

        actions: [

          if (FirebaseAuth.instance.currentUser?.email ==
              "pravendrasaini303@gmail.com")

            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AdminDashboard(),
                  ),
                );

              },
            ),

          IconButton(

            icon: const Icon(Icons.notifications_none),

            onPressed: () {

            },

          ),

          Padding(

            padding: const EdgeInsets.only(right: 15),

            child: GestureDetector(

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const ProfileScreen(),

                  ),

                );

              },

              child: const CircleAvatar(

                backgroundColor: Colors.white,

                child: Icon(

                  Icons.person,

                  color: Color(0xff1565C0),

                ),

              ),

            ),

          ),

        ],

      ),

      body: SingleChildScrollView(

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const SizedBox(height: 20),

            Padding(

              padding:
                  const EdgeInsets.symmetric(horizontal: 18),

              child: Text(

                "Keep Learning Every Day 🚀",

                style: TextStyle(

                  color: Colors.grey.shade700,

                  fontSize: 16,

                ),

              ),

            ),

            const SizedBox(height: 20),

            Padding(

              padding:
                  const EdgeInsets.symmetric(horizontal: 18),

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

//==============================
// PART 3 
//==============================

            //==========================
            // PREMIUM BANNER SLIDER
            //==========================

            SizedBox(
              height: 190,

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
                            BorderRadius.circular(22),

                        image: DecorationImage(

                          image: AssetImage(
                            banners[index],
                          ),

                          fit: BoxFit.cover,

                        ),

                        boxShadow: [

                          BoxShadow(

                            color: Colors.black.withOpacity(.20),

                            blurRadius: 12,

                            offset: const Offset(0, 5),

                          ),

                        ],

                      ),

                    ),

                  );

                },

              ),

            ),

            const SizedBox(height: 15),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: List.generate(

                banners.length,

                (index) {

                  return AnimatedContainer(

                    duration:
                        const Duration(milliseconds: 300),

                    margin:
                        const EdgeInsets.symmetric(horizontal: 4),

                    height: 8,

                    width:
                        currentBanner == index ? 28 : 8,

                    decoration: BoxDecoration(

                      color: currentBanner == index
                          ? Colors.blue
                          : Colors.grey.shade400,

                      borderRadius:
                          BorderRadius.circular(20),

                    ),

                  );

                },

              ),

            ),

            const SizedBox(height: 30),

            Padding(

              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),

              child: Row(

                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: const [

                  Text(

                    "Continue Learning",

                    style: TextStyle(

                      fontSize: 22,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                  Text(

                    "See All",

                    style: TextStyle(

                      color: Colors.blue,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                ],

              ),

            ),

            const SizedBox(height: 15),

            Padding(

              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),

              child: Card(

                elevation: 8,

                shape: RoundedRectangleBorder(

                  borderRadius:
                      BorderRadius.circular(20),

                ),

                child: Padding(

                  padding: const EdgeInsets.all(18),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(

                        "Flutter Development",

                        style: TextStyle(

                          fontSize: 20,

                          fontWeight: FontWeight.bold,

                        ),

                      ),

                      const SizedBox(height: 8),

                      const Text(

                        "Lesson 8 of 20",

                      ),

                      const SizedBox(height: 15),

                      ClipRRect(

                        borderRadius:
                            BorderRadius.circular(20),

                        child: const LinearProgressIndicator(

                          value: .40,

                          minHeight: 10,

                        ),

                      ),

                      const SizedBox(height: 18),

                      SizedBox(

                        width: double.infinity,

                        child: ElevatedButton.icon(

                          style:
                              ElevatedButton.styleFrom(

                            backgroundColor:
                                Colors.blue,

                            foregroundColor:
                                Colors.white,

                          ),

                          onPressed: () {},

                          icon: const Icon(
                            Icons.play_arrow,
                          ),

                          label: const Text(

                            "Continue",

                          ),

                        ),

                      ),

                    ],

                  ),

                ),

              ),

            ),

            const SizedBox(height: 30),

//==============================
// PART 4 
//==============================

            //==========================
            // FEATURED COURSES
            //==========================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: const [

                  Text(
                    "Featured Courses",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "View All",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 270,

              child: StreamBuilder<QuerySnapshot>(

                stream: FirebaseFirestore.instance
                    .collection("courses")
                    .snapshots(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {

                    return const Center(
                      child: CircularProgressIndicator(),
                    );

                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(

                    scrollDirection: Axis.horizontal,

                    itemCount: docs.length,

                    itemBuilder: (context, index) {

                      final data = docs[index].data()
                          as Map<String, dynamic>;

                      return SizedBox(

                        width: 220,

                        child: CourseCard(

                          course: CourseModel(

                            title: data["title"],

                            teacher: data["teacher"],

                            duration: data["duration"],

                            image: data["image"],

                            rating:
                                (data["rating"] as num)
                                    .toDouble(),

                          ),

                        ),

                      );

                    },

                  );

                },

              ),

            ),

            const SizedBox(height: 30),

            //==========================
            // CATEGORIES
            //==========================

            const Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 18),

              child: Text(

                "Categories",

                style: TextStyle(

                  fontSize: 22,

                  fontWeight: FontWeight.bold,

                ),

              ),

            ),

            const SizedBox(height: 18),

            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18),

              child: Wrap(

                spacing: 15,

                runSpacing: 15,

                children: [

                  categoryCard(
                    Icons.phone_android,
                    "Flutter",
                    Colors.blue,
                  ),

                  categoryCard(
                    Icons.language,
                    "Web",
                    Colors.orange,
                  ),

                  categoryCard(
                    Icons.code,
                    "Python",
                    Colors.green,
                  ),

                  categoryCard(
                    Icons.storage,
                    "Firebase",
                    Colors.red,
                  ),

                  categoryCard(
                    Icons.smart_display,
                    "YouTube",
                    Colors.purple,
                  ),

                  categoryCard(
                    Icons.computer,
                    "Java",
                    Colors.teal,
                  ),

                ],

              ),

            ),

            const SizedBox(height: 35),

//==============================
// PART 5 
//==============================

            //==========================
            // ACHIEVEMENTS
            //==========================

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                "Your Achievements",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
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

                  const SizedBox(width: 12),

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

            const SizedBox(height: 30),

            //==========================
            // TOP TEACHERS
            //==========================

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                "Top Teachers",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 18),

            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [

                  teacherCard(
                    "Flutter Expert",
                    Icons.person,
                    Colors.blue,
                  ),

                  teacherCard(
                    "Python Mentor",
                    Icons.person,
                    Colors.green,
                  ),

                  teacherCard(
                    "Java Trainer",
                    Icons.person,
                    Colors.orange,
                  ),

                  teacherCard(
                    "Firebase Pro",
                    Icons.person,
                    Colors.red,
                  ),

                ],
              ),
            ),

            const SizedBox(height: 30),

            //==========================
            // STUDENT REVIEWS
            //==========================

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                "Student Reviews",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text("Rahul Sharma"),
                  subtitle: Text(
                    "Best learning platform. The courses are amazing and easy to understand. ⭐⭐⭐⭐⭐",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),

//==============================
// PART 6 
//==============================

            //==========================
            // LATEST NOTIFICATIONS
            //==========================

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                "Latest Notifications",
                style: TextStyle(
                  fontSize: 22,
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

                if (docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(18),
                    child: Text("No Notifications"),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {

                    final data =
                        docs[index].data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 18,
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
    );
  }

  //==========================
  // CATEGORY CARD
  //==========================

  Widget categoryCard(
    IconData icon,
    String title,
    Color color,
  ) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            icon,
            size: 35,
            color: color,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  //==========================
  // TEACHER CARD
  //==========================

  Widget teacherCard(
    String name,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(left: 18),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //==========================
  // ACHIEVEMENT CARD
  //==========================

  Widget achievementCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            Icon(
              icon,
              color: color,
              size: 35,
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(title),
          ],
        ),
      ),
    );
  }
}
