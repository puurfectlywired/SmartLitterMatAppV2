
import 'package:flutter/material.dart';

import '../../models/cat_profile.dart';
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

  ////////////////////////////////////////////LOAD DATA//////////////////////////////////////////
  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final profiles = await ProfileService.getProfiles();
      final alerts = await AmmoniaService.getAlerts();

      if (!mounted) return;

      setState(() {
        catProfiles = profiles;
        ammoniaAlerts = alerts;
        isLoading = false;
      });
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
    return Scaffold(

      // APP BAR
      appBar: const MyAppBar(
        title: 'Alerts',
      ),

      endDrawer: const MyDrawer(),

      body: Column(
        children: [

          const SizedBox(height: 20),

          // AMMONIA AND CAT PROFILE TABS
          LayoutBuilder(
            builder: (context, constraints) {

              final int tabCount = catProfiles.length + 1;

              const double minTabWidth = 100;

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

          const SizedBox(height: 20),

          // ALERT CONTENT
          Expanded(
            child: _buildAlertContent(),
          ),
        ],
      ),

      bottomNavigationBar: const MyBottomNavBar(
        selectedIndex: 3,
      ),
    );
  }

  ////////////////////////////////////////////ALERT CONTENT//////////////////////////////////////////
  Widget _buildAlertContent() {

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (loadError != null) {
      return Center(
        child: Text(loadError!),
      );
    }

    // Ammonia alerts are currently the only implemented alert type.
    // Cat-specific alert data can be added through another service.
    final List<AmmoniaAlert> visibleAlerts =
        selectedCatId == null ? ammoniaAlerts : [];

    if (visibleAlerts.isEmpty) {
      return _buildEmptyPage();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: visibleAlerts.length,
      itemBuilder: (context, index) {

        final alert = visibleAlerts[index];

        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.warning_amber_rounded,
            ),

            title: Text(
              'Ammonia: ${alert.status}',
            ),

            subtitle: Text(
              alert.timestamp.toLocal().toString(),
            ),
          ),
        );
      },
    );
  }

  ////////////////////////////////////////////EMPTY PAGE//////////////////////////////////////////
  Widget _buildEmptyPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Icon(
            Icons.notifications,
            size: 80,
          ),

          const SizedBox(height: 20),

          const Text(
            'All caught up!', //change this phrasing later
            style: TextStyle(
              fontSize: 20,
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
                ? const Color(0xFFFFA6C9)
                : Colors.transparent,

            borderRadius: BorderRadius.circular(30),
          ),

          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: selected
                  ? Colors.black
                  : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
