
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/cat_profile_model.dart';
import '../other/global_variables.dart';
//import '../services/cat_service.dart';




//////////////////////////////////////////WEEKLY VISITS GRAPH//////////////////////////////////////////
class WeeklyVisitsChart extends StatefulWidget {
  const WeeklyVisitsChart({super.key});

  @override
  State<WeeklyVisitsChart> createState() =>
      _WeeklyVisitsChartState();
}

  //////////////////////////////////////////WEEKLY VISITS STATE//////////////////////////////////////////
  class _WeeklyVisitsChartState extends State<WeeklyVisitsChart> {

    String selectedRange = '7D';

    @override
    Widget build(BuildContext context) {

      final colors = Theme.of(context).colorScheme;

      // HARDCODED DATA FOR DEMO
      // 7D = DAILY, 30D/90D = WEEKLY, 1Y = MONTHLY
      final Map<String, List<int>> datasets = {
        '7D': [2, 4, 3, 5, 4, 7, 6],
        '30D': [25, 29, 27, 32, 8],
        '90D': [25, 28, 30, 27, 31, 29, 33, 30, 28, 32, 29, 34, 24],
        '1Y': [118, 125, 121, 130, 126, 134, 129, 137, 132, 128, 140, 135],
      };

      final visits = datasets[selectedRange]!;

      final labels = selectedRange == '7D'
          ? ['M', 'T', 'W', 'T', 'F', 'S', 'S']
          : selectedRange == '1Y'
              ? ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D']
              : List.generate(visits.length, (i) => '${i + 1}');

      final maxValue = visits.reduce((a, b) => a > b ? a : b);

      final interval = selectedRange == '7D'
          ? 2.0
          : selectedRange == '1Y'
              ? 40.0
              : 10.0;

      final maxY = ((maxValue / interval).ceil() + 1) * interval;

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

            // TIME RANGE DROPDOWN
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GraphRangeDropdown(
                  value: selectedRange,
                  onChanged: (value) {
                    setState(() {
                      selectedRange = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // BAR GRAPH
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  minY: 0,
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,

                  // GRID LINES
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colors.outlineVariant,
                        strokeWidth: 1,
                      );
                    },
                  ),

                  borderData: FlBorderData(show: false),

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
                        interval: interval,

                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
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

                          final index = value.toInt();

                          if (index < 0 ||
                              index >= labels.length ||
                              value != index.toDouble()) {
                            return const SizedBox.shrink();
                          }

                          // REDUCE LABEL CROWDING FOR 90 DAYS
                          if (selectedRange == '90D' && index.isOdd) {
                            return const SizedBox.shrink();
                          }

                          return Text(
                            labels[index],
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // BAR DATA
                  barGroups: List.generate(
                    visits.length,
                    (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: visits[index].toDouble(),
                            width: selectedRange == '90D' ? 10 : 18,
                            color: colors.primary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  barTouchData: BarTouchData(
                    enabled: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }



  //////////////////////////////////////////GRAPH TIME RANGE DROPDOWN//////////////////////////////////////////
  class GraphRangeDropdown extends StatelessWidget {

    final String value;
    final ValueChanged<String> onChanged;

    const GraphRangeDropdown({
      super.key,
      required this.value,
      required this.onChanged,
    });

    @override
    Widget build(BuildContext context) {

      final colors = Theme.of(context).colorScheme;

      const ranges = {
        '7D': 'Last 7 days',
        '30D': 'Last 30 days',
        '90D': 'Last 90 days',
        '1Y': 'Last year',
      };

      return DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        isDense: true,
        dropdownColor: colors.surfaceContainer,

        icon: Icon(
          Icons.keyboard_arrow_down,
          color: colors.onSurfaceVariant,
          size: 19,
        ),

        style: TextStyle(
          fontSize: 13,
          color: colors.onSurfaceVariant,
        ),

        items: ranges.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Text(entry.value),
          );
        }).toList(),

        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
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




//////////////////////////////////////////WEIGHT TREND GRAPH//////////////////////////////////////////
class WeightTrendCard extends StatefulWidget {

  final CatProfile cat;

  const WeightTrendCard({
    super.key,
    required this.cat,
  });

  @override
  State<WeightTrendCard> createState() =>
      _WeightTrendCardState();
}

//////////////////////////////////////////WEIGHT TREND STATE//////////////////////////////////////////
class _WeightTrendCardState extends State<WeightTrendCard> {

  String selectedRange = '7D';

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    // HARDCODED WEIGHT DATA FOR DEMO
    final Map<String, List<double>> datasets = {
      '7D': [8.70, 8.85, 9.10, 9.10, 9.15, 9.20, 9.15],
      '30D': [8.55, 8.68, 8.75, 8.92, 9.10],
      '90D': [8.40, 8.48, 8.51, 8.60, 8.58, 8.69, 8.74, 8.80, 8.83, 8.91, 9.00, 9.08, 9.20],
      '1Y': [7.80, 7.95, 8.10, 8.15, 8.30, 8.42, 8.50, 8.62, 8.74, 8.85, 9.05, 9.20],
    };

    final weightData = datasets[selectedRange]!;

    final labels = selectedRange == '7D'
        ? ['M', 'T', 'W', 'T', 'F', 'S', 'S']
        : selectedRange == '1Y'
            ? ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D']
            : List.generate(weightData.length, (i) => '${i + 1}');

    // DYNAMIC Y AXIS
    final minWeight =
        weightData.reduce((a, b) => a < b ? a : b);

    final maxWeight =
        weightData.reduce((a, b) => a > b ? a : b);

    final minY = ((minWeight - 0.2) * 5).floor() / 5;
    final maxY = ((maxWeight + 0.2) * 5).ceil() / 5;

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

          // TIME RANGE DROPDOWN
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GraphRangeDropdown(
                value: selectedRange,
                onChanged: (value) {
                  setState(() {
                    selectedRange = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 30),

          // LINE GRAPH
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: selectedRange == '7D'
                    ? 6
                    : (weightData.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,

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

                borderData: FlBorderData(show: false),

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

                        final index = value.toInt();

                        if (index < 0 ||
                            index >= labels.length ||
                            value != index.toDouble()) {
                          return const SizedBox.shrink();
                        }

                        // REDUCE LABEL CROWDING FOR 90 DAYS
                        if (selectedRange == '90D' && index.isOdd) {
                          return const SizedBox.shrink();
                        }

                        return Text(
                          labels[index],
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

