
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/app_bar.dart';

////////////////////////////////////ACCOUNT OVERVIEW PAGE////////////////////////////////////
class AccountOverviewPage extends StatefulWidget {
  const AccountOverviewPage({super.key});

  @override
  State<AccountOverviewPage> createState() =>
      _AccountOverviewPageState();
}

////////////////////////////////////ACCOUNT OVERVIEW STATE////////////////////////////////////
class _AccountOverviewPageState extends State<AccountOverviewPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isLoading = true;

  String firstName = '';
  String lastName = '';
  String username = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    _loadAccountInformation();
  }

  ////////////////////////////////////LOAD ACCOUNT INFORMATION////////////////////////////////////
  Future<void> _loadAccountInformation() async {

    final user = _auth.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final document = await _db
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final data = document.data() ?? {};

      setState(() {
        firstName = data['firstName'] ?? '';
        lastName = data['lastName'] ?? '';
        email = user.email ?? '';
        isLoading = false;
      });

    } catch (e) {
      debugPrint('ERROR LOADING ACCOUNT INFORMATION: $e');

      if (!mounted) return;

      setState(() {
        email = user.email ?? '';
        isLoading = false;
      });
    }
  }

  ////////////////////////////////////INFORMATION ROW////////////////////////////////////
  Widget _informationRow(String label, String value) {

    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            value.isNotEmpty ? value : 'Not provided',
            style: TextStyle(
              fontSize: 15,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////BUILD PAGE////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: const MyAppBar(
        title: 'Account Overview',
        showBackButton: true,
        showHamburgerMenu: false,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [

                  // ACCOUNT INFORMATION HEADING
                  // const Text(
                  //   'Account Information',
                  //   style: TextStyle(
                  //     fontSize: 22,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),

                  // const SizedBox(height: 10),

                  // const Divider(),

                  // const SizedBox(height: 20),

                  // ACCOUNT INFORMATION CARD
                  Container(
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        // FIRST NAME
                        _informationRow(
                          'First Name',
                          firstName,
                        ),

                        const Divider(),

                        // LAST NAME
                        _informationRow(
                          'Last Name',
                          lastName,
                        ),

                        const Divider(),

                        // EMAIL
                        _informationRow(
                          'Email Address',
                          email,
                        ),

                        const Divider(),

                        // EMAIL
                        _informationRow(
                          'Username',
                          username,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
