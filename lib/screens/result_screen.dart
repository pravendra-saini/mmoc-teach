import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (score / total) * 100;
    final bool passed = percentage >= 40;

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),
      appBar: AppBar(
        title: const Text("Quiz Result"),
        backgroundColor: const Color(0xff1565C0),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    passed ? Icons.emoji_events : Icons.cancel,
                    size: 90,
                    color: passed ? Colors.amber : Colors.red,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    passed ? "Congratulations 🎉" : "Better Luck Next Time",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  Text(
                    "Score : $score / $total",
                    style: const TextStyle(fontSize: 22),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "Percentage : ${percentage.toStringAsFixed(1)}%",
                    style: const TextStyle(fontSize: 20),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    passed ? "PASS ✅" : "FAIL ❌",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: passed ? Colors.green : Colors.red,
                    ),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1565C0),
                        minimumSize: const Size.fromHeight(50),
                      ),
                      onPressed: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: const Text(
                        "Back To Home",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}