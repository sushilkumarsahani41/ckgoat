import 'package:ckgoat/main.dart';
import 'package:ckgoat/services/AuthService.dart';
import 'package:ckgoat/widgets/elevation.dart';
import 'package:ckgoat/widgets/snakbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';// Localization import

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _pass = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _cnfpass = TextEditingController();
  bool _passVisibility = true;

  void togglePasswordVisibility() {
    setState(() {
      _passVisibility = !_passVisibility;
    });
  }

  Future<void> signUp() async {
    if (_email.text.isEmpty ||
        _name.text.isEmpty ||
        _pass.text.isEmpty ||
        _cnfpass.text.isEmpty) {
      SnackbarUtil.showSnackbar(
          context, AppLocalizations.of(context)!.translate('fill_all_fields'));
      return;
    }
    if (_pass.text != _cnfpass.text) {
      SnackbarUtil.showSnackbar(context,
          AppLocalizations.of(context)!.translate('password_mismatch'));
      return;
    }
    var createUser = await AuthService.creatUserWithPass(
        _name.text, _email.text, _cnfpass.text);
    if (createUser['uid'] != null) {
      Object? cred = createUser['uid'];
      if (cred != Null) {
        SnackbarUtil.showSnackbar(
            context, AppLocalizations.of(context)!.translate('user_created'));
        final SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString('uid', cred as String);
        Navigator.pushReplacementNamed(context, '/');
      } else {
        SnackbarUtil.showSnackbar(
            context, createUser['error'] as String);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color deepOne = Colors.blue;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.translate('app_title'),
                style: GoogleFonts.archivoBlack(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: deepOne),
              ),
              Text(
                AppLocalizations.of(context)!.translate('app_subtitle'),
                style: GoogleFonts.zillaSlab(
                    color: deepOne,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.translate('sign_up'),
                style: GoogleFonts.ptSans(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: deepOne),
              ),
              const SizedBox(height: 20),
              buildTextField(
                  AppLocalizations.of(context)!.translate('full_name'), _name, false),
              buildTextField(
                  AppLocalizations.of(context)!.translate('email'), _email, false),
              buildTextField(
                  AppLocalizations.of(context)!.translate('password'), _pass, true, true),
              buildTextField(
                  AppLocalizations.of(context)!.translate('confirm_password'),
                  _cnfpass, true),
              const SizedBox(height: 40),
              Center(
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: signUp,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: deepOne, elevation: 5),
                    child: Text(
                      AppLocalizations.of(context)!.translate('sign_up'),
                      style: GoogleFonts.ptSerif(
                          fontSize: 24, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              buildSignInLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, TextEditingController controller, bool isPassword,
      [bool isMainPassword = false]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.zillaSlab(
              fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        AddElevation(
          color: const Color.fromARGB(255, 231, 232, 254),
          child: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: TextField(
              controller: controller,
              obscureText: isPassword ? _passVisibility : false,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: isPassword
                    ? '*******'
                    : AppLocalizations.of(context)!
                        .translate('enter_label')
                        .replaceFirst('{}', label),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                suffixIconConstraints: const BoxConstraints(
                  minHeight: 2,
                ),
                suffixIcon: isPassword
                    ? InkWell(
                        onTap: togglePasswordVisibility,
                        child: Icon(
                          _passVisibility
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 26,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildSignInLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.translate('already_have_account'),
          style: GoogleFonts.ptSans(
              fontWeight: FontWeight.w600, fontSize: 16),
        ),
        InkWell(
          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
          child: Text(
            AppLocalizations.of(context)!.translate('sign_in'),
            style: GoogleFonts.ptSans(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                decoration: TextDecoration.underline,
                color: Colors.blue),
          ),
        )
      ],
    );
  }
}
