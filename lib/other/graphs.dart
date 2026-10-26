
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/cat_profile_model.dart';
import '../other/global_variables.dart';
//import '../services/cat_service.dart';

//line: 270, 243

//////////////////////////////////////////WEEKLY VISITS GRAPH//////////////////////////
class WeeklyVisitsChart extends StatelessWidget {
  const WeeklyVisitsChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Hard-coded demo data
    final visits = [2.0, 4.0, 3.0, 5.0, 4.0, 7.0, 6.0];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // TITLE
          const Text(
            'Litter Box Visits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Last 7 days',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 25),

          // GRAPH
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(

                minY: 0,
                maxY: 10,

                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                ),

                borderData: FlBorderData(
                  show: false,
                ),

                // X AND Y LABELS
                titlesData: FlTitlesData(

                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 2,
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,

                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();

                        if (index < 0 || index >= days.length) {
                          return const SizedBox();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[index],
                            style: const TextStyle(
                              fontSize: 11,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // DATA
                lineBarsData: [
                  LineChartBarData(

                    spots: List.generate(
                      visits.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        visits[index],
                      ),
                    ),

                    isCurved: true,
                    barWidth: 3,

                    dotData: const FlDotData(
                      show: true,
                    ),

                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFF2D5DD)
                          .withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


//////////////////////////////////////////CURRENT STATUS///////////////////////////
class CurrentStatusCard extends StatelessWidget {
  final CatProfile cat;

  const CurrentStatusCard({
    super.key,
    required this.cat,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 25,
      ),

      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(25),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [

          // WEIGHT
          Expanded(
            child: Column(
              children: [
                Text(
                  displayWeight(cat.weight),
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Weight',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // DIVIDER
          Container(
            height: 45,
            width: 1,
            color: colors.outlineVariant,
          ),

          // VISITS TODAY
          Expanded(
            child: Column(
              children: [
                Text(
                  '#',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Visits Today',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // DIVIDER
          Container(
            height: 45,
            width: 1,
            color: colors.outlineVariant,
          ),

          // DAILY AVERAGE
          Expanded(
            child: Column(
              children: [
                Text(
                  '#',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Daily Avg.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



//////////////////////////////////////////WEIGHT TREND GRAPH/////////////////////////
class WeightTrendCard extends StatelessWidget {
  final CatProfile cat;

  const WeightTrendCard({
    super.key,
    required this.cat,
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    // HARDCODED FOR DEMO
    final weightData = [
      8.70,
      8.85,
      9.10,
      9.10,
      9.15,
      9.20,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),

      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(25),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // GRAPH HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Last 7 days',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // GRAPH
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 8.2,
                maxY: 9.4,

                // GRID LINES
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.2,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: colors.outlineVariant,
                      strokeWidth: 1,
                    );
                  },
                ),

                // REMOVE BORDER
                borderData: FlBorderData(
                  show: false,
                ),

                // AXIS LABELS
                titlesData: FlTitlesData(

                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  // Y AXIS
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 0.2,

                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),

                  // X AXIS
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,

                      getTitlesWidget: (value, meta) {

                        const days = [
                          'M', 'T', 'W', 'T', 'F', 'S', 'S',
                        ];

                        final index = value.toInt();

                        if (index < 0 || index >= days.length) {
                          return const SizedBox();
                        }

                        return Text(
                          days[index],
                          style: TextStyle(
                            fontSize: 10,
                            color: colors.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // GRAPH LINE
                lineBarsData: [
                  LineChartBarData(

                    spots: List.generate(
                      weightData.length,
                      (index) => FlSpot(
                        index.toDouble(),
                        weightData[index],
                      ),
                    ),

                    isCurved: true,
                    barWidth: 3,
                    color: colors.primary,

                    // DATA POINTS
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: colors.primary,
                          strokeWidth: 0,
                        );
                      },
                    ),

                    // SHADED AREA
                    belowBarData: BarAreaData(
                      show: true,
                      color: colors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


//////////////////////////////////////////ALERT CARD////////////////////////////////
class AlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final String category;
  final Color iconColor;

  const AlertCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    required this.category,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ALERT ICON
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // ALERT INFORMATION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.chevron_right,
                      size: 20,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // GENERAL / PROFILE LABEL
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),

                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

