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
    // Ensure that email and password fields are not empty
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      // Ideally, show a user-friendly error message, possibly using a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter both email and password.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Call the login function from the Service class
    var result = await AuthService.signInWithEmailAndPass(
        _emailController.text, _passwordController.text);

    // Check the result of the login attempt
    if (result['uid'] != null) {
      // Login was successful
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      await _prefs.setString('uid', result['uid']!);
      Navigator.pushReplacementNamed(
          context, '/'); // Navigate to home or another appropriate page
    } else {
      // Login failed, display error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Failed to log in.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      var uid = await AuthService.signInWithGoogle();
      final SharedPreferences _pref = await SharedPreferences.getInstance();
      await _pref.setString('uid', uid!);
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
              Text("CK GOAT FARM",
                  style: GoogleFonts.archivoBlack(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: deepOne)),
              Text("Animal Buy and Sell",
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
              Text("Log In",
                  style: GoogleFonts.ptSans(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: deepOne)),
              SizedBox(height: 20),
              buildTextField("Email", _emailController, false),
              buildTextField("Password", _passwordController, true),
              buildForgotPasswordLink(),
              SizedBox(height: 50),
              buildLoginButton(),
              SizedBox(
                height: 40,
              ),
              buildSocialMediaLogin(),
              SizedBox(
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
        SizedBox(height: 10),
        AddElevation(
          color: Color.fromARGB(255, 254, 236, 231),
          child: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: TextField(
              controller: controller,
              obscureText: isPassword ? _passVisibility : false,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: isPassword ? '*******' : 'Enter $label',
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
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
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () {},
        child: Text("Forget Password?",
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
          child: Text('Log In',
              style: GoogleFonts.ptSerif(fontSize: 24, color: Colors.white)),
        ),
      ),
    );
  }

  Widget buildSocialMediaLogin() {
    return Column(
      children: [
        DividerWithText(text: "or continue with"),
        SizedBox(
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
        Text("Don't have an Account? ",
            style:
                GoogleFonts.ptSans(fontWeight: FontWeight.w600, fontSize: 16)),
        InkWell(
          onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
          child: Text("Sign Up",
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
        Expanded(child: Divider(height: 1, color: Colors.black87)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(text,
              style: GoogleFonts.ptSans(
                  fontWeight: FontWeight.w600, fontSize: 16)),
        ),
        Expanded(child: Divider(height: 1, color: Colors.black87)),
      ],
    );
  }
}
