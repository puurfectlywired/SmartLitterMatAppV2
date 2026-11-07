
import 'package:flutter/material.dart';

import '../../models/cat_profile_model.dart';

import '../../widgets/bottom_nav_bar.dart';
import '../../other/cat_age_formatter.dart';


//////////////////////////////////////////REPORT PAGE//////////////////////////////////////////
class ReportPage extends StatelessWidget {

  final CatProfile cat;

  final DateTime startDate;
  final DateTime endDate;

  const ReportPage({
    super.key,
    required this.cat,
    required this.startDate,
    required this.endDate,
  });




  //////////////////////////////////////////FORMAT REPORT DATE//////////////////////////////////////////
  String _formatReportDate(DateTime date) {

    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }




  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    void showPdfPlaceholder() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF generation is not available yet.'),
        ),
      );
    }

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

        // SAVE AS PDF ICON
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            color: colors.primary,
            tooltip: 'Save as PDF',
            onPressed: showPdfPlaceholder,
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
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
                    cat.name,
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
                    '${_formatReportDate(startDate)} – ${_formatReportDate(endDate)}',
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
                    value: cat.breed,
                  ),

                  _ReportRow(
                    label: 'Sex',
                    value: cat.sex,
                  ),

                  _ReportRow(
                    label: 'Age',
                    value: formatCatAge(cat.birthday),
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
                    value: '${cat.weight.toStringAsFixed(1)} lb',
                    label: 'Current Weight',
                  ),

                  _VerticalDivider(),

                  _ReportStat(
                    value: '3.2',
                    label: 'Avg. Visits/Day',
                  ),

                  _VerticalDivider(),

                  _ReportStat(
                    value: '4',
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

                  const _ReportRow(
                    label: 'Start of period',
                    value: '9.2 lb',
                  ),

                  _ReportRow(
                    label: 'Current',
                    value: '${cat.weight.toStringAsFixed(1)} lb',
                  ),

                  const _ReportRow(
                    label: 'Change',
                    value: '-0.4 lb',
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerLeft,

                    child: Text(
                      'Weight decreased gradually during the selected period.',
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
              child: const Column(
                children: [

                  _ReportRow(
                    label: 'Total visits',
                    value: '96',
                  ),

                  _ReportRow(
                    label: 'Daily average',
                    value: '3.2 visits',
                  ),

                  _ReportRow(
                    label: 'Highest daily count',
                    value: '7 visits',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ALERT HISTORY
            _ReportCard(
              title: 'Alerts',
              child: const Column(
                children: [

                  _ReportAlert(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Weight Decrease Detected',
                    date: 'September 29, 2026',
                  ),

                  Divider(height: 24),

                  _ReportAlert(
                    icon: Icons.pets,
                    title: 'Frequent Litter Box Visits',
                    date: 'September 28, 2026',
                  ),

                  Divider(height: 24),

                  _ReportAlert(
                    icon: Icons.air,
                    title: 'Elevated Ammonia Level',
                    date: 'September 26, 2026',
                  ),

                  Divider(height: 24),

                  _ReportAlert(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Weight Change Detected',
                    date: 'September 22, 2026',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // PDF BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: showPdfPlaceholder,

                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),

                icon: const Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 22,
                ),

                label: const Text(
                  'Save Report as PDF',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),

      bottomNavigationBar: const MyBottomNavBar(),
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
