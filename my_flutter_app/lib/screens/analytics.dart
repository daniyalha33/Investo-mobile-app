import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatefulWidget {
  @override
  _AnalyticsPageState createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  List<dynamic> rankData = [];
  List<dynamic> depositData = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAllAnalytics();
  }

  Future<void> fetchAllAnalytics() async {
    setState(() => loading = true);

    final rankUrl = Uri.parse('http://192.168.59.199:5000/analytics/users-by-rank');
    final depositUrl = Uri.parse('http://192.168.59.199:5000/analytics/personal-deposit-by-user');

    try {
      final responses = await Future.wait([
        http.get(rankUrl),
        http.get(depositUrl),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final rankJson = json.decode(responses[0].body);
        final depositJson = json.decode(responses[1].body);

        setState(() {
          rankData = rankJson;
          depositData = depositJson;
          loading = false;
        });
      } else {
        print('Failed to load analytics data');
        setState(() => loading = false);
      }
    } catch (e) {
      print('Error fetching analytics: $e');
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator());

    if (rankData.isEmpty) return Center(child: Text('No rank data available'));
    if (depositData.isEmpty) return Center(child: Text('No deposit data available'));

    // --- Prepare rank pie chart data ---
    final ranks = rankData.map((item) => item['_id'] as String).toList();
    final counts = rankData.map((item) => (item['count'] as num).toDouble()).toList();
    final totalCounts = counts.reduce((a, b) => a + b);

    // --- Prepare deposit bar chart data ---
    final names = depositData.map((item) => item['name'] as String? ?? 'Unknown').toList();
    final deposits = depositData.map((item) => (item['personalDeposit'] as num?)?.toDouble() ?? 0.0).toList();
    // --- Calculate dynamic interval and maxY ---
    final double maxDeposit = deposits.isNotEmpty
        ? deposits.reduce((a, b) => a > b ? a : b)
        : 0;
    final double interval = maxDeposit == 0 ? 1 : (maxDeposit / 5).ceilToDouble();
    final double maxY = maxDeposit + interval;

    return Scaffold(
      appBar: AppBar(title: Text('User Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// PIE CHART - User by Rank
            Text('User Distribution by Rank', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.3,
              child: PieChart(
                PieChartData(
                  sections: List.generate(ranks.length, (index) {
                    final percent = (counts[index] / totalCounts * 100).toStringAsFixed(1);
                    return PieChartSectionData(
                      value: counts[index],
                      title: '$percent%',
                      color: _getColor(index),
                      radius: 80,
                      titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: List.generate(ranks.length, (index) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, color: _getColor(index)),
                    SizedBox(width: 5),
                    Text(ranks[index]),
                  ],
                );
              }),
            ),
            SizedBox(height: 40),

            /// BAR CHART - Personal Deposit by Name
  /// BAR CHART - Personal Deposit by Name
/// BAR CHART - Personal Deposit by Name
Text('Personal Deposit by Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
SizedBox(height: 16),
AspectRatio(
  aspectRatio: 1.6,
  child: BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: interval,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
          ),
        ),
       bottomTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    getTitlesWidget: (value, meta) {
      int index = value.toInt();
      if (index < 0 || index >= names.length) return Container();

      return SideTitleWidget(
        meta: meta,
        space: 4,
        child: Text(
          names[index],
          style: TextStyle(fontSize: 10),
        ),
      );
    },
    interval: 1,
    reservedSize: 42,
  ),
),

        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barTouchData: BarTouchData(enabled: true),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(deposits.length, (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: deposits[index],
              width: 20,
              color: Colors.teal,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        );
      }),
    ),
  ),
),


          ],
        ),
      ),
    );
  }

  Color _getColor(int index) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.cyan,
      Colors.amber,
      Colors.indigo,
      Colors.teal,
      Colors.brown,
    ];
    return colors[index % colors.length];
  }
}
