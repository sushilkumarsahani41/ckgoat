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
      // Step 1: Trigger Google sign-in flow
      print("Attempting to sign in with Google...");
      final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: [
        'email',
        'profile',
        // Add this if you need ID token:
        'https://www.googleapis.com/auth/userinfo.profile',
      ],).signIn();

      if (googleUser == null) {
        // If the user cancels the sign-in process
        print("Google sign-in was canceled by the user.");
        return null;
      }

      print(
          "Google user sign-in successful: ${googleUser.displayName}, ${googleUser.email}");

      // Step 2: Obtain authentication details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(
          "Obtained Google authentication details. AccessToken: ${googleAuth.accessToken}, IDToken: ${googleAuth.idToken}");

      // Step 3: Create a new credential using GoogleAuthProvider
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: Sign in to Firebase with the Google credential
      print("Signing in with Google credential to Firebase...");
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print("Firebase sign-in successful. Fetching user details...");

      // Step 5: Fetch user details
      final user = userCredential.user;
      if (user != null) {
        var uname = user.displayName ?? 'Unknown';
        var uemail = user.email ?? 'Unknown';
        var uid = user.uid;

        print("User details - Name: $uname, Email: $uemail, UID: $uid");

        // Step 6: Call your method to create or update the user in the database
        print("Creating/updating user in the database...");
        await createUserDB(uid, uname, uemail, true);

        print("User created/updated successfully in the database.");

        return uid;
      } else {
        print("Error: Firebase user is null after sign-in.");
        return null;
      }
    } on FirebaseAuthException catch (e) {
      print("Firebase Authentication Error: ${e.message}");
      if (e.code == 'account-exists-with-different-credential') {
        print("Error: Account exists with different credential.");
      } else if (e.code == 'invalid-credential') {
        print("Error: Invalid credential.");
      }
      return null;
      // ignore: dead_code_catch_following_catch
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
