
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

////////////////////////////////////EDIT ACCOUNT PAGE////////////////////////////////////
class EditUserProfilePage extends StatefulWidget {
  const EditUserProfilePage({super.key});

  @override
  State<EditUserProfilePage> createState() =>
      _EditUserProfilePageState();
}

////////////////////////////////////EDIT ACCOUNT STATE////////////////////////////////////
class _EditUserProfilePageState extends State<EditUserProfilePage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final TextEditingController firstNameController =
      TextEditingController();
  final TextEditingController lastNameController =
      TextEditingController();
  final TextEditingController emailController =
      TextEditingController();
  final TextEditingController usernameController =
      TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  String originalEmail = '';

  @override
  void initState() {
    super.initState();
    _loadAccountInformation();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  ////////////////////////////////////LOAD ACCOUNT INFORMATION////////////////////////////////////
  Future<void> _loadAccountInformation() async {

    final user = _auth.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      return;
    }

    try {
      final document = await _db
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      final data = document.data() ?? {};

      firstNameController.text = data['firstName'] ?? '';
      lastNameController.text = data['lastName'] ?? '';
      usernameController.text = data['username'] ?? '';

      originalEmail = user.email ?? '';
      emailController.text = originalEmail;

    } catch (e) {
      debugPrint('ERROR LOADING ACCOUNT INFORMATION: $e');

      if (!mounted) return;

      originalEmail = user.email ?? '';
      emailController.text = originalEmail;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load all account information.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  ////////////////////////////////////SAVE CHANGES////////////////////////////////////
  Future<void> _saveChanges() async {

    if (isSaving) return;

    final user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to edit your account.'),
        ),
      );
      return;
    }

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();

    // VALIDATE ACCOUNT INFORMATION
    if (firstName.isEmpty ||
        lastName.isEmpty ||
        username.isEmpty ||
        email.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all account fields.'),
        ),
      );
      return;
    }

    final emailPattern = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailPattern.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {

      final emailChanged = email != originalEmail;

      // UPDATE THE EXISTING USER DOCUMENT
      await _db
          .collection('users')
          .doc(user.uid)
          .update({
            'firstName': firstName,
            'lastName': lastName,
            'username': username,
            'name': '$firstName $lastName',
          });

      // EMAIL CHANGES MUST ALSO BE HANDLED BY
      // FIREBASE AUTHENTICATION.
      if (emailChanged) {
        await user.verifyBeforeUpdateEmail(email);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account information saved. '
              'Check your new email address for a verification link. '
              'Your login email will change after verification.',
            ),
            duration: Duration(seconds: 6),
          ),
        );
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account information updated successfully.'),
          ),
        );
      }

      // RETURN TO ACCOUNT OVERVIEW
      if (!mounted) return;
      Navigator.pop(context, true);

    } on FirebaseAuthException catch (e) {
      debugPrint('FIREBASE AUTH ERROR: ${e.code}');

      if (!mounted) return;

      String message = 'Could not update account email.';

      if (e.code == 'requires-recent-login') {
        message =
            'Please log out and log back in before changing your email.';
      } else if (e.code == 'email-already-in-use') {
        message = 'This email address is already in use.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

    } catch (e) {
      debugPrint('ERROR UPDATING ACCOUNT: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not complete the account update.',
          ),
        ),
      );

    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  ////////////////////////////////////EDIT FIELD////////////////////////////////////
  Widget _editField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {

    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: keyboardType == TextInputType.name
            ? TextCapitalization.words
            : TextCapitalization.none,

        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: colors.surface,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  ////////////////////////////////////BUILD PAGE////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        title: const Text('Edit Account'),
        centerTitle: true,
        backgroundColor: colors.surface,
        automaticallyImplyLeading: false,
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 25,
              ),

              children: [

                // WELCOME MESSAGE
                const Text(
                  "Let's update your account information",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 35),

                // ACCOUNT ICON
                Center(
                  child: Container(
                    width: 150,
                    height: 150,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surfaceContainerHighest,
                    ),

                    child: Icon(
                      Icons.person_outline,
                      size: 75,
                      color: colors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                ////////////////////////////////////ACCOUNT INFORMATION CARD////////////////////////////////////
                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    children: [

                      // FIRST NAME
                      _editField(
                        'First Name',
                        firstNameController,
                        keyboardType: TextInputType.name,
                      ),

                      // LAST NAME
                      _editField(
                        'Last Name',
                        lastNameController,
                        keyboardType: TextInputType.name,
                      ),

                      // EMAIL ADDRESS
                      _editField(
                        'Email Address',
                        emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      // USERNAME
                      _editField(
                        'Username',
                        usernameController,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 45),

                ////////////////////////////////////SAVE CHANGES BUTTON////////////////////////////////////
                SizedBox(
                  height: 55,

                  child: ElevatedButton(
                    onPressed: isSaving ? null : _saveChanges,

                    child: isSaving
                        ? const CircularProgressIndicator()
                        : const Text('Save Changes'),
                  ),
                ),

                const SizedBox(height: 15),

                ////////////////////////////////////CANCEL BUTTON////////////////////////////////////
                SizedBox(
                  height: 55,

                  child: OutlinedButton(
                    onPressed: isSaving
                        ? null
                        : () => Navigator.pop(context),

                    child: const Text('Cancel'),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
    );
  }
}
