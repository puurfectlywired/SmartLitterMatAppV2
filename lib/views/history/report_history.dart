
import 'package:flutter/material.dart';

import '../reports/report.dart';

import '../../models/cat_profile_model.dart';
import '../../models/cat_report_model.dart';

import '../../services/cat_profile_service.dart';
import '../../services/cat_report_service.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/drawer.dart';

//////////////////////////////////////////REPORT HISTORY PAGE//////////////////////////////////////////
class ReportHistoryPage extends StatefulWidget {
  const ReportHistoryPage({super.key});

  @override
  State<ReportHistoryPage> createState() =>
      _ReportHistoryPageState();
}

//////////////////////////////////////////REPORT HISTORY STATE//////////////////////////////////////////
class _ReportHistoryPageState extends State<ReportHistoryPage> {

  String? selectedCatId;

  List<CatProfile> catProfiles = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCatProfiles();
  }

  //////////////////////////////////////////FORMAT DATE//////////////////////////////////////////
  String _formatDate(DateTime date) {

    final localDate = date.toLocal();

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr',
      'May', 'Jun', 'Jul', 'Aug',
      'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final month = months[localDate.month - 1];

    return '$month ${localDate.day}, ${localDate.year}';
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
        title: 'Report History',
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

                // REPORT HISTORY
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

    // NO CAT PROFILES
    if (catProfiles.isEmpty || selectedCatId == null) {
      return _buildEmptyPage(
        title: 'No Cat Profiles',
        message: 'Create a cat profile to view report history.',
      );
    }

    // LOAD REPORTS FOR SELECTED CAT
    return StreamBuilder<List<SavedCatReport>>(
      key: ValueKey(selectedCatId),

      stream: CatReportService.watchReportHistory(
        selectedCatId!,
      ),

      builder: (context, snapshot) {

        // ERROR LOADING REPORTS
        if (snapshot.hasError) {

          debugPrint(
            'ERROR LOADING REPORT HISTORY: ${snapshot.error}',
          );

          return _buildEmptyPage(
            title: 'Unable to Load Reports',
            message: 'Report history could not be loaded.',
          );
        }

        // LOADING REPORTS
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final reports = snapshot.data!;

        // NO SAVED REPORTS
        if (reports.isEmpty) {
          return _buildEmptyPage(
            title: 'No Reports Yet',
            message: 'Previously saved reports will appear here.',
          );
        }

        // SAVED REPORT LIST
        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),

          itemCount: reports.length,

          separatorBuilder: (context, index) =>
              const SizedBox(height: 15),

          itemBuilder: (context, index) {

            final report = reports[index];

            return _buildReportCard(report);
          },
        );
      },
    );
  }


  //////////////////////////////////////////REPORT HISTORY CARD//////////////////////////////////////////
  Widget _buildReportCard(SavedCatReport report) {

    final colors = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(25),

      // OPEN SAVED REPORT
      onTap: () {

        final matchingCats = catProfiles.where(
          (cat) => cat.id == report.catId,
        ).toList();

        if (matchingCats.isEmpty) return;

        final cat = matchingCats.first;

        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,

            pageBuilder: (
              context,
              animation,
              secondaryAnimation,
            ) => ReportPage(
              cat: cat,
              startDate: report.startDate,
              endDate: report.endDate,
              savedReport: report,
            ),
          ),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(25),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // REPORT ICON
            Container(
              width: 55,
              height: 55,

              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.description_outlined,
                color: colors.primary,
                size: 28,
              ),
            ),

            const SizedBox(width: 15),

            // REPORT INFORMATION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    'Health Report',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${_formatDate(report.startDate)} – '
                    '${_formatDate(report.endDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Saved ${_formatDate(report.generatedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // OPEN REPORT ARROW
            Icon(
              Icons.chevron_right_rounded,
              color: colors.primary,
              size: 25,
            ),
          ],
        ),
      ),
    );
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

            // REPORT HISTORY ICON
            Container(
              width: 95,
              height: 95,

              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),

              child: Icon(
                Icons.description_outlined,
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
