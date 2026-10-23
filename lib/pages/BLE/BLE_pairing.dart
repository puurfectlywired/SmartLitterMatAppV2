
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../../theme/app_colours.dart';

//models
import '../../models/cat_profile.dart';

//services
import '../../services/BLE_pairing_service.dart';

///////////////////////////////////////////BLE PAIRING PAGE///////////////////////////////////////////
class BlePairingPage extends StatefulWidget {
  final CatProfile cat;

  const BlePairingPage({
    super.key,
    required this.cat,
  });

  @override
  State<BlePairingPage> createState() => _BlePairingPageState();
}


//////////////////////////////////////////BLE PAIRING PAGE STATE////////////////////////
class _BlePairingPageState extends State<BlePairingPage> {

  String? activeRequestId;
  String scanStatus = 'idle';

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    scanSubscription;

  //temp active listener (probably use in future)
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
    firebaseTestSubscription;

  // ble tags
  List<Map<String, String>> availableTags = [];

  String? selectedTagId;

  //temp
  @override
  void initState() {
    super.initState();
    _startFirebaseListener();
  }

  //sends request and listens for a response
  Future<void> _startFirebaseScan() async {
    try {
      await scanSubscription?.cancel();

      setState(() {
        scanStatus = 'sending';
        activeRequestId = null;
        selectedTagId = null;
        availableTags.clear();
      });

      // REPLACE WITH THE ACTUAL MAT ID
      final requestId = await BlePairingService.requestScan(
        catId: widget.cat.id,
        deviceId: 'mat001',
      );

      if (!mounted) return;

      setState(() {
        activeRequestId = requestId;
        scanStatus = 'pending';
      });

      debugPrint('BLE SCAN REQUEST SENT: $requestId');

      // LISTEN FOR UPDATES FROM THE RASPBERRY PI
      scanSubscription =
          BlePairingService.watchRequest(requestId).listen(
        (snapshot) {
          if (!mounted || !snapshot.exists) return;

          final data = snapshot.data();
          if (data == null) return;

          final status = data['status'] as String? ?? 'pending';

          setState(() {
            scanStatus = status;
          });

          debugPrint('BLE SCAN STATUS: $status');
          debugPrint('DETECTED TAGS: ${data['detectedTags']}');
        },
        onError: (error) {
          debugPrint('BLE SCAN LISTENER ERROR: $error');

          if (mounted) {
            setState(() {
              scanStatus = 'error';
            });
          }
        },
      );

    } catch (e) {
      debugPrint('BLE SCAN REQUEST ERROR: $e');

      if (!mounted) return;

      setState(() {
        scanStatus = 'error';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not start BLE scan: $e'),
        ),
      );
    }
  }


  //dispose of 
  @override
  void dispose() {
    scanSubscription?.cancel();
    firebaseTestSubscription?.cancel();
    super.dispose();
  }


  // TEMPORARY PAIRING FUNCTION
  void _pairTag() {
    if (selectedTagId == null) return;

    final selectedTag = availableTags.firstWhere(
      (tag) => tag['id'] == selectedTagId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${selectedTag['name']} selected for ${widget.cat.name} (demo only)',
        ),
      ),
    );
  }

  // // TEMPORARY SCANNING FUNCTION
  // void _scanForTags() {
  //   setState(() {
  //     selectedTagId = null;
  //   });

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(
  //       content: Text('Scanning for BLE tags (demo only)'),
  //     ),
  //   );
  // }


//TEST TEMP FIREBASE LISTENER
void _startFirebaseListener() {

  firebaseTestSubscription?.cancel();

  firebaseTestSubscription = FirebaseFirestore.instance
      .collection('device_commands')
      .doc('mat001')
      .snapshots()
      .listen((snapshot) {

    if (!snapshot.exists) return;

    final data = snapshot.data();
    if (data == null) return;

    debugPrint('FIREBASE DOCUMENT UPDATED');
    debugPrint('COMMAND: ${data['command']}');
    debugPrint('STATUS: ${data['status']}');
    debugPrint('REQUEST ID: ${data['request_id']}');
    debugPrint('TEST MESSAGE: ${data['flutter_test_message']}');

  }, onError: (error) {
    debugPrint('FIREBASE LISTENER ERROR: $error');
  });
}


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final appColors = Theme.of(context).extension<AppColors>()!;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        title: const Text('Pair BLE Tag'),
        centerTitle: true,
        backgroundColor: colors.surface,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 25,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              //BLUETOOTH ICON
              Center(
                child: Container(
                  width: 110,
                  height: 110,

                  decoration: BoxDecoration(
                    color: appColors.bleIconBackground,
                    shape: BoxShape.circle,
                  ),

                  child: Icon(
                    Icons.bluetooth_searching,
                    size: 55,
                    color: appColors.bleIcon,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              //TITLE
              Text(
                'Connect a Tracking Tag',
                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Pair a BLE tracking tag with ${widget.cat.name}\'s profile '
                'to identify them when they use the mat.',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 35),

              //INSTRUCTIONS
              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(25),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colors.primary,
                          size: 22,
                        ),

                        const SizedBox(width: 10),

                        Text(
                          'Before You Begin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Make sure your tracking tag is powered on '
                      'and within Bluetooth range of the scanning device.',

                      style: TextStyle(
                        fontSize: 14,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              //CONNECTED BLE TAG
              if (user != null)
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('cats')
                      .doc(widget.cat.id)
                      .snapshots(),

                  builder: (context, snapshot) {

                    final data = snapshot.data?.data();

                    final bleStatus =
                        data?['ble_status'] as String? ?? 'unpaired';

                    final bleMac =
                        data?['ble_mac'] as String?;

                    final bleRssi =
                        data?['ble_rssi'];

                    if (bleStatus != 'connected' || bleMac == null) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        Text(
                          'Connected Tag',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Container(
                          padding: const EdgeInsets.all(20),

                          decoration: BoxDecoration(
                            color: colors.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Row(
                            children: [

                              Icon(
                                Icons.bluetooth_connected,
                                size: 32,
                                color: colors.primary,
                              ),

                              const SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      'BLE Tracking Tag',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colors.onSurface,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Text(
                                      'MAC: $bleMac',
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),

                                    if (bleRssi != null)
                                      Text(
                                        'Signal: $bleRssi dBm',
                                        style: TextStyle(
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 35),
                      ],
                    );
                  },
                ),

              //AVAILABLE TAGS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Text(
                    'Available Tags',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),

                  Text(
                    '${availableTags.length} found',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              //TAG LIST
              ...availableTags.map((tag) {

                final isSelected = selectedTagId == tag['id'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),

                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),

                    onTap: () {
                      setState(() {
                        selectedTagId = tag['id'];
                      });
                    },

                    child: Container(
                      padding: const EdgeInsets.all(15),

                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),

                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outlineVariant,
                          width: isSelected ? 2 : 1,
                        ),
                      ),

                      child: Row(
                        children: [

                          Container(
                            width: 48,
                            height: 48,

                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(15),
                            ),

                            child: Icon(
                              Icons.bluetooth,
                              color: colors.onPrimaryContainer,
                              size: 25,
                            ),
                          ),

                          const SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  tag['name']!,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurface,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  tag['signal']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,

                            color: isSelected
                                ? colors.primary
                                : colors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 25),

              //PAIR BUTTON
              SizedBox(
                height: 50,

                child: ElevatedButton.icon(
                  onPressed: selectedTagId == null
                      ? null
                      : _pairTag,

                  icon: const Icon(
                    Icons.link,
                    size: 20,
                  ),

                  label: const Text('Pair Selected Tag'),
                ),
              ),

              const SizedBox(height: 12),

              //SCAN AGAIN BUTTON
              SizedBox(
                height: 50,

                child: OutlinedButton.icon(
                  onPressed:
                    scanStatus == 'pending' ||
                    scanStatus == 'scanning' ||
                    scanStatus == 'sending'
                      ? null
                      : _startFirebaseScan,

                  icon: const Icon(
                    Icons.refresh,
                    size: 20,
                  ),

                  label: Text(
                    scanStatus == 'sending' ||
                    scanStatus == 'pending'
                        ? 'Waiting for Raspberry Pi...'
                        : scanStatus == 'scanning'
                            ? 'Scanning...'
                            : 'Scan for Tags',
                  ),
                ),
              ),

              //TEST FIREBASE BUTTON
              //const SizedBox(height: 12),

              // SizedBox(
              //   height: 50,
              //   child: OutlinedButton.icon(
              //     onPressed: () async {
              //       try {
              //         final data =
              //             await BlePairingService.testFirebaseConnection();

              //         if (!context.mounted) return;

              //         ScaffoldMessenger.of(context).showSnackBar(
              //           SnackBar(
              //             content: Text(
              //               'Firebase connected! Status: ${data['status']}',
              //             ),
              //           ),
              //         );

              //       } catch (e) {
              //         debugPrint('FIREBASE TEST ERROR: $e');

              //         if (!context.mounted) return;

              //         ScaffoldMessenger.of(context).showSnackBar(
              //           SnackBar(
              //             content: Text('Firebase connection failed: $e'),
              //           ),
              //         );
              //       }
              //     },

              //     icon: const Icon(Icons.cloud_done),

              //     label: const Text('Test Firebase Connection'),
              //   ),
              // ),



              //const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
