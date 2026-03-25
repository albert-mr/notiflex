import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:notiflex/services/auth_service.dart';
import 'package:notiflex/widgets/auth/auth_button.dart';
import 'package:notiflex/widgets/auth/custom_text_field.dart';
import 'package:notiflex/screens/platform_selection_screen.dart';

class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _phoneController = TextEditingController(text: '34');
  final _otpController = TextEditingController();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _codeSent = false;
  String? _verificationId;

  Future<void> _verifyPhone() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _authService.verifyPhone(
          phoneNumber: '+${_phoneController.text.trim()}',
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _verificationId = verificationId;
              _codeSent = true;
              _isLoading = false;
            });
          },
          verificationCompleted: (String message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: const PlatformSelectionScreen(),
                ),
              ),
              (Route<dynamic> route) => false,
            );
          },
          verificationFailed: (String error) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final userCredential = await _authService.verifyOTP(
          _verificationId!,
          _otpController.text.trim(),
        );

        if (userCredential.user != null) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WillPopScope(
                  onWillPop: () async => false,
                  child: const PlatformSelectionScreen(),
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _codeSent ? 'Enter OTP' : 'Phone Verification',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF2C3E50),
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _codeSent
                        ? 'Please enter the verification code sent to your phone'
                        : 'We will send you a one-time password',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        if (!_codeSent)
                          CustomTextField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            hint: '',
                            keyboardType: TextInputType.phone,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                              TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                final text = newValue.text.replaceAll(' ', '');
                                if (text.length <= 2) return newValue;

                                String formatted = text.substring(0, 2);
                                if (text.length > 2) {
                                  formatted +=
                                      ' ${text.substring(2, min(5, text.length))}';
                                }
                                if (text.length > 5) {
                                  formatted +=
                                      ' ${text.substring(5, min(8, text.length))}';
                                }
                                if (text.length > 8) {
                                  formatted +=
                                      ' ${text.substring(8, min(11, text.length))}';
                                }

                                return TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(
                                      offset: formatted.length),
                                );
                              }),
                            ],
                            prefix: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              child: Text(
                                '+',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter your phone number';
                              }
                              final digitsOnly = value!.replaceAll(' ', '');
                              if (digitsOnly.length < 11) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          )
                        else
                          CustomTextField(
                            controller: _otpController,
                            label: 'Verification Code',
                            hint: '',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Please enter the verification code';
                              }
                              if (value!.length != 6) {
                                return 'Please enter a valid verification code';
                              }
                              return null;
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  AuthButton(
                    text: _codeSent ? 'Verify Code' : 'Send Code',
                    onPressed: _codeSent ? _verifyOTP : _verifyPhone,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
