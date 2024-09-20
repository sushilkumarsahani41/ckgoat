import 'package:ckgoat/main.dart';
import 'package:ckgoat/services/AuthService.dart';
import 'package:ckgoat/widgets/elevation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final Color deepOne = Colors.deepOrange;
  bool _passVisibility = true;

  void togglePasswordVisibility() =>
      setState(() => _passVisibility = !_passVisibility);

  Future<void> performLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppLocalizations.of(context)!.translate('enter_email_password')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var result = await AuthService.signInWithEmailAndPass(
        _emailController.text, _passwordController.text);

    if (result['uid'] != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('uid', result['uid']!);
      Navigator.pushReplacementNamed(context, '/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ??
              AppLocalizations.of(context)!.translate('login_failed')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      var uid = await AuthService.signInWithGoogle();
      final SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setString('uid', uid!);
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      // Handle error or show a Snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 5,
              ),
              Text(AppLocalizations.of(context)!.translate('app_title'),
                  style: GoogleFonts.archivoBlack(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: deepOne)),
              Text(AppLocalizations.of(context)!.translate('app_subtitle'),
                  style: GoogleFonts.zillaSlab(
                      color: deepOne,
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.translate('login'),
                  style: GoogleFonts.ptSans(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: deepOne)),
              const SizedBox(height: 20),
              buildTextField(AppLocalizations.of(context)!.translate('email'),
                  _emailController, false),
              buildTextField(
                  AppLocalizations.of(context)!.translate('password'),
                  _passwordController,
                  true),
              buildForgotPasswordLink(),
              const SizedBox(height: 50),
              buildLoginButton(),
              const SizedBox(
                height: 40,
              ),
              buildSocialMediaLogin(),
              const SizedBox(
                height: 40,
              ),
              buildSignUpLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, TextEditingController controller, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.zillaSlab(
                fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        AddElevation(
          color: const Color.fromARGB(255, 254, 236, 231),
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

  Widget buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () {},
        child: Text(AppLocalizations.of(context)!.translate('forgot_password'),
            style: GoogleFonts.zillaSlab(
                color: deepOne, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget buildLoginButton() {
    return Center(
      child: SizedBox(
        width: 200,
        height: 50,
        child: ElevatedButton(
          onPressed: performLogin,
          style:
              ElevatedButton.styleFrom(backgroundColor: deepOne, elevation: 5),
          child: Text(AppLocalizations.of(context)!.translate('login'),
              style: GoogleFonts.ptSerif(fontSize: 24, color: Colors.white)),
        ),
      ),
    );
  }

  Widget buildSocialMediaLogin() {
    return Column(
      children: [
        DividerWithText(
            text: AppLocalizations.of(context)!.translate('or_continue_with')),
        const SizedBox(
          height: 10,
        ),
        Center(
          child: AddElevation(
            shape: BoxShape.circle,
            color: Colors.white,
            child: IconButton(
              onPressed: loginWithGoogle,
              icon: Image.asset('assets/google.png', width: 32),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppLocalizations.of(context)!.translate('dont_have_account'),
            style:
                GoogleFonts.ptSans(fontWeight: FontWeight.w600, fontSize: 16)),
        InkWell(
          onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
          child: Text(AppLocalizations.of(context)!.translate('sign_up'),
              style: GoogleFonts.ptSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                  color: Colors.blue)),
        )
      ],
    );
  }

  Widget DividerWithText({required String text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Expanded(child: Divider(height: 1, color: Colors.black87)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(text,
              style: GoogleFonts.ptSans(
                  fontWeight: FontWeight.w600, fontSize: 16)),
        ),
        const Expanded(child: Divider(height: 1, color: Colors.black87)),
      ],
    );
  }
}
