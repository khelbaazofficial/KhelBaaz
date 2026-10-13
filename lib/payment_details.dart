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

    static const _red = Color(0xFFC62828);

  InputDecoration _decoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF615A60),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF716771),
        size: 22,
      ),
      filled: true,
      fillColor: const Color(0xFFFFF7F8),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFD8CCD0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _red,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _red,
          width: 1.5,
        ),
      ),
      errorMaxLines: 3,
    );
  }

  Widget _field(
    String key,
    String label, {
    IconData icon = Icons.edit_outlined,
    TextInputType? keyboard,
    String? Function(String)? check,
    bool required = false,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: _fields[key],
      keyboardType: keyboard,
      obscureText: obscure,
      autocorrect: false,
      enableSuggestions: false,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Color(0xFF292329),
      ),
      decoration: _decoration(label, icon),
      validator: (raw) {
        final text = (raw ?? '').trim();
        if (text.isEmpty) {
          return required ? '$label भरें' : null;
        }
        return check?.call(text);
      },
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF2E7E9),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _heading(
    String title,
    IconData icon, {
    bool optional = false,
    bool blue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: blue
                  ? const Color(0xFFE3EFFF)
                  : const Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: blue
                  ? const Color(0xFF245C91)
                  : _red,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF241F26),
                  ),
                ),
                if (optional)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFFB8C00),
                        width: 1.5,
                      ),
                    ),
                    child: const Text(
                      'Optional',
                      style: TextStyle(
                        color: Color(0xFFE65100),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 14);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F6),
      appBar: AppBar(
        backgroundColor: _red,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Payment Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Icons.account_balance,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: _red,
                ),
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
                        padding: const EdgeInsets.fromLTRB(
                          16, 20, 16, 24,
                        ),
                        children: [
                          const Text(
                            'Withdrawal और deposit के लिए अपनी details सेव करें।',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF393139),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _card([
                            _heading(
                              'Account Holder',
                              Icons.person,
                            ),
                            _field(
                              'accountHolderName',
                              'Account Holder Name',
                              icon: Icons.person_outline,
                              required: true,
                            ),
                          ]),

                          _card([
                            _heading(
                              'UPI / Payment App',
                              Icons.account_balance_wallet_outlined,
                              blue: true,
                            ),
                            DropdownButtonFormField<String>(
                              value: _app,
                              isExpanded: true,
                              decoration: _decoration(
                                'Payment App',
                                Icons.phone_android,
                              ),
                              items: paymentApps.map((x) {
                                return DropdownMenuItem<String>(
                                  value: x,
                                  child: Text(x),
                                );
                              }).toList(),
                              onChanged: (x) {
                                if (x != null) {
                                  setState(() => _app = x);
                                }
                              },
                            ),
                            gap,
                            _field(
                              'upiId',
                              'UPI ID (optional)',
                              icon: Icons.alternate_email,
                              keyboard: TextInputType.emailAddress,
                              check: (x) => validPaymentUpi(x)
                                  ? null
                                  : 'सही UPI ID भरें',
                            ),
                            gap,
                            _field(
                              'paymentMobile',
                              'Linked Mobile (optional)',
                              icon: Icons.phone_android,
                              keyboard: TextInputType.phone,
                              check: (x) => validPaymentMobile(x)
                                  ? null
                                  : '10 अंकों का सही नंबर भरें',
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Payment app से जुड़ा मोबाइल नंबर',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF716771),
                              ),
                            ),
                          ]),

                          _card([
                            _heading(
                              'Bank Account',
                              Icons.account_balance,
                              optional: true,
                            ),
                            if (_savedAccount.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 14,
                                ),
                                child: Text(
                                  'Saved account: ••••${_savedAccount.substring(_savedAccount.length > 4 ? _savedAccount.length - 4 : 0)}',
                                  style: const TextStyle(
                                    color: Color(0xFF716771),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            _field(
                              'bankName',
                              'Bank Name',
                              icon: Icons.account_balance_outlined,
                            ),
                            gap,
                            _field(
                              'bankAccountNumber',
                              'Account Number',
                              icon: Icons.credit_card,
                              keyboard: TextInputType.number,
                              obscure: true,
                              check: (x) => validPaymentAccount(x)
                                  ? null
                                  : 'सही account number भरें',
                            ),
                            gap,
                            TextFormField(
                              controller: _confirm,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              autocorrect: false,
                              enableSuggestions: false,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: _decoration(
                                'Confirm Account Number',
                                Icons.credit_card,
                              ),
                              validator: (x) {
                                return (x ?? '').trim() ==
                                        value('bankAccountNumber')
                                    ? null
                                    : 'Account numbers match नहीं हुए';
                              },
                            ),
                            gap,
                            _field(
                              'bankIfsc',
                              'IFSC Code',
                              icon: Icons.tag,
                              check: (x) => validPaymentIfsc(x)
                                  ? null
                                  : 'सही IFSC भरें',
                            ),
                            gap,
                            _field(
                              'bankMobile',
                              'Bank Mobile Number',
                              icon: Icons.phone_android,
                              keyboard: TextInputType.phone,
                              check: (x) => validPaymentMobile(x)
                                  ? null
                                  : '10 अंकों का सही नंबर भरें',
                            ),
                          ]),

                          _card([
                            DropdownButtonFormField<String>(
                              value: _method,
                              isExpanded: true,
                              decoration: _decoration(
                                'Default Withdrawal Method',
                                Icons.swap_horiz,
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
                                if (x != null) {
                                  setState(() => _method = x);
                                }
                              },
                            ),
                            gap,
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F6FB),
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFDCE4EF),
                                ),
                              ),
                              child: const Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Color(0xFF657184),
                                    size: 22,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Saved details verification का प्रमाण नहीं हैं। Request में details बदल सकते हैं।',
                                      style: TextStyle(
                                        fontSize: 13,
                                        height: 1.5,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF394252),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),

                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _red,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFFE6A4A4),
                              disabledForegroundColor: Colors.white,
                              elevation: 0,
                              minimumSize: const Size.fromHeight(54),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _saving
                                ? null
                                : () {
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
                            icon: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: Text(
                              _saving
                                  ? 'Saving…'
                                  : 'SAVE PAYMENT DETAILS',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
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
