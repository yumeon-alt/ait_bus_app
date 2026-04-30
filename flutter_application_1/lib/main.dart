import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const MaterialApp(home: AitBusApp(), debugShowCheckedModeBanner: false));

class AitBusApp extends StatefulWidget {
  const AitBusApp({super.key});
  @override
  _AitBusAppState createState() => _AitBusAppState();
}

class _AitBusAppState extends State<AitBusApp> {
  // Aダイヤの主要な時刻表（大学→八草）[cite: 1]
  final List<String> uniToStationA = [
    "08:30", "08:35", "08:40", "08:45", "08:50", "08:55",
    "09:00", "09:05", "09:10", "09:15", "09:20", "09:25", "09:30", "09:35", "09:40", "09:50", "09:55",
    "15:00", "15:05", "15:10", "15:15", "15:30", "15:45", "16:00", "16:15"
  ];

  String nextBus = "--:--";
  String nextNextBus = "--:--";
  String countdown = "-分-秒";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => updateTime());
  }

  void updateTime() {
    final now = DateTime.now();
    String found = "本日終了";
    String foundNext = "--:--";
    String cd = "0分0秒";

    for (int i = 0; i < uniToStationA.length; i++) {
      final parts = uniToStationA[i].split(':');
      final busTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));

      if (busTime.isAfter(now)) {
        found = uniToStationA[i];
        foundNext = (i + 1 < uniToStationA.length) ? uniToStationA[i + 1] : "--:--";
        final diff = busTime.difference(now);
        cd = "${diff.inMinutes}分${diff.inSeconds % 60}秒";
        break;
      }
    }
    if (mounted) setState(() { nextBus = found; nextNextBus = foundNext; countdown = cd; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC9EBF7), // Figma全体の背景色
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 本日のダイヤ：Figma再現セクション ---
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 60, left: 20, right: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF3282B8), // 濃い青の背景
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "本日のダイヤ",
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // 白い角丸ボックス
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.calendar_today_outlined, size: 28, color: Colors.black87),
                        SizedBox(width: 12),
                        Text(
                          "Aダイヤ",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "2026年4月30日(木)",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // --- バスカード ---
            buildFigmaCard("大学 → 八草駅", nextBus, countdown, nextNextBus),
            buildFigmaCard("八草駅 → 大学", "15:30", "8分0秒", "15:40"),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF3282B8),
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: '時刻表'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'カレンダー'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }

  Widget buildFigmaCard(String title, String time, String left, String subTime) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3282B8).withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.directions_bus_filled, size: 22, color: Colors.black87),
            ],
          ),
          const SizedBox(height: 5),
          const Text(" 次のバス", style: TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Color(0xFF0F4C75))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text("あと ", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(left, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(subTime, style: const TextStyle(fontSize: 16, color: Colors.black45, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}