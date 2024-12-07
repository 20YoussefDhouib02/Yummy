import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Current user's authentication flow
  Stream<AppUser?> get user {
    return _auth.authStateChanges().map(
          (User? user) => user != null
              ? AppUser(
                  uid: user.uid, email: user.email, name: user.displayName)
              : null,
        );
  }

  // Method to get the current user
  User? get currentUser => _auth.currentUser;

  // Asynchronous method to get the current user
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Google login
  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user == null) {
        throw Exception("User not found after Google login");
      }
      print(user.uid);
      print(user.email);
      print(user.displayName);

      return AppUser(uid: user.uid, email: user.email, name: user.displayName);
    } catch (e) {
      print('Error during Google login: $e');
      return null;
    }
  }

  // Apple login
  Future<AppUser?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);
      User? user = userCredential.user;

      if (user == null) {
        throw Exception("User not found after Apple login");
      }

      return AppUser(uid: user.uid, email: user.email, name: user.displayName);
    } catch (e) {
      print('Error during Apple login: $e');
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      await _auth.currentUser?.delete();
    } catch (e) {
      print('Error deleting the account: $e');
    }
  }
}
