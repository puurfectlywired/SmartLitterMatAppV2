
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../widgets/app_bar.dart';
import 'change_password.dart';
import '../login.dart';
import 'edit_user_profile.dart';

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
        username = data['username'] ?? '';
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

  ////////////////////////////////////RESET PASSWORD////////////////////////////////////
  void resetPassword() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ChangePasswordPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  ////////////////////////////////////LOG OUT////////////////////////////////////
  Future<void> logOut() async {

    await _auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            const LoginPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
      (route) => false,
    );
  }

  ////////////////////////////////////CONFIRM ACCOUNT DELETION////////////////////////////////////
  Future<void> confirmDeleteAccount() async {

    final confirm = await showDialog<bool>(
      context: context,

      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),

        content: const Text(
          'Are you sure you want to delete your account? '
          'This action cannot be undone.',
        ),

        actions: [

          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),

          TextButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Account deletion requires deleting associated
    // Firestore data and may require recent login.
    // Implement the complete deletion workflow
    // before enabling this action.

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Account deletion is not configured yet',
        ),
      ),
    );
  }

  ////////////////////////////////////EDIT ACCOUNT INFORMATION////////////////////////////////////
  Future<void> editAccountInformation() async {

    final updated = await Navigator.push<bool>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const EditUserProfilePage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

    // RELOAD ACCOUNT INFORMATION AFTER SAVING
    if (updated == true && mounted) {
      await _loadAccountInformation();
    }
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

                  ////////////////////////////////////ACCOUNT INFORMATION CARD////////////////////////////////////
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

                        // EMAIL ADDRESS
                        _informationRow(
                          'Email Address',
                          email,
                        ),

                        const Divider(),

                        // USERNAME
                        _informationRow(
                          'Username',
                          username,
                        ),
                      ],
                      
                    ),
                    
                  ),

                  const SizedBox(height: 25),

                  ////////////////////////////////////EDIT ACCOUNT BUTTON////////////////////////////////////
                  SizedBox(
                    width: double.infinity,
                    height: 80,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.primary,
                        elevation: 0,
                      ),

                      onPressed: editAccountInformation,

                      icon: Icon(
                        Icons.edit_outlined,
                        size: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),

                      label: const Text('Edit Account Information'),
                    ),
                  ),

                  const SizedBox(height: 25),

                  ////////////////////////////////////LOGIN INFORMATION CARD////////////////////////////////////
                  Container(
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        // RESET PASSWORD
                        ListTile(
                          contentPadding: EdgeInsets.zero,

                          title: const Text(
                            'Reset Password',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          trailing: const Icon(
                            Icons.chevron_right,
                          ),

                          onTap: resetPassword,
                        ),

                        const Divider(),

                        // DELETE ACCOUNT
                        ListTile(
                          contentPadding: EdgeInsets.zero,

                          title: const Text(
                            'Delete Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          trailing: const Icon(
                            Icons.chevron_right,
                          ),

                          onTap: confirmDeleteAccount,
                        ),

                        const SizedBox(height: 20),

                        // LOG OUT
                        Center(
                          child: TextButton.icon(
                            onPressed: logOut,

                            icon: Icon(
                              Icons.logout,
                              size: 24,
                              color: colors.primary,
                            ),

                            label: Text(
                              'Log Out',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}