import 'package:flutter/material.dart';

/// Phase 2 UI-only preview. This page NEVER accesses the shared wallet.
/// Table drafts live only while this page is open; Firebase will come later.
class LudoAdminTablesPage extends StatefulWidget {
  const LudoAdminTablesPage({super.key});

  @override
  State<LudoAdminTablesPage> createState() => _LudoAdminTablesPageState();
}

class _LudoTableDraft {
  const _LudoTableDraft({
    required this.id,
    required this.name,
    required this.playerCount,
    required this.entryCredits,
    required this.rewards,
    this.enabled = true,
  });

  final int id;
  final String name;
  final int playerCount;
  final int entryCredits;
  final List<int> rewards;
  final bool enabled;

  _LudoTableDraft withEnabled(bool value) => _LudoTableDraft(
        id: id,
        name: name,
        playerCount: playerCount,
        entryCredits: entryCredits,
        rewards: rewards,
        enabled: value,
      );
}

class _LudoAdminTablesPageState extends State<LudoAdminTablesPage> {
  static const Color _background = Color(0xFF07172C);
  static const Color _panel = Color(0xFF112B47);
  static const Color _accent = Color(0xFFFFC43D);

  final List<_LudoTableDraft> _tables = [];
  int _nextId = 1;

  Future<void> _editTable({_LudoTableDraft? existing}) async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(
      text: existing?.name ?? 'Ludo Table $_nextId',
    );
    final entry = TextEditingController(
      text: '${existing?.entryCredits ?? 0}',
    );
    final prizes = List.generate(4, (index) => TextEditingController(
      text: '${existing != null && index < existing.rewards.length ? existing.rewards[index] : 0}',
    ));
    int count = existing?.playerCount ?? 2;

    String? validateCredits(String? raw) {
      final parsed = int.tryParse((raw ?? '').trim());
      if (parsed == null || parsed < 0 || parsed > 1000000) {
        return '0 से 1000000 तक संख्या लिखें';
      }
      return null;
    }

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, updateDialog) => AlertDialog(
            title: Text(existing == null ? '🎲 Create Demo Table' : '🎲 Edit Demo Table'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('केवल टेस्ट प्रीव्यू • Wallet पर कोई असर नहीं',
                          style: TextStyle(color: Colors.deepOrange)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: name,
                        maxLength: 35,
                        decoration: const InputDecoration(
                          labelText: 'Table Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Table Name जरूरी है' : null,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: count,
                        decoration: const InputDecoration(
                          labelText: 'Players', border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 2, child: Text('2 Players')),
                          DropdownMenuItem(value: 4, child: Text('4 Players')),
                        ],
                        onChanged: (v) {
                          if (v != null) updateDialog(() => count = v);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: entry,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Entry Credits (Demo only)',
                          border: OutlineInputBorder(),
                        ),
                        validator: validateCredits,
                      ),
                      const SizedBox(height: 16),
                      const Text('Rank-wise Reward Credits (Demo only)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text('Rank गोटियाँ HOME पहुँचने के क्रम से तय होगी, Points से नहीं.',
                          style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 12),
                      for (int i = 0; i < count; i++) ...[
                        TextFormField(
                          controller: prizes[i],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Rank ${i + 1} Reward Credits',
                            border: const OutlineInputBorder(),
                          ),
                          validator: validateCredits,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  final item = _LudoTableDraft(
                    id: existing?.id ?? _nextId,
                    name: name.text.trim(),
                    playerCount: count,
                    entryCredits: int.parse(entry.text.trim()),
                    rewards: List.generate(
                      count, (i) => int.parse(prizes[i].text.trim()),
                    ),
                    enabled: existing?.enabled ?? true,
                  );
                  setState(() {
                    if (existing == null) {
                      _tables.add(item);
                      _nextId++;
                    } else {
                      final index = _tables.indexWhere((t) => t.id == existing.id);
                      if (index != -1) _tables[index] = item;
                    }
                  });
                  Navigator.pop(dialogContext);
                },
                child: Text(existing == null ? 'CREATE DEMO' : 'SAVE DEMO'),
              ),
            ],
          ),
        ),
      );
    } finally {
      // Controllers belong to this dialog; dispose after it is dismissed.
      name.dispose();
      entry.dispose();
      for (final controller in prizes) {
        controller.dispose();
      }
    }
  }

  Future<void> _deleteTable(_LudoTableDraft table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete demo table?'),
        content: Text('${table.name} को इस प्रीव्यू से हटाएँ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('DELETE')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _tables.removeWhere((t) => t.id == table.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: Colors.white,
        title: const Text('Manage Ludo Tables'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editTable(),
        backgroundColor: _accent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('CREATE TABLE'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [
                Color(0xFF142F56), Color(0xFF452168),
              ]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🎲  KHELBAAZ LUDO', style: TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900,
                )),
                SizedBox(height: 8),
                Text('2 या 4 Player Table बनाएँ और Rank Rewards का प्रीव्यू देखें।',
                    style: TextStyle(color: Colors.white70, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF3D2E40),
              border: Border.all(color: _accent),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '⚠️ यह केवल Admin UI Demo है। यहाँ बनाई गई टेबल Firebase में सेव नहीं होती, '
              'यूजर को नहीं दिखती और Cricket/Ludo के साझा Wallet से कोई Credit नहीं कटता। '
              'इस स्क्रीन से बाहर निकलने पर Demo Tables रीसेट हो जाएँगी।',
              style: TextStyle(color: Colors.white, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          Text('TABLES (${_tables.length})', style: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 12),
          if (_tables.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(children: [
                Text('🎲', style: TextStyle(fontSize: 55)),
                SizedBox(height: 12),
                Text('अभी कोई Demo Table नहीं', style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold,
                )),
                SizedBox(height: 6),
                Text('नीचे CREATE TABLE दबाएँ',
                    style: TextStyle(color: Colors.white70)),
              ]),
            ),
          for (final table in _tables) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('🎲', style: TextStyle(fontSize: 30)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(table.name, style: const TextStyle(
                          color: Colors.white, fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                        Text('${table.playerCount} Players • Demo #${table.id}',
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    )),
                    Switch.adaptive(
                      value: table.enabled,
                      activeColor: _accent,
                      onChanged: (value) => setState(() {
                        final i = _tables.indexWhere((t) => t.id == table.id);
                        if (i != -1) _tables[i] = table.withEnabled(value);
                      }),
                    ),
                  ]),
                  const Divider(color: Colors.white24),
                  Text('Demo Entry Credits: ${table.entryCredits}',
                      style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  for (int i = 0; i < table.rewards.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text('🏆 Rank ${i + 1}: ${table.rewards[i]} Credits',
                          style: const TextStyle(color: _accent)),
                    ),
                  const SizedBox(height: 8),
                  Text(table.enabled ? '● PREVIEW ENABLED' : '● PREVIEW DISABLED',
                      style: TextStyle(
                        color: table.enabled ? Colors.greenAccent : Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8),
                  Row(children: [
                    OutlinedButton.icon(
                      onPressed: () => _editTable(existing: table),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('EDIT'),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => _deleteTable(table),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('DELETE'),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
