import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class AuthService {
  static Future<Map<String, dynamic>> loginWithPass(
      String email, String pass) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      return {
        'credential': credential,
        'error': null
      }; // Use `null` instead of `Null`
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        return {'credential': null, 'error': 'No user found for that email'};
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        return {
          'credential': null,
          'error': "Wrong password provided for that user"
        };
      }
    }
    return {
      'credential': null,
      'error': 'Unknown error occurred'
    }; // Ensuring a return on all paths
  }

  static Future<Map<String, dynamic>> creatUserWithPass(
      String name, String email, String pass) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );
      await createUserDB(credential.user!.uid, name, email, false);
      return {'uid': credential.user!.uid, 'error': null};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        return {'uid': null, 'error': 'The password provided is too weak.'};
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        return {
          'uid': null,
          'error': 'The account already exists for that email.'
        };
      }
    } catch (e) {
      print(e);
      return {'uid': null, 'error': e.toString()};
    }
    return {}; // Added return statement to handle case where no exception is thrown
  }

  static Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final cred = await FirebaseAuth.instance.signInWithCredential(credential);
      var uname = cred.user!.displayName;
      var uemail = cred.user!.email;
      var uid = cred.user!.uid;
      await createUserDB(uid, uname, uemail, true);
      return uid;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  static Future<bool> checkUser(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> data =
          await db.collection('users').where('email', isEqualTo: email).get();
      return data.docs.isNotEmpty;
    } catch (e) {
      print(e.toString());
      return false; // Handle errors by returning false
    }
  }

  static Future<Map<String, dynamic>> createUserDB(
      String uid, String? name, String? email, bool emailVerified) async {
    Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'emailVerified': emailVerified
    };
    var userExist = await checkUser(email!);
    if (!userExist) {
      await db.collection('users').doc(uid).set(data);
      return {'status': 'user data stored', 'status_code': 1};
    }
    return {'status': 'User Already Exists', 'status_code': 0};
  }

  static Future<Map<String, String?>> signInWithEmailAndPass(
      String email, String pass) async {
    try {
      final UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );
      // Return the user ID and null error if authentication is successful
      return {'uid': credential.user?.uid, 'error': null};
    } on FirebaseAuthException catch (e) {
      // Determine the error message based on the FirebaseAuthException code
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = e.message ?? 'Sign-in failed with an unknown error.';
      }
      print(errorMessage);
      return {
        'uid': null,
        'error': errorMessage
      }; // Return null uid and an error message
    } catch (e) {
      // Handle unexpected errors
      String unexpectedError = 'An unexpected error occurred: ${e.toString()}';
      print(unexpectedError);
      return {
        'uid': null,
        'error': unexpectedError
      }; // Return null uid and an unexpected error message
    }
  }
}
