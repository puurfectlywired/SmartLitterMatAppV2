
import 'package:flutter/material.dart';
import 'dart:async';

//models
import '../../models/cat_profile_model.dart';
import '../../models/ammonia_model.dart';
import '../../models/weight_alert_model.dart';
import '../../models/frequency_alert_model.dart';

//services
import '../../services/cat_profile_service.dart';
import '../../services/ammonia_service.dart';
import '../../services/weight_alert_service.dart';
import '../../services/frequency_alert_service.dart';

//widgets
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

  // weight alert listener
  StreamSubscription<List<WeightAlert>>? _weightSubscription;
  List<WeightAlert> weightAlerts = [];

  // frequency alert listener
  StreamSubscription<List<FrequencyAlert>>? _frequencySubscription;
  List<FrequencyAlert> frequencyAlerts = [];

  // cat alert loading
  String? weightLoadError;
  bool isLoadingCatAlerts = false;
  int _catLoadVersion = 0;

  //ammonia alert listener
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
    _weightSubscription?.cancel();
    _frequencySubscription?.cancel();
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




  //////////////////////////////////////////LOAD CAT ALERTS//////////////////////////////////////////
  Future<void> _loadCatAlerts(String? catId) async {

    final int loadVersion = ++_catLoadVersion;

    // CANCEL PREVIOUS CAT LISTENERS
    await _weightSubscription?.cancel();
    await _frequencySubscription?.cancel();

    _weightSubscription = null;
    _frequencySubscription = null;

    if (!mounted || loadVersion != _catLoadVersion) return;

    setState(() {
      weightAlerts = [];
      frequencyAlerts = [];
      weightLoadError = null;
      isLoadingCatAlerts = catId != null;
    });

    // AMMONIA TAB SELECTED
    if (catId == null) return;

    // CHECK BOTH ALERT TYPES
    try {

      await WeightAlertService.checkWeightHistory(catId);

      await FrequencyAlertService.checkFrequencyHistory(catId);

    } catch (e) {

      debugPrint('CAT ALERT DETECTION ERROR: $e');

      if (!mounted ||
          loadVersion != _catLoadVersion ||
          selectedCatId != catId) {
        return;
      }

      setState(() {
        weightLoadError = 'Unable to check cat health alerts.';
        isLoadingCatAlerts = false;
      });

      return;
    }

    if (!mounted ||
        loadVersion != _catLoadVersion ||
        selectedCatId != catId) {
      return;
    }

    // LISTEN FOR ACTIVE WEIGHT ALERTS
    _weightSubscription =
        WeightAlertService.watchAlerts(catId).listen(

      (alerts) {

        if (!mounted ||
            loadVersion != _catLoadVersion ||
            selectedCatId != catId) {
          return;
        }

        setState(() {
          weightAlerts = alerts;
        });
      },

      onError: (error) {

        debugPrint('WEIGHT ALERT ERROR: $error');

        if (!mounted ||
            loadVersion != _catLoadVersion ||
            selectedCatId != catId) {
          return;
        }

        setState(() {
          weightLoadError = 'Unable to load weight alerts.';
          isLoadingCatAlerts = false;
        });
      },
    );

    // LISTEN FOR ACTIVE FREQUENCY ALERTS
    _frequencySubscription =
        FrequencyAlertService.watchAlerts(catId).listen(

      (alerts) {

        if (!mounted ||
            loadVersion != _catLoadVersion ||
            selectedCatId != catId) {
          return;
        }

        setState(() {
          frequencyAlerts = alerts;
          isLoadingCatAlerts = false;
        });
      },

      onError: (error) {

        debugPrint('FREQUENCY ALERT ERROR: $error');

        if (!mounted ||
            loadVersion != _catLoadVersion ||
            selectedCatId != catId) {
          return;
        }

        setState(() {
          weightLoadError = 'Unable to load frequency alerts.';
          isLoadingCatAlerts = false;
        });
      },
    );
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

    // CAT HEALTH ALERTS - weight and frequency
    if (selectedCatId != null) {

      // ERROR LOADING ALERTS
      if (weightLoadError != null) {
        return Center(
          child: Text(weightLoadError!),
        );
      }

      // LOADING ALERTS
      if (isLoadingCatAlerts) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // COMBINE WEIGHT AND FREQUENCY ALERTS
      final List<Object> catAlerts = [
        ...weightAlerts,
        ...frequencyAlerts,
      ];

      // SORT BY TIMESTAMP - NEWEST FIRST
      catAlerts.sort((a, b) {

        final dateA = a is WeightAlert
            ? a.timestamp
            : (a as FrequencyAlert).timestamp;

        final dateB = b is WeightAlert
            ? b.timestamp
            : (b as FrequencyAlert).timestamp;

        return dateB.compareTo(dateA);
      });

      // NO ACTIVE CAT ALERTS
      if (catAlerts.isEmpty) {
        return _buildEmptyPage();
      }

      // DISPLAY ALL CAT ALERTS
      return ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),

        itemCount: catAlerts.length,

        separatorBuilder: (context, index) =>
            const SizedBox(height: 15),

        itemBuilder: (context, index) {

          final alert = catAlerts[index];

          if (alert is WeightAlert) {
            return _buildWeightAlertCard(alert);
          }

          if (alert is FrequencyAlert) {
            return _buildFrequencyAlertCard(alert);
          }

          return const SizedBox.shrink();
        },
      );
    }



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
            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(25),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ALERT INFORMATION
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ALERT TITLE
                          Text(
                            'Time to freshen up!',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ALERT DESCRIPTION
                          Text(
                            alert.percentIncrease == null
                                ? 'Your litter box may need cleaning. '
                                  'Ammonia levels are elevated.'
                                : 'Your litter box may need cleaning. '
                                  // 'Ammonia levels have increased by '
                                  // '${alert.percentIncrease!.toStringAsFixed(1)}%.'
                                  ,

                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: colors.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ALERT TIMESTAMP
                          Row(
                            children: [

                              Icon(
                                Icons.access_time_rounded,
                                size: 15,
                                color: colors.onSurfaceVariant,
                              ),

                              const SizedBox(width: 6),

                              Flexible(
                                child: Text(
                                  _formatDate(alert.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Divider(
                  height: 1,
                  color: colors.outlineVariant,
                ),

                const SizedBox(height: 14),

                // CLEANING CONFIRMATION PROMPT
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    Text(
                      'Tap to confirm cleaning',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),

                    Icon(
                      Icons.chevron_right_rounded,
                      color: colors.primary,
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


//////////////////////////////////////////WEIGHT ALERT CARD//////////////////////////////////////////
Widget _buildWeightAlertCard(WeightAlert alert) {

  final colors = Theme.of(context).colorScheme;

  final isGain = alert.type == 'gain';

  return InkWell(
    onTap: () => _acknowledgeWeightAlert(alert),

    borderRadius: BorderRadius.circular(25),

    child: Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(25),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

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

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      isGain
                          ? 'Weight Gain Detected'
                          : 'Weight Loss Detected',

                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'A weight ${isGain ? "gain" : "loss"} '
                      'of ${alert.weightChange.abs().toStringAsFixed(1)} lb '
                      'was detected over approximately one week.',

                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${alert.previousWeight.toStringAsFixed(1)} lb'
                      ' → '
                      '${alert.currentWeight.toStringAsFixed(1)} lb',

                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _formatDate(alert.timestamp),

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

          const SizedBox(height: 18),

          Divider(
            height: 1,
            color: colors.outlineVariant,
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                'Tap to acknowledge',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: colors.primary,
                size: 22,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


//////////////////////////////////////////FREQUENCY ALERT CARD//////////////////////////////////////////
Widget _buildFrequencyAlertCard(FrequencyAlert alert) {

  final colors = Theme.of(context).colorScheme;

  final isIncrease = alert.type == 'increase';

  return InkWell(
    onTap: () => _acknowledgeFrequencyAlert(alert),

    borderRadius: BorderRadius.circular(25),

    child: Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(25),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [

              Container(
                width: 55,
                height: 55,

                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  Icons.bar_chart_rounded,
                  color: colors.primary,
                  size: 30,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      isIncrease
                          ? 'Visit Frequency Increased'
                          : 'Visit Frequency Decreased',

                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Litter box visits have '
                      '${isIncrease ? "increased" : "decreased"} '
                      'by ${alert.percentChange.abs().toStringAsFixed(1)}% '
                      'compared to the previous seven-day average.',

                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${alert.currentVisits} visits '
                      '(Average: ${alert.averageVisits.toStringAsFixed(1)} visits/day)',

                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _formatDate(alert.timestamp),

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

          const SizedBox(height: 18),

          Divider(
            height: 1,
            color: colors.outlineVariant,
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                'Tap to acknowledge',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: colors.primary,
                size: 22,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}



  //////////////////////////////////////////ACKNOWLEDGE WEIGHT ALERT//////////////////////////////////////////
  Future<void> _acknowledgeWeightAlert(
    WeightAlert alert,
  ) async {

    final colors = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surfaceContainerHigh,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),

        title: const Text(
          'Acknowledge Weight Alert?',
          textAlign: TextAlign.center,
        ),

        content: const Text(
          'This alert will be moved to the cat\'s '
          'weight alert history.',
          textAlign: TextAlign.center,
        ),

        actionsAlignment: MainAxisAlignment.spaceEvenly,

        actions: [

          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),

            child: const Text('Acknowledge'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    try {

      await WeightAlertService.acknowledgeAlert(
        catId: alert.catId,
        alertId: alert.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Weight alert moved to history.'),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to acknowledge alert: $e'),
        ),
      );
    }
  }



  //////////////////////////////////////////ACKNOWLEDGE FREQUENCY ALERT//////////////////////////////////////////
  Future<void> _acknowledgeFrequencyAlert(
    FrequencyAlert alert,
  ) async {

    final colors = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surfaceContainerHigh,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),

        title: const Text(
          'Acknowledge Frequency Alert?',
          textAlign: TextAlign.center,
        ),

        content: const Text(
          'This alert will be moved to the cat\'s '
          'frequency alert history.',
          textAlign: TextAlign.center,
        ),

        actionsAlignment: MainAxisAlignment.spaceEvenly,

        actions: [

          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),

            child: const Text('Acknowledge'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    try {

      await FrequencyAlertService.acknowledgeAlert(
        catId: alert.catId,
        alertId: alert.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Frequency alert moved to history.'),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to acknowledge alert: $e'),
        ),
      );
    }
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

        _loadCatAlerts(catId);
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
