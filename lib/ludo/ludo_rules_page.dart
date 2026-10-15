import 'package:flutter/material.dart';

/// KhelBaaz's original classic-rules guide.
/// UI only: does not alter LudoGame or the shared Cricket/Ludo wallet.
class LudoRulesPage extends StatelessWidget {
  const LudoRulesPage({super.key});

  static const Color _bg = Color(0xFF061A32);
  static const Color _blue = Color(0xFF0F3966);
  static const Color _gold = Color(0xFFFFC53D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: const Color(0xFF07162C),
        foregroundColor: Colors.white,
        title: const Text(
          'KhelBaaz Ludo Rules',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF07172E), Color(0xFF0E3A6A), Color(0xFF07162C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF071E3B),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _gold, width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x55FFC53D), blurRadius: 18),
                ],
              ),
              child: const Column(
                children: [
                  Text('🎲', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 5),
                  Text(
                    'CLASSIC LUDO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _gold,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    '2 PLAYER • RED vs YELLOW',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'चारों गोटियाँ सबसे पहले HOME पहुँचाने वाला विजेता।',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const _SectionTitle(icon: '🏆', title: 'WINNING RULE'),
            const _RuleCard(
              number: '1', icon: '🥇',
              title: 'पहला Winner',
              detail: 'जिसकी चारों गोटियाँ सबसे पहले HOME पहुँचेंगी, वह 1st Winner होगा।',
            ),
            const _RuleCard(
              number: '2', icon: '🥈',
              title: 'दूसरा स्थान',
              detail: 'दूसरे खिलाड़ी को 2nd Position मिलेगी। Winner points से तय नहीं होगा।',
            ),
            const SizedBox(height: 12),
            const _SectionTitle(icon: '📖', title: 'CLASSIC GAME RULES'),
            const _RuleCard(
              number: '3', icon: '🎲',
              title: '6 आने पर गोटी बाहर',
              detail: 'बंद गोटी तभी शुरुआती खाने पर आएगी जब पासे पर 6 आए।',
            ),
            const _RuleCard(
              number: '4', icon: '🔁',
              title: '6 आने पर Extra Turn',
              detail: '6 आने पर नियम के अनुसार एक और बार पासा फेंकने का मौका मिलेगा।',
            ),
            const _RuleCard(
              number: '5', icon: '3️⃣',
              title: 'लगातार तीन 6',
              detail: 'लगातार तीसरी बार 6 आने पर तीसरा रोल रद्द होगा और बारी बदल जाएगी।',
            ),
            const _RuleCard(
              number: '6', icon: '⚔️',
              title: 'गोटी काटने पर Extra Turn',
              detail: 'Safe Zone के बाहर दूसरी गोटी को काटने पर एक अतिरिक्त बारी मिलेगी।',
            ),
            const _RuleCard(
              number: '7', icon: '⭐',
              title: 'Safe Zone',
              detail: 'बोर्ड के सुरक्षित खानों में रखी गोटी को दूसरी गोटी नहीं काट सकती।',
            ),
            const _RuleCard(
              number: '8', icon: '🏠',
              title: 'HOME पहुँचने पर Extra Turn',
              detail: 'गोटी को HOME तक पहुँचाने पर अतिरिक्त बारी मिलेगी, जब तक खेल पूरा न हो।',
            ),
            const _RuleCard(
              number: '9', icon: '👣',
              title: 'पूरा रास्ता और सही नंबर',
              detail: 'गोटी को पूरे रास्ते से HOME लाना होगा। HOME पहुँचने के लिए सही पासा चाहिए।',
            ),
            const SizedBox(height: 12),
            const _SectionTitle(icon: '📱', title: 'ONLINE FEATURES • COMING NEXT'),
            const _RuleCard(
              number: '10', icon: '⏱️',
              title: 'Turn Timer / Auto Move',
              detail: 'ऑनलाइन गेम शुरू होने पर बारी का समय और समय समाप्त होने का नियम लागू होगा।',
            ),
            const _RuleCard(
              number: '11', icon: '📶',
              title: 'Reconnect',
              detail: 'इंटरनेट कटने पर उसी ऑनलाइन मैच से दोबारा जुड़ने की सुविधा अगले चरण में आएगी।',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF122C4B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF5B8BB4)),
              ),
              child: const Text(
                '🔒 अभी यह Local Demo है। Cricket और Ludo का Wallet भविष्य में साझा रहेगा। '
                'इस डेमो में कोई Wallet Entry या Reward नहीं लगता। '
                '4 Player Mode भविष्य के अपडेट के लिए रखा गया है।',
                style: TextStyle(color: Colors.white, height: 1.5),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 52),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK • GAME पर वापस जाएँ',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 0, 12),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 25)),
            const SizedBox(width: 9),
            Flexible(
              child: Text(title,
                  style: const TextStyle(
                    color: Color(0xFFFFC53D),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  )),
            ),
          ],
        ),
      );
}

class _RuleCard extends StatelessWidget {
  final String number;
  final String icon;
  final String title;
  final String detail;

  const _RuleCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF092B55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF6D9DCE), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x23000000), blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFFFC53D),
            child: Text(number,
                style: const TextStyle(color: Color(0xFF10243C), fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    )),
                const SizedBox(height: 5),
                Text(detail,
                    style: const TextStyle(color: Color(0xFFE0EEFF), fontSize: 14, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
