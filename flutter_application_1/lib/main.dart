import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(const MaterialApp(home: AitBusApp(), debugShowCheckedModeBanner: false));

class AitBusApp extends StatefulWidget {
  const AitBusApp({super.key});
  @override
  _AitBusAppState createState() => _AitBusAppState();
}

class _AitBusAppState extends State<AitBusApp> {
  // 時刻表データ（Aダイヤ）[cite: 1]
  final List<String> uniToStationA = [
    "08:30", "08:35", "08:40", "08:45", "08:50", "08:55",
    "09:00", "09:05", "09:10", "09:15", "09:20", "09:25", "09:30", "09:35", "09:40", "09:50", "09:55",
    "15:00", "15:05", "15:10", "15:15", "15:30", "15:40", "15:45", "16:00", "16:15"
  ];

  // 駅から大学へのデータも追加[cite: 1]
  final List<String> stationToUniA = [
    "08:15", "08:20", "08:25", "08:30", "08:35", "08:40",
    "15:15", "15:20", "15:25", "15:30", "15:40", "15:45", "16:00", "16:15", "16:30"
  ];

  // 大学行きの状態
  String nextBusUtoS = "--:--";
  String nextNextBusUtoS = "--:--";
  String countdownUtoS = "-分-秒";

  // 駅行きの状態
  String nextBusStoU = "--:--";
  String nextNextBusStoU = "--:--";
  String countdownStoU = "-分-秒";

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => updateTime());
  }

  // バスを探す共通ロジック
  Map<String, String> getNextBusInfo(List<String> timetable, DateTime now) {
    String found = "本日終了";
    String foundNext = "--:--";
    String cd = "0分0秒";

    for (int i = 0; i < timetable.length; i++) {
      final parts = timetable[i].split(':');
      final busTime = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));

      if (busTime.isAfter(now)) {
        found = timetable[i];
        foundNext = (i + 1 < timetable.length) ? timetable[i + 1] : "--:--";
        final diff = busTime.difference(now);
        cd = "${diff.inMinutes}分${diff.inSeconds % 60}秒";
        break;
      }
    }
    return {"next": found, "nextNext": foundNext, "countdown": cd};
  }

  void updateTime() {
    final now = DateTime.now();
    final utoS = getNextBusInfo(uniToStationA, now);
    final stoU = getNextBusInfo(stationToUniA, now);

    if (mounted) {
      setState(() {
        nextBusUtoS = utoS["next"]!;
        nextNextBusUtoS = utoS["nextNext"]!;
        countdownUtoS = utoS["countdown"]!;

        nextBusStoU = stoU["next"]!;
        nextNextBusStoU = stoU["nextNext"]!;
        countdownStoU = stoU["countdown"]!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainBgColor = Color(0xFFE2F5FB); 
    const Color primaryBlue = Color(0xFF3282B8); 

    return Scaffold(
      backgroundColor: mainBgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- ヘッダー（Aダイヤ部分に枠線あり） ---
            Container(
              margin: const EdgeInsets.only(top: 60, left: 20, right: 20),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: const BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    ),
                    child: const Center(
                      child: Text("本日のダイヤ", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: mainBgColor,
                      border: Border.all(color: primaryBlue.withOpacity(0.4), width: 1.5),
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.calendar_today_outlined, size: 24, color: Colors.black87),
                            SizedBox(width: 10),
                            Text("Aダイヤ", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text("2026年4月30日(木)", style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            // --- バスカード（両方とも変数を割り当て） ---
            buildFigmaCard("大学 → 八草駅", nextBusUtoS, countdownUtoS, nextNextBusUtoS, Colors.white, primaryBlue),
            buildFigmaCard("八草駅 → 大学", nextBusStoU, countdownStoU, nextNextBusStoU, Colors.white, primaryBlue),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.white,
        selectedItemColor: primaryBlue,
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

  Widget buildFigmaCard(String title, String time, String left, String subTime, Color bgColor, Color borderColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withOpacity(0.15), width: 1.5),
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