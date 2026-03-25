import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signInWithEmailPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserCredential> signUpWithEmailPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String, int?) codeSent,
    required Function(String) verificationCompleted,
    required Function(String) verificationFailed,
  }) async {
    try {
      String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^\+\d]'), '');

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            verificationCompleted("Phone number automatically verified");
          } catch (e) {
            verificationFailed(_handleAuthError(e));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          verificationFailed(_handleAuthError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          codeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      verificationFailed(_handleAuthError(e));
    }
  }

  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return await _auth.signInWithCredential(credential);
  }

  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-verification-code':
          return 'Invalid verification code.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'invalid-phone-number':
          return 'The phone number provided is invalid.';
        default:
          return e.message ?? 'An error occurred.';
      }
    }
    return e.toString();
  }
}
