
import 'package:flutter/material.dart';

import '../widgets/bottom_nav_bar.dart';


/////////////////////////////////////////////REPORT PAGE/////////////////////////////////////////////
class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Report'),
        centerTitle: true,

        // SAVE AS PDF ICON
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Save as PDF',
            onPressed: () {
              // PDF generation will be added later

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report saved as PDF'),
                ),
              );
            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // REPORT HEADER
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.pets,
                    size: 40,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Olive',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Health Report',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'September 1 – September 30, 2026',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CAT INFORMATION
            _ReportCard(
              title: 'Profile',
              child: Column(
                children: const [
                  _ReportRow(
                    label: 'Breed',
                    value: 'Domestic Shorthair',
                  ),
                  _ReportRow(
                    label: 'Sex',
                    value: 'Female',
                  ),
                  _ReportRow(
                    label: 'Age',
                    value: '14 years',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // SUMMARY
            _ReportCard(
              title: 'Summary',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [

                  _ReportStat(
                    value: '8.8 lb',
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

            const SizedBox(height: 12),

            // WEIGHT
            _ReportCard(
              title: 'Weight',
              child: Column(
                children: const [

                  _ReportRow(
                    label: 'Start of period',
                    value: '9.2 lb',
                  ),

                  _ReportRow(
                    label: 'Current',
                    value: '8.8 lb',
                  ),

                  _ReportRow(
                    label: 'Change',
                    value: '-0.4 lb',
                  ),

                  SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Weight decreased gradually during the selected period.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // LITTER BOX ACTIVITY
            _ReportCard(
              title: 'Litter Box Activity',
              child: Column(
                children: const [

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

            const SizedBox(height: 12),

            // ALERT HISTORY
            _ReportCard(
              title: 'Alerts',
              child: Column(
                children: const [

                  _ReportAlert(
                    icon: Icons.monitor_weight_outlined,
                    title: 'Weight Decrease Detected',
                    date: 'September 29, 2026',
                  ),

                  Divider(),

                  _ReportAlert(
                    icon: Icons.pets,
                    title: 'Frequent Litter Box Visits',
                    date: 'September 28, 2026',
                  ),

                  Divider(),

                  _ReportAlert(
                    icon: Icons.air,
                    title: 'Elevated Ammonia Level',
                    date: 'September 26, 2026',
                  ),

                  Divider(),

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
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report saved as PDF'),
                    ),
                  );
                },

                icon: const Icon(Icons.picture_as_pdf),

                label: const Text(
                  'Save Report as PDF',
                ),
              ),
            ),

            const SizedBox(height: 20),
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
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),

          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
    return Expanded(
      child: Column(
        children: [

          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
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
    return Container(
      width: 1,
      height: 42,
      color: Colors.grey[300],
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
    return Row(
      children: [

        Container(
          width: 38,
          height: 38,

          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),

          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                date,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

