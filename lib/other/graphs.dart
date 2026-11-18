
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

//models
import '../models/cat_profile_model.dart';
import '../models/weight_measurement_model.dart';
import '../models/litter_visit_model.dart';

//services
import '../services/weight_measurement_service.dart';
import '../services/litter_visit_service.dart';

//widgets
import '../widgets/latest_weight.dart';




//////////////////////////////////////////WEEKLY VISITS GRAPH//////////////////////////////////////////
class WeeklyVisitsChart extends StatefulWidget {

  final CatProfile cat;

  const WeeklyVisitsChart({
    super.key,
    required this.cat,
  });

  @override
  State<WeeklyVisitsChart> createState() =>
      _WeeklyVisitsChartState();
}


//////////////////////////////////////////WEEKLY VISITS STATE//////////////////////////////////////////
class _WeeklyVisitsChartState extends State<WeeklyVisitsChart> {

  String selectedRange = '7D';

  late Stream<List<DailyLitterVisits>> visitStream;

  late DateTime startDate;
  late DateTime endDate;

  int numberOfDays = 7;


  @override
  void initState() {
    super.initState();

    _loadVisitHistory();
  }


  @override
  void didUpdateWidget(
    covariant WeeklyVisitsChart oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.cat.id != widget.cat.id) {
      _loadVisitHistory();
    }
  }


  //////////////////////////////////////////LOAD VISIT HISTORY//////////////////////////////////////////
  void _loadVisitHistory() {

    final now = DateTime.now();

    // DETERMINE SELECTED TIME RANGE
    switch (selectedRange) {

      case '30D':
        numberOfDays = 30;
        break;

      case '90D':
        numberOfDays = 90;
        break;

      case '1Y':
        numberOfDays = 365;
        break;

      default:
        numberOfDays = 7;
    }

    // START OF FIRST DAY
    startDate = DateTime(
      now.year,
      now.month,
      now.day - (numberOfDays - 1),
    );

    // END OF TODAY
    endDate = DateTime(
      now.year,
      now.month,
      now.day + 1,
    ).subtract(
      const Duration(microseconds: 1),
    );

    // WATCH FIREBASE VISIT DATA
    visitStream = LitterVisitService.watchVisitHistory(
      catId: widget.cat.id,
      startDate: startDate,
      endDate: endDate,
    );
  }


  //////////////////////////////////////////CHANGE TIME RANGE//////////////////////////////////////////
  void _changeRange(String value) {

    setState(() {

      selectedRange = value;

      _loadVisitHistory();

    });
  }


  //////////////////////////////////////////FORMAT DATE LABEL//////////////////////////////////////////
  String _formatDateLabel(DateTime date) {

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'May', 'Jun', 'Jul', 'Aug',
      'Sep', 'Oct', 'Nov', 'Dec',
    ];

    if (selectedRange == '1Y') {
      return months[date.month - 1];
    }

    return '${months[date.month - 1]} ${date.day}';
  }


  //////////////////////////////////////////GET DAY INDEX//////////////////////////////////////////
  int _getDayIndex(DateTime date) {

    final localDate = date.toLocal();

    // USE CALENDAR DATES TO AVOID DAYLIGHT SAVING ISSUES
    final firstDay = DateTime.utc(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    final measurementDay = DateTime.utc(
      localDate.year,
      localDate.month,
      localDate.day,
    );

    return measurementDay.difference(firstDay).inDays;
  }


  //////////////////////////////////////////BUILD CARD//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        20, 22, 20, 20,
      ),

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
                onChanged: _changeRange,
              ),

            ],
          ),

          const SizedBox(height: 30),

          // FIREBASE VISIT DATA
          StreamBuilder<List<DailyLitterVisits>>(
            key: ValueKey(
              '${widget.cat.id}_$selectedRange',
            ),

            stream: visitStream,

            builder: (context, snapshot) {

              // LOADING STATE
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {

                return const SizedBox(
                  height: 160,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // ERROR STATE
              if (snapshot.hasError) {

                debugPrint(
                  'Error loading litter visits: '
                  '${snapshot.error}',
                );

                return SizedBox(
                  height: 160,
                  child: Center(
                    child: Text(
                      'Unable to load visit data.',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              final visitData = snapshot.data ?? [];

              // EMPTY STATE
              if (visitData.isEmpty) {

                return SizedBox(
                  height: 160,
                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        Icon(
                          Icons.bar_chart,
                          size: 35,
                          color: colors.onSurfaceVariant,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'No visit data available',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              }

              return _buildVisitGraph(
                visitData,
                colors,
              );
            },
          ),

        ],
      ),
    );
  }


  //////////////////////////////////////////BUILD VISIT GRAPH//////////////////////////////////////////
  Widget _buildVisitGraph(
    List<DailyLitterVisits> visitData,
    ColorScheme colors,
  ) {

    // GROUP DAILY DATA ACCORDING TO TIME RANGE
    //
    // 7D = DAILY TOTALS
    // 30D / 90D = WEEKLY TOTALS
    // 1Y = 30-DAY TOTALS

    final int daysPerGroup = selectedRange == '7D'
        ? 1
        : selectedRange == '1Y'
            ? 30
            : 7;

    final int groupCount =
        (numberOfDays / daysPerGroup).ceil();

    // INITIALIZE GRAPH GROUPS
    final visits = List<int>.filled(
      groupCount,
      0,
    );

    final hasData = List<bool>.filled(
      groupCount,
      false,
    );

    // ADD FIREBASE VISITS TO CORRECT GROUP
    for (final visit in visitData) {

      final dayIndex = _getDayIndex(visit.date);

      if (dayIndex < 0 ||
          dayIndex >= numberOfDays) {
        continue;
      }

      final groupIndex = dayIndex ~/ daysPerGroup;

      visits[groupIndex] += visit.visitCount;

      hasData[groupIndex] = true;
    }

    // GENERATE DATE LABELS
    final labels = List.generate(
      groupCount,
      (index) {

        final date = DateTime(
          startDate.year,
          startDate.month,
          startDate.day + (index * daysPerGroup),
        );

        return _formatDateLabel(date);
      },
    );

    // DYNAMIC Y AXIS
    final maxValue = visits.reduce(
      (a, b) => a > b ? a : b,
    );

    final double interval = maxValue <= 10
        ? 2.0
        : (maxValue / 4).ceilToDouble();

    final double maxY =
        ((maxValue / interval).ceil() + 1) * interval;


    //////////////////////////////////////////BAR GRAPH//////////////////////////////////////////
    return SizedBox(
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

          borderData: FlBorderData(
            show: false,
          ),

          // AXIS LABELS
          titlesData: FlTitlesData(

            topTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
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

                  // REDUCE LABEL CROWDING
                  if ((selectedRange == '7D' ||
                      selectedRange == '90D' ||
                      selectedRange == '1Y') &&
                      index.isOdd) {

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

                    width: selectedRange == '90D' ||
                           selectedRange == '1Y'
                        ? 10
                        : 18,

                    color: colors.primary,

                    borderRadius:
                        const BorderRadius.only(

                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),

                    ),
                  ),

                ],

                // DO NOT SHOW TOOLTIPS FOR MISSING DATA
                showingTooltipIndicators: const [],
              );
            },
          ),

          barTouchData: BarTouchData(
            enabled: true,

            touchTooltipData: BarTouchTooltipData(

              getTooltipItem: (
                group,
                groupIndex,
                rod,
                rodIndex,
              ) {

                if (!hasData[groupIndex]) {
                  return null;
                }

                return BarTooltipItem(
                  '${visits[groupIndex]} visits',

                  TextStyle(
                    color: colors.onSurface,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
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
class CurrentStatusCard extends StatefulWidget {
  final CatProfile cat;

  const CurrentStatusCard({
    super.key,
    required this.cat,
  });

  @override
  State<CurrentStatusCard> createState() =>
      _CurrentStatusCardState();
}

//////////////////////////////////////////CURRENT STATUS STATE///////////////////////////
class _CurrentStatusCardState extends State<CurrentStatusCard> {

  late Stream<List<DailyLitterVisits>> visitStream;

  //INITIALIZE STREAM
  @override
  void initState() {
    super.initState();

    _loadStatusData();
  }

  // UPDATE CAT
  @override
  void didUpdateWidget(
    covariant CurrentStatusCard oldWidget,
  ) {

    super.didUpdateWidget(oldWidget);

    if (oldWidget.cat.id != widget.cat.id) {

      _loadStatusData();
    }
  }

  //////////////////////////////////////////LOAD STATUS DATA//////////////////////////////////////////
  void _loadStatusData() {

    final now = DateTime.now();

    // START OF 7-DAY PERIOD
    final startDate = DateTime(
      now.year,
      now.month,
      now.day - 6,
    );

    // END OF TODAY
    final endDate = DateTime(
      now.year,
      now.month,
      now.day + 1,
    ).subtract(
      const Duration(microseconds: 1),
    );

    // WATCH FIREBASE VISIT DATA
    visitStream =
        LitterVisitService.watchVisitHistory(
      catId: widget.cat.id,
      startDate: startDate,
      endDate: endDate,
    );
  }

  //////////////////////////////////////////FORMAT COUNT//////////////////////////////////////////
  String _formatCount(int? value) {

    if (value == null) return '—';

    return value.toString();
  }

  //////////////////////////////////////////FORMAT DECIMAL//////////////////////////////////////////
  String _formatDecimal(double? value) {

    if (value == null) return '—';

    return value.toStringAsFixed(1);
  }

  //////////////////////////////////////////BUILD CARD//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return StreamBuilder<List<DailyLitterVisits>>(

    stream: visitStream,

    builder: (context, snapshot) {

      // DEFAULT VALUES WHEN DATA IS UNAVAILABLE
      String visitsToday = '—';
      String dailyAverage = '—';

      // USE FIREBASE DATA WHEN AVAILABLE
      if (snapshot.hasData && !snapshot.hasError) {

        final litterVisits = snapshot.data!;

        if (litterVisits.isNotEmpty) {

          final now = DateTime.now();

          // GET TODAY'S VISIT COUNT
          final today = DateTime(
            now.year,
            now.month,
            now.day,
          );

          int todayCount = 0;

          for (final day in litterVisits) {

            final visitDate = DateTime(
              day.date.year,
              day.date.month,
              day.date.day,
            );

            if (visitDate == today) {

              todayCount = day.visitCount;

              break;
            }
          }

          visitsToday = _formatCount(todayCount);


          // CALCULATE TOTAL VISITS
          final totalVisits = litterVisits.fold<int>(
            0,
            (total, day) =>
                total + day.visitCount,
          );


          // COUNT DAYS WITH RECORDED VISITS
          final daysWithVisits = litterVisits
              .where((day) => day.visitCount > 0)
              .length;


          // CALCULATE DAILY AVERAGE
          final double? averageVisitsPerDay =
              daysWithVisits == 0
                  ? null
                  : totalVisits / daysWithVisits;

          dailyAverage = _formatDecimal(
            averageVisitsPerDay,
          );
        }
      }

      // PRINT ANY FIREBASE ERRORS
      if (snapshot.hasError) {

        debugPrint(
          'Error loading current status: '
          '${snapshot.error}',
        );
      }

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

                    LatestWeight(
                      key: ValueKey(widget.cat.id),
                      catId: widget.cat.id,
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
                      visitsToday,
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
                      dailyAverage,
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
      },
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

  late Stream<List<WeightMeasurement>> weightStream;

  late DateTime startDate;
  late DateTime endDate;

  int numberOfDays = 7;

  //////////////////////////////////////////INITIALIZE GRAPH//////////////////////////////////////////
  @override
  void initState() {
    super.initState();

    _loadWeightHistory();
  }

  //////////////////////////////////////////UPDATE CAT//////////////////////////////////////////
  @override
  void didUpdateWidget(covariant WeightTrendCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.cat.id != widget.cat.id) {
      _loadWeightHistory();
    }
  }

  //////////////////////////////////////////LOAD WEIGHT HISTORY//////////////////////////////////////////
  void _loadWeightHistory() {

    final now = DateTime.now();

    // DETERMINE SELECTED TIME RANGE
    switch (selectedRange) {

      case '30D':
        numberOfDays = 30;
        break;

      case '90D':
        numberOfDays = 90;
        break;

      case '1Y':
        numberOfDays = 365;
        break;

      default:
        numberOfDays = 7;
    }

    // START OF SELECTED PERIOD
    startDate = DateTime(
      now.year,
      now.month,
      now.day - (numberOfDays - 1),
    );

    // END OF TODAY
    endDate = DateTime(
      now.year,
      now.month,
      now.day + 1,
    ).subtract(
      const Duration(microseconds: 1),
    );

    // WATCH FIREBASE WEIGHT MEASUREMENTS
    weightStream = WeightService.watchWeightHistory(
      catId: widget.cat.id,
      startDate: startDate,
      endDate: endDate,
    );
  }

  //////////////////////////////////////////CHANGE TIME RANGE//////////////////////////////////////////
  void _changeRange(String value) {

    setState(() {

      selectedRange = value;

      _loadWeightHistory();
    });
  }

  //////////////////////////////////////////FORMAT DATE LABEL//////////////////////////////////////////
  String _formatDateLabel(DateTime date) {

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'May', 'Jun', 'Jul', 'Aug',
      'Sep', 'Oct', 'Nov', 'Dec',
    ];

    if (selectedRange == '1Y') {
      return months[date.month - 1];
    }

    return '${months[date.month - 1]} ${date.day}';
  }

  //////////////////////////////////////////X AXIS INTERVAL//////////////////////////////////////////
  double _getXInterval() {

    switch (selectedRange) {

      case '30D':
        return 7;

      case '90D':
        return 21;

      case '1Y':
        return 60;

      default:
        return 2;
    }
  }

  //////////////////////////////////////////GET MEASUREMENT POSITION//////////////////////////////////////////
  double _getMeasurementX(DateTime timestamp) {

    final date = timestamp.toLocal();

    // USE CALENDAR DAYS TO AVOID DAYLIGHT SAVING ISSUES
    final firstDay = DateTime.utc(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    final measurementDay = DateTime.utc(
      date.year,
      date.month,
      date.day,
    );

    final days = measurementDay
        .difference(firstDay)
        .inDays;

    // INCLUDE TIME OF DAY
    final fractionOfDay =
        (date.hour * 60 + date.minute +
            date.second / 60) / 1440.0;

    return days + fractionOfDay;
  }

  //////////////////////////////////////////BUILD GRAPH CARD//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.fromLTRB(
        20, 22, 20, 20,
      ),

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
                onChanged: _changeRange,
              ),
            ],
          ),

          const SizedBox(height: 30),

          // FIREBASE WEIGHT DATA
          StreamBuilder<List<WeightMeasurement>>(
            key: ValueKey(
              '${widget.cat.id}_$selectedRange',
            ),

            stream: weightStream,

            builder: (context, snapshot) {

              // LOADING
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {

                return const SizedBox(
                  height: 160,

                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // ERROR LOADING DATA
              if (snapshot.hasError) {

                return SizedBox(
                  height: 160,

                  child: Center(
                    child: Text(
                      'Unable to load weight data.',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }

              final measurements =
                  snapshot.data ?? [];

              // NO WEIGHT MEASUREMENTS
              if (measurements.isEmpty) {

                return SizedBox(
                  height: 160,

                  child: Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        Icon(
                          Icons.monitor_weight_outlined,
                          size: 35,
                          color: colors.primary,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'No weight data available',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // DISPLAY WEIGHT GRAPH
              return _buildWeightGraph(
                measurements,
              );
            },
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////WEIGHT TREND GRAPH//////////////////////////////////////////
  Widget _buildWeightGraph(
    List<WeightMeasurement> measurements,
  ) {

    final colors = Theme.of(context).colorScheme;

    // CREATE GRAPH POINTS
    final spots = measurements.map((measurement) {

      return FlSpot(
        _getMeasurementX(measurement.timestamp),

        measurement.weight,
      );

    }).toList();

    // GET MINIMUM AND MAXIMUM WEIGHTS
    final weightData = measurements
        .map((measurement) => measurement.weight)
        .toList();

    final minWeight =
        weightData.reduce((a, b) => a < b ? a : b);

    final maxWeight =
        weightData.reduce((a, b) => a > b ? a : b);

    // DYNAMIC Y AXIS
    final weightRange = maxWeight - minWeight;

    final padding = weightRange > 0.8
        ? weightRange * 0.15
        : 0.2;

    final minY = (minWeight - padding)
        .clamp(0.0, double.infinity)
        .toDouble();

    final maxY = maxWeight + padding;

    final yInterval = (maxY - minY) / 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // WEIGHT UNIT
        Text(
          'Weight (lb)',
          style: TextStyle(
            fontSize: 11,
            color: colors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 8),

        // LINE GRAPH
        SizedBox(
          height: 160,

          child: LineChart(
            LineChartData(

              minX: 0,
              maxX: numberOfDays.toDouble(),

              minY: minY,
              maxY: maxY,

              // GRID LINES
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: yInterval,

                getDrawingHorizontalLine: (value) {

                  return FlLine(
                    color: colors.outlineVariant,
                    strokeWidth: 1,
                  );
                },
              ),

              borderData: FlBorderData(
                show: false,
              ),

              // AXIS LABELS
              titlesData: FlTitlesData(

                topTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),

                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: false,
                  ),
                ),

                // Y AXIS
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: yInterval,

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
                    interval: _getXInterval(),

                    getTitlesWidget: (value, meta) {

                      // ONLY DISPLAY DATES IN RANGE
                      if (value < 0 ||
                          value >= numberOfDays) {

                        return const SizedBox.shrink();
                      }

                      // CALCULATE DATE FROM X POSITION
                      final date = DateTime(
                        startDate.year,
                        startDate.month,
                        startDate.day + value.toInt(),
                      );

                      return Text(
                        _formatDateLabel(date),

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

                  spots: spots,

                  isCurved: true,

                  // PREVENT CURVE OVERSHOOT
                  preventCurveOverShooting: true,

                  barWidth: 3,
                  color: colors.primary,

                  // DATA POINTS
                  dotData: FlDotData(
                    show: true,

                    getDotPainter: (
                      spot,
                      percent,
                      bar,
                      index,
                    ) {

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

                    color: colors.primary.withValues(
                      alpha: 0.12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

