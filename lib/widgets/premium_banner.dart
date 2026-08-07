import 'package:flutter/material.dart';

class PremiumBanner extends StatelessWidget {
  final PageController controller;
  final List<String> banners;
  final int currentBanner;
  final Function(int) onPageChanged;

  const PremiumBanner({
    super.key,
    required this.controller,
    required this.banners,
    required this.currentBanner,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: controller,
            itemCount: banners.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),

                  child: Stack(
                    children: [

                      Positioned.fill(
                        child: Image.asset(
                          banners[index],
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                        ),
                      ),

                      Positioned.fill(
                        child: Container(
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
                      ),

                      Positioned(
                        left: 20,
                        bottom: 20,
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

                            const SizedBox(height: 6),

                            const Text(
                              "Learn Anywhere • Anytime",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 15),

                            Container(
                              padding: const EdgeInsets.symmetric(
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
              );
            },
          ),
        ),

        const SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin:
                    const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: currentBanner == index ? 28 : 8,
                decoration: BoxDecoration(
                  color: currentBanner == index
                      ? Colors.blue
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}