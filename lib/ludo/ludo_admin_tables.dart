import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ==============================================
// KHELBAAZ LUDO - FIREBASE ADMIN TABLE MANAGEMENT
// PHASE 3A
// ==============================================
//
// 2 Player only.
// Firebase table persistence.
// Shared wallet is NOT modified.
// Demo credits only.
// ==============================================

class LudoAdminTablesPage extends StatefulWidget {
  const LudoAdminTablesPage({super.key});

  @override
  State<LudoAdminTablesPage> createState() =>
      _LudoAdminTablesPageState();
}

class _LudoAdminTablesPageState
    extends State<LudoAdminTablesPage> {

  static const Color background =
      Color(0xFF07172C);

  static const Color panel =
      Color(0xFF102944);

  static const Color gold =
      Color(0xFFFFC43D);

  final CollectionReference<Map<String, dynamic>>
      _tables = FirebaseFirestore.instance
          .collection('ludo_tables');

  bool _saving = false;

  // ============================================
  // ADMIN SECURITY CHECK
  // ============================================

  Future<bool> _verifyAdmin() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return false;
    }

    final admin = await FirebaseFirestore.instance
        .collection('admins')
        .doc(user.uid)
        .get();

    final data = admin.data();

    return admin.exists &&
        (data?['role'] ?? '')
                .toString()
                .trim()
                .toUpperCase() ==
            'ADMIN' &&
        data?['active'] == true;
  }

  // ============================================
  // ERROR / SUCCESS MESSAGE
  // ============================================

  void _showMessage(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================
  // CREATE / EDIT TABLE
  // ============================================

  Future<void> _openTableForm({
    DocumentSnapshot<Map<String, dynamic>>?
        existing,
  }) async {

    if (_saving) return;

    try {
      if (!await _verifyAdmin()) {
        _showMessage(
          'केवल Admin ही Ludo Table बना सकता है।',
        );
        return;
      }
    } catch (e) {
      _showMessage('Admin verification failed: $e');
      return;
    }

    if (!mounted) return;

    final old = existing?.data() ?? {};

    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(
      text: (old['name'] ?? '').toString(),
    );

    final entryController = TextEditingController(
      text: '${old['entryCredits'] ?? 0}',
    );

    final oldRewards =
        old['rewards'] is List
            ? List<dynamic>.from(old['rewards'] as List)
            : <dynamic>[];

    final firstController = TextEditingController(
      text: oldRewards.isNotEmpty
          ? '${oldRewards[0]}'
          : '0',
    );

    final secondController = TextEditingController(
      text: oldRewards.length > 1
          ? '${oldRewards[1]}'
          : '0',
    );

    String? validateCredits(String? value) {
      final number = int.tryParse(
        (value ?? '').trim(),
      );

      if (number == null ||
          number < 0 ||
          number > 1000000) {
        return '0 से 1000000 तक संख्या लिखें';
      }

      return null;
    }

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              existing == null
                  ? '🎲 Create Ludo Table'
                  : '🎲 Edit Ludo Table',
            ),

            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        '2 PLAYER ONLINE TABLE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: nameController,
                        maxLength: 35,
                        decoration: const InputDecoration(
                          labelText: 'Table Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Table Name जरूरी है';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Players: 2',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'TEST CREDITS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: entryController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText:
                              'Entry Credits (Demo)',
                          border: OutlineInputBorder(),
                        ),
                        validator: validateCredits,
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: firstController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText:
                              '1st Winner Reward Credits',
                          border: OutlineInputBorder(),
                        ),
                        validator: validateCredits,
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: secondController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText:
                              '2nd Position Reward Credits',
                          border: OutlineInputBorder(),
                        ),
                        validator: validateCredits,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'Winner चारों गोटियाँ HOME '
                        'पहुँचने के आधार पर बनेगा। '
                        'Points से Ranking नहीं होगी।',
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'यह केवल टेस्ट क्रेडिट है। '
                        'Cricket और Ludo के साझा Wallet '
                        'से कोई लेनदेन नहीं होगा।',
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    false,
                  );
                },
                child: const Text('CANCEL'),
              ),

              FilledButton(
                onPressed: () {
                  if (formKey.currentState
                          ?.validate() ??
                      false) {
                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  }
                },

                child: Text(
                  existing == null
                      ? 'CREATE TABLE'
                      : 'SAVE CHANGES',
                ),
              ),
            ],
          );
        },
      );

      if (confirmed != true || !mounted) {
        return;
      }

      setState(() {
        _saving = true;
      });

      final data = <String, dynamic>{
        'name': nameController.text.trim(),
        'playerCount': 2,
        'entryCredits':
            int.parse(entryController.text.trim()),
        'rewards': [
          int.parse(firstController.text.trim()),
          int.parse(secondController.text.trim()),
        ],
        'updatedAt': FieldValue.serverTimestamp(),
      };

      try {
        if (!await _verifyAdmin()) {
          throw StateError('Admin permission denied');
        }

        if (existing == null) {
          await _tables.add({
            ...data,
            'enabled': true,
            'createdAt':
                FieldValue.serverTimestamp(),
          });
        } else {
          await _tables
              .doc(existing.id)
              .update(data);
        }

        _showMessage(
          existing == null
              ? '✅ Ludo Table Firebase में सेव हो गई'
              : '✅ Ludo Table अपडेट हो गई',
        );
      } catch (e) {
        _showMessage(
          'Table Save Error: $e',
        );
      } finally {
        if (mounted) {
          setState(() {
            _saving = false;
          });
        }
      }
    } finally {
      nameController.dispose();
      entryController.dispose();
      firstController.dispose();
      secondController.dispose();
    }
  }

  // ============================================
  // ENABLE / DISABLE TABLE
  // ============================================

  Future<void> _changeStatus(
    String id,
    bool enabled,
  ) async {

    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      if (!await _verifyAdmin()) {
        throw StateError('Admin permission denied');
      }

      await _tables.doc(id).update({
        'enabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _showMessage(
        enabled
            ? '✅ Table Enabled'
            : '✅ Table Disabled',
      );
    } catch (e) {
      _showMessage('Status Update Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ============================================
  // DELETE TABLE
  // ============================================

  Future<void> _deleteTable(
    String id,
    String name,
  ) async {

    if (_saving) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Ludo Table?'),

        content: Text(
          '$name को Firebase से हटाना चाहते हैं?',
        ),

        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),

          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      if (!await _verifyAdmin()) {
        throw StateError('Admin permission denied');
      }

      await _tables.doc(id).delete();

      _showMessage('✅ Table Deleted');
    } catch (e) {
      _showMessage('Delete Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ============================================
  // TABLE CARD
  // ============================================

  Widget _tableCard(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {

    final data = doc.data() ?? {};

    final name =
        (data['name'] ?? 'Ludo Table').toString();

    final enabled = data['enabled'] == true;

    final entry = data['entryCredits'] ?? 0;

    final rewards =
        data['rewards'] is List
            ? List<dynamic>.from(data['rewards'] as List)
            : <dynamic>[];

    final first =
        rewards.isNotEmpty ? rewards[0] : 0;

    final second =
        rewards.length > 1 ? rewards[1] : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: enabled
              ? gold
              : Colors.white24,
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Row(
            children: [
              const Text(
                '🎲',
                style: TextStyle(fontSize: 30),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Switch.adaptive(
                value: enabled,
                onChanged: _saving
                    ? null
                    : (value) {
                        _changeStatus(
                          doc.id,
                          value,
                        );
                      },
              ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            '👥 2 PLAYER TABLE',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Demo Entry: $entry Credits',
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '🥇 1st Winner: $first Credits',
            style: const TextStyle(
              color: gold,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            '🥈 2nd Position: $second Credits',
            style: const TextStyle(
              color: gold,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            enabled
                ? '● ENABLED'
                : '● DISABLED',
            style: TextStyle(
              color: enabled
                  ? Colors.greenAccent
                  : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Divider(color: Colors.white24),

          Row(
            children: [

              OutlinedButton.icon(
                onPressed: _saving
                    ? null
                    : () => _openTableForm(
                          existing: doc,
                        ),

                icon: const Icon(Icons.edit),

                label: const Text('EDIT'),
              ),

              const SizedBox(width: 12),

              OutlinedButton.icon(
                onPressed: _saving
                    ? null
                    : () => _deleteTable(
                          doc.id,
                          name,
                        ),

                icon: const Icon(
                  Icons.delete_outline,
                ),

                label: const Text('DELETE'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // MAIN ADMIN SCREEN
  // ============================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        title: const Text(
          'Manage Ludo Tables',
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(

        onPressed:
            _saving ? null : () => _openTableForm(),

        backgroundColor: gold,

        foregroundColor: Colors.black,

        icon: const Icon(Icons.add),

        label: const Text('CREATE TABLE'),
      ),

      body: Column(
        children: [

          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF142F56),
                  Color(0xFF452168),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),

            child: const Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  '🎲 KHELBAAZ LUDO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  '2 Player Online Tables',
                  style: TextStyle(
                    color: gold,
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'Firebase Table Management\n'
                  'Cricket + Ludo = One Wallet',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Text(
              'अभी यह Table Setup चरण है। '
              'Game Joining और Rewards बाद में चालू होंगे। '
              'Wallet से कोई लेनदेन नहीं होगा।',
              style: TextStyle(
                color: Colors.orangeAccent,
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (_saving)
            const LinearProgressIndicator(),

          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(

              stream: _tables.snapshots(),

              builder: (context, snapshot) {

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Firebase Error:\n'
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                  );
                }
if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'अभी कोई Ludo Table नहीं है।',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    14, 0, 14, 110,
                  ),

                  itemCount: docs.length,

                  itemBuilder: (context, index) {
                    return _tableCard(
                      docs[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
                
