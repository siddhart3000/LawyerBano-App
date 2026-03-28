import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream of user changes
  Stream<User?> get user => _auth.authStateChanges();

  // Get current user data from Firestore
  Future<DocumentSnapshot?> getUserData(String uid) async {
    try {
      return await _db.collection('users').doc(uid).get();
    } catch (e) {
      return null;
    }
  }

  // Update Full Profile Info including new location fields
  Future<void> updateFullProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  // Sign up with email & password
  Future<User?> signUpWithEmail(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
          'role': null,
        });
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  // Sign in with email & password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      return null;
    }
  }

  // Google Sign In - Optimized
  Future<User?> signInWithGoogle() async {
    try {
      // Ensure any previous session is cleared
      await _googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        DocumentSnapshot doc = await _db.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await _db.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'email': user.email,
            'name': user.displayName,
            'photoUrl': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            'role': null,
          });
        }
      }
      return user;
    } catch (e) {
      print("Google Sign In Detailed Error: $e");
      return null;
    }
  }

  // Update User Role
  Future<void> updateUserRole(String uid, bool isLawyer) async {
    await _db.collection('users').doc(uid).update({
      'role': isLawyer ? 'lawyer' : 'client',
    });
  }

  // Delete User Data and Account
  Future<bool> deleteUserAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      String uid = user.uid;

      // 1. Delete user document from Firestore
      await _db.collection('users').doc(uid).delete();
      
      // 2. Delete sub-collections (e.g., trials)
      final trials = await _db.collection('users').doc(uid).collection('trials').get();
      for (var doc in trials.docs) {
        await doc.reference.delete();
      }

      // 3. Delete the auth account
      await user.delete();
      return true;
    } catch (e) {
      print("Delete Account Error: $e");
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }
}
