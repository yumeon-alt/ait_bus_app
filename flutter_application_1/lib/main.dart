import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: AitBusApp(), debugShowCheckedModeBanner: false));

class AitBusApp extends StatelessWidget {
  const AitBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD0E7FF), // Figmaで決めた薄い青
      body: Column(
        children: [
          const SizedBox(height: 60),
          // 今日のダイヤ表示
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: const [
                Icon(Icons.calendar_today, color: Color(0xFF003366)),
                SizedBox(width: 15),
                Text("Aダイヤ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          // 大学→駅のカード
          buildBusCard("大学 → 八草駅", "15:30", "8"),
          // 駅→大学のカード
          buildBusCard("八草駅 → 大学", "15:45", "23"),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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

  // カードを使い回すための部品（Widget）
  Widget buildBusCard(String title, String time, String left) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
              Text("あと $left分", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}