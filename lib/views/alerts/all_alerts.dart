
import 'package:flutter/material.dart';
import 'dart:async';

import '../../models/cat_profile_model.dart';
import '../../models/ammonia_model.dart';

import '../../services/cat_profile_service.dart';
import '../../services/ammonia_service.dart';

import '../../widgets/app_bar.dart';
import '../../widgets/drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

////////////////////////////////////////////ALERTS PAGE//////////////////////////////////////////
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

////////////////////////////////////////////ALERTS PAGE STATE//////////////////////////////////////////
class _AlertsPageState extends State<AlertsPage> {

  StreamSubscription<List<AmmoniaAlert>>? _ammoniaSubscription;

  String? selectedCatId;

  List<CatProfile> catProfiles = [];
  List<AmmoniaAlert> ammoniaAlerts = [];

  bool isLoading = true;
  String? loadError;

  @override
  void initState() {
    super.initState();
    _loadData();
  }


  ////////////////////////////////////////////DISPOSE//////////////////////////////////////////
  @override
  void dispose() {
    _ammoniaSubscription?.cancel();
    super.dispose();
  }

  ////////////////////////////////////////////LOAD DATA//////////////////////////////////////////
  Future<void> _loadData() async {

    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {

      // LOAD CAT PROFILES
      final profiles = await ProfileService.getProfiles();

      if (!mounted) return;

      setState(() {
        catProfiles = profiles;
        isLoading = false;
      });

      // LISTEN FOR AMMONIA ALERTS
      await _ammoniaSubscription?.cancel();

      if (!mounted) return;

      _ammoniaSubscription =
          AmmoniaService.watchAlerts().listen(

        (alerts) {

          if (!mounted) return;

          setState(() {
            ammoniaAlerts = alerts;
            loadError = null;
          });
        },

        onError: (error) {

          debugPrint('AMMONIA FIREBASE ERROR: $error');

          if (!mounted) return;

          setState(() {
            loadError = 'Unable to load ammonia alerts:\n$error';
          });
        },
      );

    } catch (e) {

      if (!mounted) return;

      setState(() {
        loadError = 'Unable to load alerts.';
        isLoading = false;
      });
    }
  }


  ////////////////////////////////////////////BUILD PAGE//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      // APP BAR
      appBar: const MyAppBar(
        title: 'Alerts',
        showBackButton: false,
      ),

      endDrawer: const MyDrawer(),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : loadError != null
              ? Center(
                  child: Text(loadError!),
                )
              : Column(
                  children: [

                    // AMMONIA AND CAT PROFILE TABS
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),

                      child: LayoutBuilder(
                        builder: (context, constraints) {

                          final int tabCount =
                              catProfiles.length + 1;

                          const double minTabWidth = 110;

                          final double tabWidth =
                              constraints.maxWidth / tabCount;

                          final double effectiveTabWidth =
                              tabWidth < minTabWidth
                                  ? minTabWidth
                                  : tabWidth;

                          return SizedBox(
                            height: 60,

                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,

                              child: Row(
                                children: [

                                  // AMMONIA TAB
                                  SizedBox(
                                    width: effectiveTabWidth,
                                    child: _alertTab(
                                      title: 'Ammonia',
                                      catId: null,
                                    ),
                                  ),

                                  // CAT PROFILE TABS
                                  ...catProfiles.map(
                                    (cat) => SizedBox(
                                      width: effectiveTabWidth,
                                      child: _alertTab(
                                        title: cat.name,
                                        catId: cat.id,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ALERT CONTENT
                    Expanded(
                      child: _buildAlertContent(),
                    ),
                  ],
                ),

      bottomNavigationBar: const MyBottomNavBar(
        selectedIndex: 2,
      ),
    );
  }

  ////////////////////////////////////////////ALERT CONTENT//////////////////////////////////////////
  Widget _buildAlertContent() {

    final colors = Theme.of(context).colorScheme;

    // AMMONIA ALERTS
    final List<AmmoniaAlert> visibleAlerts =
        selectedCatId == null ? ammoniaAlerts : [];

    if (visibleAlerts.isEmpty) {
      return _buildEmptyPage();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 10,
      ),

      itemCount: visibleAlerts.length,

      separatorBuilder: (context, index) =>
          const SizedBox(height: 15),

      itemBuilder: (context, index) {

        final alert = visibleAlerts[index];

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),

          decoration: BoxDecoration(
            color: colors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(25),
          ),

          child: Row(
            children: [

              // ALERT ICON
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      'Elevated Ammonia Detected',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      alert.percentIncrease == null
                          ? 'Ammonia level exceeded the threshold.'
                          : 'Ammonia increased by '
                            '${alert.percentIncrease!.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      alert.timestamp.toLocal().toString(),
                      style: TextStyle(
                        fontSize: 13,
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

  ////////////////////////////////////////////EMPTY PAGE//////////////////////////////////////////
  Widget _buildEmptyPage() {

    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          // NOTIFICATION ICON
          Container(
            width: 95,
            height: 95,

            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: colors.primary,
            ),
          ),

          const SizedBox(height: 20),

          // EMPTY MESSAGE
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'No new alerts to display.',
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////TOP BAR ALERT TAB//////////////////////////////////////////
  Widget _alertTab({
    required String title,
    required String? catId,
  }) {

    final colors = Theme.of(context).colorScheme;
    final bool selected = selectedCatId == catId;

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
}
