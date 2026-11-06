
import 'package:flutter/material.dart';

import '../../models/ammonia_model.dart';
import '../../services/ammonia_service.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/drawer.dart';

//////////////////////////////////////////ALERT HISTORY PAGE//////////////////////////////////////////
class AmmoniaAlertHistoryPage extends StatefulWidget {
  const AmmoniaAlertHistoryPage({super.key});

  @override
  State<AmmoniaAlertHistoryPage> createState() =>
      _AmmoniaAlertHistoryPageState();
}

//////////////////////////////////////////ALERT HISTORY STATE//////////////////////////////////////////
class _AmmoniaAlertHistoryPageState extends State<AmmoniaAlertHistoryPage> {

  //////////////////////////////////////////BUILD PAGE//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: const MyAppBar(
        title: 'Cleaning Alert History',
        showBackButton: false,
      ),

      endDrawer: const MyDrawer(),

      body: _buildHistoryContent(),
    );
  }


  //////////////////////////////////////////HISTORY CONTENT//////////////////////////////////////////
  Widget _buildHistoryContent() {

    return StreamBuilder<List<AmmoniaAlert>>(
      stream: AmmoniaService.watchCleanAlertHistory(),

      builder: (context, snapshot) {

        // ERROR LOADING HISTORY
        if (snapshot.hasError) {
          debugPrint(
            'ERROR LOADING CLEANING HISTORY: ${snapshot.error}',
          );

          return _buildEmptyPage(
            title: 'Unable to Load History',
            message: 'Cleaning history could not be loaded.',
          );
        }

        // LOADING HISTORY
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // GET CLEANED AMMONIA ALERTS
        final alerts = snapshot.data!;

        // NO PREVIOUS ALERTS
        if (alerts.isEmpty) {
          return _buildEmptyPage(
            title: 'No Cleaning History',
            message: 'Previous cleaning alerts will appear here.',
          );
        }

        // ALERT HISTORY LIST
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),

          itemCount: alerts.length,

          separatorBuilder: (context, index) =>
              const SizedBox(height: 15),

          itemBuilder: (context, index) {

            final alert = alerts[index];

            return _buildHistoryCard(
              percentIncrease: alert.percentIncrease,
              timestamp: alert.timestamp,
              resolvedAt: alert.cleanedAt,
            );
          },
        );
      },
    );
  }


  //////////////////////////////////////////HISTORY CARD//////////////////////////////////////////
  Widget _buildHistoryCard({
    required double? percentIncrease,
    required DateTime? timestamp,
    required DateTime? resolvedAt,
  }) {

    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(25),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // AMMONIA ALERT ICON
          Container(
            width: 55,
            height: 55,

            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.warning_amber_rounded,
              color: colors.primary,
              size: 30,
            ),
          ),

          const SizedBox(width: 15),

          // ALERT INFORMATION
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                // ALERT TITLE
                Text(
                  'Time to clean!',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 8),

                // AMMONIA LEVEL
                Text(
                  percentIncrease == null
                      ? 'Ammonia level exceeded the threshold.'
                      : 'Ammonia increased by '
                        '${percentIncrease.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 12),

                // ALERT DATE
                Text(
                  timestamp == null
                      ? 'Detected: Date unavailable'
                      : 'Detected: ${_formatDate(timestamp)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                // CLEANING DATE
                if (resolvedAt != null) ...[

                  const SizedBox(height: 5),

                  Text(
                    'Cleaned: ${_formatDate(resolvedAt)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////FORMAT DATE//////////////////////////////////////////
  String _formatDate(DateTime date) {

    final localDate = date.toLocal();

    final year = localDate.year;
    final month = localDate.month.toString().padLeft(2, '0');
    final day = localDate.day.toString().padLeft(2, '0');

    final hour = localDate.hour % 12 == 0
        ? 12
        : localDate.hour % 12;

    final minute =
        localDate.minute.toString().padLeft(2, '0');

    final period =
        localDate.hour >= 12 ? 'PM' : 'AM';

    return '$year-$month-$day  $hour:$minute $period';
  }


  //////////////////////////////////////////EMPTY HISTORY PAGE//////////////////////////////////////////
  Widget _buildEmptyPage({
    required String title,
    required String message,
  }) {

    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            // HISTORY ICON
            Container(
              width: 95,
              height: 95,

              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.cleaning_services_outlined,
                size: 48,
                color: colors.primary,
              ),
            ),

            const SizedBox(height: 20),

            // EMPTY HISTORY TITLE
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 8),

            // EMPTY HISTORY DESCRIPTION
            Text(
              message,
              textAlign: TextAlign.center,
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

}
