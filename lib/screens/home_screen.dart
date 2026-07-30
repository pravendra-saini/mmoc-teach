import 'dart:async';
import 'package:flutter/material.dart';
import '../data/course_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import '../widgets/course_card.dart';
import 'my_courses_screen.dart';
import 'wishlist_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_dashboard.dart';
import '../models/course_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  String searchText = "";
  

  final PageController _pageController = PageController();

  int currentBanner = 0;

  final List<String> banners = [
    "assets/images/banner1.jpg",
    "assets/images/banner2.jpg",
    "assets/images/banner3.jpg",
  ];

 @override
void initState() {
  super.initState();

  final user = FirebaseAuth.instance.currentUser;

  print("EMAIL: ${user?.email}");
  print("UID: ${user?.uid}");

  Timer.periodic(const Duration(seconds: 3), (timer) {
    if (_pageController.hasClients) {
      currentBanner++;

      if (currentBanner >= banners.length) {
        currentBanner = 0;
      }

      _pageController.animateToPage(
        currentBanner,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  });
}
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

    @override
Widget build(BuildContext context) {
 
  return Scaffold(
    backgroundColor: const Color(0xffF5F7FB),

    appBar: AppBar(
      backgroundColor: const Color(0xff1565C0),
      foregroundColor: Colors.white,
      elevation: 0,
      title: const Text("MMOC Teach"),
      actions: [
        IconButton(
  icon: const Icon(Icons.admin_panel_settings),
  tooltip: "Admin",
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminDashboard(),
      ),
    );
  },
),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();

            if (!mounted) return;

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
              (route) => false,
            );
          },
        ),
      ],
    ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

            // Banner Slider
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      banners[index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // Search Bar
            TextField(
              onChanged: (value) {
  setState(() {
    searchText = value.toLowerCase();
  });
},
              decoration: InputDecoration(
                hintText: "Search Courses...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const SizedBox(height: 25),
const Text(
  "Continue Watching",
  style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 15),

SizedBox(
  height: 180,
  child: StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection("enrollments")
        .where(
          "uid",
          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
        )
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final docs = snapshot.data!.docs;

      if (docs.isEmpty) {
        return const Center(
          child: Text("No Course Started Yet"),
        );
      }

      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final data =
              docs[index].data() as Map<String, dynamic>;

          final progress =
              (data["progress"] ?? 0) as int;

          return Container(
            width: 260,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    data["courseName"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 10,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "$progress% Completed",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Spacer(),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const MyCoursesScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Continue"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ),
),
  

            const Text(
              "Popular Categories",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                category(Icons.phone_android, "Flutter"),
                category(Icons.language, "Web Dev"),
                category(Icons.code, "Python"),
                category(Icons.smart_toy, "AI"),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Popular Courses",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),
SizedBox(
  height: 280,
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
          child: Text("No Courses Available"),
        );
      }

      final docs = snapshot.data!.docs;

      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final data =
              docs[index].data() as Map<String, dynamic>;

          final course = CourseModel(
            title: data["title"],
            teacher: data["teacher"],
            duration: data["duration"],
            image: data["image"],
            rating:
                (data["rating"] as num).toDouble(),
          );

          return CourseCard(
            course: course,
            color: Colors.blue,
          );
        },
      );
    },
  ),
),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xff1565C0),
        unselectedItemColor: Colors.grey,
onTap: (index) {
  setState(() {
    currentIndex = index;
  });

  // Home
  if (index == 0) {
    return;
  }

  // My Courses
  if (index == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyCoursesScreen(),
      ),
    );
  }

  // Wishlist
  if (index == 2) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WishlistScreen(),
      ),
    );
  }

  // Profile
  if (index == 3) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
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
            icon: Icon(Icons.menu_book),
            label: "Courses",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Wishlist",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget category(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 45,
            color: const Color(0xff1565C0),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}