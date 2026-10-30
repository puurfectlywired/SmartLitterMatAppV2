
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/app_bar.dart';

////////////////////////////////////////////CHANGE PASSWORD PAGE//////////////////////////////////////////
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() =>
      _ChangePasswordPageState();
}

////////////////////////////////////////////CHANGE PASSWORD PAGE STATE//////////////////////////////////////////
class _ChangePasswordPageState extends State<ChangePasswordPage> {

  // TEXT CONTROLLERS
  final TextEditingController currentPasswordController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FocusNode passwordFocusNode = FocusNode();

  // PASSWORD VISIBILITY
  bool currentPasswordVisible = false;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  bool passwordFieldActive = false;
  bool isSaving = false;

  ////////////////////////////////////////////PASSWORD REQUIREMENTS//////////////////////////////////////////

  bool get hasMinLength =>
      passwordController.text.length >= 8;

  bool get hasUppercase =>
      RegExp(r'[A-Z]').hasMatch(passwordController.text);

  bool get hasLowercase =>
      RegExp(r'[a-z]').hasMatch(passwordController.text);

  bool get hasNumber =>
      RegExp(r'[0-9]').hasMatch(passwordController.text);

  bool get hasSpecialCharacter =>
      RegExp(r'[^a-zA-Z0-9]').hasMatch(passwordController.text);

  bool get allRequirementsMet =>
      hasMinLength &&
      hasUppercase &&
      hasLowercase &&
      hasNumber &&
      hasSpecialCharacter;

  bool get passwordsMatch =>
      passwordController.text == confirmPasswordController.text;

  bool get canContinue =>
      currentPasswordController.text.isNotEmpty &&
      allRequirementsMet &&
      passwordsMatch &&
      confirmPasswordController.text.isNotEmpty;

  ////////////////////////////////////////////INITIALIZE//////////////////////////////////////////
  @override
  void initState() {
    super.initState();

    passwordFocusNode.addListener(() {
      if (passwordFocusNode.hasFocus && mounted) {
        setState(() {
          passwordFieldActive = true;
        });
      }
    });
  }

  ////////////////////////////////////////////DISPOSE//////////////////////////////////////////
  @override
  void dispose() {
    currentPasswordController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  ////////////////////////////////////////////PASSWORD REQUIREMENT//////////////////////////////////////////
  Widget passwordRequirement(String text, bool isMet) {

    final highlightColor = Theme.of(context).colorScheme.primary;

    final requirementColor = isMet && passwordFieldActive
        ? highlightColor
        : Colors.grey;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(
            '• $text',
            style: TextStyle(
              fontSize: 12,
              color: requirementColor,
            ),
          ),

          if (isMet && passwordFieldActive)
            Icon(
              Icons.check,
              size: 16,
              color: highlightColor,
            ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////CHANGE PASSWORD//////////////////////////////////////////
  Future<void> _changePassword() async {

    if (!canContinue || isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No signed-in user was found.',
        );
      }

      // VERIFY CURRENT PASSWORD
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );

      await user.reauthenticateWithCredential(credential);

      // UPDATE PASSWORD IN FIREBASE AUTHENTICATION
      await user.updatePassword(passwordController.text);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully.'),
        ),
      );

      // RETURN TO LOGIN INFORMATION PAGE
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {

      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Your current password is incorrect.';
          break;

        case 'weak-password':
          message = 'Please choose a stronger password.';
          break;

        case 'requires-recent-login':
          message = 'Please log in again and try again.';
          break;

        case 'too-many-requests':
          message = 'Too many attempts. Please try again later.';
          break;

        default:
          message = e.message ?? 'Could not change password.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not change password.'),
        ),
      );

    } finally {

      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  ////////////////////////////////////////////BUILD PAGE//////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: const MyAppBar(
        title: 'Change Password',
        showBackButton: true,
        showHamburgerMenu: false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 30,
          ),

          child: Center(
            child: SizedBox(
              width: 300,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  ////////////////////////////////////////////CURRENT PASSWORD//////////////////////////////////////////
                  const Text(
                    'Current Password',
                    style: TextStyle(fontSize: 15),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: currentPasswordController,
                    obscureText: !currentPasswordVisible,
                    enabled: !isSaving,
                    onChanged: (value) {
                      setState(() {});
                    },

                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: const OutlineInputBorder(),

                      suffixIcon: IconButton(
                        icon: Icon(
                          currentPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),

                        onPressed: () {
                          setState(() {
                            currentPasswordVisible =
                                !currentPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  //const SizedBox(height: 15),

                  // FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerRight,

                    child: TextButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final user =
                                  FirebaseAuth.instance.currentUser;

                              if (user?.email == null) return;

                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(
                                  email: user!.email!,
                                );

                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password reset email sent.',
                                    ),
                                  ),
                                );

                              } on FirebaseAuthException catch (e) {
                                if (!context.mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.message ??
                                          'Could not send reset email.',
                                    ),
                                  ),
                                );
                              }
                            },

                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  ////////////////////////////////////////////NEW PASSWORD//////////////////////////////////////////

                  const Text(
                    'Create New Password',
                    style: TextStyle(fontSize: 15),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    obscureText: !passwordVisible,
                    enabled: !isSaving,

                    onChanged: (value) {
                      setState(() {});
                    },

                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: const OutlineInputBorder(),

                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),

                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  ////////////////////////////////////////////PASSWORD REQUIREMENTS//////////////////////////////////////////

                  const Text(
                    'Password must contain:',
                    style: TextStyle(fontSize: 12),
                  ),

                  const SizedBox(height: 6),

                  passwordRequirement(
                    'At least 8 characters',
                    hasMinLength,
                  ),

                  passwordRequirement(
                    'One uppercase letter',
                    hasUppercase,
                  ),

                  passwordRequirement(
                    'One lowercase letter',
                    hasLowercase,
                  ),

                  passwordRequirement(
                    'One number',
                    hasNumber,
                  ),

                  passwordRequirement(
                    'One special character',
                    hasSpecialCharacter,
                  ),

                  const SizedBox(height: 30),

                  ////////////////////////////////////////////CONFIRM PASSWORD//////////////////////////////////////////

                  const Text(
                    'Confirm New Password',
                    style: TextStyle(fontSize: 15),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !confirmPasswordVisible,
                    enabled: !isSaving,

                    onChanged: (value) {
                      setState(() {});
                    },

                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: const OutlineInputBorder(),

                      suffixIcon: IconButton(
                        icon: Icon(
                          confirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),

                        onPressed: () {
                          setState(() {
                            confirmPasswordVisible =
                                !confirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  ////////////////////////////////////////////CHANGE PASSWORD BUTTON//////////////////////////////////////////

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed:
                          canContinue && !isSaving
                              ? _changePassword
                              : null,

                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Change Password'),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
