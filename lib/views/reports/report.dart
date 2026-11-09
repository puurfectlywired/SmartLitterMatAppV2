
import 'package:flutter/material.dart';

//models
import '../../models/cat_profile_model.dart';
import '../../models/cat_report_model.dart';

//services
import '../../services/cat_report_service.dart';


import '../../widgets/bottom_nav_bar.dart';
import '../../other/global_variables.dart';
import '../../other/cat_age_formatter.dart';




//////////////////////////////////////////REPORT PAGE//////////////////////////////////////////
class ReportPage extends StatefulWidget {

  final CatProfile cat;
  final DateTime startDate;
  final DateTime endDate;

  // OPTIONAL SAVED REPORT
  final SavedCatReport? savedReport;

  const ReportPage({
    super.key,
    required this.cat,
    required this.startDate,
    required this.endDate,
    this.savedReport,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}



//////////////////////////////////////////REPORT PAGE STATE//////////////////////////////////////////
class _ReportPageState extends State<ReportPage> {

  late Future<CatReportData> reportFuture;

  bool isSaving = false;
  bool hasSaved = false;

  @override
  void initState() {
    super.initState();

    // SAVED REPORTS USE THEIR ORIGINAL DATA
    if (widget.savedReport != null) {

      reportFuture = Future.value(
        widget.savedReport!.reportData,
      );

      hasSaved = true;

    } else {

      // NEW REPORTS LOAD CURRENT DATA
      reportFuture = CatReportService.getReportData(
        catId: widget.cat.id,
        startDate: widget.startDate,
        endDate: widget.endDate,
      );
    }
  }



  //////////////////////////////////////////FORMAT REPORT DATE//////////////////////////////////////////
  String _formatReportDate(DateTime date) {

    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }


  //////////////////////////////////////////FORMAT WEIGHT//////////////////////////////////////////
  String _formatWeight(double? weight) {

    if (weight == null) return '—';

    return displayWeight(weight);
  }


  //////////////////////////////////////////FORMAT WEIGHT CHANGE//////////////////////////////////////////
  String _formatWeightChange(double? change) {

    if (change == null) return '—';

    final prefix = change > 0 ? '+' : '';

    return '$prefix${displayWeight(change)}';
  }


  //////////////////////////////////////////FORMAT DECIMAL//////////////////////////////////////////
  String _formatDecimal(double? value) {

    if (value == null) return '—';

    return value.toStringAsFixed(1);
  }


  //////////////////////////////////////////FORMAT COUNT//////////////////////////////////////////
  String _formatCount(int? value) {

    if (value == null) return '—';

    return value.toString();
  }


  //////////////////////////////////////////PDF PLACEHOLDER//////////////////////////////////////////
  void _showPdfPlaceholder() {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF generation is not available yet.'),
      ),
    );
  }


  //////////////////////////////////////////SAVE REPORT//////////////////////////////////////////
  Future<void> _saveReport(CatReportData data) async {

    if (isSaving || hasSaved) return;

    setState(() {
      isSaving = true;
    });

    try {

      // CREATE A PERMANENT REPORT SNAPSHOT
      final report = SavedCatReport(
        id: '',
        catId: widget.cat.id,
        catName: widget.cat.name,
        breed: widget.cat.breed,
        sex: widget.cat.sex,
        ageLabel: formatCatAge(widget.cat.birthday),
        startDate: widget.startDate,
        endDate: widget.endDate,
        generatedAt: DateTime.now(),
        reportData: data,
      );

      // SAVE TO FIRESTORE
      await CatReportService.saveReport(report);

      if (!mounted) return;

      setState(() {
        hasSaved = true;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report saved to Report History.'),
        ),
      );

    } catch (e) {

      debugPrint('ERROR SAVING REPORT: $e');

      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save report.'),
        ),
      );
    }
  }


  //////////////////////////////////////////BUILD PAGE//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'Health Report',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            color: colors.primary,
            tooltip: 'Save as PDF',
            onPressed: _showPdfPlaceholder,
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: FutureBuilder<CatReportData>(
        future: reportFuture,

        builder: (context, snapshot) {

          // LOADING REPORT
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ERROR LOADING REPORT
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load report data.',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                ),
              ),
            );
          }

          final report = snapshot.data ?? const CatReportData();

          return _buildReportContent(report);
        },
      ),

      bottomNavigationBar: const MyBottomNavBar(),
    );
  }


  //////////////////////////////////////////REPORT CONTENT//////////////////////////////////////////
  Widget _buildReportContent(CatReportData report) {

    final colors = Theme.of(context).colorScheme;
    
    // USE SAVED PROFILE INFORMATION WHEN REOPENING A REPORT
    final saved = widget.savedReport;

    final reportCatName = saved?.catName ?? widget.cat.name;
    final reportBreed = saved?.breed ?? widget.cat.breed;
    final reportSex = saved?.sex ?? widget.cat.sex;
    final reportAge = saved?.ageLabel ??
        formatCatAge(widget.cat.birthday);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // REPORT HEADER
          Center(
            child: Column(
              children: [

                Container(
                  width: 75,
                  height: 75,

                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),

                  child: Icon(
                    Icons.pets_rounded,
                    size: 40,
                    color: colors.primary,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  reportCatName,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Health Report',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '${_formatReportDate(widget.startDate)} – '
                  '${_formatReportDate(widget.endDate)}',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // CAT INFORMATION
          _ReportCard(
            title: 'Profile',

            child: Column(
              children: [

                _ReportRow(
                  label: 'Breed',
                  value: reportBreed.isEmpty
                      ? 'Not provided'
                      : reportBreed,
                ),

                _ReportRow(
                  label: 'Sex',
                  value: reportSex,
                ),

                _ReportRow(
                  label: 'Age',
                  value: reportAge,
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // SUMMARY
          _ReportCard(
            title: 'Summary',

            child: Row(
              children: [

                _ReportStat(
                  value: _formatWeight(report.endingWeight),
                  label: 'End Weight',
                ),

                const _VerticalDivider(),

                _ReportStat(
                  value: _formatDecimal(report.averageVisitsPerDay),
                  label: 'Avg. Visits/Day',
                ),

                const _VerticalDivider(),

                _ReportStat(
                  value: '—',   //replace with line below later
                  //value: report.alerts.length.toString(),
                  label: 'Alerts',
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // WEIGHT
          _ReportCard(
            title: 'Weight',

            child: Column(
              children: [

                _ReportRow(
                  label: 'Start of period',
                  value: _formatWeight(report.startingWeight),
                ),

                _ReportRow(
                  label: 'End of period',
                  value: _formatWeight(report.endingWeight),
                ),

                _ReportRow(
                  label: 'Change',
                  value: _formatWeightChange(report.weightChange),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,

                  child: Text(
                    report.startingWeight == null ||
                            report.endingWeight == null
                        ? 'Weight data is not available for this period.'
                        : 'Weight measurements for the selected period.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // LITTER BOX ACTIVITY
          _ReportCard(
            title: 'Litter Box Activity',

            child: Column(
              children: [

                _ReportRow(
                  label: 'Total visits',
                  value: _formatCount(report.totalVisits),
                ),

                _ReportRow(
                  label: 'Daily average',
                  value: report.averageVisitsPerDay == null
                      ? '—'
                      : '${_formatDecimal(report.averageVisitsPerDay)} visits',
                ),

                _ReportRow(
                  label: 'Highest daily count',
                  value: report.highestDailyVisits == null
                      ? '—'
                      : '${report.highestDailyVisits} visits',
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // WEIGHT AND FREQUENCY ALERT HISTORY
          _ReportCard(
            title: 'Weight & Frequency Alerts',

            child: report.alerts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ),

                    child: Center(
                      child: Column(
                        children: [

                          Icon(
                            Icons.notifications_none_rounded,
                            size: 38,
                            color: colors.primary,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'No alert data available',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [

                      for (int i = 0; i < report.alerts.length; i++) ...[

                        if (i > 0)
                          const Divider(height: 24),

                        _ReportAlert(
                          icon: report.alerts[i].type ==
                                  CatReportAlertType.weight
                              ? Icons.monitor_weight_outlined
                              : Icons.pets,
                          title: report.alerts[i].title,
                          date: _formatReportDate(
                            report.alerts[i].timestamp.toLocal(),
                          ),
                        ),
                      ],
                    ],
                  ),
          ),

          const SizedBox(height: 25),

          // SAVE REPORT BUTTON
          SizedBox(
            width: double.infinity,
            height: 55,

            child: ElevatedButton.icon(
              onPressed: isSaving || hasSaved
                  ? null
                  : () => _saveReport(report),

              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                disabledBackgroundColor: colors.surfaceContainerHigh,
                disabledForegroundColor: colors.onSurfaceVariant,
                elevation: 0,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              icon: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      hasSaved
                          ? Icons.check_circle_outline
                          : Icons.save_outlined,
                      size: 22,
                    ),

              label: Text(
                isSaving
                    ? 'Saving Report...'
                    : hasSaved
                        ? 'Report Saved'
                        : 'Save Report',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),


          const SizedBox(height: 25),
        ],
      ),
    );
  }
}


/////////////////////////////////////////////REPORT CARD/////////////////////////////////////////////
class _ReportCard extends StatelessWidget {

  final String title;
  final Widget child;

  const _ReportCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(25),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // CARD TITLE
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}


/////////////////////////////////////////////REPORT ROW/////////////////////////////////////////////
class _ReportRow extends StatelessWidget {

  final String label;
  final String value;

  const _ReportRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),

      child: Row(
        children: [

          // ROW LABEL
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ROW VALUE
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/////////////////////////////////////////////REPORT STAT/////////////////////////////////////////////
class _ReportStat extends StatelessWidget {

  final String value;
  final String label;

  const _ReportStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // STAT VALUE
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),

          const SizedBox(height: 7),

          // STAT LABEL
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}


/////////////////////////////////////////////VERTICAL DIVIDER/////////////////////////////////////////////
class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 1,
      height: 48,
      color: colors.outlineVariant,
    );
  }
}


/////////////////////////////////////////////REPORT ALERT/////////////////////////////////////////////
class _ReportAlert extends StatelessWidget {

  final IconData icon;
  final String title;
  final String date;

  const _ReportAlert({
    required this.icon,
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        // ALERT ICON
        Container(
          width: 42,
          height: 42,

          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),

          child: Icon(
            icon,
            size: 23,
            color: colors.primary,
          ),
        ),

        const SizedBox(width: 15),

        // ALERT INFORMATION
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
