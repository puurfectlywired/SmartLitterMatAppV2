
import 'package:flutter/material.dart';
import 'dart:async';

//firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//themes
import '../../theme/app_colours.dart';

//models
import '../../models/cat_profile_model.dart';
import '../../models/ble_tag_model.dart';

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


  // BLE TAGS from model
  List<BleTag> availableTags = [];

  String? selectedTagId;

  //temp
  @override
  void initState() {
    super.initState();
    _startFirebaseListener();
  }


  // SCAN FOR NEAREST BEACON THROUGH RASPBERRY PI
  Future<void> _startFirebaseScan() async {

    if (scanStatus == 'sending' ||
        scanStatus == 'pending' ||
        scanStatus == 'scanning' ||
        scanStatus == 'pairing') {
      return;
    }

    try {
      await scanSubscription?.cancel();

      if (!mounted) return;

      setState(() {
        scanStatus = 'sending';
        activeRequestId = null;
        selectedTagId = null;
        availableTags.clear();
      });

      final requestId = await BlePairingService.requestScan(
        catId: widget.cat.id,
        catName: widget.cat.name,
        deviceId: 'mat001',
      );

      if (!mounted) return;

      setState(() {
        activeRequestId = requestId;
        scanStatus = 'pending';
      });

      debugPrint('BLE SCAN REQUEST: $requestId');

      scanSubscription = BlePairingService.watchRequest(
        requestId: requestId,
        deviceId: 'mat001',
      ).listen((snapshot) {

        if (!mounted || !snapshot.exists) return;

        final data = snapshot.data();
        if (data == null) return;

        final status = data['status'] as String? ?? 'pending';
        final response = data['response']?.toString() ?? '';

        debugPrint('BLE SCAN STATUS: $status');
        debugPrint('BLE SCAN RESPONSE: $response');
        debugPrint('BLE MAC: ${data['mac']}');
        debugPrint('BLE RSSI: ${data['rssi']}');

        if (status == 'found') {

          final mac = data['mac'];

          if (mac is! String || mac.isEmpty) {
            setState(() {
              scanStatus = 'failed';
            });
            return;
          }

          final beacon = BleTag.fromMap(data);

          setState(() {
            scanStatus = 'found';
            availableTags = [beacon];
            selectedTagId = null;
          });

        } else if (status == 'not_found' ||
                   status == 'failed' ||
                   status == 'cancelled') {

          setState(() {
            scanStatus = status;
            availableTags.clear();
            selectedTagId = null;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.isNotEmpty
                    ? response
                    : 'BLE scan $status',
              ),
            ),
          );

        } else {

          setState(() {
            scanStatus = status;
          });
        }

      }, onError: (error) {

        debugPrint('BLE SCAN LISTENER ERROR: $error');

        if (mounted) {
          setState(() {
            scanStatus = 'failed';
          });
        }
      });

    } catch (e) {

      debugPrint('BLE SCAN REQUEST ERROR: $e');

      if (!mounted) return;

      setState(() {
        scanStatus = 'failed';
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




  // CONFIRM SELECTED BEACON WITH RASPBERRY PI
  Future<void> _pairTag() async {

    final tagId = selectedTagId;

    if (tagId == null || scanStatus != 'found') {
      return;
    }

    // THE PI CURRENTLY ACCEPTS ONLY THESE CAT NAMES
    const supportedCats = {'zeusu', 'okja', 'kujza'};

    if (!supportedCats.contains(
        widget.cat.name.trim().toLowerCase())) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The Smart Mat currently accepts only '
            'zeusu, okja, or kujza.',
          ),
        ),
      );

      return;
    }

    try {
      // STOP LISTENING TO THE PREVIOUS SCAN REQUEST
      await scanSubscription?.cancel();

      if (!mounted) return;

      setState(() {
        scanStatus = 'pairing';
      });

      // SEND CONFIRM COMMAND
      final requestId = await BlePairingService.requestPair(
        catId: widget.cat.id,
        catName: widget.cat.name,
        deviceId: 'mat001',
        tagId: tagId,
      );

      if (!mounted) return;

      setState(() {
        activeRequestId = requestId;
      });

      debugPrint('BLE CONFIRM REQUEST: $requestId');

      bool resultHandled = false;

      scanSubscription = BlePairingService.watchRequest(
        requestId: requestId,
        deviceId: 'mat001',
      ).listen((snapshot) async {

        if (!mounted || !snapshot.exists || resultHandled) {
          return;
        }

        final data = snapshot.data();
        if (data == null) return;

        final status = data['status'] as String? ?? 'pending';
        final response = data['response']?.toString() ?? '';

        debugPrint('BLE PAIRING STATUS: $status');
        debugPrint('BLE PAIRING RESPONSE: $response');

        if (status == 'paired') {

          resultHandled = true;

          try {
            // VERIFY THE PI CONFIRMED THE EXPECTED MAC
            final confirmedMac = data['mac']?.toString();

            if (confirmedMac == null ||
                confirmedMac.toUpperCase() !=
                    tagId.toUpperCase()) {
              throw Exception(
                'Pi confirmed an unexpected beacon.',
              );
            }

            // SAVE PAIRING TO FIREBASE CAT PROFILE
            await BlePairingService.savePairedTag(
              catId: widget.cat.id,
              deviceId: 'mat001',
              tagId: tagId,
            );

            if (!mounted) return;

            setState(() {
              scanStatus = 'paired';
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'BLE beacon paired successfully!',
                ),
              ),
            );

          } catch (e) {

            if (!mounted) return;

            setState(() {
              scanStatus = 'failed';
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Pi pairing succeeded, but saving '
                  'the cat profile failed: $e',
                ),
              ),
            );
          }

        } else if (status == 'failed' ||
                   status == 'cancelled') {

          resultHandled = true;

          if (!mounted) return;

          setState(() {
            scanStatus = status;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.isNotEmpty
                    ? response
                    : 'BLE pairing failed.',
              ),
            ),
          );
        }

      }, onError: (error) {

        debugPrint('BLE PAIRING LISTENER ERROR: $error');

        if (mounted) {
          setState(() {
            scanStatus = 'failed';
          });
        }
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        scanStatus = 'failed';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pairing error: $e'),
        ),
      );
    }
  }


//FIREBASE LISTENER
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


  // UNPAIR BLE TAG FROM CAT PROFILE
  Future<void> _unpairTag() async {

    try {

      await BlePairingService.unpairTag(
        catId: widget.cat.id,
      );

      if (!mounted) return;

      setState(() {
        selectedTagId = null;
        availableTags.clear();
        scanStatus = 'idle';
        activeRequestId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'BLE tag removed from cat profile.',
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not remove BLE tag: $e'),
        ),
      );
    }
  }




//////////////////////////////////////////BUILD PAGE///////////////////////////////////
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

                    if ((bleStatus != 'paired' &&
                        bleStatus != 'connected') ||
                        bleMac == null) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [

                        Text(
                          bleStatus == 'connected'
                            ? 'Connected Tag'
                            : 'Paired Tag',
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

                        const SizedBox(height: 16),

                        // UNPAIR TAG BUTTON
                        OutlinedButton.icon(
                          onPressed: _unpairTag,

                          icon: const Icon(
                            Icons.link_off,
                            size: 20,
                          ),

                          label: const Text('Unpair Tag'),

                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.primary,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
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

              
              // TAG LIST
              ...availableTags.map((tag) {

                final isSelected = selectedTagId == tag.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),

                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),

                    onTap: () {
                      setState(() {
                        selectedTagId = tag.id;
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

                          // BLUETOOTH ICON
                          Container(
                            width: 48,
                            height: 48,

                            decoration: BoxDecoration(
                              color: appColors.bleIconBackground,
                              borderRadius: BorderRadius.circular(15),
                            ),

                            child: Icon(
                              Icons.bluetooth,
                              color: appColors.bleIcon,
                              size: 25,
                            ),
                          ),

                          const SizedBox(width: 15),

                          // TAG INFORMATION
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  tag.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurface,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  tag.rssi != null
                                      ? 'Signal: ${tag.rssi} dBm'
                                      : 'Signal unavailable',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // SELECTION INDICATOR
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
                  onPressed: selectedTagId != null &&
                        scanStatus == 'found'
                    ? _pairTag
                    : null,

                  icon: const Icon(
                    Icons.link,
                    size: 20,
                  ),

                  label: Text(
                    scanStatus == 'pairing'
                        ? 'Pairing...'
                        : 'Pair Selected Tag',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              //SCAN AGAIN BUTTON
              SizedBox(
                height: 50,

                child: OutlinedButton.icon(
                  onPressed: scanStatus == 'sending' ||
                            scanStatus == 'pending' ||
                            scanStatus == 'scanning' ||
                            scanStatus == 'pairing'
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
                            ? 'Scanning for Beacons...'
                            : 'Scan for Tags',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
