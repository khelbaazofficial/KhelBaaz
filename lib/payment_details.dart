import 'dart:convert';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

const paymentApps = [
  'UPI',
  'Google Pay',
  'PhonePe',
  'Paytm',
];

bool validPaymentUpi(String value) =>
    RegExp(r'^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+$')
        .hasMatch(value.trim());

bool validPaymentMobile(String value) =>
    RegExp(r'^[6-9][0-9]{9}$').hasMatch(value.trim());

bool validPaymentIfsc(String value) =>
    RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$')
        .hasMatch(value.trim().toUpperCase());

bool validPaymentAccount(String value) =>
    RegExp(r'^[0-9]{6,34}$').hasMatch(value.trim());

Future<Map<String, dynamic>> loadPaymentDetails(
  String uid,
) async {
  if (FirebaseAuth.instance.currentUser?.uid != uid) {
    throw StateError('Account changed');
  }

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get(const GetOptions(source: Source.server));

  if (FirebaseAuth.instance.currentUser?.uid != uid) {
    throw StateError('Account changed');
  }

  final raw = doc.data()?['paymentDetails'];

  return raw is Map
      ? Map<String, dynamic>.from(raw)
      : {};
}

Future<void> savePaymentDetails(
  String uid,
  Map<String, dynamic> values,
) async {
  if (FirebaseAuth.instance.currentUser?.uid != uid) {
    throw StateError('Account changed');
  }

  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(uid);

  await ref.update({
    for (final entry in values.entries)
      'paymentDetails.${entry.key}': entry.value,
    'paymentDetails.updatedAt': FieldValue.serverTimestamp(),
  });
}

class PaymentDetailsPage extends StatefulWidget {
  const PaymentDetailsPage({super.key});

  @override
  State<PaymentDetailsPage> createState() =>
      _PaymentDetailsPageState();
}

class _PaymentDetailsPageState
    extends State<PaymentDetailsPage> {
  final _form = GlobalKey<FormState>();

  final _fields = <String, TextEditingController>{
    for (final key in [
      'upiId',
      'paymentMobile',
      'accountHolderName',
      'bankName',
      'bankAccountNumber',
      'bankIfsc',
      'bankMobile',
    ])
      key: TextEditingController(),
  };

  final _confirm = TextEditingController();

  late final String? _uid =
      FirebaseAuth.instance.currentUser?.uid;

  bool _loading = true;
  bool _saving = false;
  bool _failed = false;

  String _app = 'UPI';
  String _method = 'UPI';
  String _savedAccount = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  String value(String key) => _fields[key]!.text.trim();

  void _message(String text) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text)),
      );
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });

    try {
      if (_uid == null) {
        throw StateError('Sign in required');
      }

      final data = await loadPaymentDetails(_uid!);

      if (!mounted) return;

      for (final entry in _fields.entries) {
        entry.value.text =
            (data[entry.key] ?? '').toString();
      }

      _savedAccount = value('bankAccountNumber');
      _confirm.text = _savedAccount;

      _app = paymentApps.contains(data['paymentApp'])
          ? data['paymentApp'] as String
          : 'UPI';

      _method =
          data['payoutMethod'] == 'BANK' ? 'BANK' : 'UPI';
    } catch (_) {
      _failed = true;
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) {
      return;
    }

    final hasUpi = value('upiId').isNotEmpty;
    final hasNumber = value('paymentMobile').isNotEmpty;
    final hasBank = value('bankAccountNumber').isNotEmpty;

    if (!hasUpi && !hasNumber && !hasBank) {
      _message('कम से कम एक payment detail भरें');
      return;
    }

    if (_method == 'BANK' && !hasBank) {
      _message('Default BANK के लिए bank details भरें');
      return;
    }

    if (_method == 'UPI' && !hasUpi && !hasNumber) {
      _message(
        'Default UPI के लिए UPI ID या linked number भरें',
      );
      return;
    }

    if (!hasUpi && hasNumber && _app == 'UPI') {
      _message('इस नंबर का payment app चुनें');
      return;
    }

    setState(() => _saving = true);

    try {
      await savePaymentDetails(_uid!, {
        for (final key in _fields.keys)
          key: value(key),
        'bankIfsc': value('bankIfsc').toUpperCase(),
        'paymentApp': _app,
        'payoutMethod': _method,
      });

      if (!mounted) return;

      setState(() {
        _savedAccount = value('bankAccountNumber');
      });

      _message('Payment details सेव हो गईं');
    } catch (_) {
      _message(
        'Details सेव नहीं हुईं। फिर कोशिश करें।',
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _field(
    String key,
    String label, {
    TextInputType? keyboard,
    String? Function(String)? check,
    bool required = false,
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _fields[key],
        keyboardType: keyboard,
        obscureText: obscure,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (raw) {
          final text = (raw ?? '').trim();

          if (text.isEmpty) {
            return required ? '$label भरें' : null;
          }

          return check?.call(text);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _failed
              ? Center(
                  child: ElevatedButton(
                    onPressed: _load,
                    child: const Text(
                      'Details load नहीं हुईं • Retry',
                    ),
                  ),
                )
              : Form(
                  key: _form,
                  child: AbsorbPointer(
                    absorbing: _saving,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const Text(
                          'Withdrawal और deposit के लिए अपनी details सेव करें।',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _field(
                          'accountHolderName',
                          'Account Holder Name',
                          required: true,
                        ),

                        DropdownButtonFormField<String>(
                          value: _app,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Payment App',
                            border: OutlineInputBorder(),
                          ),
                          items: paymentApps
                              .map(
                                (x) => DropdownMenuItem(
                                  value: x,
                                  child: Text(x),
                                ),
                              )
                              .toList(),
                          onChanged: (x) {
                            setState(() => _app = x!);
                          },
                        ),

                        const SizedBox(height: 14),

                        _field(
                          'upiId',
                          'UPI ID (optional)',
                          keyboard: TextInputType.emailAddress,
                          check: (x) => validPaymentUpi(x)
                              ? null
                              : 'सही UPI ID भरें',
                        ),

                        _field(
                          'paymentMobile',
                          'Payment app से जुड़ा मोबाइल (optional)',
                          keyboard: TextInputType.phone,
                          check: (x) => validPaymentMobile(x)
                              ? null
                              : '10 अंकों का सही नंबर भरें',
                        ),

                        const Text(
                          'Bank Account (optional)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if (_savedAccount.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Text(
                              'Saved account: ••••${_savedAccount.substring(_savedAccount.length > 4 ? _savedAccount.length - 4 : 0)}',
                            ),
                          ),

                        const SizedBox(height: 14),

                        _field(
                          'bankName',
                          'Bank Name',
                          check: (_) => null,
                        ),

                        _field(
                          'bankAccountNumber',
                          'Account Number',
                          keyboard: TextInputType.number,
                          obscure: true,
                          check: (x) => validPaymentAccount(x)
                              ? null
                              : 'सही account number भरें',
                        ),

                        TextFormField(
                          controller: _confirm,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Account Number',
                            border: OutlineInputBorder(),
                          ),
                          validator: (x) {
                            return (x ?? '').trim() ==
                                    value('bankAccountNumber')
                                ? null
                                : 'Account numbers match नहीं हुए';
                          },
                        ),

                        const SizedBox(height: 14),

                        _field(
                          'bankIfsc',
                          'IFSC Code',
                          check: (x) => validPaymentIfsc(x)
                              ? null
                              : 'सही IFSC भरें',
                        ),

                        _field(
                          'bankMobile',
                          'Bank Mobile Number',
                          keyboard: TextInputType.phone,
                          check: (x) => validPaymentMobile(x)
                              ? null
                              : '10 अंकों का सही नंबर भरें',
                        ),

                        DropdownButtonFormField<String>(
                          value: _method,
                          decoration: const InputDecoration(
                            labelText:
                                'Default Withdrawal Method',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'UPI',
                              child: Text('UPI / Payment App'),
                            ),
                            DropdownMenuItem(
                              value: 'BANK',
                              child: Text('Bank Account'),
                            ),
                          ],
                          onChanged: (x) {
                            setState(() => _method = x!);
                          },
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Saved details verification का प्रमाण नहीं हैं। Request में details बदल सकते हैं।',
                        ),

                        const SizedBox(height: 16),

                        ElevatedButton.icon(
                          onPressed: () {
                            if (value('bankAccountNumber')
                                    .isNotEmpty &&
                                (value('bankName').isEmpty ||
                                    value('bankIfsc').isEmpty ||
                                    value('bankMobile')
                                        .isEmpty)) {
                              _message(
                                'Bank account के साथ Bank Name, IFSC और Mobile भी भरें',
                              );
                              return;
                            }

                            _save();
                          },
                          icon: const Icon(Icons.save),
                          label: Text(
                            _saving
                                ? 'Saving…'
                                : 'SAVE PAYMENT DETAILS',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }

    _confirm.dispose();
    super.dispose();
  }
}

class SavePaymentImageButton extends StatefulWidget {
  final ValueNotifier<String?> image;

  const SavePaymentImageButton({
    super.key,
    required this.image,
  });

  @override
  State<SavePaymentImageButton> createState() =>
      _SavePaymentImageButtonState();
}

class _SavePaymentImageButtonState
    extends State<SavePaymentImageButton> {
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;

    final source = widget.image.value;
    String message;

    if (source == null || source.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Admin की payment image उपलब्ध नहीं है',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    ui.Codec? codec;
    ui.Image? decoded;

    try {
      if (!await Gal.hasAccess() &&
          !await Gal.requestAccess()) {
        throw StateError('permission');
      }

      final bytes = base64Decode(
        source.contains(',')
            ? source.split(',').last
            : source,
      );

      codec = await ui.instantiateImageCodec(bytes);
      decoded = (await codec.getNextFrame()).image;

      final png = await decoded.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (png == null) {
        throw StateError('image');
      }

      await Gal.putImageBytes(
        png.buffer.asUint8List(
          png.offsetInBytes,
          png.lengthInBytes,
        ),
        name:
            'KhelBaaz_Payment_${DateTime.now().millisecondsSinceEpoch}',
      );

      message = 'Payment image Gallery में सेव हो गई';
    } catch (_) {
      message =
          'Image सेव नहीं हुई। Gallery permission और device storage जाँचकर फिर कोशिश करें।';
    } finally {
      decoded?.dispose();
      codec?.dispose();

      if (mounted) {
        setState(() => _saving = false);
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      onPressed: _saving ? null : _save,
      icon: const Icon(Icons.download),
      label: Text(
        _saving ? 'SAVING…' : 'SAVE PAYMENT IMAGE',
      ),
    );
  }
}
