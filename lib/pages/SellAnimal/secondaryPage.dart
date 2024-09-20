import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ckgoat/main.dart';
import 'package:ckgoat/pages/uploadPages.dart';
import 'package:ckgoat/services/UploadService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SecondaryInfoPage extends StatefulWidget {
  final String? animalType;
  final String? breed;
  final int? age;
  final double? weight;
  final double? price;
  final String? gender;
  final int? lactation;
  final int? milkCapacity;

  const SecondaryInfoPage({
    this.animalType,
    this.breed,
    this.age,
    this.weight,
    this.price,
    this.gender,
    this.lactation,
    this.milkCapacity,
    super.key,
  });

  @override
  _SecondaryInfoPageState createState() => _SecondaryInfoPageState();
}

class _SecondaryInfoPageState extends State<SecondaryInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressLine1Controller = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _otpController = TextEditingController();
  Timer? _resendTimer;
  bool isSubmitting = false; // New flag to prevent multiple submissions

  List<File> selectedFiles = [];
  List<String> uploadedUrls = [];
  bool isSubmitClicked = false;
  String? city;
  String? state;
  bool isLoading = false;
  bool isPinCodeValid = true;
  bool verifyOTP = false;
  final String bearerToken =
      'gCW0z7uTiZqbNwoYQsDvE2gAPxdHfXciazPmCzPneXpn444glZ';
  String? transactionId;

  Future<void> _fetchLocationData(String pincode) async {
    setState(() {
      isLoading = true;
      isPinCodeValid = false;
    });

    final apiUrl = 'https://api.ckgoat.greatshark.in/location/pincode/$pincode';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null) {
          setState(() {
            city = data['district'];
            state = data['state'];
            _cityController.text = city!;
            _stateController.text = state!;
            isPinCodeValid = true;
          });
        } else {
          _showSnackBar('Invalid Pin Code');
        }
      } else {
        _showSnackBar('Failed to fetch location data');
      }
    } catch (e) {
      _showSnackBar('Error fetching location data');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (isSubmitting) return; // Prevent multiple submissions

    if (!_formKey.currentState!.validate()) return;

    if (selectedFiles.isEmpty) {
      _showSnackBar('Please upload at least one image');
      return;
    }

    setState(() {
      isSubmitClicked = true;
      isSubmitting = true; // Set flag to prevent multiple submissions
    });

    await _sendOtp(_mobileNumberController.text);
  }

  void _onFilesSelected(List<File> files) {
    setState(() {
      selectedFiles = files;
    });
  }

  void _resetLocationFields() {
    setState(() {
      _cityController.clear();
      _stateController.clear();
      city = null;
      state = null;
      isPinCodeValid = false;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.translate('scd_secondary_info'),
          style: GoogleFonts.archivoBlack(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                AppLocalizations.of(context)!.translate('scd_images_videos'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 8),
              FileUploadWidget(onFilesSelected: _onFilesSelected),
              const SizedBox(height: 5),
              Text(
                AppLocalizations.of(context)!.translate('scd_max_file_size'),
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.translate('scd_address'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressLine1Controller,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!
                      .translate('scd_address_hint'),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.deepOrange, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .translate('scd_enter_address');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.translate('scd_pin_code'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                maxLength: 6,
                controller: _pinCodeController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!
                      .translate('scd_pin_code_hint'),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.deepOrange, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .translate('scd_enter_pin_code');
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.length == 6) {
                    _fetchLocationData(value);
                  } else if (value.isEmpty) {
                    _resetLocationFields();
                  }
                },
              ),
              if (isLoading) const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      enabled: false,
                      controller: _cityController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .translate('scd_city_hint'),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.deepOrange, width: 2.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('scd_enter_city');
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!
                            .translate('scd_state_hint'),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.deepOrange, width: 2.0),
                        ),
                      ),
                      enabled: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('scd_enter_state');
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.translate('scd_mobile_number'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _mobileNumberController,
                decoration: InputDecoration(
                  prefix: const Text("🇮🇳 +91 | "),
                  hintText: AppLocalizations.of(context)!
                      .translate('scd_mobile_hint'),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.deepOrange, width: 2.0),
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context)!
                        .translate('scd_enter_mobile');
                  } else if (value.length != 10) {
                    return AppLocalizations.of(context)!
                        .translate('scd_mobile_invalid');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: _submitForm,
                child: isSubmitClicked
                    ? Padding(
                        padding: const EdgeInsets.all(5),
                        child: const CircularProgressIndicator(
                            color: Colors.white),
                      )
                    : Text(
                        AppLocalizations.of(context)!
                            .translate('scd_submit_button'),
                        style:
                            const TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp(String mobileNumber) async {
    final apiUrl =
        'https://api.ckgoat.greatshark.in/otp/send/?mobile_no=$mobileNumber';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $bearerToken'},
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        setState(() {
          transactionId = data['transaction_id'];
        });
        _showOtpBottomSheet(mobileNumber);
      } else {
        _showSnackBar('Failed to send OTP');
      }
    } catch (e) {
      _showSnackBar('Error sending OTP');
    }
  }

  void _showOtpBottomSheet(String mobileNumber) {
    bool isResendEnabled = false;
    int resendCounter = 60; // Initial countdown for 60 seconds

    void _startResendTimer(StateSetter setModal) {
      const oneSec = Duration(seconds: 1);
      _resendTimer = Timer.periodic(oneSec, (Timer timer) {
        if (mounted) {
          if (resendCounter == 0) {
            setModal(() {
              isResendEnabled = true;
              _resendTimer?.cancel();
            });
          } else {
            setModal(() {
              resendCounter--;
            });
          }
        } else {
          timer.cancel(); // Cancel the timer if the widget is no longer mounted
        }
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This makes the bottom sheet expandable
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            if (!isResendEnabled && _resendTimer == null) {
              _startResendTimer(setModal); // Start the timer when modal opens
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Icon(
                    Icons.lock_outline,
                    color: Colors.deepOrange,
                    size: 40,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${AppLocalizations.of(context)!.translate('otp_enter_otp')} $mobileNumber',
                    style: GoogleFonts.ptSerif(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    autofocus: true,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    controller: _otpController,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context)!.translate('otp_hint'),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.deepOrange, width: 2.0),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!
                            .translate('otp_error_empty');
                      } else if (value.length != 6) {
                        return AppLocalizations.of(context)!
                            .translate('otp_error_invalid');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Colors.deepOrange),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(
                                context); // Allow user to edit the number
                          },
                          child: Text(
                            AppLocalizations.of(context)!
                                .translate('otp_edit_number'),
                            style: const TextStyle(color: Colors.deepOrange),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () async {
                            if (_otpController.text.isNotEmpty &&
                                _otpController.text.length == 6) {
                              setModal(() {
                                verifyOTP = true;
                              });
                              await _verifyOtp(_otpController.text);
                              Navigator.pop(context);
                            }
                          },
                          child: verifyOTP
                              ? Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)!
                                      .translate('otp_verify_button'),
                                  style: const TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      isResendEnabled
                          ? TextButton(
                              onPressed: () async {
                                setModal(() {
                                  isResendEnabled = false;
                                  resendCounter = 60; // Reset the counter
                                  _startResendTimer(
                                      setModal); // Start timer again
                                });
                                await _sendOtp(
                                    mobileNumber); // Resend OTP functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(AppLocalizations.of(
                                              context)!
                                          .translate('otp_resend_success'))),
                                );
                              },
                              child: Text(
                                AppLocalizations.of(context)!
                                    .translate('otp_resend'),
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Text(
                              "${AppLocalizations.of(context)!.translate('otp_resend_timer')} ${resendCounter.toString()}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _verifyOtp(String otp) async {
    final apiUrl =
        'https://api.ckgoat.greatshark.in/otp/verify/?transaction_id=$transactionId&otp=$otp';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $bearerToken'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 1) {
          setState(() {
            verifyOTP = false;
          });
          _showSnackBar('OTP verified successfully');
          _resendTimer?.cancel();
          await _submitToFirestore();
        } else {
          _showSnackBar('Invalid OTP');
          _resetFormSubmissionState(); // Reset if OTP verification fails
        }
      } else {
        _showSnackBar('Failed to verify OTP');
        _resetFormSubmissionState(); // Reset on error
      }
    } catch (e) {
      _showSnackBar('Error verifying OTP');
      _resetFormSubmissionState(); // Reset on error
    }
  }

  void _resetFormSubmissionState() {
    setState(() {
      isSubmitting = false; // Reset the submission flag
      isSubmitClicked = false;
    });
  }

  Future<void> _submitToFirestore() async {
    uploadedUrls = await UploadService().uploadFiles(selectedFiles);
    Map<String, dynamic> animalData = {};

    if (widget.animalType != null && widget.animalType!.isNotEmpty) {
      animalData['animalType'] = widget.animalType;
    }
    if (widget.breed != null && widget.breed!.isNotEmpty) {
      animalData['breed'] = widget.breed;
    }
    if (widget.age != null) {
      animalData['age'] = widget.age;
    }
    if (widget.weight != null) {
      animalData['weight'] = widget.weight;
    }
    if (widget.price != null) {
      animalData['price'] = widget.price;
    }
    if (widget.gender != null && widget.gender!.isNotEmpty) {
      animalData['gender'] = widget.gender;
    }
    if (widget.lactation != null) {
      animalData['lactation'] = widget.lactation;
    }
    if (widget.milkCapacity != null) {
      animalData['milkCapacity'] = widget.milkCapacity;
    }
    if (_addressLine1Controller.text.isNotEmpty) {
      animalData['address'] = _addressLine1Controller.text;
    }
    if (_pinCodeController.text.isNotEmpty) {
      animalData['pinCode'] = _pinCodeController.text;
    }
    if (_cityController.text.isNotEmpty) {
      animalData['city'] = _cityController.text;
    }
    if (_stateController.text.isNotEmpty) {
      animalData['state'] = _stateController.text;
    }
    if (_mobileNumberController.text.isNotEmpty) {
      animalData['mobileNumber'] = _mobileNumberController.text;
    }

    SharedPreferences _pref = await SharedPreferences.getInstance();
    String uid = _pref.getString('uid')!;

    animalData['uid'] = uid;
    animalData['uploadedUrls'] = uploadedUrls;
    animalData['timestamp'] = FieldValue.serverTimestamp();

    if (animalData.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('animals').add(animalData);
        _showSnackBar('Animal information submitted successfully');
        _resetFormSubmissionState();
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacementNamed(context, '/home');
        });
      } catch (e) {
        _showSnackBar('Failed to submit data');
        _resetFormSubmissionState(); // Reset on failure
      }
    } else {
      _showSnackBar('No valid data to submit');
      _resetFormSubmissionState(); // Reset if no data
    }
  }
}
