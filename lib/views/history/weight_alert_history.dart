
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/cat_profile_model.dart';
import '../../services/cat_profile_service.dart';
import '../../services/alert_history_service.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/drawer.dart';

//////////////////////////////////////////WEIGHT HISTORY PAGE//////////////////////////////////////////
class WeightAlertHistoryPage extends StatefulWidget {
  const WeightAlertHistoryPage({super.key});

  @override
  State<WeightAlertHistoryPage> createState() =>
      _WeightAlertHistoryPageState();
}

//////////////////////////////////////////WEIGHT HISTORY STATE//////////////////////////////////////////
class _WeightAlertHistoryPageState extends State<WeightAlertHistoryPage> {

  String? selectedCatId;

  List<CatProfile> catProfiles = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCatProfiles();
  }

  //////////////////////////////////////////LOAD CAT PROFILES//////////////////////////////////////////
  Future<void> _loadCatProfiles() async {

    try {

      final profiles = await ProfileService.getProfiles();

      if (!mounted) return;

      setState(() {
        catProfiles = profiles;

        // SELECT FIRST CAT BY DEFAULT
        if (profiles.isNotEmpty) {
          selectedCatId = profiles.first.id;
        }

        isLoading = false;
      });

    } catch (e) {

      debugPrint('ERROR LOADING CAT PROFILES: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  //////////////////////////////////////////BUILD PAGE//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: const MyAppBar(
        title: 'Weight Alert History',
        showBackButton: false,
      ),

      endDrawer: const MyDrawer(),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [

                // CAT PROFILE TABS
                _buildCatTabs(),

                const SizedBox(height: 25),

                // WEIGHT HISTORY
                Expanded(
                  child: _buildHistoryContent(),
                ),
              ],
            ),
    );
  }

  //////////////////////////////////////////CAT PROFILE TABS//////////////////////////////////////////
  Widget _buildCatTabs() {

    if (catProfiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: LayoutBuilder(
        builder: (context, constraints) {

          final tabCount = catProfiles.length;

          const minTabWidth = 110.0;

          final tabWidth =
              constraints.maxWidth / tabCount;

          final effectiveTabWidth =
              tabWidth < minTabWidth
                  ? minTabWidth
                  : tabWidth;

          return SizedBox(
            height: 60,

            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,

              child: Row(
                children: catProfiles.map((cat) {

                  return SizedBox(
                    width: effectiveTabWidth,

                    child: _catTab(
                      title: cat.name,
                      catId: cat.id,
                    ),
                  );

                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  //////////////////////////////////////////CAT TAB//////////////////////////////////////////
  Widget _catTab({
    required String title,
    required String catId,
  }) {

    final colors = Theme.of(context).colorScheme;

    final selected = selectedCatId == catId;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCatId = catId;
        });
      },

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
        ),

        child: Container(
          height: double.infinity,
          alignment: Alignment.center,

          decoration: BoxDecoration(
            color: selected
                ? colors.surfaceContainerHigh
                : Colors.transparent,

            borderRadius: BorderRadius.circular(22),
          ),

          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,

            style: TextStyle(
              fontSize: 15,

              fontWeight: selected
                  ? FontWeight.w600
                  : FontWeight.normal,

              color: selected
                  ? colors.primary
                  : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////HISTORY CONTENT//////////////////////////////////////////
  Widget _buildHistoryContent() {

    //final colors = Theme.of(context).colorScheme;

    // NO CAT PROFILES
    if (catProfiles.isEmpty || selectedCatId == null) {
      return _buildEmptyPage(
        title: 'No Cat Profiles',
        message: 'Create a cat profile to view weight history.',
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: AlertHistoryService.watchAlertHistory(),

      builder: (context, snapshot) {

        // ERROR LOADING HISTORY
        if (snapshot.hasError) {

          debugPrint('ERROR LOADING WEIGHT HISTORY: ${snapshot.error}');

          return _buildEmptyPage(
            title: 'Unable to Load History',
            message: 'Weight alert history could not be loaded.',
          );
        }

        // LOADING HISTORY
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // ONLY SHOW WEIGHT ALERTS FOR SELECTED CAT
        final alerts = snapshot.data!.docs.where((doc) {

          final data = doc.data();

          return data['type'] == 'weight' &&
              data['catId'] == selectedCatId;

        }).toList();

        // SORT ALERTS BY DATE - NEWEST FIRST
        alerts.sort((a, b) {

          final aTime =
              (a.data()['timestamp'] as Timestamp?)
                  ?.toDate() ?? DateTime(1970);

          final bTime =
              (b.data()['timestamp'] as Timestamp?)
                  ?.toDate() ?? DateTime(1970);

          return bTime.compareTo(aTime);
        });

        // NO PREVIOUS WEIGHT ALERTS
        if (alerts.isEmpty) {
          return _buildEmptyPage(
            title: 'No Weight History',
            message: 'Previous weight alerts will appear here.',
          );
        }

        // WEIGHT HISTORY LIST
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),

          itemCount: alerts.length,

          separatorBuilder: (context, index) =>
              const SizedBox(height: 15),

          itemBuilder: (context, index) {

            final data = alerts[index].data();

            final timestamp =
                (data['timestamp'] as Timestamp?)
                    ?.toDate();

            final resolvedAt =
                (data['resolvedAt'] as Timestamp?)
                    ?.toDate();

            final title =
                data['title'] as String? ??
                'Weight Change Detected';

            final description =
                data['description'] as String? ??
                'An unusual weight change was detected.';

            return _buildHistoryCard(
              title: title,
              description: description,
              timestamp: timestamp,
              resolvedAt: resolvedAt,
            );
          },
        );
      },
    );
  }

  //////////////////////////////////////////HISTORY CARD//////////////////////////////////////////
  Widget _buildHistoryCard({
    required String title,
    required String description,
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

          // WEIGHT ALERT ICON
          Container(
            width: 55,
            height: 55,

            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.monitor_weight_outlined,
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
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 8),

                // ALERT DESCRIPTION
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 12),

                // DETECTION DATE
                Text(
                  timestamp == null
                      ? 'Detected: Date unavailable'
                      : 'Detected: ${_formatDate(timestamp)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurfaceVariant,
                  ),
                ),

                // RESOLVED DATE
                if (resolvedAt != null) ...[

                  const SizedBox(height: 5),

                  Text(
                    'Resolved: ${_formatDate(resolvedAt)}',
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
                Icons.monitor_weight_outlined,
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
