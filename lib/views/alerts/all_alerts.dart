
import 'package:flutter/material.dart';
import 'dart:async';

//import 'package:cloud_firestore/cloud_firestore.dart';

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




  //////////////////////////////////////////AMMONIA CALIBRATION//////////////////////////////////////////
  bool isCalibrating = false;

  // SEND CALIBRATION COMMAND TO FIREBASE
  Future<bool> _requestAmmoniaCalibration() async {

    if (isCalibrating) return false;

    setState(() {
      isCalibrating = true;
    });

    try {

      // REQUEST RECALIBRATION THROUGH AMMONIA SERVICE
      await AmmoniaService.requestAmmoniaCalibration();

      if (!mounted) return true;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ammonia recalibration requested. '
            'The cycle will take approximately 5 minutes.',
          ),
        ),
      );

      return true;

    } catch (e) {

      debugPrint('AMMONIA CALIBRATION ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Calibration error: $e'),
            duration: const Duration(seconds: 8),
          ),
        );
      }

      return false;

    } finally {

      if (mounted) {
        setState(() {
          isCalibrating = false;
        });
      }
    }
  }





  //////////////////////////////////////////CONFIRM LITTER BOX CLEANING//////////////////////////////////////////
  Future<void> _confirmLitterBoxCleaning(AmmoniaAlert alert) async {

    if (isCalibrating) return;

    final colors = Theme.of(context).colorScheme;

    final bool? confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) => AlertDialog(

        backgroundColor: colors.surfaceContainerHigh,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),

        title: const Text(
          'Litter Box Cleaned?',
          textAlign: TextAlign.center,
        ),

        content: const Text(
          'Have you cleaned the litter box?\n\n'
          'Confirming will request a new ammonia baseline '
          'calibration, which takes approximately 5 minutes.',
          textAlign: TextAlign.center,
        ),

        actionsAlignment: MainAxisAlignment.spaceEvenly,

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
            ),

            child: const Text('Yes, Cleaned'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    // SEND RECALIBRATION COMMAND
    final calibrationRequested =
        await _requestAmmoniaCalibration();

    if (!calibrationRequested) return;

    // SAVE SELECTED ALERT TO USER HISTORY
    try {

      await AmmoniaService.moveAlertToCleanHistory(alert.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Alert moved to Clean Alert History.',
          ),
        ),
      );

    } catch (e) {

      debugPrint('AMMONIA HISTORY ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Recalibration requested, but the alert '
            'could not be saved to history: $e',
          ),
          duration: const Duration(seconds: 8),
        ),
      );
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

        return InkWell(
          onTap: isCalibrating
              ? null
              : () => _confirmLitterBoxCleaning(alert),


          borderRadius: BorderRadius.circular(25),

          child: Container(
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
                      'Time to clean!',
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

                    // ALERT DATE
                    Text(
                      'Detected: ${_formatDate(alert.timestamp)}',
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
        ),
      );
    },
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
