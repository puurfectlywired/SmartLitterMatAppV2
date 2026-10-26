
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../settings/change_password.dart';

import '../login.dart';

////////////////////////////////////LOGIN INFORMATION PAGE////////////////////////////////////
class LoginInfoPage extends StatefulWidget {
  const LoginInfoPage({super.key});

  @override
  State<LoginInfoPage> createState() =>
      _LoginInfoPageState();
}

class _LoginInfoPageState
    extends State<LoginInfoPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isLoading = true;
  String firstName = '';
  String lastName = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    loadUserInformation();
  }

  // LOAD USER INFORMATION FROM FIREBASE
  Future<void> loadUserInformation() async {
    final user = _auth.currentUser;

    if (user == null) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    try {
      final doc = await _db
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final data = doc.data() ?? {};

      setState(() {
        firstName = data['firstName'] ?? '';
        lastName = data['lastName'] ?? '';
        email = user.email ?? '';
        isLoading = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        email = user.email ?? '';
        isLoading = false;
      });
    }
  }

  // CHANGE PASSWORD
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


  // LOG OUT
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

  // CONFIRM ACCOUNT DELETION
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        title: const Text('Login Information'),
        centerTitle: true,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        toolbarHeight: 70,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: colors.surfaceContainerHigh,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      // NAME
                      Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        '$firstName $lastName'.trim(),
                        style: TextStyle(
                          fontSize: 15,
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const Divider(height: 32),

                      // EMAIL
                      Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 15,
                          color: colors.onSurfaceVariant,
                        ),
                      ),

                      const Divider(height: 32),

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
                        child: TextButton(
                          onPressed: logOut,
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
